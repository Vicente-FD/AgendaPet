import { z } from "zod";
import { MemberStatus } from "@prisma/client";
import { prisma } from "../../lib/prisma";
import { assertPetWriteAccess, getAccessiblePet } from "./pet-access";

export const createPetSchema = z.object({
  name: z.string().min(1).max(60),
  species: z.string().min(1).max(40),
  breed: z.string().max(60).optional(),
  birthDate: z.coerce.date().optional(),
  weightKg: z.number().positive().optional(),
  avatarUrl: z.string().url().optional(),
});

export const updatePetSchema = createPetSchema.partial();

// Lista las mascotas que el usuario posee o administra.
export async function listPets(userId: string) {
  return prisma.pet.findMany({
    where: {
      OR: [
        { ownerId: userId },
        { memberships: { some: { userId, status: MemberStatus.ACTIVE } } },
      ],
    },
    orderBy: { createdAt: "asc" },
  });
}

export async function getPet(userId: string, petId: string) {
  return getAccessiblePet(userId, petId);
}

export async function createPet(
  userId: string,
  data: z.infer<typeof createPetSchema>,
) {
  return prisma.pet.create({ data: { ...data, ownerId: userId } });
}

export async function updatePet(
  userId: string,
  petId: string,
  data: z.infer<typeof updatePetSchema>,
) {
  await assertPetWriteAccess(userId, petId);
  return prisma.pet.update({ where: { id: petId }, data });
}

export async function deletePet(userId: string, petId: string) {
  const pet = await prisma.pet.findUnique({ where: { id: petId } });
  if (pet && pet.ownerId !== userId) {
    // Solo el dueño puede eliminar.
    await assertPetWriteAccess(userId, petId, []);
  }
  await prisma.pet.delete({ where: { id: petId } });
}
