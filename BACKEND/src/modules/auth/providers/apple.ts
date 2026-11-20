import { env } from "../../../config/env";
import { AppError } from "../../../lib/errors";
import type { OAuthProfile } from "./google";

// `jose` es ESM-only; en un proyecto CommonJS lo cargamos con import dinámico.
// Cacheamos el JWKS remoto de Apple (rota sus llaves de firma).
let jwksCache: unknown = null;

async function getAppleJwks() {
  const { createRemoteJWKSet } = await import("jose");
  if (!jwksCache) {
    jwksCache = createRemoteJWKSet(
      new URL("https://appleid.apple.com/auth/keys"),
    );
  }
  return jwksCache as Parameters<typeof import("jose").jwtVerify>[1];
}

// Verifica el identity token de "Sign in with Apple".
// `fallbackName` porque Apple solo envía el nombre en el primer login.
export async function verifyAppleIdentityToken(
  identityToken: string,
  fallbackName?: string | null,
): Promise<OAuthProfile> {
  if (env.apple.clientIds.length === 0) {
    throw AppError.badRequest(
      "Sign in with Apple no configurado (APPLE_CLIENT_IDS)",
    );
  }
  const { jwtVerify } = await import("jose");
  const jwks = await getAppleJwks();
  try {
    const { payload } = await jwtVerify(identityToken, jwks, {
      issuer: "https://appleid.apple.com",
      audience: env.apple.clientIds,
    });
    if (!payload.sub) throw AppError.unauthorized("Token de Apple inválido");
    return {
      providerUserId: String(payload.sub),
      email: (payload.email as string | undefined) ?? null,
      name: fallbackName ?? null,
      avatarUrl: null,
    };
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw AppError.unauthorized("Token de Apple inválido o expirado");
  }
}
