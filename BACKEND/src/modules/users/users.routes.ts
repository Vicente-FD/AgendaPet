import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as users from "./users.service";

export const usersRouter = Router();

usersRouter.use(requireAuth);

usersRouter.get(
  "/me",
  asyncHandler(async (req, res) => {
    res.json({ user: await users.getProfile(req.userId!) });
  }),
);

usersRouter.patch(
  "/me",
  validate({ body: users.updateProfileSchema }),
  asyncHandler(async (req, res) => {
    res.json({ user: await users.updateProfile(req.userId!, req.body) });
  }),
);

// Borrado de cuenta: requisito de App Store y Google Play.
usersRouter.delete(
  "/me",
  asyncHandler(async (req, res) => {
    await users.deleteAccount(req.userId!);
    res.status(204).send();
  }),
);
