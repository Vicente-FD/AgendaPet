import { z } from "zod";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { assertPetWriteAccess, getAccessiblePet } from "../pets/pet-access";

export const reminderSchema = z.object({
  title: z.string().min(1).max(120),
  type: z.string().max(40).optional(),
  dueAt: z.coerce.date(),
  done: z.boolean().default(false),
});

export const reminderUpdateSchema = reminderSchema.partial();

export async function listReminders(userId: string, petId: string) {
  await getAccessiblePet(userId, petId);
  return prisma.reminder.findMany({
    where: { petId },
    orderBy: { dueAt: "asc" },
  });
}

export async function createReminder(
  userId: string,
  petId: string,
  data: z.infer<typeof reminderSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  return prisma.reminder.create({ data: { ...data, petId } });
}

async function findOwned(petId: string, id: string) {
  const reminder = await prisma.reminder.findUnique({ where: { id } });
  if (!reminder || reminder.petId !== petId) {
    throw AppError.notFound("Recordatorio no encontrado");
  }
  return reminder;
}

export async function updateReminder(
  userId: string,
  petId: string,
  id: string,
  data: z.infer<typeof reminderUpdateSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  await findOwned(petId, id);
  return prisma.reminder.update({ where: { id }, data });
}

export async function deleteReminder(userId: string, petId: string, id: string) {
  await assertPetWriteAccess(userId, petId);
  await findOwned(petId, id);
  await prisma.reminder.delete({ where: { id } });
}
