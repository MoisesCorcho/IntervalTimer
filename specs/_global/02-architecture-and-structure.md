# Arquitectura y Estructura del Proyecto

## Stack general

- **Framework:** Flutter (Android + iOS desde un solo codebase).
- **Gestion de estado:** **Riverpod** (`flutter_riverpod`) — unico enfoque en todo el proyecto. No usar Bloc ni otros frameworks de estado para logica de negocio.
- **Navegacion:** `go_router` centralizado en `app/router.dart`.
- **Persistencia local:** `drift` (SQLite tipado) — unico motor de base de datos local. No usar `isar` ni almacenamiento JSON como fuente primaria de entidades de usuario.
- **Code generation:** `build_runner` para drift; `freezed` + `sealed` para union types (`RoutineItem`).
- **Backend (solo cuando aplica):** Firebase o Supabase como BaaS para las pocas features que lo requieren.

### Criterio Firebase vs Supabase

| Criterio | Preferir Firebase | Preferir Supabase |
|---|---|---|
| Ecosistema unificado (Auth + Storage + Functions) | Si | No |
| Queries SQL relacionales en remoto | No | Si |
| Equipo con experiencia Postgres | No | Si |

Decidir al implementar F25/F26; hasta entonces, no agregar dependencias de BaaS.

## Dependencias base (F01 en adelante)

| Paquete | Uso |
|---|---|
| `flutter_riverpod` | Estado global y por feature |
| `go_router` | Navegacion declarativa |
| `drift` + `sqlite3_flutter_libs` | Persistencia local |
| `uuid` | IDs de entidades (UUID v4 string) |
| `freezed` + `freezed_annotation` | Modelos inmutables y union types |
| `flutter_colorpicker` ^1.1.0 | Selector de color HSV (F01) |
| `flutter_tts` ^4.2.5 | TTS nativo del sistema (F02; multi-voz/premium en F07) |

Dev: `drift_dev`, `build_runner`, `freezed`, `flutter_test`, `fake_async`.

## Por que NO hay backend propio (Laravel/FastAPI) en v1

La mayoria de las features son 100% locales (temporizador, colores, historial, catalogo de rutinas
empaquetado como assets). Montar un backend dedicado desde el inicio agrega costo de infraestructura y
mantenimiento sin beneficio real hasta que existan features que genuinamente lo requieran.

## Backend minimo (cuando se necesite)

1. **Voces TTS premium (F07):** una Cloud Function (Firebase Functions) que recibe texto, llama a la API
   del proveedor de voz (con la API key segura del lado del servidor) y devuelve el audio. Es un proxy de
   una sola responsabilidad, no un backend completo.
2. **Compartir rutinas / retos grupales (F25, F26):** aqui si se requiere un BaaS real (Firestore/Postgres
   + Auth). Recomendado: Firebase (todo en un ecosistema) o Supabase (mejor si se prefiere SQL/Postgres).

Si el producto crece hacia necesitar un backend de administracion de contenido robusto (equipo no tecnico
subiendo rutinas), ahi si se evaluaria Laravel (con Filament/Nova) como reemplazo del enfoque BaaS.

## Ubicacion de codigo

Regla de oro: **entidades compartidas en `data/`, logica de feature en `features/<f>/`**.

```
data/models/              → entidades de dominio compartidas (Interval, Routine, SessionLog, etc.)
data/local/               → tablas drift, DAOs, database.dart, mappers row ↔ domain
data/repositories/        → implementaciones de persistencia (RoutineRepository, etc.)
features/<f>/application/ → Notifiers/Providers especificos de la feature (ej. TimerController)
features/<f>/presentation/→ screens y widgets propios de la feature
features/<f>/domain/      → (opcional) logica pura sin dependencias Flutter
shared/widgets/           → componentes UI reutilizables (CountdownRing, IntervalColorBadge, etc.)
core/theme/               → ThemeData (F27 implementa; tokens definidos en 04-design-system.md)
core/constants/           → ui_strings.dart y otras constantes
core/utils/               → utilidades transversales (contrastTextColor, parsers mm:ss, etc.)
```

No duplicar modelos de dominio dentro de `features/` si ya existen en `data/models/`.

### Reutilizacion y limites entre capas (resumen)

Detalle operativo en `_global/03-conventions.md` (seccion *Calidad de codigo y reutilizacion*). Resumen arquitectonico:

