import { describe, expect, it } from "vitest";
import {
  generateRefreshToken,
  hashToken,
  signAccessToken,
  ttlToDate,
  verifyAccessToken,
} from "../lib/jwt";
import { careSchema } from "../modules/care/care.service";
import { reminderSchema } from "../modules/reminders/reminders.service";

describe("Sesiones", () => {
  it("firma y verifica un token de acceso", () => {
    const token = signAccessToken("user-1", "maria@agendapet.cl");
    const claims = verifyAccessToken(token);
    expect(claims.sub).toBe("user-1");
    expect(claims.email).toBe("maria@agendapet.cl");
  });

  it("rechaza un token manipulado", () => {
    const token = signAccessToken("user-1");
    expect(() => verifyAccessToken(token + "x")).toThrow();
  });

  it("guarda el refresh token solo como hash", () => {
    const token = generateRefreshToken();
    const hash = hashToken(token);
    expect(hash).not.toBe(token);
    expect(hash).toHaveLength(64);
    expect(hashToken(token)).toBe(hash);
  });

  it("calcula el vencimiento a partir del TTL", () => {
    const desde = new Date("2026-01-01T00:00:00Z");
    expect(ttlToDate("15m", desde).toISOString()).toBe(
      "2026-01-01T00:15:00.000Z",
    );
    expect(ttlToDate("30d", desde).toISOString()).toBe(
      "2026-01-31T00:00:00.000Z",
    );
  });
});

describe("Esquemas de cuidado", () => {
  it("acepta una vacuna con próximo control", () => {
    const parsed = careSchema.parse({
      type: "VACCINE",
      name: "Rabia",
      date: "2026-10-01T10:00:00.000Z",
      nextDueDate: "2027-10-01T10:00:00.000Z",
    });
    expect(parsed.type).toBe("VACCINE");
    expect(parsed.date).toBeInstanceOf(Date);
  });

  it("rechaza un tipo que no existe", () => {
    expect(() =>
      careSchema.parse({ type: "PASEO", name: "x", date: new Date() }),
    ).toThrow();
  });

  it("rechaza un registro sin nombre", () => {
    expect(() =>
      careSchema.parse({ type: "SERVICE", name: "", date: new Date() }),
    ).toThrow();
  });
});

describe("Esquema de recordatorios", () => {
  it("marca como pendiente por defecto", () => {
    const parsed = reminderSchema.parse({
      title: "Baño",
      dueAt: "2026-10-20T16:00:00.000Z",
    });
    expect(parsed.done).toBe(false);
  });

  it("exige una fecha", () => {
    expect(() => reminderSchema.parse({ title: "Baño" })).toThrow();
  });
});
