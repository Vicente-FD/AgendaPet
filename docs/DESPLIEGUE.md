# Despliegue de Agenda Pet

Guía para dejar la API y la base de datos en producción. Todo lo que aquí
aparece como `<...>` lo completas tú.

Arquitectura: **app → HTTPS → API (Fly.io, São Paulo) → Supabase Postgres
(São Paulo)**. El teléfono nunca habla directo con la base de datos.

---

## 1. Base de datos: proyecto Supabase de producción

1. En supabase.com, crear un proyecto nuevo en la región **South America
   (São Paulo) · `sa-east-1`**. Desde Santiago responde en ~46 ms, contra
   ~167 ms de Oregón. La región **no se puede cambiar** después.
2. Plan **Pro (USD 25/mes)**: el plan gratuito se pausa tras una semana sin
   uso y no tiene respaldos.
3. En *Settings → Database*, copiar la cadena de conexión del **pooler en modo
   sesión** (puerto 5432) y guardar la contraseña.
4. En *Settings → API*, desactivar la **Data API** si no se usa el cliente de
   Supabase: la app solo habla con nuestra API, y una tabla expuesta sin RLS
   se puede leer y escribir con la clave pública del proyecto.
5. En *Storage*, crear un bucket **público** llamado `pets` para las fotos.
6. En *Settings → Database → Network restrictions*, permitir solo las IP de
   salida de la API (en Fly: `fly ips list`).

## 2. Aplicar el esquema

```bash
cd BACKEND
export DATABASE_URL="<cadena del pooler en modo sesión>"
npx prisma migrate deploy      # base nueva: crea las 16 tablas
npx prisma migrate status      # debe decir "up to date"
npx prisma db seed             # tips iniciales (opcional)
```

Si la base ya existía porque se creó con `db push`, marcar la migración como
aplicada en vez de volver a crearla:

```bash
npm run prisma:baseline
```

## 3. API en Fly.io

```bash
fly auth login
cd BACKEND
fly launch --no-deploy            # usa el fly.toml de este repositorio
```

Cargar los secretos (no van en el repositorio):

```bash
fly secrets set \
  DATABASE_URL="<cadena del pooler>" \
  DIRECT_URL="<la misma cadena>" \
  JWT_ACCESS_SECRET="$(openssl rand -hex 32)" \
  JWT_REFRESH_SECRET="$(openssl rand -hex 32)" \
  CORS_ORIGINS="https://miagendapet.cl" \
  SUPABASE_URL="https://<ref>.supabase.co" \
  SUPABASE_SERVICE_ROLE_KEY="<service role key>" \
  SUPABASE_BUCKET="pets"
```

```bash
fly deploy
curl https://<app>.fly.dev/api/health      # {"status":"ok"}
```

> `ALLOW_UNVERIFIED_IAP` **no** se define en producción: sin esa variable, la
> API rechaza cualquier compra que no pueda verificar contra Apple o Google.

### Alternativa: Google Cloud Run

Tiene región en Santiago (`southamerica-west1`) y capa gratuita.

```bash
gcloud run deploy agendapet-api \
  --source BACKEND \
  --region southamerica-west1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production \
  --set-secrets DATABASE_URL=agendapet-db:latest,JWT_ACCESS_SECRET=agendapet-jwt:latest
```

## 4. Dominio

1. En NIC Chile, apuntar `api.miagendapet.cl` al proveedor elegido
   (`fly certs add api.miagendapet.cl` entrega los registros DNS).
2. El certificado HTTPS lo emiten Fly o Cloud Run automáticamente.
3. Dejar `CORS_ORIGINS` con el dominio del sitio web, no con `*`.

## 5. Compilar la app contra producción

```bash
flutter build appbundle --release \
  --dart-define=USE_BACKEND=true \
  --dart-define=API_BASE_URL=https://api.miagendapet.cl/api
```

Para iOS, `flutter build ipa` con los mismos `--dart-define`.

## 6. Checklist antes de abrir al público

- [ ] `curl https://api.miagendapet.cl/api/health` responde `{"status":"ok"}`.
- [ ] `npx prisma migrate status` dice "up to date".
- [ ] Crear una cuenta desde la app y verificar que la mascota queda guardada.
- [ ] Respaldos diarios activos en Supabase (incluidos en el plan Pro).
- [ ] Secretos solo en el gestor del proveedor, nunca en el repositorio.
- [ ] Monitoreo de errores conectado (Sentry o el panel del proveedor).
- [ ] Probar el borrado de cuenta de punta a punta.

## 7. Costos mensuales

| Servicio | Plan | USD/mes |
|---|---|---|
| Supabase (base de datos + fotos) | Pro | 25 |
| API en Fly.io (São Paulo) | 2 × 512 MB | ~8–14 |
| Dominio `.cl` | anual (CLP 9.990) | ~0,9 |
| **Total** | | **≈ 35–40** |
