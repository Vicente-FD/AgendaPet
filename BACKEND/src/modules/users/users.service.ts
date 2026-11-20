import { z } from "zod";
import { AppError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";

export const updateProfileSchema = z.object({
  name: z.string().min(1).max(80).optional(),
  avatarUrl: z.string().url().optional(),
});

export async function getProfile(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      entitlement: true,
      _count: { select: { ownedPets: true } },
    },
  });
  if (!user) throw AppError.notFound("Usuario no encontrado");
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
    plan: user.entitlement?.plan === "PRO" ? "PRO" : "FREE",
    petsCount: user._count.ownedPets,
  };
}

export async function updateProfile(
  userId: string,
  data: z.infer<typeof updateProfileSchema>,
) {
  const user = await prisma.user.update({ where: { id: userId }, data });
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    avatarUrl: user.avatarUrl,
  };
}

// Elimina la cuenta y todo lo asociado (mascotas, recordatorios, sesiones…).
// Las relaciones del esquema están en cascada, así que basta con borrar el usuario.
export async function deleteAccount(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw AppError.notFound("Usuario no encontrado");
  await prisma.user.delete({ where: { id: userId } });
}
