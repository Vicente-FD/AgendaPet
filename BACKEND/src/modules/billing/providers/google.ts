import fs from "node:fs";
import { google } from "googleapis";
import { env } from "../../../config/env";
import { AppError } from "../../../lib/errors";
import type { NormalizedPurchase } from "./types";

// Cliente de la Google Play Developer API (androidpublisher) con service account.
let publisherPromise: Promise<ReturnType<typeof google.androidpublisher> | null> | null =
  null;

async function getPublisher() {
  if (!env.googlePlay.enabled) return null;
  if (
    !env.googlePlay.serviceAccountPath ||
    !fs.existsSync(env.googlePlay.serviceAccountPath)
  ) {
    return null;
  }
  if (!publisherPromise) {
    publisherPromise = (async () => {
      const auth = new google.auth.GoogleAuth({
        keyFile: env.googlePlay.serviceAccountPath,
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });
      return google.androidpublisher({ version: "v3", auth });
    })();
  }
  return publisherPromise;
}

// Valida una compra/suscripción de Play a partir del purchaseToken.
export async function verifyGooglePurchase(
  productId: string,
  purchaseToken: string,
): Promise<NormalizedPurchase> {
  const publisher = await getPublisher();
  if (!publisher) {
    if (!env.allowUnverifiedIap) {
      throw AppError.badRequest(
        "Google Play no configurado (falta GOOGLE_SERVICE_ACCOUNT_PATH)",
      );
    }
    console.warn(
      "[google] Play API no configurada: aceptando compra SIN verificar (solo dev)",
    );
    return {
      productId,
      transactionId: purchaseToken,
      purchaseToken,
      expiresAt: null,
      autoRenew: false,
      active: true,
      raw: { dev: true },
    };
  }

  try {
    const res = await publisher.purchases.subscriptionsv2.get({
      packageName: env.googlePlay.packageName,
      token: purchaseToken,
    });
    const data = res.data as Record<string, any>;
    const line = data.lineItems?.[0] ?? {};
    const expiresAt = line.expiryTime ? new Date(line.expiryTime) : null;
    const active =
      data.subscriptionState === "SUBSCRIPTION_STATE_ACTIVE" ||
      data.subscriptionState === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD";
    return {
      productId: line.productId ?? productId,
      transactionId: data.latestOrderId ?? purchaseToken,
      purchaseToken,
      expiresAt,
      autoRenew: Boolean(line.autoRenewingPlan?.autoRenewEnabled),
      active,
      raw: data,
    };
  } catch {
    // No es suscripción: intenta como producto único.
    const res = await publisher.purchases.products.get({
      packageName: env.googlePlay.packageName,
      productId,
      token: purchaseToken,
    });
    const data = res.data as Record<string, any>;
    return {
      productId,
      transactionId: data.orderId ?? purchaseToken,
      purchaseToken,
      expiresAt: null,
      autoRenew: false,
      active: data.purchaseState === 0, // 0 = comprado
      raw: data,
    };
  }
}

// Decodifica un mensaje de Real-time Developer Notifications (Pub/Sub push).
export function decodeRtdn(messageDataBase64: string): {
  packageName?: string;
  purchaseToken?: string;
  subscriptionId?: string;
  sku?: string;
  notificationType?: number;
  type: "subscription" | "product" | "unknown";
  raw: unknown;
} {
  const json = JSON.parse(
    Buffer.from(messageDataBase64, "base64").toString("utf8"),
  );
  const sub = json.subscriptionNotification;
  const one = json.oneTimeProductNotification;
  return {
    packageName: json.packageName,
    purchaseToken: sub?.purchaseToken ?? one?.purchaseToken,
    subscriptionId: sub?.subscriptionId,
    sku: one?.sku,
    notificationType: sub?.notificationType ?? one?.notificationType,
    type: sub ? "subscription" : one ? "product" : "unknown",
    raw: json,
  };
}
