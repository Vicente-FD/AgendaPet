import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { authLimiter } from "../../middleware/rateLimit";
import { validate } from "../../middleware/validate";
import * as controller from "./auth.controller";
import {
  appleSchema,
  googleSchema,
  loginSchema,
  refreshSchema,
  registerSchema,
} from "./auth.schemas";

export const authRouter = Router();

authRouter.post(
  "/register",
  authLimiter,
  validate({ body: registerSchema }),
  asyncHandler(controller.register),
);
authRouter.post(
  "/login",
  authLimiter,
  validate({ body: loginSchema }),
  asyncHandler(controller.login),
);
authRouter.post(
  "/google",
  validate({ body: googleSchema }),
  asyncHandler(controller.google),
);
authRouter.post(
  "/apple",
  validate({ body: appleSchema }),
  asyncHandler(controller.apple),
);
authRouter.post(
  "/refresh",
  authLimiter,
  validate({ body: refreshSchema }),
  asyncHandler(controller.refresh),
);
authRouter.post(
  "/logout",
  validate({ body: refreshSchema }),
  asyncHandler(controller.logout),
);
authRouter.get("/me", requireAuth, asyncHandler(controller.me));
