import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { env } from "./config/env";
import { apiRouter } from "./routes";
import { apiLimiter } from "./middleware/rateLimit";
import { errorHandler, notFoundHandler } from "./middleware/error";

export function createApp() {
  const app = express();
  // Fly.io / Cloud Run entregan la IP real en X-Forwarded-For.
  app.set("trust proxy", 1);

  app.use(helmet());
  app.use(
    cors({
      origin: env.corsOrigins.length ? env.corsOrigins : true,
      credentials: true,
    }),
  );
  // 8 MB: las fotos llegan en base64 (ocupan ~33% más que el archivo).
  app.use(express.json({ limit: "8mb" }));
  app.use(express.urlencoded({ extended: true }));
  if (!env.isProd) app.use(morgan("dev"));

  app.get("/", (_req, res) => res.json({ name: "agendapet-api", status: "ok" }));
  app.use("/api", apiLimiter, apiRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
