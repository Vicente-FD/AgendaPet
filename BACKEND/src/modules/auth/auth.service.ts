import bcrypt from "bcryptjs";
import { AuthProvider, type User } from "@prisma/client";
import { env } from "../../config/env";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import {
  generateRefreshToken,
  hashToken,
  signAccessToken,
  ttlToDate,
} from "../../lib/jwt";
import { verifyGoogleIdToken, type OAuthProfile } from "./providers/google";
import { verifyAppleIdentityToken } from "./providers/apple";
import type { LoginInput, RegisterInput } from "./auth.schemas";

export interface AuthResult {
  accessToken: string;
  refreshToken: string;
  user: PublicUser;
}

export interface PublicUser {
  id: string;
  email: string | null;
  name: string | null;
  avatarUrl: string | null;
  plan: "FREE" | "PRO";
}

async function toPublicUser(user: User): Promise<PublicUser> {
  const entitlement = await prisma.entitlement.findUnique({
    where: { userId: user.id },
  });
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
    plan: entitlement?.plan === "PRO" ? "PRO" : "FREE",
  };
}

async function issueTokens(user: User): Promise<AuthResult> {
  const accessToken = signAccessToken(user.id, user.email);
  const refreshRaw = generateRefreshToken();
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashToken(refreshRaw),
      expiresAt: ttlToDate(env.jwt.refreshTtl),
    },
  });
  return { accessToken, refreshToken: refreshRaw, user: await toPublicUser(user) };
}

// ─── Email / contraseña ─────────────────────────────────────────────────────

export async function registerEmail(input: RegisterInput): Promise<AuthResult> {
  const existing = await prisma.identity.findUnique({
    where: {
      provider_providerUserId: {
        provider: AuthProvider.EMAIL,
        providerUserId: input.email.toLowerCase(),
      },
    },
  });
  if (existing) throw AppError.conflict("Ese correo ya está registrado");

  const passwordHash = await bcrypt.hash(input.password, 10);
  const user = await prisma.user.create({
    data: {
      email: input.email.toLowerCase(),
      name: input.name ?? null,
      passwordHash,
      identities: {
        create: {
          provider: AuthProvider.EMAIL,
          providerUserId: input.email.toLowerCase(),
        },
      },
    },
  });
  return issueTokens(user);
}

export async function loginEmail(input: LoginInput): Promise<AuthResult> {
  const user = await prisma.user.findUnique({
    where: { email: input.email.toLowerCase() },
  });
  if (!user?.passwordHash) throw AppError.unauthorized("Credenciales inválidas");
  const ok = await bcrypt.compare(input.password, user.passwordHash);
  if (!ok) throw AppError.unauthorized("Credenciales inválidas");
  return issueTokens(user);
}

// ─── OAuth (Google / Apple) ─────────────────────────────────────────────────

async function upsertOAuthUser(
  provider: AuthProvider,
  profile: OAuthProfile,
): Promise<User> {
  const identity = await prisma.identity.findUnique({
    where: {
      provider_providerUserId: {
        provider,
        providerUserId: profile.providerUserId,
      },
    },
    include: { user: true },
  });
  if (identity) return identity.user;

  // Enlaza a un usuario existente con el mismo correo, o crea uno nuevo.
  const existingByEmail = profile.email
    ? await prisma.user.findUnique({ where: { email: profile.email } })
    : null;

  if (existingByEmail) {
    await prisma.identity.create({
      data: {
        provider,
        providerUserId: profile.providerUserId,
        userId: existingByEmail.id,
      },
    });
    return existingByEmail;
  }

  return prisma.user.create({
    data: {
      email: profile.email,
      name: profile.name,
      avatarUrl: profile.avatarUrl,
      identities: {
        create: { provider, providerUserId: profile.providerUserId },
      },
    },
  });
}

export async function loginWithGoogle(idToken: string): Promise<AuthResult> {
  const profile = await verifyGoogleIdToken(idToken);
  const user = await upsertOAuthUser(AuthProvider.GOOGLE, profile);
  return issueTokens(user);
}

export async function loginWithApple(
  identityToken: string,
  name?: string,
): Promise<AuthResult> {
  const profile = await verifyAppleIdentityToken(identityToken, name);
  const user = await upsertOAuthUser(AuthProvider.APPLE, profile);
  return issueTokens(user);
}

// ─── Refresh / logout / me ──────────────────────────────────────────────────

export async function refresh(rawToken: string): Promise<AuthResult> {
  const stored = await prisma.refreshToken.findUnique({
    where: { tokenHash: hashToken(rawToken) },
    include: { user: true },
  });
  if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
    throw AppError.unauthorized("Refresh token inválido o expirado");
  }
  // Rotación: revoca el actual y emite uno nuevo.
  await prisma.refreshToken.update({
    where: { id: stored.id },
    data: { revokedAt: new Date() },
  });
  return issueTokens(stored.user);
}

export async function logout(rawToken: string): Promise<void> {
  await prisma.refreshToken
    .updateMany({
      where: { tokenHash: hashToken(rawToken), revokedAt: null },
      data: { revokedAt: new Date() },
    })
    .catch(() => undefined);
}

export async function getMe(userId: string): Promise<PublicUser> {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw AppError.notFound("Usuario no encontrado");
  return toPublicUser(user);
}
