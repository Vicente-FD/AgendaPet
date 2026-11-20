import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as walks from "./walks.service";

export const walksRouter = Router({ mergeParams: true });

walksRouter.use(requireAuth);

walksRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    res.json({ walks: await walks.listWalks(req.userId!, req.params.petId) });
  }),
);

walksRouter.post(
  "/",
  validate({ body: walks.walkSchema }),
  asyncHandler(async (req, res) => {
    res.status(201).json({
      walk: await walks.createWalk(req.userId!, req.params.petId, req.body),
    });
  }),
);

walksRouter.patch(
  "/:id",
  validate({ body: walks.walkUpdateSchema }),
  asyncHandler(async (req, res) => {
    res.json({
      walk: await walks.updateWalk(
        req.userId!,
        req.params.petId,
        req.params.id,
        req.body,
      ),
    });
  }),
);

walksRouter.delete(
  "/:id",
  asyncHandler(async (req, res) => {
    await walks.deleteWalk(req.userId!, req.params.petId, req.params.id);
    res.status(204).send();
  }),
);
