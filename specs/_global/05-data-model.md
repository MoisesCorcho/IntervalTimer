# Modelo de Datos Global

Este documento consolida las entidades que se van agregando a lo largo de las features. Cada feature
que introduce o modifica una entidad debe reflejarlo aqui **antes** de implementar migraciones drift.

## Politica de identificadores

- Todos los IDs de entidades persistidas en drift son **UUID v4** representados como `String`.
- Generar con el paquete `uuid` en la capa de repositorio al crear registros.
- No usar autoincrement integer como ID publico de dominio.

## Entidades principales (por feature de origen)

| Entidad | Origen | Descripcion breve |
|---|---|---|
| `Interval` | F01 | Unidad basica: nombre, duracion, color, tipo. |
| `Routine` | F01 | Coleccion ordenada de `RoutineItem` (intervalos y/o bloques). |
| `RoutineItem` | F01/F08 | Union discriminada: `interval(Interval)` en F01; `block(Block)` en F08. |
| `Block` | F08 | Agrupacion de intervalos con numero de repeticiones. |
| `Exercise` | F03 | Ejercicio con metadata y referencia a media (Lottie/video/imagen). |
| `PresetRoutine` | F03 | Rutina prediseñada con categoria y ejercicios asociados (assets, no drift). |
| `SessionLog` | F04 | Registro de una sesion ejecutada (completa o abortada). |
| `ProgressionPlan` / `WeekAdjustment` | F09 | Plan de incremento automatico de dificultad. |
| `Achievement` / `UnlockedAchievement` | F13 | Catalogo de logros y su estado de desbloqueo. |
| `Reminder` | F14 | Configuracion de notificaciones recurrentes. |
| `BodyMeasurement` | F15 | Registro de peso/medidas en el tiempo. |
| `FavoriteRoutine` | F24 | Marca de rutina favorita (referencia por id + tipo preset/user). |
| `Workout` | F32 | Entrenamiento del usuario: nombre + lista ordenada de ejercicios. |
| `WorkoutExercise` | F32 / F34 | Ejercicio dentro de un entrenamiento: nombre, sets, trabajo, descanso entre sets y descanso final (post-ejercicio). |

## Schema F01 (drift) — fundacional

### Enums de dominio

```dart
enum IntervalType { warmup, work, rest, stretch, custom }
enum RoutineItemType { interval }  // F08 agrega: block
```

### Entidades de dominio

```
Interval {
  id: String              // UUID v4
  name: String            // max 50 chars (validacion en UI)
  durationSeconds: int    // 1..5999 (00:01..99:59)
  colorArgb: int          // 0xAARRGGBB
  type: IntervalType
}

Routine {
  id: String              // UUID v4
  name: String            // max 80 chars (validacion en UI — F05)
  createdAt: DateTime     // UTC al persistir
  updatedAt: DateTime     // UTC al persistir; F05 — orden listado Mis rutinas
  source: RoutineSource   // F05 — default custom para filas F01
  originId: String?       // F05 — PresetRoutine.id cuando source == presetDerived
  items: List<RoutineItem> // orden por position
}

enum RoutineSource { custom, presetDerived }

RoutineItem (sealed class / freezed union) {
  F01: solo variante IntervalItem { interval: Interval }
  F08: agrega BlockItem { block: Block }
}
```

### Tablas drift (schema version 1 — F01)

| Tabla | Columnas | Notas |
|---|---|---|
| `intervals` | `id` TEXT PK, `name` TEXT, `duration_seconds` INTEGER, `color_argb` INTEGER, `type` TEXT | `type` almacena nombre del enum |
| `routines` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER | `created_at` = millisecondsSinceEpoch UTC |
| `routines` (F05) | + `source` TEXT NOT NULL DEFAULT `'custom'`, `origin_id` TEXT NULL, `updated_at` INTEGER NOT NULL | Migracion v2; backfill `updated_at = created_at` |
| `routine_items` | `id` TEXT PK, `routine_id` TEXT FK→routines, `position` INTEGER, `item_type` TEXT, `interval_id` TEXT FK→intervals NULL | F01: solo `item_type='interval'` |

**Integridad referencial:**

- `routine_items.routine_id` → `routines.id` ON DELETE CASCADE
- `routine_items.interval_id` → `intervals.id` ON DELETE RESTRICT (no borrar intervalo referenciado sin reasignar)
- Indice unico: `(routine_id, position)` para garantizar orden sin duplicados

### Mapper drift ↔ dominio

