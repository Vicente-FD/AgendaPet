# Agenda Pet

Aplicación móvil híbrida **Android/iOS** para organizar recordatorios y el cuidado de mascotas.

**Autores:** Vicente FD, Mauro Castro Lazcano  
**Repositorio:** [github.com/Vicente-FD/AgendaPet](https://github.com/Vicente-FD/AgendaPet)

---

## Descripción

Agenda Pet permite a dueños de mascotas llevar un registro de baños, vacunas, medicinas y servicios veterinarios. El proyecto está en **Fase 1 (Frontend / UI-UX)**: interfaces visuales, navegación y estilos con **datos mockeados**, sin backend real.

Stack principal: **Flutter** + **Dart**, un solo código para Android e iOS (motor de renderizado Impeller por defecto en móvil).

---

## Historial de commits

### `chore: init Flutter project - UI Phase` (commit inicial)

Configuración base del proyecto:

| Área | Qué se hizo |
|------|-------------|
| **Proyecto** | `flutter create` con org `com.agendapet` y nombre `agenda_pet` |
| **Plataformas** | Carpetas nativas `android/` e `ios/` para build híbrido |
| **Dependencias** | `go_router`, `google_fonts`, `flutter_svg`, `flutter_lints` |
| **Arquitectura** | Estructura feature-driven en `lib/core`, `lib/shared`, `lib/features` |
| **Tema** | Material 3, paleta verde institucional (`#43A047`), botones redondeados, tarjetas sin elevación |
| **Linting** | `prefer_const_constructors`, `require_trailing_commas`, `avoid_print` |
| **Entrada** | `main.dart` con `MaterialApp.router` y ruta inicial a Onboarding |

### `feat: add Phase 1 UI screens, routing and shared components`

Pantallas y componentes de la Fase 1 UI:

- **Onboarding** — pantalla de bienvenida con CTA "¡Comenzar!"
- **Dashboard activo** — Home de María con acciones rápidas y recordatorios mock
- **Dashboard vacío** — Home de Ernesto sin mascotas (placeholder)
- **Perfil de mascota** — ficha de Carolina (placeholder)
- **Widgets compartidos** — logo, botones, tarjetas, barra inferior
- **Routing** — `go_router` con rutas nombradas y menú dev para previsualizar pantallas en debug
- **Mocks** — datos falsos de usuario, mascota y recordatorios en `lib/core/mocks/`

### `feat: add care category screens, calendar and pet profile tabs`

Nuevas pantallas de cuidado y mejoras al perfil:

| Área | Qué se hizo |
|------|-------------|
| **Agenda** | Calendario mensual con eventos por color, leyenda y lista del día seleccionado |
| **Vacunas** | Pantalla con listado mock de vacunas y desparasitación |
| **Medicinas** | Pantalla con tratamientos y dosis mock |
| **Servicios** | Pantalla con baños, peluquería y hospedaje mock |
| **Perfil de mascota** | Pestañas Perfil, Agenda e Historial con datos de Carolina |
| **Dashboard** | Acciones rápidas enlazadas a cada categoría |
| **Widgets** | `CategoryScreenLayout`, `CareItemCard`, `SegmentedTabs`, calendario |
| **Mocks** | `care_mock_data.dart` y `agenda_calendar_mock_data.dart` |

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
flutter run -d edge      # Web (Edge)
flutter run -d windows   # Escritorio Windows (requiere Visual Studio C++)
flutter run              # Emulador o dispositivo Android/iOS conectado
```

Durante el desarrollo: **`r`** hot reload · **`R`** hot restart.

---

## Rutas de la app

| Pantalla | Ruta | Persona (mock) |
|----------|------|----------------|
| Bienvenida | `/onboarding` | — |
| Home con mascotas | `/dashboard-active` | María |
| Home sin mascotas | `/dashboard-empty` | Ernesto |
| Perfil de mascota | `/pet-profile` | Carolina |
| Agenda (calendario) | `/agenda` | Carolina |
| Vacunas | `/vacunas` | Carolina |
| Medicinas | `/medicinas` | Carolina |
| Servicios | `/servicios` | Carolina |

En modo **debug** aparece un botón flotante (icono de ruta) para saltar entre pantallas sin navegar el flujo completo.

---

## Estructura del proyecto

```
lib/
├── main.dart                 # Arranque de la app
├── core/
│   ├── theme/                # Colores y estilos globales
│   ├── routing/              # Rutas y navegación
│   └── mocks/                # Datos de prueba
├── shared/widgets/           # Botones, tarjetas, pestañas, calendario
└── features/
    ├── onboarding/           # Bienvenida
    ├── dashboard_active/     # Home con mascotas
    ├── dashboard_empty/      # Home sin mascotas
    ├── pet_profile/          # Ficha con pestañas
    ├── agenda/               # Calendario mensual
    ├── vaccines/             # Vacunas
    ├── medicines/            # Medicinas
    └── services/             # Servicios
```

---

## Paleta de colores

| Token | Hex | Uso |
|-------|-----|-----|
| Primario | `#43A047` | Botones, marca, acentos |
| Fondo | `#FFFFFF` | Superficie principal |
| Tarjetas | `#F5F5F5` | Cards y contenedores |
| Calendario | `#1E88E5` | Acción Agenda |
| Vacunas | `#43A047` | Acción Vacunas |
| Medicinas | `#8E24AA` | Acción Medicinas |
| Servicios | `#F4511E` | Acción Servicios |

---

## Próximos pasos (fuera de Fase 1)

- Conectar backend / API real
- Formularios de alta de mascotas y recordatorios
- Notificaciones push
- Persistencia local (SQLite / Hive)
- Assets definitivos (ilustraciones SVG del diseño)
