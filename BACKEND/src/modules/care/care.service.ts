import { CareType } from "@prisma/client";
import { z } from "zod";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { assertPetWriteAccess, getAccessiblePet } from "../pets/pet-access";

/// Vacunas, medicinas, servicios y citas comparten tabla y se distinguen por `type`.
export const careSchema = z.object({
  type: z.nativeEnum(CareType),
  name: z.string().min(1).max(120),
  date: z.coerce.date(),
  nextDueDate: z.coerce.date().optional(),
  notes: z.string().max(500).optional(),
});

export const careUpdateSchema = careSchema.partial();

export const careQuerySchema = z.object({
  type: z.nativeEnum(CareType).optional(),
});

export async function listCare(
  userId: string,
  petId: string,
  type?: CareType,
) {
  await getAccessiblePet(userId, petId);
  return prisma.careRecord.findMany({
    where: { petId, ...(type ? { type } : {}) },
    orderBy: { date: "desc" },
  });
}

export async function createCare(
  userId: string,
  petId: string,
  data: z.infer<typeof careSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  return prisma.careRecord.create({ data: { ...data, petId } });
}

async function findOwned(petId: string, id: string) {
  const record = await prisma.careRecord.findUnique({ where: { id } });
  if (!record || record.petId !== petId) {
    throw AppError.notFound("Registro no encontrado");
  }
  return record;
}

export async function updateCare(
  userId: string,
  petId: string,
  id: string,
  data: z.infer<typeof careUpdateSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  await findOwned(petId, id);
  return prisma.careRecord.update({ where: { id }, data });
}

export async function deleteCare(userId: string, petId: string, id: string) {
  await assertPetWriteAccess(userId, petId);
  await findOwned(petId, id);
  await prisma.careRecord.delete({ where: { id } });
}
