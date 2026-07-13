# Agenda Pet — Estado del proyecto y roadmap

**Autores:** Vicente FD, Mauro Castro Lazcano  
**Repositorio:** [github.com/Vicente-FD/AgendaPet](https://github.com/Vicente-FD/AgendaPet)  
**Documento de referencia:** `docs/Agenda Pet Propuesta de Negocio y Técnica.pdf` (Plan detallado Fase 1)  
**Última actualización:** 12 de julio de 2026

---

## 1. Resumen ejecutivo

Agenda Pet es una aplicación móvil híbrida (**Android / iOS / Web**) para organizar el cuidado de mascotas: recordatorios, vacunas, medicinas, servicios, alimentación, paseos, crecimiento, documentos y familia compartida.

| Aspecto | Estado actual |
|---------|----------------|
| **Fase contractual (propuesta)** | **Fase 1 — UI/UX y Frontend** (8 jun – 12 jul 2026) |
| **Alcance técnico actual** | Frontend completo con **datos mock**; sin backend real |
| **Stack** | Flutter + Dart, `go_router`, Material 3, tipografía **Inter**, modo claro/oscuro |
| **Regla de producto** | Uso sencillo en **2 o 3 clics** (según propuesta Fase 1) |
| **Cierre Fase 1 (propuesta)** | Fecha de término: **12 de julio de 2026** |

La Fase 1 de la propuesta pedía **4 pantallas maquetadas** (bienvenida, dashboard vacío, dashboard activo, ficha de mascota) con datos mock. El repositorio **ya cumple ese núcleo** y además incorpora módulos adicionales de producto (paseos, alimentación, certificados, PRO, etc.) todavía en UI simulada.

---

## 2. Qué dice la propuesta (Fase 1)

Fuente: *Plan Detallado de Trabajo: Fase 1 (UI/UX y Frontend) — Agenda Pet*.

### 2.1 Marco temporal y entregable

| Ítem | Según propuesta |
|------|-----------------|
| Inicio | Lunes **8 de junio de 2026** |
| Término | Domingo **12 de julio de 2026** |
| Duración | 5 semanas |
| Tecnología | Flutter (código único iOS + Android) |
| Entregable de cierre | APK de pruebas Android + link TestFlight iOS, flujo interactivo de las 4 pantallas, **sin BD de Fase 2**, solo mocks |

### 2.2 Cronograma semanal (propuesta)

| Semana | Fechas | Foco |
|--------|--------|------|
| **1** | 8–14 jun | Setup, arquitectura, guía de estilos, componentes reutilizables |
| **2** | 15–21 jun | Onboarding / bienvenida (“¡Comenzar!”, ilustración, eslogan) |
| **3** | 22–28 jun | Dashboard vacío (Ernesto): acciones rápidas, “Todo al día”, agregar mascota |
| **4** | 29 jun – 5 jul | Dashboard activo (María): Carolina, recordatorios, notificaciones UI |
| **5** | 6–12 jul | Ficha de mascota (Perfil / Agenda / Historial) + QA visual |

### 2.3 Matriz de cierre Fase 1 (propuesta)

| Vista | Funcionalidades esperadas | Criterio |
|-------|---------------------------|----------|
| Bienvenida | Botón “¡Comenzar!”, imagen, eslogan | Fidedigno al diseño |
| Dashboard vacío | Header Ernesto, acciones rápidas, “Todo al día”, CTA agregar mascota | Fidedigno al diseño |
| Dashboard activo | Resumen Carolina, menú rápido, recordatorios Baño / Vacuna Rabia | Fidedigno al diseño |
| Ficha mascota | Foto, tabs Perfil/Agenda/Historial, recordatorios, “+ Añadir Recordatorio” | Fidedigno al diseño |

La validación de esta matriz cierra Fase 1 y habilita el hito de **Fase 2** (según el PDF).

---

## 3. Qué llevamos construido (código actual)

### 3.1 Cumplimiento del núcleo Fase 1

| Entregable propuesta | Estado en el repo |
|----------------------|-------------------|
| Setup Flutter + Git + estilos (verde `#43A047`, Inter, botones redondeados) | Hecho |
| Onboarding interactivo | Hecho (`/onboarding`) + login/registro mock |
| Dashboard vacío (Ernesto) | Hecho (`/dashboard-empty`) |
| Dashboard activo (María / Carolina) | Hecho (`/dashboard-active`) |
| Ficha mascota con tabs | Hecho (`/pet-profile`) |
| Datos mock (sin persistencia) | Hecho en todo el proyecto |
| Navegación entre pantallas | Hecho (`go_router` + shell inferior) |
| QA / smoke tests de layout | Hay `flutter test` + `flutter analyze` (README) |

### 3.2 Módulos de producto ya en UI (más allá de las 4 pantallas base)

Estos módulos **existen como pantallas y formularios**, con mocks. No implican backend.

#### Acceso y cuenta
- Onboarding animado → registro / login
- Login y registro (sociales simulados)
- Mi cuenta y Ajustes (modo oscuro, notificaciones, idioma — UI)
- Plan **PRO** (comparativa Free vs PRO, checkout simulado, éxito)
- Banner publicitario placeholder (solo Free)

#### Inicio y mascotas
- Selector multi-mascota, tip del día, recordatorios
- Lista “Mis mascotas”
- Perfil de mascota: foto editable, tabs Perfil / Agenda / Historial
- Enlaces desde perfil: crecimiento, eventos, familia, **certificados**

#### Cuidado
- Agenda (calendario mensual, colores, leyenda)
- Vacunas, Medicinas, Servicios
- **Alimentación** (saco, próxima compra, calculadora de ración)
- Formularios de alta: mascota, cita, recordatorio, vacuna, medicina, servicio, alimento

#### Certificados y documentos *(reciente)*
- Listado `/certificados` (carnet, vacuna, perro de compañía, microchip…)
- Alta `/agregar-certificado` (tipo, fecha, emisor, escaneo/foto, PDF simulado)
- En **Registrar vacuna**, si el estado es **Realizada**, se pide escanear/adjuntar el certificado

#### Paseos (estilo Strava — UI)
- Feed semanal, paseo en vivo (mapa estilizado), detalle con parciales
- Rol paseador en familia (mock)

#### Crecimiento y comunidad
- Historial de crecimiento (timeline, gráfico, antes/ahora, video resumen UI)
- Eventos significativos
- Tips de cuidado
- Familia compartida
- Centro de notificaciones (agrupado, mock)

### 3.3 Stack, tipografía y dependencias

| Paquete | Uso |
|---------|-----|
| Flutter / Dart `^3.12` | App multiplataforma |
| `go_router` | Rutas y shell de tabs |
| `google_fonts` | Tipografía **Inter** (`GoogleFonts.interTextTheme` en `app_theme.dart`) |
| `flutter_svg` | SVG |
| `image_picker` | Cámara / galería (bytes; web + móvil) |
| `flutter_lints` | Análisis estático |

**Tipografía:** toda la UI usa **Inter** de forma global vía tema. Si falla la descarga de Google Fonts en web, hay fallback al `textTheme` del sistema para evitar pantalla en blanco.

**No hay** (aún): cliente HTTP, Firebase/Supabase, auth real, pagos reales, push, `file_picker` productivo para PDF.

### 3.4 Arquitectura de carpetas

```
lib/
├── main.dart
├── core/
│   ├── theme/          # Colores, tema claro/oscuro, superficies
│   ├── routing/        # app_router + app_navigation
│   ├── state/          # AppSettings (tema + isPro)
│   ├── session/        # homeRoute mock (active vs empty)
│   ├── mocks/          # Todos los datos de prueba
│   └── utils/          # Fechas, image_picker helper
├── shared/widgets/     # Shell, forms, cards, animaciones, etc.
└── features/           # Un módulo por dominio (presentation/)
```

### 3.5 Navegación principal

**Shell inferior (tabs):** Inicio → Agenda → Perfil  
Implementado con `StatefulShellRoute` (`AppShell` + `AppBottomNav`).

**Flujo de entrada:** `/` → `/onboarding` → `/login` o `/registro` → `/dashboard-active`

Rutas destacadas (lista completa en `README.md` y `AppRoutes`):

| Área | Rutas |
|------|-------|
| Auth | `/onboarding`, `/login`, `/registro` |
| Home | `/dashboard-active`, `/dashboard-empty`, `/mis-mascotas` |
| Cuidado | `/agenda`, `/vacunas`, `/medicinas`, `/servicios`, `/alimentacion` |
| Documentos | `/certificados`, `/agregar-certificado` |
| Paseos | `/paseos`, `/paseo-activo`, `/paseo-detalle` |
| Extra | `/crecimiento`, `/eventos`, `/tips`, `/familia`, `/notificaciones` |
| Cuenta | `/mi-cuenta`, `/ajustes`, `/suscripcion`, `/pago` |

En **debug** hay menú flotante de rutas (`DevRouteMenu`).

### 3.6 Qué es real vs mock

| Real en dispositivo | Simulado / mock |
|---------------------|-----------------|
| UI, navegación, temas | Todos los datos de dominio |
| Cámara/galería (`image_picker`) | Auth y login social |
| Validación de formularios + snackbar | Persistencia al “Guardar” |
| Animaciones y layout | GPS / mapa real, push, pagos, AdMob, PDF real |

---

## 4. Cómo levantarlo en local

```bash
flutter pub get
.\run.ps1
# o:
flutter run -d web-server --profile --web-port=3000 --web-hostname=0.0.0.0
```

Abrir: **http://127.0.0.1:3000** o **http://localhost:3000**

> En Windows, `web-server` + **profile** evita la pantalla blanca típica del modo debug sin extensión Dart Debug / fallos DWDS con Edge.

También: `.vscode/launch.json` (Web Server / Edge :3000) y `dart.flutterRunAdditionalArgs` con puerto 3000.

```bash
flutter analyze   # debe quedar sin issues
flutter test      # smoke tests de pantallas (claro/oscuro)
```

---

## 5. Qué viene (roadmap)

### 5.1 Cierre inmediato de Fase 1 (propuesta → 12 jul 2026)

- [x] Núcleo de 4 pantallas + formularios + módulos UI adicionales en el repo
- [ ] Alineación visual fina con mockups del cliente (Ernesto / María / Carolina)
- [ ] QA en tamaños compactos y grandes (evitar overflows; en web un overflow puede verse como pantalla blanca)
- [ ] Empaquetado de prueba: **APK Android** + **TestFlight iOS** (flujo interactivo mock)
- [ ] Checklist formal de la matriz de 4 pantallas para aprobación y liberación de Fase 2

### 5.2 Fase 2 — Backend e infraestructura *(siguiente hito según propuesta)*

Alcance típico (alineado a README + lógica de producto; detalle contractual en el PDF de negocio):

| Tema | Trabajo esperado |
|------|------------------|
| **API / BD** | Backend real (p. ej. Supabase o similar): usuarios, mascotas, recordatorios, documentos |
| **Auth** | Login/registro reales (email + proveedores sociales) |
| **Persistencia** | Que “Guardar” en formularios escriba en BD; sync multi-dispositivo |
| **Storage** | Fotos y certificados (imagen/PDF) en almacenamiento cloud |
| **Push** | Notificaciones reales de recordatorios y familia |
| **Pagos** | Compras In-App / suscripción PRO real |
| **Ads** | AdMob (o equivalente) en plan Free |

### 5.3 Evolución de producto (post–Fase 1 UI)

Prioridades sugeridas una vez exista backend:

1. **Documentos / certificados** — persistir escaneos; OCR opcional; vincular certificado ↔ vacuna  
2. **Vacunas e historial clínico** — fechas de refuerzo, alertas de vencimiento  
3. **Familia y roles** — invitaciones reales, permisos dueño / familiar / paseador  
4. **Paseos** — GPS real, tracking, compartir ubicación en vivo  
5. **Alimentación** — stock y recordatorios de compra reales  
6. **Crecimiento** — generación real de collage/video mensual  
7. **Tips con IA** — personalizados por especie/edad (hoy son curados mock)  
8. **Assets definitivos** — ilustraciones y marca finales del diseño

### 5.4 Deuda técnica / mejoras de ingeniería

- Sustituir mocks por repositorios / capa de datos
- Persistencia local opcional (cache offline)
- `file_picker` real para PDF (hoy es simulado)
- CI: analyze + tests en cada PR
- Entornos (dev / staging / prod) y secretos fuera del repo

---

## 6. Personas y flujos mock actuales

| Persona | Rol en UI | Ruta / pantalla |
|---------|-----------|-----------------|
| Visitante | Onboarding | `/onboarding` |
| María | Dueña con mascota(s) | `/dashboard-active` |
| Ernesto | Sin mascotas / vacío | `/dashboard-empty` |
| Carolina | Mascota de ejemplo | `/pet-profile` + cuidado |

---

## 7. Paleta (referencia rápida)

| Token | Hex | Uso |
|-------|-----|-----|
| Primario | `#43A047` | Marca, CTAs |
| Agenda | `#1E88E5` | Calendario |
| Vacunas | `#43A047` | Vacunas |
| Medicinas | `#8E24AA` | Medicinas |
| Servicios | `#F4511E` | Servicios |
| Alimentación | `#FB8C00` | Feeding |
| Paseos | `#3D5AFE` / `#00B0FF` | Walks |
| Crecimiento | `#00897B` | Growth |
| Eventos | `#EC407A` | Memories |
| Familia | `#5E35B1` | Family |
| Certificados | `#546E7A` | Documentos |
| Tips / PRO | `#FFB300` | Tips y suscripción |

---

## 8. Conclusión

- **Fase 1 (propuesta):** núcleo de 4 pantallas + estilos + mocks → **cubierto** en el código. Fecha de término contractual: **12 de julio de 2026**; pendiente cierre formal (QA final, builds de prueba, aprobación cliente).  
- **Estado real del repo:** frontend **mucho más amplio** que el mínimo de Fase 1 (paseos, feeding, certificados con escaneo, vacunas con certificado si están realizadas, PRO, familia, etc.), siempre con datos simulados.  
- **Siguiente gran paso:** **Fase 2 — backend, auth, persistencia, storage de documentos, push y monetización real**, manteniendo la regla de producto de pocos clics.

Para detalle contractual, montos e hitos de pago, ver el PDF en `docs/`. Este Markdown describe el **estado técnico del repositorio** y el **roadmap de producto/ingeniería** alineado a esa propuesta.
