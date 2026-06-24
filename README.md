# Agenda Pet

Aplicación móvil híbrida **Android/iOS** (y web) para organizar recordatorios y el cuidado de mascotas.

**Autores:** Vicente FD, Mauro Castro Lazcano  
**Repositorio:** [github.com/Vicente-FD/AgendaPet](https://github.com/Vicente-FD/AgendaPet)

---

## Descripción

Agenda Pet permite a dueños de mascotas llevar un registro de baños, vacunas, medicinas y servicios veterinarios, además de guardar el crecimiento y los recuerdos de cada mascota.

El proyecto está en **fase de Frontend (UI/UX)**: interfaces visuales, navegación, estado de la app y estilos con **datos mockeados**, sin backend real (pagos, autenticación y notificaciones están **simulados**).

Stack principal: **Flutter** + **Dart**, un solo código para Android, iOS y web (motor de renderizado Impeller por defecto en móvil).

---

## Funcionalidades

**Acceso y cuenta**
- Onboarding animado con enlace a registro / inicio de sesión
- Login y registro (mock, con accesos sociales simulados)
- Perfil de usuario y **Ajustes** (modo oscuro, notificaciones, idioma)

**Inicio y mascotas**
- Dashboard con **selector multi-mascota**, tarjeta de estado, tip del día y recordatorios
- Lista **"Mis mascotas"** y dashboard vacío ("Todo al día") para usuarios nuevos
- Perfil de mascota con pestañas **Perfil / Agenda / Historial** y **foto editable**

**Cuidado**
- Agenda con calendario mensual, eventos por color y leyenda
- Pantallas de **Vacunas, Medicinas y Servicios**
- Formularios de alta (mascota, cita, recordatorio, vacuna, medicina, servicio)

**Crecimiento y recuerdos**
- **Historial de Crecimiento**: línea de tiempo con fotos, peso y notas, **gráfico de peso**, comparador **Antes/Ahora** y **video resumen** ("Mi mascota a través del tiempo")
- **Eventos significativos** (cumpleaños, primeras veces…)
- **Tips** de cuidado curados (p. ej. cuándo esterilizar)
- **Familia compartida**: varios miembros administran la misma mascota
- **Centro de notificaciones** agrupado (crecimiento, recuerdos, salud, día a día)

**Monetización (simulada)**
- **Plan PRO**: comparativa Free vs PRO, checkout simulado (tarjeta, Apple/Google Pay) y pantalla de éxito
- **Banner publicitario (placeholder AdMob)** visible solo en plan Free

**Experiencia**
- **Modo oscuro** real (conmutable en Ajustes)
- **Subida de fotos** con `image_picker` (galería/cámara, vía bytes — funciona en web y móvil)
- **Micro-animaciones**: feedback al pulsar tarjetas, entradas escalonadas, contadores animados, gráfico que se dibuja y check de éxito con rebote

---

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable)
- Para móvil: Android Studio y/o Xcode
- Para desarrollo rápido en PC: Microsoft Edge o Chrome

```bash
flutter doctor
```

---

## Ejecutar en local

```bash
flutter pub get
flutter run -d chrome                                   # Web (Chrome)
flutter run -d web-server --web-port=3000               # Web sin depurador (abre http://localhost:3000)
flutter run -d windows                                  # Escritorio Windows (requiere Visual Studio C++)
flutter run                                             # Emulador o dispositivo Android/iOS conectado
```

> Si `flutter run -d edge`/`chrome` falla al conectar el depurador (DWDS), usa el dispositivo `web-server` y abre `http://localhost:3000` manualmente.

Durante el desarrollo: **`r`** hot reload · **`R`** hot restart.

---

## Pruebas y análisis

```bash
flutter analyze        # análisis estático (debe quedar sin issues)
flutter test           # smoke tests de todas las pantallas + navegación
```

Los smoke tests renderizan cada pantalla a ancho de móvil (390×844), en claro y oscuro, para detectar desbordes de layout (que en Flutter web dejan la pantalla en blanco).

---

## Rutas de la app

**Principales**

| Pantalla | Ruta |
|----------|------|
| Bienvenida | `/onboarding` |
| Login / Registro | `/login` · `/registro` |
| Home con mascotas | `/dashboard-active` |
| Home sin mascotas | `/dashboard-empty` |
| Mis mascotas | `/mis-mascotas` |
| Perfil de mascota | `/pet-profile` |

