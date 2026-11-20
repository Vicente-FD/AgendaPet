import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as care from "./care.service";

// mergeParams: hereda :petId del router de pets.
export const careRouter = Router({ mergeParams: true });

careRouter.use(requireAuth);

careRouter.get(
  "/",
  validate({ query: care.careQuerySchema }),
  asyncHandler(async (req, res) => {
    const { type } = req.query as { type?: never };
    res.json({
      records: await care.listCare(req.userId!, req.params.petId, type),
    });
  }),
);

careRouter.post(
  "/",
  validate({ body: care.careSchema }),
  asyncHandler(async (req, res) => {
    res.status(201).json({
      record: await care.createCare(req.userId!, req.params.petId, req.body),
    });
  }),
);

careRouter.patch(
  "/:id",
  validate({ body: care.careUpdateSchema }),
  asyncHandler(async (req, res) => {
    res.json({
      record: await care.updateCare(
        req.userId!,
        req.params.petId,
        req.params.id,
        req.body,
      ),
    });
  }),
);

careRouter.delete(
  "/:id",
  asyncHandler(async (req, res) => {
    await care.deleteCare(req.userId!, req.params.petId, req.params.id);
    res.status(204).send();
  }),
);
