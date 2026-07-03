# Modelo de Datos Global

Este documento consolida las entidades que se van agregando a lo largo de las features. Cada feature
que introduce o modifica una entidad debe reflejarlo aqui ademas de en su propio `design.md`.

## Entidades principales (por feature de origen)

| Entidad | Origen | Descripcion breve |
|---|---|---|
| `Interval` | F01 | Unidad basica: nombre, duracion, color, tipo. |
| `Routine` | F01 | Coleccion ordenada de `RoutineItem` (intervalos y/o bloques). |
| `Block` | F08 | Agrupacion de intervalos con numero de repeticiones. |
| `Exercise` | F03 | Ejercicio con metadata y referencia a media (Lottie/video/imagen). |
| `PresetRoutine` | F03 | Rutina prediseñada con categoria y ejercicios asociados. |
| `SessionLog` | F04 | Registro de una sesion ejecutada (completa o abortada). |
| `ProgressionPlan` / `WeekAdjustment` | F09 | Plan de incremento automatico de dificultad. |
| `Achievement` / `UnlockedAchievement` | F13 | Catalogo de logros y su estado de desbloqueo. |
| `Reminder` | F14 | Configuracion de notificaciones recurrentes. |
| `BodyMeasurement` | F15 | Registro de peso/medidas en el tiempo. |
| `FavoriteRoutine` | F24 | Marca de rutina favorita (referencia generica por id). |

## Motor de persistencia

- **Local:** `drift` (SQLite). Todas las entidades viven en la base de datos local, salvo excepcion.
- **Remoto (solo F25/F26):** Firestore o Postgres (Supabase), unicamente para rutinas publicadas y retos
  grupales - el resto de los datos permanece local.

## Relaciones clave

- `Routine` 1-N `RoutineItem` (union de `Interval` y `Block`).
- `PresetRoutine` N-N `Exercise`.
- `SessionLog` N-1 `Routine` (por id + snapshot del nombre, para que el historial no se rompa si la
  rutina original se edita o elimina despues).
- `FavoriteRoutine` referencia generica a `routineId` - resolver el join en la capa de repositorio.

## Estrategia de migraciones

- Toda migracion de `drift` debe ser aditiva siempre que sea posible.
- Migraciones destructivas requieren un paso de backup previo (ver F29), documentado en el `design.md`
  de la feature que la introduce.

## Snapshot vs referencia

Cuando una entidad se usa como registro historico (ej. `SessionLog` referenciando una `Routine`), se debe
guardar un snapshot minimo (nombre, duracion total) ademas del id.
