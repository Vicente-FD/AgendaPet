import { OAuth2Client } from "google-auth-library";
import { env } from "../../../config/env";
import { AppError } from "../../../lib/errors";

export interface OAuthProfile {
  providerUserId: string;
  email: string | null;
  name: string | null;
  avatarUrl: string | null;
}

const client = new OAuth2Client();

// Verifica el ID token que la app obtiene con Google Sign-In.
export async function verifyGoogleIdToken(idToken: string): Promise<OAuthProfile> {
  if (env.google.clientIds.length === 0) {
    throw AppError.badRequest("Google Sign-In no configurado (GOOGLE_CLIENT_IDS)");
  }
  const ticket = await client.verifyIdToken({
    idToken,
    audience: env.google.clientIds,
  });
  const payload = ticket.getPayload();
  if (!payload?.sub) throw AppError.unauthorized("Token de Google inválido");
  // Sin esta comprobación, una cuenta de Google con un correo ajeno sin
  // verificar podría quedar enlazada a la cuenta de otro usuario.
  if (payload.email && payload.email_verified !== true) {
    throw AppError.unauthorized(
      "Tu correo de Google no está verificado. Verifícalo e inténtalo de nuevo.",
    );
  }
  return {
    providerUserId: payload.sub,
    email: payload.email ?? null,
    name: payload.name ?? null,
    avatarUrl: payload.picture ?? null,
  };
}
