import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as feeding from "./feeding.service";

// mergeParams: hereda :petId del router de pets.
export const feedingRouter = Router({ mergeParams: true });

feedingRouter.use(requireAuth);

feedingRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    res.json({
      plans: await feeding.listFeeding(req.userId!, req.params.petId),
    });
  }),
);

feedingRouter.post(
  "/",
  validate({ body: feeding.feedingSchema }),
  asyncHandler(async (req, res) => {
    res.status(201).json({
      plan: await feeding.createFeeding(req.userId!, req.params.petId, req.body),
    });
  }),
);

feedingRouter.patch(
  "/:id",
  validate({ body: feeding.feedingUpdateSchema }),
  asyncHandler(async (req, res) => {
    res.json({
      plan: await feeding.updateFeeding(
        req.userId!,
        req.params.petId,
        req.params.id,
        req.body,
      ),
    });
  }),
);

feedingRouter.delete(
  "/:id",
  asyncHandler(async (req, res) => {
    await feeding.deleteFeeding(req.userId!, req.params.petId, req.params.id);
    res.status(204).send();
  }),
);
