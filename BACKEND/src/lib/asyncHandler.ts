import type { NextFunction, Request, Response } from "express";

// Envuelve controladores async para que los errores lleguen al middleware.
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
) {
  return (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };
}
