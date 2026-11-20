import { Router } from "express";
import { authRouter } from "./modules/auth/auth.routes";
import { usersRouter } from "./modules/users/users.routes";
import { petsRouter } from "./modules/pets/pets.routes";
import { feedingRouter } from "./modules/feeding/feeding.routes";
import { walksRouter } from "./modules/walks/walks.routes";
import { remindersRouter } from "./modules/reminders/reminders.routes";
import { careRouter } from "./modules/care/care.routes";
import { billingRouter } from "./modules/billing/billing.routes";

export const apiRouter = Router();

apiRouter.get("/health", (_req, res) => res.json({ status: "ok" }));

apiRouter.use("/auth", authRouter);
apiRouter.use("/users", usersRouter);
apiRouter.use("/pets", petsRouter);
apiRouter.use("/billing", billingRouter);

// Rutas anidadas por mascota.
apiRouter.use("/pets/:petId/feeding", feedingRouter);
apiRouter.use("/pets/:petId/walks", walksRouter);
apiRouter.use("/pets/:petId/reminders", remindersRouter);
apiRouter.use("/pets/:petId/care", careRouter);
