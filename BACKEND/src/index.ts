import { createApp } from "./app";
import { env } from "./config/env";
import { prisma } from "./lib/prisma";

const app = createApp();

const server = app.listen(env.port, () => {
  console.log(`🐾 Agenda Pet API escuchando en http://localhost:${env.port}`);
  console.log(`   Entorno: ${env.nodeEnv}`);
});

async function shutdown(signal: string) {
  console.log(`\n${signal} recibido, cerrando...`);
  server.close();
  await prisma.$disconnect();
  process.exit(0);
}

process.on("SIGINT", () => void shutdown("SIGINT"));
process.on("SIGTERM", () => void shutdown("SIGTERM"));
