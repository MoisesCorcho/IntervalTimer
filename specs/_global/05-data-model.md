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
| `Interval` | F01 (+ F02) | Unidad basica: nombre, duracion, color, tipo; F02 agrega `announceText` opcional. |
| `Routine` | F01 | Coleccion ordenada de `RoutineItem` (intervalos; bloques de rutina plana no en MVP de F08). |
| `RoutineItem` | F01 | Union discriminada: `interval(Interval)` en F01. (Historico: `block` se dejo de lado; F08 vive en Workout.) |
| `Block` | — (historico) | Agrupacion de intervalos en `Routine` — **no implementado**; F08 usa `WorkoutCircuit` en el eje Workout. |
| `Exercise` | F03 | Ejercicio con metadata y referencia a media (Lottie/video/imagen). |
| `PresetRoutine` | F03 | Rutina prediseñada con categoria y ejercicios asociados (assets, no drift). |
| `SessionLog` | F04 | Registro de una sesion ejecutada (completa o abortada). |
| `ProgressionPlan` / `WeekAdjustment` | F09 | Plan de incremento automatico de dificultad. |
| `Achievement` / `UnlockedAchievement` | F13 | Catalogo de logros y su estado de desbloqueo. |
| `Reminder` | F14 | Configuracion de notificaciones recurrentes. |
| `BodyMeasurement` | F15 | Registro de peso/medidas en el tiempo. |
| `FavoriteRoutine` | F24 | Marca de rutina favorita (referencia por id + tipo preset/user). |
| `Workout` | F32 | Entrenamiento del usuario: nombre + lista ordenada de ejercicios (y circuitos F08). |
| `WorkoutExercise` | F32 / F34 / F08 | Ejercicio dentro de un entrenamiento: nombre, sets, trabajo, descansos; opcional `circuitId` (F08). |
| `WorkoutCircuit` | F08 | Circuito: `rounds` (1–99) + ejercicios miembros del mismo workout (1 nivel). |

## Schema F01 (drift) — fundacional

### Enums de dominio

```dart
enum IntervalType { warmup, work, rest, stretch, custom }
enum RoutineItemType { interval }  // F08 ya NO agrega block aqui; ver WorkoutCircuit
```

### Entidades de dominio

```
Interval {
  id: String              // UUID v4
  name: String            // max 50 chars (validacion en UI)
  durationSeconds: int    // 1..5999 (00:01..99:59)
  colorArgb: int          // 0xAARRGGBB
  type: IntervalType
  announceText: String?   // F02 — opcional; max 80 chars; null/blank → usar name en TTS
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
  // Historico F08-sobre-Routine (BlockItem): descartado. Rounds viven en WorkoutCircuit (F08).
}
```

### Tablas drift (schema version 1 — F01)

| Tabla | Columnas | Notas |
|---|---|---|
| `intervals` | `id` TEXT PK, `name` TEXT, `duration_seconds` INTEGER, `color_argb` INTEGER, `type` TEXT | `type` almacena nombre del enum |
| `intervals` (F02) | + `announce_text` TEXT NULL | Migracion aditiva; null = anunciar `name` |
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

### Preferencias F35 (`app_preferences` / PreferencesRepository)

Preferencias globales de app (no por rutina). Introducidas con el shell `features/settings/`.
Semantica de clave igual a shared_preferences; implementacion en Drift `app_preferences` via `PreferencesRepository` (mismo patron que F32 `active_workout_id`).

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `prep_seconds` | `int` | `10` | `0..60` | Segundos de preparacion antes del primer intervalo al iniciar una sesion. `0` = sin fase prep. Leido **una vez** en `TimerController.start` y copiado a estado de sesion (`sessionPrepSeconds`); cambios posteriores no alteran la sesion activa. |

### Preferencias F02 (voz — globales)

