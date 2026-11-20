import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "../app";
import { signAccessToken } from "../lib/jwt";

const app = createApp();

describe("API", () => {
  it("responde el healthcheck", async () => {
    const res = await request(app).get("/api/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("devuelve 404 con formato de error en rutas desconocidas", async () => {
    const res = await request(app).get("/api/no-existe");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("not_found");
  });
});

describe("Autenticación requerida", () => {
  const protegidas = [
    "/api/users/me",
    "/api/pets",
    "/api/pets/abc/reminders",
    "/api/pets/abc/care",
    "/api/pets/abc/feeding",
    "/api/billing/entitlement",
  ];

  for (const ruta of protegidas) {
    it(`rechaza ${ruta} sin token`, async () => {
      const res = await request(app).get(ruta);
      expect(res.status).toBe(401);
      expect(res.body.error.code).toBe("unauthorized");
    });
  }

  it("rechaza un token inválido", async () => {
    const res = await request(app)
      .get("/api/users/me")
      .set("Authorization", "Bearer esto-no-es-un-token");
    expect(res.status).toBe(401);
  });

  it("acepta un token bien firmado y pasa del middleware de sesión", async () => {
    const token = signAccessToken("usuario-de-prueba", "test@agendapet.cl");
    const res = await request(app)
      .get("/api/users/me")
      .set("Authorization", `Bearer ${token}`);
    // Pasa la autenticación: el 401 ya no aparece (fallará más adelante al
    // consultar la base de datos, que en los tests no existe).
    expect(res.status).not.toBe(401);
  });
});

describe("Validación de datos", () => {
  it("rechaza un registro con contraseña corta", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ email: "test@agendapet.cl", password: "123" });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("bad_request");
  });

  it("rechaza un correo con formato inválido", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ email: "no-es-un-correo", password: "12345678" });
    expect(res.status).toBe(400);
  });
});
