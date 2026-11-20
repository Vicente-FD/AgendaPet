import { Router } from "express";
import { z } from "zod";
import { asyncHandler } from "../../lib/asyncHandler";
import { env } from "../../config/env";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as billing from "./billing.service";

export const billingRouter = Router();

const appleValidateSchema = z.object({ signedTransaction: z.string().min(10) });
const googleValidateSchema = z.object({
  productId: z.string().min(1),
  purchaseToken: z.string().min(10),
});
const appleWebhookSchema = z.object({ signedPayload: z.string().min(10) });
const googleWebhookSchema = z.object({
  message: z.object({ data: z.string().min(1), messageId: z.string().optional() }),
  subscription: z.string().optional(),
});

// ─── Estado de la suscripción ───────────────────────────────────────────────
billingRouter.get(
  "/entitlement",
  requireAuth,
  asyncHandler(async (req, res) => {
    res.json({ entitlement: await billing.getEntitlement(req.userId!) });
  }),
);

// ─── Validación desde la app ────────────────────────────────────────────────
billingRouter.post(
  "/validate/apple",
  requireAuth,
  validate({ body: appleValidateSchema }),
  asyncHandler(async (req, res) => {
    const entitlement = await billing.validateApple(
      req.userId!,
      req.body.signedTransaction,
    );
    res.json({ entitlement });
  }),
);

billingRouter.post(
  "/validate/google",
  requireAuth,
  validate({ body: googleValidateSchema }),
  asyncHandler(async (req, res) => {
    const entitlement = await billing.validateGoogle(
      req.userId!,
      req.body.productId,
      req.body.purchaseToken,
    );
    res.json({ entitlement });
  }),
);

// ─── Webhooks (sin auth; se validan por firma / token) ──────────────────────
// App Store Server Notifications v2.
billingRouter.post(
  "/webhooks/apple",
  validate({ body: appleWebhookSchema }),
  asyncHandler(async (req, res) => {
    const type = await billing.handleAppleNotification(req.body.signedPayload);
    res.json({ ok: true, type });
  }),
);

// Google Play Real-time Developer Notifications (Pub/Sub push).
billingRouter.post(
  "/webhooks/google",
  validate({ body: googleWebhookSchema }),
  asyncHandler(async (req, res) => {
    // Verificación simple por token compartido (configura el push de Pub/Sub
    // con ?token=... o el header correspondiente).
    const token = req.query.token;
    if (
      env.googlePlay.rtdnVerificationToken &&
      token !== env.googlePlay.rtdnVerificationToken
    ) {
      res.status(403).json({ error: { code: "forbidden", message: "Token inválido" } });
      return;
    }
    await billing.handleGoogleRtdn(req.body.message.data);
    res.status(204).send(); // Pub/Sub espera 2xx para no reintentar
  }),
);
