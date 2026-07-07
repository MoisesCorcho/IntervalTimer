# Interval Timer App

App Flutter para entrenamientos con intervalos. El proyecto sigue **Spec Driven Development (SDD)** —
ver `AGENTS.md` para instrucciones de uso con agentes de IA.

## Desarrollo

### Requisitos previos

| Herramienta | Version minima | Notas |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.29+ (Dart **3.12+**) | El proyecto declara `sdk: ^3.12.2` en `pubspec.yaml` |
| Git | cualquiera reciente | — |
| Android Studio / SDK | para correr en Android | Emulador o dispositivo fisico con depuracion USB |
| Xcode + CocoaPods | solo macOS, para iOS | Requerido para builds en iPhone/iPad |
| Visual Studio 2022 | solo Windows, para desktop | Workload "Desktop development with C++" |

Verificar que el entorno esta listo:

```bash
flutter doctor
```

`flutter doctor` debe mostrar al menos un dispositivo disponible (emulador, fisico o Windows desktop).

### Primer arranque

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd interval_timer

# 2. Instalar dependencias de Dart/Flutter
flutter pub get

# 3. Generar codigo (drift, freezed) — obligatorio antes del primer run
dart run build_runner build --delete-conflicting-outputs
```

### Correr la app

Listar dispositivos disponibles:

```bash
flutter devices
```

Ejecutar en el dispositivo por defecto:

```bash
flutter run
```

Ejecutar en una plataforma especifica:

```bash
flutter run -d windows    # Windows desktop
flutter run -d android    # Android (emulador o fisico)
flutter run -d chrome     # Web (experimental, no es target principal)
```

Modo debug con hot reload activo (por defecto). Atajos utiles durante `flutter run`:

| Tecla | Accion |
|---|---|
| `r` | Hot reload — recarga cambios en UI/logica sin reiniciar |
| `R` | Hot restart — reinicia el estado de la app |
| `q` | Salir |

Para un build de release en Android:

```bash
flutter run --release -d android
```

### Code generation

El proyecto usa `build_runner` para generar archivos de **drift** (base de datos) y **freezed** (modelos).
Regenerar despues de cambiar tablas drift, modelos freezed o anotaciones:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Modo watch (regenera automaticamente mientras desarrollas):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Tests y analisis estatico

```bash
flutter test              # Ejecutar todos los tests
flutter test test/ruta/al_test.dart   # Un archivo especifico
flutter analyze           # Linter y analisis estatico (flutter_lints)
```

### Limpiar cache y builds

Usar estos comandos cuando haya errores de compilacion extranos, dependencias desactualizadas o codigo
generado inconsistente.

**Limpieza ligera** (la mayoria de los casos):

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Limpieza de codigo generado** (si `build_runner` falla o genera archivos corruptos):

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Limpieza profunda** (cuando lo anterior no alcanza):

```bash
flutter clean
# Borrar caches locales del proyecto (PowerShell en Windows)
Remove-Item -Recurse -Force .dart_tool, build -ErrorAction SilentlyContinue
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Reparar cache global de paquetes** (ultimo recurso, tarda varios minutos):

```bash
flutter pub cache repair
flutter pub get
```

#### Cuando limpiar

| Situacion | Comando recomendado |
|---|---|
| Cambiaste `pubspec.yaml` o version de Flutter | `flutter clean` + `flutter pub get` |
| Modificaste tablas drift o modelos freezed | `build_runner build --delete-conflicting-outputs` |
| Hot reload no refleja cambios estructurales | Hot restart (`R`) o `flutter run` de nuevo |
| Errores de plugins nativos (sqlite3, etc.) | Limpieza ligera completa |
| Errores persistentes de dependencias | Limpieza profunda o `pub cache repair` |

### Estructura del codigo

```
lib/
  app/                  # Router (go_router), shell de la app
  core/                 # Constantes, tema, utilidades transversales
  data/
    local/              # Tablas drift, database.dart
    models/             # Entidades de dominio (freezed)
    repositories/       # Acceso a persistencia
  features/<feature>/   # Logica y UI por feature (application/, presentation/)
  shared/widgets/       # Widgets reutilizables
test/                   # Tests unitarios y de widget (espejo de lib/)
specs/                  # Especificaciones SDD (ver seccion siguiente)
```

Convenciones de branches y commits: `feature/<NN>-<slug>`, `feat(F01): descripcion` — ver
`specs/_global/03-conventions.md`.

---

## Specs (SDD)

## Estructura

