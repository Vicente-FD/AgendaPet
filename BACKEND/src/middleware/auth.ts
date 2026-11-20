import type { NextFunction, Request, Response } from "express";
import { AppError } from "../lib/errors";
import { verifyAccessToken } from "../lib/jwt";

// Extiende Request con el usuario autenticado.
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId?: string;
    }
  }
}

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    throw AppError.unauthorized("Falta el token Bearer");
  }
  const token = header.slice("Bearer ".length).trim();
  try {
    const claims = verifyAccessToken(token);
    req.userId = claims.sub;
    next();
  } catch {
    throw AppError.unauthorized("Token inválido o expirado");
  }
}
