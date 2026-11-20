import type { NextFunction, Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { AppError } from "../lib/errors";

export function notFoundHandler(_req: Request, res: Response) {
  res.status(404).json({ error: { code: "not_found", message: "Ruta no encontrada" } });
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  if (err instanceof AppError) {
    res.status(err.status).json({
      error: { code: err.code, message: err.message, details: err.details },
    });
    return;
  }

  // Errores conocidos de Prisma → respuestas limpias.
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === "P2002") {
      res.status(409).json({
        error: { code: "conflict", message: "Registro duplicado" },
      });
      return;
    }
    if (err.code === "P2025") {
      res.status(404).json({
        error: { code: "not_found", message: "No encontrado" },
      });
      return;
    }
  }

  console.error("[error]", err);
  res.status(500).json({
    error: { code: "internal", message: "Error interno del servidor" },
  });
}
