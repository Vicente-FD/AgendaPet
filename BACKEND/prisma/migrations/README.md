# Migraciones

`0_init` es la foto del esquema completo, generada con `prisma migrate diff`.

## Base de datos nueva (producción o staging)

```bash
npx prisma migrate deploy
```

## Base que ya existe y se creó con `prisma db push`

La tabla ya está creada, así que solo hay que marcar la migración como aplicada:

```bash
npx prisma migrate resolve --applied 0_init   # npm run prisma:baseline
npx prisma migrate status                      # debe decir "up to date"
```

## Cambios posteriores al esquema

1. Edita `prisma/schema.prisma`.
2. Crea la migración contra un PostgreSQL local:
   `npx prisma migrate dev --name describe_el_cambio`
3. Súbela al repositorio y aplícala en producción con `npx prisma migrate deploy`
   desde la integración continua.

No volver a usar `prisma db push` fuera de pruebas desechables: no deja
historial y puede borrar datos.
