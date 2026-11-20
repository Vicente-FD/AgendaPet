import { z } from "zod";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { assertPetWriteAccess, getAccessiblePet } from "../pets/pet-access";

export const feedingSchema = z.object({
  foodName: z.string().min(1).max(120),
  brand: z.string().max(80).optional(),
  kind: z.enum(["DRY", "WET", "MIXED"]).default("DRY"),
  bagSizeKg: z.number().positive().optional(),
  dailyGrams: z.number().int().positive().optional(),
  activity: z.enum(["LOW", "NORMAL", "HIGH"]).default("NORMAL"),
  openedAt: z.coerce.date().optional(),
});

export const feedingUpdateSchema = feedingSchema.partial();

export async function listFeeding(userId: string, petId: string) {
  await getAccessiblePet(userId, petId);
  return prisma.feedingPlan.findMany({
    where: { petId },
    orderBy: { createdAt: "desc" },
  });
}

export async function createFeeding(
  userId: string,
  petId: string,
  data: z.infer<typeof feedingSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  return prisma.feedingPlan.create({ data: { ...data, petId } });
}

export async function updateFeeding(
  userId: string,
  petId: string,
  id: string,
  data: z.infer<typeof feedingUpdateSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  const plan = await prisma.feedingPlan.findUnique({ where: { id } });
  if (!plan || plan.petId !== petId) throw AppError.notFound("Plan no encontrado");
  return prisma.feedingPlan.update({ where: { id }, data });
}

export async function deleteFeeding(userId: string, petId: string, id: string) {
  await assertPetWriteAccess(userId, petId);
  const plan = await prisma.feedingPlan.findUnique({ where: { id } });
  if (!plan || plan.petId !== petId) throw AppError.notFound("Plan no encontrado");
  await prisma.feedingPlan.delete({ where: { id } });
}
