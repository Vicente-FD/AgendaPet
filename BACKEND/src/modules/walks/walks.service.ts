import { z } from "zod";
import { MemberRole } from "@prisma/client";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { assertPetWriteAccess, getAccessiblePet } from "../pets/pet-access";

// Paseos: pueden crearlos dueño, editor o paseador.
const WALK_ROLES = [MemberRole.OWNER, MemberRole.EDITOR, MemberRole.WALKER];

export const walkSchema = z.object({
  walkerId: z.string().optional(), // por defecto, el usuario actual
  startedAt: z.coerce.date(),
  endedAt: z.coerce.date().optional(),
  distanceKm: z.number().min(0).default(0),
  durationSec: z.number().int().min(0).default(0),
  route: z.any().optional(),
  byWalker: z.boolean().default(false),
});

export const walkUpdateSchema = z.object({
  endedAt: z.coerce.date().optional(),
  distanceKm: z.number().min(0).optional(),
  durationSec: z.number().int().min(0).optional(),
  route: z.any().optional(),
  kudos: z.number().int().min(0).optional(),
});

export async function listWalks(userId: string, petId: string) {
  await getAccessiblePet(userId, petId);
  return prisma.walk.findMany({
    where: { petId },
    orderBy: { startedAt: "desc" },
    include: { walker: { select: { id: true, name: true, avatarUrl: true } } },
  });
}

export async function createWalk(
  userId: string,
  petId: string,
  data: z.infer<typeof walkSchema>,
) {
  await assertPetWriteAccess(userId, petId, WALK_ROLES);
  const { walkerId, ...rest } = data;
  return prisma.walk.create({
    data: { ...rest, petId, walkerId: walkerId ?? userId },
  });
}

export async function updateWalk(
  userId: string,
  petId: string,
  id: string,
  data: z.infer<typeof walkUpdateSchema>,
) {
  await assertPetWriteAccess(userId, petId, WALK_ROLES);
  const walk = await prisma.walk.findUnique({ where: { id } });
  if (!walk || walk.petId !== petId) throw AppError.notFound("Paseo no encontrado");
  return prisma.walk.update({ where: { id }, data });
}

export async function deleteWalk(userId: string, petId: string, id: string) {
  await assertPetWriteAccess(userId, petId, WALK_ROLES);
  const walk = await prisma.walk.findUnique({ where: { id } });
  if (!walk || walk.petId !== petId) throw AppError.notFound("Paseo no encontrado");
  await prisma.walk.delete({ where: { id } });
}
