import type { NextFunction, Request, Response } from "express";
import { ZodError, type ZodTypeAny } from "zod";
import { AppError } from "../lib/errors";

type Schemas = {
  body?: ZodTypeAny;
  query?: ZodTypeAny;
  params?: ZodTypeAny;
};

// Valida body/query/params con zod y sustituye por los valores parseados.
export function validate(schemas: Schemas) {
  return (req: Request, _res: Response, next: NextFunction) => {
    try {
      if (schemas.body) req.body = schemas.body.parse(req.body);
      if (schemas.query) req.query = schemas.query.parse(req.query) as never;
      if (schemas.params) req.params = schemas.params.parse(req.params) as never;
      next();
    } catch (err) {
      if (err instanceof ZodError) {
        next(AppError.badRequest("Datos inválidos", err.flatten()));
      } else {
        next(err);
      }
    }
  };
}