Misma semantica de store que preferencias de app (`PreferencesRepository` / `app_preferences` o el store de preferencias vigente al implementar). Claves estables; no por rutina.

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `voice_enabled` | `bool` | `true` | — | Mute in-app de TTS; `false` detiene utterance y suprime anuncios sin afectar el timer (F02 R4). |
| `countdown_seconds` | `int` | `3` | `0..10` | Segundos de cuenta regresiva hablada; `0` desactiva countdown (F02 R2/R3). |
| `announce_interval_name` | `bool` | `true` | — | Si `false`, omite anuncio de inicio de intervalo; countdown sigue si aplica (F02 R6). |

No requiere tabla drift nueva para prefs. La columna `intervals.announce_text` si requiere migracion aditiva en la tabla `intervals` (ver schema F01 arriba).

No requiere tabla drift nueva en F35 (reutiliza `app_preferences`). Otras preferencias de F27/F28/F31 pueden convivir en el mismo store con claves propias.

### Preferencias F18 (vibracion — globales)

Misma semantica de store que F02/F35 (`PreferencesRepository` / `app_preferences`). Claves estables; no por rutina. **Independientes** de las claves de voz F02 (`voice_enabled`, `countdown_seconds`).

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `vibration_enabled` | `bool` | `true` | — | Master mute de haptics; `false` suprime todos los patrones sin afectar el timer ni la voz (F18 R3). |
| `vibration_on_interval_start` | `bool` | `true` | — | Si `false`, omite patron A al iniciar intervalo; countdown haptico sigue si aplica (F18 R4). |
| `vibration_on_countdown` | `bool` | `true` | — | Si `false`, omite patron B de ticks; inicio de intervalo sigue si aplica (F18 R4). |
| `vibration_countdown_seconds` | `int` | `3` | `0..10` | Ventana N de cuenta regresiva hapticas; `0` desactiva solo ticks (F18 R2/R5). No reutiliza `countdown_seconds` de F02. |

No requiere tabla drift nueva en F18 (solo key-value en `app_preferences`).

### Preferencias F19 (pantalla siempre encendida — globales)

Misma semantica de store que F02/F18/F35 (`PreferencesRepository` / `app_preferences`). Claves estables; no por rutina. **Independientes** de voz (F02) y vibracion (F18).

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `keep_screen_on_enabled` | `bool` | `true` | — | Master on/off de screen wakelock durante sesion activa (`running` / `preparing`); `false` no solicita wakelock aunque el timer corra (F19 R5–R8, R12). |

No requiere tabla drift nueva en F19 (solo key-value en `app_preferences`). Screen wakelock via paquete `wakelock_plus` (sin permisos de plataforma).

### Preferencias F20 (notificacion / lock screen de sesion — globales)

Misma semantica de store que F02/F18/F19/F35 (`PreferencesRepository` / `app_preferences`). Claves estables; no por rutina. **Independientes** de `keep_screen_on_enabled` (F19), voz (F02) y vibracion (F18).

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `session_lock_screen_enabled` | `bool` | `true` | — | Master on/off de la superficie de sesion (notificacion ongoing Android / Live Activity iOS) durante `preparing`/`running`/`paused` (F20 R9–R10). `false` no muestra la superficie aunque haya sesion activa. |

No requiere tabla drift nueva en F20 (solo key-value en `app_preferences`). Canales de notificacion de sesion deben ser distintos de los de recordatorios F14 (ver design F20).

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
// No agregar BlockRoutineItem en F08. Circuitos = WorkoutCircuit (abajo).
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
  position: int                    // ver reglas F08 abajo
  name: String                     // max 50 chars
  sets: int                        // 1..99
  workSeconds: int                 // 1..5999
  restSeconds: int                 // 0..5999 — descanso entre sets del mismo ejercicio
                                   //   (omitido si 0 o si es el ultimo set)
  restAfterExerciseSeconds: int    // 0..5999 — F34: descanso final tras el ultimo set
                                   //   solo si hay "siguiente trabajo" distinto; 0 = omitir;
                                   //   nunca se emite al cerrar el workout (ultimo work de sesion)
  circuitId: String?               // F08: null = ejercicio suelto (top-level);
                                   //   no null = miembro de WorkoutCircuit
}

