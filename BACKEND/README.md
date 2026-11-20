# Agenda Pet — Backend (API)

API REST para Agenda Pet: **auth** (Google / Apple / email), **usuarios**, **mascotas**, **alimentación**, **paseos** y **facturación IAP** (App Store + Play Store).

Stack: **Node.js + TypeScript + Express + Prisma + PostgreSQL**.

> Estado: base ejecutable con esquema de datos completo (todas las funciones modeladas). CRUD implementado para `users`, `pets`, `feeding`, `walks` y `billing`; el resto de tablas (crecimiento, eventos, cuidado, recordatorios, tips, notificaciones, familia) están en el esquema listas para replicar el mismo patrón de módulo.

---

## Requisitos

- Node.js ≥ 20
- Docker (para PostgreSQL) — o un Postgres propio
- `openssl` (para generar secretos JWT)

## Puesta en marcha (local)

```bash
cd backend
cp .env.example .env            # edita los valores (al menos genera los JWT secrets)
docker compose up -d            # levanta PostgreSQL en localhost:5432
npm install
npm run prisma:generate
npm run prisma:migrate          # crea las tablas (primera migración)
npm run seed                    # tips de ejemplo (opcional)
npm run dev                     # http://localhost:4000
```

Prueba: `GET http://localhost:4000/api/health` → `{ "status": "ok" }`.

Genera secretos:

```bash
openssl rand -hex 32   # úsalo en JWT_ACCESS_SECRET y JWT_REFRESH_SECRET
```

---

## Endpoints

Base: `/api`. Los que requieren sesión usan `Authorization: Bearer <accessToken>`.

### Auth
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/auth/register` | Crear usuario con email/contraseña |
| POST | `/auth/login` | Login email/contraseña |
| POST | `/auth/google` | Login con Google (`{ idToken }`) |
| POST | `/auth/apple` | Login con Apple (`{ identityToken, name? }`) |
| POST | `/auth/refresh` | Rotar tokens (`{ refreshToken }`) |
| POST | `/auth/logout` | Revocar refresh token |
| GET | `/auth/me` | Usuario actual 🔒 |

Respuesta de login/registro: `{ accessToken, refreshToken, user }`.

### Usuarios · Mascotas
| Método | Ruta | Descripción |
|---|---|---|
| GET/PATCH | `/users/me` | Perfil del dueño 🔒 |
| GET/POST | `/pets` | Listar / crear mascota 🔒 |
| GET/PATCH/DELETE | `/pets/:id` | Ver / editar / borrar 🔒 |

### Alimentación · Paseos (anidados por mascota)
| Método | Ruta |
|---|---|
| GET/POST | `/pets/:petId/feeding` |
| PATCH/DELETE | `/pets/:petId/feeding/:id` |
| GET/POST | `/pets/:petId/walks` |
| PATCH/DELETE | `/pets/:petId/walks/:id` |

El acceso se controla por dueño o **membresía** de la mascota (roles `OWNER/EDITOR/VIEWER/WALKER`).

### Facturación (IAP)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/billing/entitlement` | Plan actual (FREE/PRO) 🔒 |
| POST | `/billing/validate/apple` | Validar compra Apple (`{ signedTransaction }`) 🔒 |
| POST | `/billing/validate/google` | Validar compra Play (`{ productId, purchaseToken }`) 🔒 |
| POST | `/billing/webhooks/apple` | App Store Server Notifications v2 |
| POST | `/billing/webhooks/google` | Play Real-time Developer Notifications (Pub/Sub) |

---

## Configurar login social

- **Google:** pon tus OAuth Client IDs (Android/iOS/Web) en `GOOGLE_CLIENT_IDS`. La app manda el `idToken`; el backend lo verifica con `google-auth-library`.
- **Apple:** pon tu App ID (bundle) y, si usas web, el Services ID en `APPLE_CLIENT_IDS`. La app manda el `identityToken`; se verifica contra el JWKS de Apple.

## Configurar pagos (App Store / Play Store)

Son **compras dentro de la app (IAP)**, no un gateway tipo Stripe. La app compra con las
librerías de la tienda y envía el comprobante al backend, que lo valida y guarda el
`entitlement`. Además, las tiendas notifican cambios por webhook.

- **Apple:** crea una llave de la App Store Server API (`.p8`), configura
  `APPLE_ISSUER_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY_PATH`, `APPLE_BUNDLE_ID`,
  `APPLE_APP_APPLE_ID` y descarga los **certificados raíz de Apple** a
  `APPLE_ROOT_CERTS_DIR`. Pon `APPLE_IAP_ENABLED=true`. Registra el endpoint
  `/api/billing/webhooks/apple` en App Store Connect (Server Notifications v2).
- **Google:** crea un **service account** con acceso a la app en Play Console y apunta
  `GOOGLE_SERVICE_ACCOUNT_PATH` al JSON. Pon `GOOGLE_PLAY_ENABLED=true` y
  `GOOGLE_PLAY_PACKAGE_NAME`. Configura RTDN vía Pub/Sub con push al endpoint
  `/api/billing/webhooks/google?token=<GOOGLE_RTDN_VERIFICATION_TOKEN>`.

> En **desarrollo**, si Apple/Google no están configurados, la validación **decodifica el
> comprobante sin verificar la firma** (con aviso en consola) para poder probar el flujo.
> En producción (`NODE_ENV=production`) exige la verificación real.

---

## Estructura

```
backend/
├── prisma/
│   ├── schema.prisma        # esquema completo (todas las funciones)
│   └── seed.ts
├── src/
│   ├── index.ts             # arranque
│   ├── app.ts               # express + middlewares
│   ├── routes.ts            # montaje de routers
│   ├── config/env.ts        # variables de entorno tipadas
│   ├── lib/                 # prisma, jwt, errors, asyncHandler
│   ├── middleware/          # auth, validate (zod), errores
│   └── modules/
│       ├── auth/            # email + Google + Apple + refresh
│       ├── users/
│       ├── pets/            # + control de acceso por membresía
│       ├── feeding/
│       ├── walks/
│       └── billing/         # IAP Apple/Google + webhooks
└── docker-compose.yml       # PostgreSQL
```

## Scripts

```bash
npm run dev            # desarrollo con recarga (tsx watch)
npm run build          # compila a dist/
npm start              # ejecuta dist/
npm run typecheck      # tsc --noEmit
npm run prisma:migrate # migraciones (dev)
npm run prisma:studio  # explorador de la BD
npm run seed           # datos de ejemplo (tips)
```
