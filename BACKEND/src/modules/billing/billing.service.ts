import { EntitlementStatus, Plan, Prisma, Store } from "@prisma/client";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { decodeAppleNotification, verifyAppleTransaction } from "./providers/apple";
import { decodeRtdn, verifyGooglePurchase } from "./providers/google";
import type { NormalizedPurchase } from "./providers/types";

export async function getEntitlement(userId: string) {
  const ent = await prisma.entitlement.findUnique({ where: { userId } });
  return (
    ent ?? {
      userId,
      plan: Plan.FREE,
      store: Store.NONE,
      status: EntitlementStatus.NONE,
      productId: null,
      expiresAt: null,
      autoRenew: false,
      originalTransactionId: null,
      purchaseToken: null,
    }
  );
}

// Aplica una compra normalizada al entitlement del usuario y la registra.
// Un mismo comprobante no puede activar PRO en dos cuentas distintas.
async function assertNoReclamadaPorOtro(
  userId: string,
  purchase: NormalizedPurchase,
) {
  const claves: Prisma.EntitlementWhereInput[] = [];
  if (purchase.originalTransactionId) {
    claves.push({ originalTransactionId: purchase.originalTransactionId });
  }
  if (purchase.purchaseToken) {
    claves.push({ purchaseToken: purchase.purchaseToken });
  }
  if (claves.length === 0) return;

  const existente = await prisma.entitlement.findFirst({
    where: { OR: claves },
  });
  if (existente && existente.userId !== userId) {
    throw AppError.conflict(
      "Esta compra ya está asociada a otra cuenta de Agenda Pet",
    );
  }
}

async function grant(userId: string, store: Store, purchase: NormalizedPurchase) {
  await assertNoReclamadaPorOtro(userId, purchase);
  const status = purchase.active
    ? EntitlementStatus.ACTIVE
    : EntitlementStatus.EXPIRED;
  const plan = purchase.active ? Plan.PRO : Plan.FREE;

  const ent = await prisma.entitlement.upsert({
    where: { userId },
    create: {
      userId,
      plan,
      store,
      status,
      productId: purchase.productId,
      expiresAt: purchase.expiresAt ?? undefined,
      autoRenew: purchase.autoRenew,
      originalTransactionId: purchase.originalTransactionId ?? undefined,
      purchaseToken: purchase.purchaseToken ?? undefined,
    },
    update: {
      plan,
      store,
      status,
      productId: purchase.productId,
      expiresAt: purchase.expiresAt ?? null,
      autoRenew: purchase.autoRenew,
      originalTransactionId: purchase.originalTransactionId ?? null,
      purchaseToken: purchase.purchaseToken ?? null,
    },
  });

  await prisma.purchase.create({
    data: {
      userId,
      store,
      productId: purchase.productId,
      transactionId: purchase.transactionId,
      type: "validation",
      rawPayload: purchase.raw as never,
    },
  });

  return ent;
}

// ─── Validación iniciada por la app ─────────────────────────────────────────

export async function validateApple(userId: string, signedTransaction: string) {
  const purchase = await verifyAppleTransaction(signedTransaction);
  return grant(userId, Store.APPLE, purchase);
}

export async function validateGoogle(
  userId: string,
  productId: string,
  purchaseToken: string,
) {
  const purchase = await verifyGooglePurchase(productId, purchaseToken);
  return grant(userId, Store.GOOGLE, purchase);
}

// ─── Webhooks de las tiendas ────────────────────────────────────────────────

export async function handleAppleNotification(signedPayload: string) {
  const decoded = await decodeAppleNotification(signedPayload);
  const origTx = decoded.purchase?.originalTransactionId;
  if (decoded.purchase && origTx) {
    const ent = await prisma.entitlement.findFirst({
      where: { originalTransactionId: origTx },
    });
    if (ent) await grant(ent.userId, Store.APPLE, decoded.purchase);
  }
  return decoded.notificationType;
}

export async function handleGoogleRtdn(messageDataBase64: string) {
  const notif = decodeRtdn(messageDataBase64);
  if (notif.purchaseToken && notif.subscriptionId) {
    const ent = await prisma.entitlement.findFirst({
      where: { purchaseToken: notif.purchaseToken },
    });
    if (ent) {
      const purchase = await verifyGooglePurchase(
        notif.subscriptionId,
        notif.purchaseToken,
      );
      await grant(ent.userId, Store.GOOGLE, purchase);
    }
  }
  return notif.notificationType ?? "unknown";
}
