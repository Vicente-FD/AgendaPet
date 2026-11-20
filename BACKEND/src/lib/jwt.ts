import crypto from "node:crypto";
import jwt from "jsonwebtoken";
import { env } from "../config/env";

export interface AccessClaims {
  sub: string; // userId
  email?: string | null;
}

// ─── Access token (JWT propio de la API) ────────────────────────────────────

export function signAccessToken(userId: string, email?: string | null): string {
  return jwt.sign({ email: email ?? null }, env.jwt.accessSecret, {
    subject: userId,
    expiresIn: env.jwt.accessTtl as jwt.SignOptions["expiresIn"],
  });
}

export function verifyAccessToken(token: string): AccessClaims {
  const decoded = jwt.verify(token, env.jwt.accessSecret) as jwt.JwtPayload;
  return { sub: String(decoded.sub), email: (decoded.email as string) ?? null };
}

// ─── Refresh token (opaco + hash en BD) ─────────────────────────────────────

export function generateRefreshToken(): string {
  return crypto.randomBytes(48).toString("base64url");
}

export function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

// Suma un TTL tipo "30d" / "15m" a la fecha dada.
export function ttlToDate(ttl: string, from = new Date()): Date {
  const match = /^(\d+)\s*([smhd])$/.exec(ttl.trim());
  if (!match) return new Date(from.getTime() + 30 * 24 * 3600 * 1000);
  const value = Number(match[1]);
  const unit = match[2];
  const seconds = { s: 1, m: 60, h: 3600, d: 86400 }[unit] ?? 86400;
  return new Date(from.getTime() + value * seconds * 1000);
}
