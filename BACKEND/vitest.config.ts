import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["src/**/*.test.ts"],
    // Los tests no tocan la base de datos: validan rutas, permisos y esquemas.
    setupFiles: ["src/test/setup.ts"],
  },
});