| Ubicacion | Contiene | No contiene |
|---|---|---|
| `shared/widgets/` | UI reutilizable entre features | Logica de negocio, acceso a drift |
| `features/<f>/presentation/` | Screens y widgets **solo** de esa feature | Repositorios, SQL, reglas de dominio |
| `features/<f>/application/` | Notifiers/providers de la feature | Widgets de otras features |
| `data/` | Modelos, DAOs, repositorios | UI |
| `core/` | Theme, utils, strings, constantes | Features concretas |

- **Preferir** componentes de `shared/widgets/` y utils de `core/` antes de crear duplicados.
- **Prohibido** importar widgets de `features/A/` desde `features/B/`. Si hace falta compartir UI → `shared/widgets/`.
- **Prohibido** que `presentation/` dependa de tipos generados por drift; solo dominio + providers.

## Estructura de carpetas (Flutter)

```
lib/
  main.dart                 → runApp(ProviderScope(child: App()))
  app/
    app.dart                → MaterialApp.router + tema
    router.dart             → GoRouter, rutas por feature
  core/
    theme/                  # F27
    l10n/                   # F28
    constants/              # ui_strings.dart (pre-F28)
    utils/
  data/
    local/
      database.dart
      daos/
      tables/
    repositories/
    models/
  features/
    timer/                  # F01
    voice/                  # F02, F07
    preset_routines/        # F03
    calendar_history/       # F04
    routine_builder/        # F05
    workout_builder/        # F32
    pro/                    # F06
    circuit_rounds/         # F08
    progression/            # F09
    rep_mode/               # F10
    intensity_scaling/      # F11
    stats/                  # F12
    achievements/           # F13
    reminders/              # F14
    body_tracking/          # F15
    sharing/                # F16, F25, F26
    music_ducking/          # F17
    vibration/              # F18
    always_on/              # F19
    lock_screen/            # F20
    smartwatch/             # F21 (futuro)
    routine_filters/        # F22
    no_video_mode/          # F23
    favorites/              # F24
    backup_export/          # F29
    onboarding/             # F30
    settings/               # F27, F28, F31 (pantallas de ajustes compartidas)
  shared/
    widgets/
test/
  (misma estructura que lib/, espejada)
```

**Regla:** cada carpeta bajo `features/` corresponde a una o varias specs en `specs/features/`.

## Capas dentro de cada feature

```
features/<feature>/
  presentation/     # Widgets, screens
  application/      # Controllers/Providers (Riverpod Notifier / AsyncNotifier)
  domain/           # (opcional) logica de negocio pura
```

No todas las features necesitan las 3 capas — usar juicio, no aplicar la plantilla completa por dogma.

## Arranque de la app

```dart
void main() {
  runApp(const ProviderScope(child: App()));
}
```

`App` expone `MaterialApp.router` con `routerConfig` de `go_router`. Los providers de repositorios y
servicios se declaran en `application/` o en un archivo `providers.dart` por feature.

## Contratos entre features

Las features se comunican mediante **streams o providers observables**, no imports directos de widgets entre features.

| Evento / contrato | Emisor | Consumidores | Payload minimo |
|---|---|---|---|
| `SessionCompletedEvent` | `TimerController` (F01) | F04, F12, F13 | `routineId`, `completedAt`, `totalElapsedSeconds`, `intervalCount` |
| `SessionCancelledEvent` | `TimerController` (F01) | F04 | `routineId`, `cancelledAt`, `elapsedSeconds`, `completedIntervalCount` |

Los consumidores se suscriben via `ref.listen` o stream expuesto por el provider — nunca acoplar UI de F04 al widget de ejecucion de F01.

## Ciclo de vida y background (F01 R5, F19, F20)

- Registrar `WidgetsBindingObserver` en el controller o servicio que gestiona el timer activo.
- Al pasar a `AppLifecycleState.paused` / `resumed`, recalcular `remainingMs` desde timestamps (no desde ticks acumulados).
- El patron vive en `features/timer/application/`; otras features no reimplementan logica de tiempo.

## Excepciones de persistencia

Ver detalle en `05-data-model.md`. Resumen:

| Tipo de dato | Almacenamiento |
|---|---|
| Rutinas e intervalos del usuario | drift |
| Catalogo de presets (F03) | JSON en `assets/routines/` (read-only, versionado en build) |
| Preferencias ligeras (tema, flags) | `shared_preferences` (F19, F23, F27) |
| Historial de sesiones (F04+) | drift |