```
specs/
  _global/                          <- Documentos transversales (leer primero)
    00-how-to-use-these-specs.md
    01-vision-and-principles.md
    02-architecture-and-structure.md
    03-conventions.md
    04-design-system.md
    05-data-model.md
    06-roadmap-and-dependencies.md
  features/                          <- Una carpeta por feature (31 features)
    01-interval-timer-core/
      requirements.md
      design.md
      tasks.md
    ... (30 mas)
AGENTS.md                            <- Punto de entrada para agentes de IA
```

## Indice rapido de features

| ID | Feature | Fase | Prerequisitos |
|---|---|---|---|
| F01 | [Interval Timer Core](../specs/features/01-interval-timer-core/requirements.md) | Fase 0 · Fundacion | - |
| F02 | [Voz: Cuenta Regresiva y Anuncios](../specs/features/02-voice-countdown-announcements/requirements.md) | Fase 0 · Fundacion | F01 |
| F03 | [Sesiones Preestablecidas con Animacion/Video](../specs/features/03-preset-workout-sessions/requirements.md) | Fase 0 · Fundacion | F01 |
| F04 | [Calendario e Historial de Sesiones](../specs/features/04-workout-calendar-history/requirements.md) | Fase 0 · Fundacion | F01 |
| F05 | [Editor de Rutinas Propias](../specs/features/05-custom-routine-builder/requirements.md) | Fase 1 · Personalizacion | F01, F03 |
| F06 | [Capa Pro / Compras In-App](../specs/features/06-pro-tier-iap/requirements.md) | Fase 1 · Personalizacion | F01 |
| F07 | [Seleccion de Voces (Sistema y Premium)](../specs/features/07-multiple-tts-voices/requirements.md) | Fase 1 · Personalizacion | F02 |
| F08 | [Repeticion de Circuitos (Rounds)](../specs/features/08-circuit-repetition-rounds/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01, F05 |
| F09 | [Progresion Automatica](../specs/features/09-automatic-progression/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F05, F04 |
| F10 | [Modo por Repeticiones](../specs/features/10-rep-based-mode/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01 |
| F11 | [Ajuste Rapido de Intensidad](../specs/features/11-quick-intensity-scaling/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01, F05 |
| F12 | [Estadisticas y Progreso](../specs/features/12-statistics-progress/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F13 | [Logros y Badges](../specs/features/13-achievements-badges/requirements.md) | Fase 3 · Seguimiento y Motivacion | F12 |
| F14 | [Recordatorios y Notificaciones](../specs/features/14-reminders-notifications/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F15 | [Registro de Peso y Medidas](../specs/features/15-body-measurements-tracking/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F16 | [Compartir Resumen de Sesion](../specs/features/16-session-summary-sharing/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04, F12 |
| F17 | [Integracion de Musica / Audio Ducking](../specs/features/17-background-music-ducking/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F18 | [Vibracion como Feedback](../specs/features/18-vibration-feedback/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F19 | [Pantalla Siempre Encendida](../specs/features/19-always-on-screen/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F20 | [Widget de Pantalla de Bloqueo / Notificacion Persistente](../specs/features/20-lock-screen-widget/requirements.md) | Fase 4 · Audio y Experiencia | F01, F19 |
| F21 | [Soporte para Smartwatch (Wear OS / Apple Watch)](../specs/features/21-smartwatch-support/requirements.md) | Fase 4 · Audio y Experiencia (Futuro) | F01, F19 |
| F22 | [Filtros de Rutinas](../specs/features/22-routine-filters/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03 |
| F23 | [Modo Sin Video](../specs/features/23-no-video-mode/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03 |
| F24 | [Favoritos](../specs/features/24-favorites/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03, F05 |
| F25 | [Compartir Rutinas con Otros Usuarios](../specs/features/25-routine-sharing/requirements.md) | Fase 6 · Social (Futuro) | F05, F06 |
| F26 | [Retos Grupales](../specs/features/26-group-challenges/requirements.md) | Fase 6 · Social (Futuro) | F25, F12 |
| F27 | [Modo Oscuro](../specs/features/27-dark-mode/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F28 | [Multilenguaje (i18n)](../specs/features/28-multi-language-i18n/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F29 | [Backup y Exportacion de Datos](../specs/features/29-backup-export/requirements.md) | Fase 7 · Calidad y Pulido | F04, F12 |
| F30 | [Onboarding](../specs/features/30-onboarding/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F31 | [Accesibilidad](../specs/features/31-accessibility/requirements.md) | Fase 7 · Calidad y Pulido | F01 |

## Por donde empezar

1. `specs/_global/00-how-to-use-these-specs.md`
2. `specs/_global/01-vision-and-principles.md`
3. `specs/features/01-interval-timer-core/requirements.md` (primera feature a implementar)
