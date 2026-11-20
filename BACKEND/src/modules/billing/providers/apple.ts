import fs from "node:fs";
import path from "node:path";
import { env } from "../../../config/env";
import { AppError } from "../../../lib/errors";
import type { NormalizedPurchase } from "./types";

// Decodifica el payload de un JWS SIN verificar la firma. Solo para dev/lectura
// cuando aún no hay certificados; nunca se usa en producción.
function decodeJwsUnverified<T = Record<string, unknown>>(jws: string): T {
  const parts = jws.split(".");
  if (parts.length !== 3) throw AppError.badRequest("JWS con formato inválido");
  return JSON.parse(Buffer.from(parts[1], "base64url").toString("utf8")) as T;
}

// Construye (una sola vez) el verificador oficial de Apple con los certs raíz.
let verifierPromise: Promise<unknown> | null = null;
async function getVerifier(): Promise<unknown | null> {
  if (!env.appleIap.enabled) return null;
  if (!env.appleIap.rootCertsDir || !fs.existsSync(env.appleIap.rootCertsDir)) {
    return null;
  }
  if (!verifierPromise) {
    verifierPromise = (async () => {
      const { SignedDataVerifier, Environment } = await import(
        "@apple/app-store-server-library"
      );
      const certs = fs
        .readdirSync(env.appleIap.rootCertsDir)
        .filter((f) => /\.(cer|pem|crt|der)$/i.test(f))
        .map((f) => fs.readFileSync(path.join(env.appleIap.rootCertsDir, f)));
      const environment =
        env.appleIap.environment === "production"
          ? Environment.PRODUCTION
          : Environment.SANDBOX;
      return new SignedDataVerifier(
        certs,
        true,
        environment,
        env.appleIap.bundleId,
        env.appleIap.appAppleId,
      );
    })();
  }
  return verifierPromise;
}

function normalize(tx: Record<string, unknown>): NormalizedPurchase {
  const expires = tx.expiresDate ? new Date(Number(tx.expiresDate)) : null;
  return {
    productId: String(tx.productId ?? ""),
    transactionId: String(tx.transactionId ?? tx.originalTransactionId ?? ""),
    originalTransactionId: tx.originalTransactionId
      ? String(tx.originalTransactionId)
      : undefined,
    expiresAt: expires,
    autoRenew: false, // se conoce con precisión al leer el renewalInfo
    active: expires ? expires.getTime() > Date.now() : true,
    raw: tx,
  };
}

// Verifica y decodifica un signedTransaction que envía la app tras comprar.
export async function verifyAppleTransaction(
  signedTransaction: string,
): Promise<NormalizedPurchase> {
  const verifier = (await getVerifier()) as {
    verifyAndDecodeTransaction: (jws: string) => Promise<Record<string, unknown>>;
  } | null;
  if (verifier) {
    return normalize(await verifier.verifyAndDecodeTransaction(signedTransaction));
  }
  if (!env.allowUnverifiedIap) {
    throw AppError.badRequest(
      "Apple IAP no configurado (faltan APPLE_ROOT_CERTS_DIR / certificados)",
    );
  }
  console.warn(
    "[apple] verificación desactivada: decodificando transacción SIN verificar (solo dev)",
  );
  return normalize(decodeJwsUnverified(signedTransaction));
}

// Verifica/decodifica una App Store Server Notification v2.
export async function decodeAppleNotification(signedPayload: string): Promise<{
  notificationType: string;
  subtype?: string;
  purchase: NormalizedPurchase | null;
  raw: unknown;
}> {
  const verifier = (await getVerifier()) as {
    verifyAndDecodeNotification: (jws: string) => Promise<Record<string, unknown>>;
  } | null;
  let payload: Record<string, unknown>;
  if (verifier) {
    payload = await verifier.verifyAndDecodeNotification(signedPayload);
  } else if (!env.allowUnverifiedIap) {
    throw AppError.badRequest("Apple IAP no configurado");
  } else {
    console.warn("[apple] notificación decodificada SIN verificar (solo dev)");
    payload = decodeJwsUnverified(signedPayload);
  }

  const data = payload.data as { signedTransactionInfo?: string } | undefined;
  const purchase = data?.signedTransactionInfo
    ? await verifyAppleTransaction(data.signedTransactionInfo)
    : null;

  return {
    notificationType: String(payload.notificationType ?? "UNKNOWN"),
    subtype: payload.subtype ? String(payload.subtype) : undefined,
    purchase,
    raw: payload,
  };
}