WorkoutCircuit {
  id: String                       // UUID v4
  workoutId: String                // FK → workouts.id
  position: int                    // orden entre elementos de nivel superior (sueltos + circuitos)
  rounds: int                      // 1..99
}
```

**Orden (F08):**

- Elementos de **nivel superior**: ejercicios con `circuitId == null` y filas `WorkoutCircuit`, ordenados por su `position` compartida (0..n-1).
- Miembros de un circuito: ejercicios con ese `circuitId`, ordenados por `position` **intra-circuito** (0..k-1).
- Maximo un nivel de anidacion; un ejercicio pertenece a 0 o 1 circuito.

### Tablas drift (F32 + F34 + F08)

| Tabla | Columnas | Notas |
|---|---|---|
| `workouts` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER, `updated_at` INTEGER | timestamps UTC ms |
| `workout_exercises` | `id` TEXT PK, `workout_id` TEXT FK→workouts ON DELETE CASCADE, `position` INTEGER, `name` TEXT, `sets` INTEGER, `work_seconds` INTEGER, `rest_seconds` INTEGER | indice unico `(workout_id, position)` en F32; tras F08 el indice de position se interpreta segun suelto vs miembro — ver design F08; F32 schema v3 |
| `workout_exercises` (F34) | + `rest_after_exercise_seconds` INTEGER NOT NULL DEFAULT 0 | Migracion aditiva schema v4; backfill 0 en filas existentes |
| `workout_exercises` (F08) | + `circuit_id` TEXT NULL FK→workout_circuits | Schema v6; null = suelto |
| `workout_circuits` (F08) | `id` TEXT PK, `workout_id` TEXT FK→workouts ON DELETE CASCADE, `position` INTEGER, `rounds` INTEGER | Schema v6; `rounds` 1..99 |
| `app_preferences` | `key` TEXT PK, `value` TEXT nullable | key-value; F32 schema v3 |

### Aplanado a `Interval` (F01) — solo en memoria (F32 extendido por F34 y F08)

**Sin circuitos (F32/F34, o workout pre-F08):** por cada `WorkoutExercise` suelto en orden de `position` top-level:

1. Por cada set de 1 a `sets`:
   1. `Interval` tipo `work`, nombre = `formatDisplayName(exercise.name)` (MAYUSCULAS), duracion = `workSeconds`
   2. Si no es el ultimo set y `restSeconds > 0`: `Interval` tipo `rest`, nombre = `"DESCANSO"`, duracion = `restSeconds`
2. Si el ejercicio **no** es el ultimo del workout y `restAfterExerciseSeconds > 0`: `Interval` tipo `rest`, nombre = `"DESCANSO FINAL"` / `"Descanso entre ejercicios"`, duracion = `restAfterExerciseSeconds`

**Con circuitos (F08):** recorrer elementos de nivel superior (sueltos + circuitos). Para un circuito con `rounds = R` y miembros E1..Ek, repetir R veces el aplanado de E1..Ek. `restAfterExerciseSeconds` se emite cuando hay un siguiente trabajo que no es otro set del mismo ejercicio (siguiente miembro, primera ronda siguiente, o siguiente top-level). No emitir descanso final tras el ultimo work de la sesion. Cada intervalo de un circuito lleva metadata de ronda (`roundIndex` 1-based, `roundCount`, `circuitId`) para UI "Ronda X de Y". Detalle: `08-circuit-repetition-rounds/design.md`.

**Notas de semantica (F34 + F08):**

- `restSeconds` y `restAfterExerciseSeconds` son independientes (no se reutiliza un solo valor para ambos).
- `sets = 1` nunca emite descanso entre sets; puede emitir descanso final si hay siguiente trabajo.
- El ultimo trabajo de la sesion **no** emite descanso final (no hay cooldown de sesion inventado).
- Default de migracion / alta: `restAfterExerciseSeconds = 0` (comportamiento pre-F34).
- F08 **no** agrega campos de duracion al circuito; hereda tiempos de cada ejercicio.
- Workouts sin filas en `workout_circuits` se comportan como pre-F08.

Implementacion: `WorkoutFlattener` en `features/workout_builder/domain/`. Ver `32-workout-exercise-builder/design.md` (base), `34-exercise-rest-between-and-final/design.md` (dual rest) y `08-circuit-repetition-rounds/design.md` (rondas).

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

## SessionLog (F04) — historial de sesiones

Registro historico de una sesion de timer (completada o abortada con progreso). Introducido por F04.

```dart
enum SessionLogStatus { completed, aborted }