- Tablas drift generan clases `*Data` o `*Row` via drift.
- Mappers en `data/local/` o junto al DAO convierten row → entidad de dominio en `data/models/`.
- La capa `presentation/` nunca importa clases generadas por drift directamente.

### Alcance F01 vs F05

- **F01:** motor del timer y CRUD de intervalos de la **rutina activa**; una fila en `routines` al inicio, referenciada por `active_routine_id` en `shared_preferences` (introducido en F05).
- **F05:** biblioteca multi-rutina (todas las filas `routines` con `source` ∈ {`custom`, `presetDerived`}), duplicar presets, reordenar intervalos, eliminar rutinas propias, cambiar rutina activa.

### Preferencias F05 (`shared_preferences`)

| Clave | Tipo | Uso |
|---|---|---|
| `active_routine_id` | String (UUID) | Rutina cargada por `TimerController` (F01); limpiar al eliminar rutina activa en idle |

### Preferencias F35 (`shared_preferences`)

Preferencias globales de app (no por rutina). Introducidas con el shell `features/settings/`.

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `prep_seconds` | `int` | `10` | `0..60` | Segundos de preparacion antes del primer intervalo al iniciar una sesion. `0` = sin fase prep. Leido **una vez** en `TimerController.start` y copiado a estado de sesion; cambios posteriores no alteran la sesion activa. |

No requiere tabla drift en F35. Otras preferencias de F27/F28/F31 pueden convivir en el mismo store con claves propias.

### Schema F05 (drift) — migracion v2

Columnas aditivas en `routines`:

- `source` TEXT NOT NULL DEFAULT `'custom'` — valores: `custom`, `presetDerived`
- `origin_id` TEXT NULL — `PresetRoutine.id` del asset cuando `source = presetDerived`
- `updated_at` INTEGER NOT NULL — millisecondsSinceEpoch UTC; en migracion, `updated_at = created_at` para filas existentes

Indice sugerido: `(source, updated_at DESC)` para pantalla **Mis rutinas**.

Los presets empaquetados (F03) **no** se almacenan en esta tabla; duplicar un preset crea una fila `presetDerived` nueva.

## RoutineItem — union discriminada

Implementar como `sealed class` (Dart 3) o `@freezed sealed class`:

```dart
sealed class RoutineItem { ... }
class IntervalRoutineItem extends RoutineItem { final Interval interval; }
// F08: class BlockRoutineItem extends RoutineItem { final Block block; }
```

En drift, `routine_items.item_type` discrimina la variante; F01 solo persiste `interval`.

## PresetRoutine (F03) — excepcion de persistencia

- **No** se almacena en drift en el MVP.
- Catalogo empaquetado como JSON en `assets/routines/` + media en `assets/media/`.
- Al seleccionar un preset, el sistema **mapea** su estructura a una `Routine` temporal o copia en drift (F05 define duplicacion persistente).
- `PresetRoutine` puede modelar intervalos como `List<Interval>` en JSON; al cargar en el timer, convertir a `List<RoutineItem>` con `IntervalRoutineItem`.

## Workout / WorkoutExercise (F32 / F34) — entrenamientos estructurados

Modelo declarativo ejercicio + sets. **No** se persiste la secuencia aplanada de intervalos; se genera en runtime al iniciar el entrenamiento.

```dart
Workout {
  id: String              // UUID v4
  name: String            // max 80 chars
  createdAt: DateTime     // UTC
  updatedAt: DateTime     // UTC
  exercises: List<WorkoutExercise>  // orden por position
}

WorkoutExercise {
  id: String                       // UUID v4
  workoutId: String                // FK → workouts.id
  position: int                    // 0..n-1, unico por workout
  name: String                     // max 50 chars
  sets: int                        // 1..99
  workSeconds: int                 // 1..5999
  restSeconds: int                 // 0..5999 — descanso entre sets del mismo ejercicio
                                   //   (omitido si 0 o si es el ultimo set)
  restAfterExerciseSeconds: int    // 0..5999 — F34: descanso final tras el ultimo set
                                   //   solo si hay ejercicio siguiente; 0 = omitir;
                                   //   nunca se emite en el ultimo ejercicio del workout
}
```

### Tablas drift (F32 + F34)

| Tabla | Columnas | Notas |
|---|---|---|
| `workouts` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER, `updated_at` INTEGER | timestamps UTC ms |
| `workout_exercises` | `id` TEXT PK, `workout_id` TEXT FK→workouts ON DELETE CASCADE, `position` INTEGER, `name` TEXT, `sets` INTEGER, `work_seconds` INTEGER, `rest_seconds` INTEGER | indice unico `(workout_id, position)`; F32 schema v3 |
| `workout_exercises` (F34) | + `rest_after_exercise_seconds` INTEGER NOT NULL DEFAULT 0 | Migracion aditiva schema v4; backfill 0 en filas existentes |
| `app_preferences` | `key` TEXT PK, `value` TEXT nullable | key-value; F32 schema v3 |

