import rateLimit from "express-rate-limit";

/// Frena ataques de fuerza bruta contra el login y el registro.
/// 10 intentos por IP cada 15 minutos; los exitosos no se cuentan.
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  skipSuccessfulRequests: true,
  standardHeaders: "draft-7",
  legacyHeaders: false,
  message: {
    error: {
      code: "too_many_requests",
      message: "Demasiados intentos. Espera unos minutos e inténtalo de nuevo.",
    },
  },
});

/// Límite general de la API, por si alguien abusa de un endpoint.
export const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 120,
  standardHeaders: "draft-7",
  legacyHeaders: false,
});
