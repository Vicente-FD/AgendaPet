import { MemberRole, MemberStatus, type Pet } from "@prisma/client";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";

// Lectura: dueño o miembro activo.
export async function getAccessiblePet(
  userId: string,
  petId: string,
): Promise<Pet> {
  const pet = await prisma.pet.findUnique({ where: { id: petId } });
  if (!pet) throw AppError.notFound("Mascota no encontrada");
  if (pet.ownerId === userId) return pet;

  const membership = await prisma.petMembership.findFirst({
    where: { petId, userId, status: MemberStatus.ACTIVE },
  });
  if (!membership) throw AppError.forbidden("No tienes acceso a esta mascota");
  return pet;
}

// Escritura: dueño o miembro activo con rol permitido.
export async function assertPetWriteAccess(
  userId: string,
  petId: string,
  roles: MemberRole[] = [MemberRole.OWNER, MemberRole.EDITOR],
): Promise<Pet> {
  const pet = await prisma.pet.findUnique({ where: { id: petId } });
  if (!pet) throw AppError.notFound("Mascota no encontrada");
  if (pet.ownerId === userId) return pet;

  const membership = await prisma.petMembership.findFirst({
    where: { petId, userId, status: MemberStatus.ACTIVE },
  });
  if (!membership || !roles.includes(membership.role)) {
    throw AppError.forbidden("No tienes permiso para modificar esta mascota");
  }
  return pet;
}
