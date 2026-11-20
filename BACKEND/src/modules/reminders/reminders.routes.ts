import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as reminders from "./reminders.service";

// mergeParams: hereda :petId del router de pets.
export const remindersRouter = Router({ mergeParams: true });

remindersRouter.use(requireAuth);

remindersRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    res.json({
      reminders: await reminders.listReminders(req.userId!, req.params.petId),
    });
  }),
);

remindersRouter.post(
  "/",
  validate({ body: reminders.reminderSchema }),
  asyncHandler(async (req, res) => {
    res.status(201).json({
      reminder: await reminders.createReminder(
        req.userId!,
        req.params.petId,
        req.body,
      ),
    });
  }),
);

remindersRouter.patch(
  "/:id",
  validate({ body: reminders.reminderUpdateSchema }),
  asyncHandler(async (req, res) => {
    res.json({
      reminder: await reminders.updateReminder(
        req.userId!,
        req.params.petId,
        req.params.id,
        req.body,
      ),
    });
  }),
);

remindersRouter.delete(
  "/:id",
  asyncHandler(async (req, res) => {
    await reminders.deleteReminder(req.userId!, req.params.petId, req.params.id);
    res.status(204).send();
  }),
);
