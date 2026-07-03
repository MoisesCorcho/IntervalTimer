# Arquitectura y Estructura del Proyecto

## Stack general

- **Framework:** Flutter (Android + iOS desde un solo codebase).
- **Gestion de estado:** Riverpod (recomendado) o Bloc - elegir UNO y ser consistente en todo el proyecto.
- **Persistencia local:** `drift` (SQLite tipado), preferido sobre `isar` por madurez y comunidad activa
  para queries relacionales (calendario/historial F04, estadisticas F12).
- **Backend (solo cuando aplica):** Firebase o Supabase como BaaS para las pocas features que lo requieren.

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

## Estructura de carpetas (Flutter)

```
lib/
  main.dart
  app/
    app.dart
    router.dart
  core/
    theme/                   # F27
    l10n/                    # F28
    constants/
    utils/
  data/
    local/
      database.dart          # drift database
      daos/
    repositories/
    models/                   # Interval, Routine, Block, SessionLog, etc.
  features/
    timer/                   # F01
    voice/                   # F02, F07
    calendar_history/        # F04
    preset_routines/         # F03
    routine_builder/         # F05
    pro/                     # F06
    stats/                   # F12
    achievements/            # F13
    reminders/                # F14
    body_tracking/            # F15
    sharing/                  # F16, F25
    settings/                 # F19, F23, F27, F28, F31
    onboarding/                # F30
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
  application/       # Controllers/Providers
  domain/             # (opcional) logica de negocio pura
```

No todas las features necesitan las 3 capas - usar juicio, no aplicar la plantilla completa por dogma.