SessionLog {
  id: String                    // UUID v4
  sourceId: String              // routineId (F01/F05) o workoutId (F32) del evento
  displayName: String           // snapshot del nombre al cerrar sesion (puede ser '')
  endedAt: DateTime             // UTC al persistir (ms epoch)
  localDate: String             // yyyy-MM-dd en zona local del dispositivo al momento de endedAt
  status: SessionLogStatus      // completed | aborted
  totalDurationSeconds: int     // totalElapsedSeconds o elapsedSeconds del evento
  itemCount: int                // intervalCount o completedIntervalCount
  note: String?                 // opcional; max 500 chars en validacion UI
}
```

### Tabla drift (F04 — migracion aditiva)

| Tabla | Columnas | Notas |
|---|---|---|
| `session_logs` | `id` TEXT PK, `source_id` TEXT NOT NULL, `display_name` TEXT NOT NULL, `ended_at` INTEGER NOT NULL, `local_date` TEXT NOT NULL, `status` TEXT NOT NULL, `total_duration_seconds` INTEGER NOT NULL, `item_count` INTEGER NOT NULL, `note` TEXT NULL | Indices: `(local_date)`, `(ended_at DESC)` |

**Integridad:**

- **Sin FK** a `routines` / `workouts`: el origen puede borrarse y el historial permanece (snapshot).
- `schemaVersion`: **5** (migracion F04: `createTable(sessionLogs)`). Confirmado en `lib/data/local/database.dart`.

**Semantica de escritura (resumen F04):**

| Evento F01 | Condicion | `status` |
|---|---|---|
| `SessionCompletedEvent` | siempre | `completed` |
| `SessionCancelledEvent` | `elapsedSeconds > 0` | `aborted` |
| `SessionCancelledEvent` | `elapsedSeconds == 0` | no insertar |

Queries tipicas: por `local_date` (lista del dia), rango de `local_date` del mes (marcadores), update de `note`, delete por `id`.

## Motor de persistencia

| Capa | Tecnologia | Que vive ahi |
|---|---|---|
| **Local principal** | drift (SQLite) | Rutinas usuario, entrenamientos (F32), intervalos, session logs, mediciones, logros, etc. |
| **Assets read-only** | JSON en bundle | Presets F03, catalogo de ejercicios |
| **Preferencias** | shared_preferences | Flags de UI, tema, ajustes ligeros |
| **Remoto (F25/F26)** | Firestore o Supabase | Rutinas publicadas, retos grupales — opt-in |

## Relaciones clave

- `Routine` 1-N `RoutineItem` (F01: `Interval`; sin `Block` en MVP de F08).
- `PresetRoutine` N-N `Exercise` (en assets; no FK en drift).
- `SessionLog` referencia debil a rutina/workout por `sourceId` + snapshot (`displayName`, duracion, `itemCount`); **sin FK** (F04).
- `FavoriteRoutine` referencia `routineId` + `routineSource` enum (`user` | `preset`) — resolver join en repositorio (F24).
- `Workout` 1-N `WorkoutExercise` (orden por `position`; F32/F34).
- `Workout` 1-N `WorkoutCircuit` (F08); `WorkoutExercise` 0..1 `WorkoutCircuit` via `circuitId`.

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