import { Router } from "express";
import { asyncHandler } from "../../lib/asyncHandler";
import { requireAuth } from "../../middleware/auth";
import { validate } from "../../middleware/validate";
import * as pets from "./pets.service";
import { z } from "zod";
import { subirImagen } from "../storage/storage.service";

export const petsRouter = Router();

petsRouter.use(requireAuth);

petsRouter.get(
  "/",
  asyncHandler(async (req, res) => {
    res.json({ pets: await pets.listPets(req.userId!) });
  }),
);

petsRouter.post(
  "/",
  validate({ body: pets.createPetSchema }),
  asyncHandler(async (req, res) => {
    res.status(201).json({ pet: await pets.createPet(req.userId!, req.body) });
  }),
);

petsRouter.get(
  "/:id",
  asyncHandler(async (req, res) => {
    res.json({ pet: await pets.getPet(req.userId!, req.params.id) });
  }),
);

petsRouter.patch(
  "/:id",
  validate({ body: pets.updatePetSchema }),
  asyncHandler(async (req, res) => {
    res.json({ pet: await pets.updatePet(req.userId!, req.params.id, req.body) });
  }),
);

// Foto de la mascota: la app manda la imagen en base64 y la API la guarda en
// Supabase Storage, dejando la URL pública en el registro.
const fotoSchema = z.object({
  data: z.string().min(16),
  contentType: z.string().min(5).max(40),
});

petsRouter.post(
  "/:id/photo",
  validate({ body: fotoSchema }),
  asyncHandler(async (req, res) => {
    const mascota = await pets.getPet(req.userId!, req.params.id);
    const archivo = await subirImagen(
      `mascotas/${mascota.id}`,
      "avatar",
      req.body.data,
      req.body.contentType,
    );
    const actualizada = await pets.updatePet(req.userId!, mascota.id, {
      avatarUrl: archivo.url,
    });
    res.status(201).json({ pet: actualizada });
  }),
);

petsRouter.delete(
  "/:id",
  asyncHandler(async (req, res) => {
    await pets.deletePet(req.userId!, req.params.id);
    res.status(204).send();
  }),
);