**Cuidado y agenda**

| Pantalla | Ruta |
|----------|------|
| Agenda (calendario) | `/agenda` |
| Vacunas / Medicinas / Servicios | `/vacunas` · `/medicinas` · `/servicios` |
| Formularios de alta | `/agregar-cita` · `/agregar-vacuna` · `/agregar-medicina` · `/agregar-servicio` · `/agregar-mascota` · `/agregar-recordatorio` |

**Crecimiento, recuerdos y más**

| Pantalla | Ruta |
|----------|------|
| Historial de crecimiento | `/crecimiento` (+ `/agregar-crecimiento`) |
| Eventos significativos | `/eventos` (+ `/agregar-evento`) |
| Tips | `/tips` |
| Familia compartida | `/familia` |
| Notificaciones | `/notificaciones` |

**Cuenta y suscripción**

| Pantalla | Ruta |
|----------|------|
| Mi cuenta | `/mi-cuenta` |
| Ajustes | `/ajustes` |
| Suscripción PRO | `/suscripcion` |
| Pago / checkout | `/pago` |
| Suscripción exitosa | `/suscripcion-exito` |

En modo **debug** aparece un botón flotante (icono de ruta) para saltar entre todas las pantallas sin navegar el flujo completo.

---

## Estructura del proyecto

```
lib/
├── main.dart                 # Arranque de la app (tema dinámico claro/oscuro)
├── core/
│   ├── theme/                # Colores, tema y superficies sensibles al modo
│   ├── routing/              # Rutas y navegación
│   ├── state/                # AppSettings (modo oscuro + plan PRO)
│   ├── mocks/                # Datos de prueba
│   └── utils/                # Helpers (selector de imágenes, fechas)
├── shared/widgets/           # Botones, tarjetas, avatar, animaciones, banner, etc.
└── features/
    ├── onboarding/           # Bienvenida
    ├── auth/                 # Login y registro
    ├── account/              # Perfil de usuario
    ├── settings/             # Ajustes (modo oscuro, plan)
    ├── dashboard_active/     # Home con mascotas
    ├── dashboard_empty/      # Home sin mascotas
    ├── pets/                 # Lista "Mis mascotas"
    ├── pet_profile/          # Ficha con pestañas
    ├── agenda/               # Calendario mensual
    ├── vaccines/ medicines/ services/
    ├── growth/               # Historial de crecimiento
    ├── events/               # Eventos significativos
    ├── tips/                 # Tips de cuidado
    ├── family/               # Familia compartida
    ├── notifications/        # Centro de notificaciones
    ├── subscription/         # Plan PRO + checkout simulado
    └── forms/                # Formularios de alta
```

---

## Paleta de colores

| Token | Hex | Uso |
|-------|-----|-----|
| Primario | `#43A047` | Botones, marca, acentos |
| Primario oscuro | `#2E7D32` | Degradados |
| Calendario | `#1E88E5` | Acción Agenda |
| Vacunas | `#43A047` | Acción Vacunas |
| Medicinas | `#8E24AA` | Acción Medicinas |
| Servicios | `#F4511E` | Acción Servicios |
| Crecimiento | `#00897B` | Historial de crecimiento |
| Recuerdos | `#EC407A` | Eventos significativos |
| Familia | `#5E35B1` | Familia compartida |
| Tips / PRO | `#FFB300` | Consejos y plan PRO |
| Texto secundario | `#757575` | Texto tenue (claro y oscuro) |
| Superficies oscuras | `#121212` · `#1E1E1E` · `#2A2A2A` | Fondo y tarjetas en modo oscuro |

---

## Estado y próximos pasos

Hecho en frontend (con datos mock): navegación completa, modo oscuro, subida de fotos, historial de crecimiento, suscripción PRO simulada, familia compartida, tips y notificaciones.

Pendiente (requiere backend / infraestructura):

- Conectar backend / API real (p. ej. Supabase) y persistencia
- Autenticación real y compras In-App (AdMob / App Store / Play Store)
- Notificaciones push reales
- Generación real del video/collage mensual y tips con IA
- Assets definitivos (ilustraciones del diseño)
```

---

## Dependencias

`go_router` · `google_fonts` · `flutter_svg` · `image_picker` · `flutter_lints`
