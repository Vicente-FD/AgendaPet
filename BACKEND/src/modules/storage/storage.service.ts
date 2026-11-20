import { env } from "../../config/env";
import { AppError } from "../../lib/errors";

/// Sube archivos a Supabase Storage usando su API REST.
/// No necesita el SDK: una petición con la service key basta.
const TIPOS_PERMITIDOS = ["image/jpeg", "image/png", "image/webp"];
const MAX_BYTES = 5 * 1024 * 1024; // 5 MB

export interface ArchivoSubido {
  url: string;
  path: string;
}

export function storageConfigurado(): boolean {
  return Boolean(env.supabase.url && env.supabase.serviceKey);
}

export async function subirImagen(
  carpeta: string,
  nombre: string,
  base64: string,
  contentType: string,
): Promise<ArchivoSubido> {
  if (!storageConfigurado()) {
    throw AppError.badRequest(
      "El almacenamiento de archivos no está configurado (SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY)",
    );
  }
  if (!TIPOS_PERMITIDOS.includes(contentType)) {
    throw AppError.badRequest(
      `Formato no permitido. Usa ${TIPOS_PERMITIDOS.join(", ")}`,
    );
  }

  const bytes = Buffer.from(base64, "base64");
  if (bytes.length === 0) throw AppError.badRequest("La imagen viene vacía");
  if (bytes.length > MAX_BYTES) {
    throw AppError.badRequest("La imagen supera los 5 MB");
  }

  const extension = contentType.split("/")[1].replace("jpeg", "jpg");
  const path = `${carpeta}/${nombre}-${Date.now()}.${extension}`;
  const base = env.supabase.url.replace(/\/$/, "");
  const bucket = env.supabase.bucket;

  const res = await fetch(`${base}/storage/v1/object/${bucket}/${path}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env.supabase.serviceKey}`,
      "Content-Type": contentType,
      "x-upsert": "true",
    },
    body: new Uint8Array(bytes),
  });

  if (!res.ok) {
    const detalle = await res.text().catch(() => "");
    console.error("[storage] error subiendo archivo:", res.status, detalle);
    throw AppError.badRequest("No se pudo guardar la imagen");
  }

  return {
    path,
    url: `${base}/storage/v1/object/public/${bucket}/${path}`,
  };
}