### Aplanado a `Interval` (F01) — solo en memoria (F32 extendido por F34)

Por cada `WorkoutExercise` en orden de `position`:

1. Por cada set de 1 a `sets`:
   1. `Interval` tipo `work`, nombre = `exercise.name`, duracion = `workSeconds`
   2. Si no es el ultimo set y `restSeconds > 0`: `Interval` tipo `rest`, nombre = `"Descanso"`, duracion = `restSeconds`
2. Si el ejercicio **no** es el ultimo del workout y `restAfterExerciseSeconds > 0`: `Interval` tipo `rest`, nombre = `"Descanso entre ejercicios"`, duracion = `restAfterExerciseSeconds`

**Notas de semantica (F34):**

- `restSeconds` y `restAfterExerciseSeconds` son independientes (no se reutiliza un solo valor para ambos).
- `sets = 1` nunca emite descanso entre sets; puede emitir descanso final si hay ejercicio siguiente.
- El ultimo ejercicio del entrenamiento **no** emite descanso final (no hay cooldown de sesion inventado).
- Default de migracion / alta: `restAfterExerciseSeconds = 0` (comportamiento pre-F34).

Implementacion: `WorkoutFlattener` en `features/workout_builder/domain/`. Ver `32-workout-exercise-builder/design.md` (base) y `34-exercise-rest-between-and-final/design.md` (dual rest).

### Preferencias F32 (drift `app_preferences`)

| Clave | Tipo | Uso |
|---|---|---|
| `active_workout_id` | String (UUID) | Ultimo entrenamiento cargado en `TimerController` via aplanado |

Persistencia via `PreferencesRepository` en `data/repositories/`. Misma semantica que `shared_preferences`; almacenamiento unificado en SQLite para evitar dependencia nativa adicional en Android.

### F32 vs F01 / F05

| Feature | Persistencia | Ejecucion |
|---|---|---|
| F01 | Rutina activa (draft) con intervalos en drift | Timer directo |
| F05 | Biblioteca de rutinas con intervalos planos en drift | Carga rutina → timer |
| F32 | Entrenamientos + ejercicios en drift | Aplana a intervalos efimeros → timer |

`SessionCompletedEvent.routineId` puede contener `workoutId` cuando la sesion se inicio desde F32.

## Motor de persistencia

| Capa | Tecnologia | Que vive ahi |
|---|---|---|
| **Local principal** | drift (SQLite) | Rutinas usuario, entrenamientos (F32), intervalos, session logs, mediciones, logros, etc. |
| **Assets read-only** | JSON en bundle | Presets F03, catalogo de ejercicios |
| **Preferencias** | shared_preferences | Flags de UI, tema, ajustes ligeros |
| **Remoto (F25/F26)** | Firestore o Supabase | Rutinas publicadas, retos grupales — opt-in |

## Relaciones clave

- `Routine` 1-N `RoutineItem` (union de `Interval` y, desde F08, `Block`).
- `PresetRoutine` N-N `Exercise` (en assets; no FK en drift).
- `SessionLog` N-1 `Routine` (por id + snapshot del nombre y duracion total).
- `FavoriteRoutine` referencia `routineId` + `routineSource` enum (`user` | `preset`) — resolver join en repositorio (F24).
- `Workout` 1-N `WorkoutExercise` (orden por `position`).

## Convenciones drift

- Nombres de tabla y columna: `snake_case` en SQL; clases Dart generadas en `PascalCase`.
- Una migracion aditiva por feature que toque schema; incrementar `schemaVersion` en `database.dart`.
- Documentar cada migracion en el `design.md` de la feature y reflejar cambios aqui.
- Toda migracion debe ser aditiva siempre que sea posible.
- Migraciones destructivas requieren backup previo (F29) documentado en el `design.md` de la feature.

## Estrategia de migraciones

- Toda migracion de `drift` debe ser aditiva siempre que sea posible.
- Migraciones destructivas requieren un paso de backup previo (ver F29), documentado en el `design.md`
  de la feature que la introduce.

## Snapshot vs referencia

Cuando una entidad se usa como registro historico (ej. `SessionLog` referenciando una `Routine`), se debe
guardar un snapshot minimo (nombre, duracion total) ademas del id.