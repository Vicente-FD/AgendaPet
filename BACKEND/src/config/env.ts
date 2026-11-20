import dotenv from "dotenv";

dotenv.config();

function required(name: string, fallback?: string): string {
  const value = process.env[name] ?? fallback;
  if (value === undefined || value === "") {
    throw new Error(`Falta la variable de entorno ${name}`);
  }
  return value;
}

function list(name: string, fallback = ""): string[] {
  return (process.env[name] ?? fallback)
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

// Secreto obligatorio: en producción no se permite valor por defecto, y el
// servidor no arranca si falta o si quedó el de ejemplo.
function secret(name: string): string {
  const value = process.env[name];
  const isProd = process.env.NODE_ENV === "production";
  const esDeEjemplo = !value || value.startsWith("change-me");
  if (isProd && esDeEjemplo) {
    throw new Error(
      `${name} no está configurado. Genera uno con: openssl rand -hex 32`,
    );
  }
  if (esDeEjemplo) {
    console.warn(`[env] ${name} usa un valor de desarrollo. No sirve para producción.`);
    return value ?? `dev-only-${name.toLowerCase()}`;
  }
  return value;
}

function bool(name: string, fallback = false): boolean {
  const v = process.env[name];
  if (v === undefined) return fallback;
  return ["1", "true", "yes", "on"].includes(v.toLowerCase());
}

export const env = {
  nodeEnv: process.env.NODE_ENV ?? "development",
  isProd: process.env.NODE_ENV === "production",
  port: Number(process.env.PORT ?? 4000),
  corsOrigins: list("CORS_ORIGINS", "http://localhost:3000,http://localhost:3001"),

  databaseUrl: required("DATABASE_URL"),

  jwt: {
    accessSecret: secret("JWT_ACCESS_SECRET"),
    refreshSecret: secret("JWT_REFRESH_SECRET"),
    accessTtl: process.env.JWT_ACCESS_TTL ?? "15m",
    refreshTtl: process.env.JWT_REFRESH_TTL ?? "30d",
  },

  google: {
    clientIds: list("GOOGLE_CLIENT_IDS"),
  },
  apple: {
    clientIds: list("APPLE_CLIENT_IDS"),
  },

  appleIap: {
    enabled: bool("APPLE_IAP_ENABLED"),
    bundleId: process.env.APPLE_BUNDLE_ID ?? "",
    issuerId: process.env.APPLE_ISSUER_ID ?? "",
    keyId: process.env.APPLE_KEY_ID ?? "",
    privateKeyPath: process.env.APPLE_PRIVATE_KEY_PATH ?? "",
    // Carpeta con los certificados raíz de Apple (AppleRootCA-G3, etc.) para
    // verificar la firma de transacciones y notificaciones.
    rootCertsDir: process.env.APPLE_ROOT_CERTS_DIR ?? "",
    appAppleId: process.env.APPLE_APP_APPLE_ID
      ? Number(process.env.APPLE_APP_APPLE_ID)
      : undefined,
    environment: (process.env.APPLE_ENVIRONMENT ?? "sandbox") as
      | "sandbox"
      | "production",
  },

  // Almacenamiento de fotos (Supabase Storage). El bucket debe ser público
  // para que la app pueda mostrar las imágenes sin firmar cada URL.
  supabase: {
    url: process.env.SUPABASE_URL ?? "",
    serviceKey: process.env.SUPABASE_SERVICE_ROLE_KEY ?? "",
    bucket: process.env.SUPABASE_BUCKET ?? "pets",
  },

  // Permite validar compras sin verificar la firma. Solo para pruebas locales:
  // si no está en true, la API rechaza cualquier compra que no pueda verificar.
  allowUnverifiedIap: bool("ALLOW_UNVERIFIED_IAP"),

  googlePlay: {
    enabled: bool("GOOGLE_PLAY_ENABLED"),
    packageName: process.env.GOOGLE_PLAY_PACKAGE_NAME ?? "",
    serviceAccountPath: process.env.GOOGLE_SERVICE_ACCOUNT_PATH ?? "",
    rtdnVerificationToken: process.env.GOOGLE_RTDN_VERIFICATION_TOKEN ?? "",
  },
};
