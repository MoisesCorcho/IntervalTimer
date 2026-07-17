# Design: Constructor de Entrenamientos por Ejercicios

**ID:** F32 &nbsp;|&nbsp; **Slug:** `32-workout-exercise-builder`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; F32 es la biblioteca estructurada de entrenamientos.
- `_global/02-architecture-and-structure.md` — carpeta `features/workout_builder/`, capas presentation/application.
- `_global/03-conventions.md` — Riverpod unico; tests con `ProviderContainer` y mocks.
- `_global/04-design-system.md` — dialogo destructivo, SnackBar error DB, estado vacio.
- `_global/05-data-model.md` — entidades `Workout`, `WorkoutExercise`; aplanado a `Interval` de F01.

## Decisiones de diseno

### Modelo de datos

Alineado con `_global/05-data-model.md`. F32 introduce entidades propias en drift; **no** reutiliza `Routine` para persistir la estructura ejercicio+sets (solo para ejecucion aplanada efimera).

```dart
class Workout {
  final String id;           // UUID v4
  final String name;         // max 80 chars
  final DateTime createdAt;  // UTC
  final DateTime updatedAt;  // UTC
  final int rounds;          // 1..99, default 1 — rondas globales del bloque
  final List<WorkoutExercise> exercises; // orden por position
}

class WorkoutExercise {
  final String id;           // UUID v4
  final String workoutId;    // FK
  final int position;        // 0..n-1
  final String name;         // max 50 chars
  final int sets;            // 1..99
  final int workSeconds;     // 1..5999
  final int restSeconds;     // 0..5999 — entre sets del mismo ejercicio
  // F34: final int restAfterExerciseSeconds; // 0..5999 — tras ultimo set si hay ejercicio siguiente
}
```

> **F34** extiende este modelo con `restAfterExerciseSeconds` y el algoritmo de aplanado dual. Ver `34-exercise-rest-between-and-final/design.md` y `_global/05-data-model.md`.
>
> **Rondas globales (extension F32):** `Workout.rounds` repite todo el bloque. **No** es F08 (`WorkoutCircuit` sobre subconjuntos).

**Migracion drift:**

| Tabla | Columnas | Notas |
|---|---|---|
| `workouts` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER, `updated_at` INTEGER | timestamps UTC ms |
| `workouts` (rondas) | + `rounds` INTEGER NOT NULL DEFAULT 1 | Migracion aditiva schema **v7**; backfill 1 |
| `workout_exercises` | `id` TEXT PK, `workout_id` TEXT FK→workouts ON DELETE CASCADE, `position` INTEGER, `name` TEXT, `sets` INTEGER, `work_seconds` INTEGER, `rest_seconds` INTEGER | indice unico `(workout_id, position)` |
| `app_preferences` | `key` TEXT PK, `value` TEXT nullable | key-value drift; F32 usa clave `active_workout_id` |

**Preferencias F32:** clave `active_workout_id` (String UUID) en tabla drift `app_preferences` via `PreferencesRepository`. No usa `shared_preferences` (evita fallos de build Kotlin en Windows con proyecto y pub cache en discos distintos); comportamiento identico al spec original.

### Servicio de aplanado (R8 + R19/R20)

Ubicacion: `features/workout_builder/domain/workout_flattener.dart` (logica pura, sin Flutter).

**Algoritmo:**

1. Clampear `rounds` a 1–99 (defensa en profundidad; UI/repo ya validan).
2. Para cada `roundIndex` de 1 a `rounds`:
   1. Generar **un pase** con reglas F32/F34 (sets, rest entre sets, rest final F34).
   2. Flag `emitFinalRestOnLastExercise = (roundIndex < rounds)`:
      - Si hay **ronda siguiente** y el ultimo ejercicio del pase tiene `restAfterExerciseSeconds > 0`, emitir ese `"Descanso final"` al final del pase (puente N → N+1).
      - Si es la **ultima ronda**, no emitir descanso final tras el ultimo ejercicio (fin de sesion).
   3. IDs nuevos por intervalo.
   4. Si `rounds > 1`, adjuntar metadata efimera en cada `Interval` del pase: `roundIndex`, `roundCount = rounds`. Si `rounds == 1`, metadata null (sin etiqueta en timer).
3. Concatenar pases **sin** cooldown inventado aparte (R20): el unico puente entre rondas es el `restAfterExerciseSeconds` del ultimo ejercicio del pase (si > 0).

```dart
List<Interval> flattenWorkout(Workout workout, {required int workColorArgb, required int restColorArgb}) {
  final rounds = workout.rounds.clamp(1, 99);
  final result = <Interval>[];
  for (var round = 1; round <= rounds; round++) {
    final pass = flattenSinglePass(
      workout,
      emitFinalRestOnLastExercise: round < rounds,
      ...
    );
    for (final interval in pass) {
      result.add(rounds > 1
          ? interval.copyWith(roundIndex: round, roundCount: rounds)
          : interval);
    }
  }
  return result;
}
```

- La secuencia aplanada **no se persiste** en drift; se genera en runtime al iniciar entrenamiento.
- IDs nuevos por intervalo aplanado evitan colisiones con intervalos persistidos de F01.
- **F34 dentro del pase:** tras el bucle de sets de un ejercicio que no es el ultimo del pase, si `restAfterExerciseSeconds > 0`, emitir `rest` `"Descanso final"`.
- **F34 entre rondas (R20):** el ultimo ejercicio del pase emite su `restAfterExerciseSeconds` solo si hay ronda siguiente; nunca tras el ultimo work de la sesion.
- **No-goals de aplanado:** no expande circuitos F08; no inventa un campo/cooldown de sesion distinto de `restAfterExerciseSeconds`.

### Integracion con F01 (TimerController)

- Nuevo metodo en `TimerController` (o servicio de carga): `loadFlattenedWorkout({required String workoutId, required List<Interval> flattened})`.
  - Guarda `workoutId` como referencia de origen para `SessionCompletedEvent` / `SessionCancelledEvent`.
  - Carga intervalos en memoria como rutina efimera (estado `idle`).
  - No escribe intervalos aplanados en tablas `routines` / `routine_items` de F01.
- `active_workout_id` se persiste al cargar; se limpia si el usuario elimina ese entrenamiento en idle.

### Persistencia y repositorio

`WorkoutRepository` en `data/repositories/`:

| Metodo | Uso |
|---|---|
| `watchWorkouts()` | Stream listado R1 |
| `createWorkout(name)` | R2 |
| `getWorkout(id)` | Edicion |
| `updateWorkoutName(id, name)` | R12 |
| `updateWorkoutRounds(id, rounds)` | R19, R21, R25 — clamp 1–99 |
| `addExercise(...)` / `updateExercise(...)` / `deleteExercise(...)` | R3–R5 |
| `reorderExercises(workoutId, orderedIds)` | R6 — transaccion unica |
| `duplicateWorkout(id)` | R10 / R24 — deep copy ejercicios + `rounds` |
| `deleteWorkout(id)` | R11 |

### Gestion de estado (Riverpod)

Ubicacion: `features/workout_builder/application/`.

| Provider | Responsabilidad |
|---|---|
| `workoutsListProvider` | `AsyncNotifier` — listado R1 |
| `workoutEditorControllerProvider` | `Notifier` — CRUD ejercicios, reorder, `updateRounds`, validaciones R13–R15, R25 |
| `activeWorkoutIdProvider` | get/set `active_workout_id` |
| `workoutFlattenerProvider` | expone `flattenWorkout` con colores de tema |

### UI

Ubicacion: `features/workout_builder/presentation/`.

| Pantalla | Criterios |
|---|---|
| `MyWorkoutsScreen` | R1, R10, R11, R13, R17, R22 — lista + acciones Entrenar / Editar / Duplicar / Eliminar; chip de rondas si `rounds > 1` |
| `WorkoutEditorScreen` | R2–R7, R12–R16, R21 — card de rondas + lista ejercicios `ReorderableListView`, formulario ejercicio |
| `WorkoutRoundsCard` | R21, R25 — seccion premium de rondas (ver mock abajo) |
| Formulario ejercicio | R3, R4, R15 — validacion inline (`04-design-system.md`) |
| Dialogo eliminar | R11, R18 |
| `TimerExecutionScreen` | R23 — subtitulo "Ronda X de Y" si metadata presente |

**Mock — `WorkoutRoundsCard` (editor, arriba de la lista de ejercicios):**

```
┌──────────────────────────────────────────────────────────┐
│  (○ loop)  Rondas del entrenamiento          [ −  3  + ] │
│            Todo el bloque se repite N veces              │
│            [chip: Todo el bloque × 3]  (si N > 1)        │
└──────────────────────────────────────────────────────────┘
```

- Fondo: gradiente sutil primary→surface (mismo lenguaje que `StatMetricCard` F12), borde accent alpha, radio `AppTheme.radiusMd`/`radiusXl`.
- Icono en circulo soft (`primary` alpha ~0.18).
- Tipografia: titulo `titleMedium` bold; helper `bodySmall` `onSurfaceVariant`.
- Stepper: `NumberStepper` F33 (1–99), alineado a la derecha o debajo en pantallas estrechas.
- Dark mode: solo `ColorScheme` / `AppTheme` (sin negros/blancos hardcodeados rotos).
- Semantics: label "Rondas del entrenamiento, valor N".

**Listado — indicador (R22):**

- Si `rounds > 1`: chip compacto o texto secundario `N rondas` + `Icons.loop` (o `×N`), densidad compacta como chips de `SessionLogCard`.
- Si `rounds == 1`: no mostrar indicador de rondas.

**Campos del formulario de ejercicio:**

| Campo | Widget | Validacion |
|---|---|---|
| Nombre | `TextField` | no vacio, max 50 |
| Sets | `TextField` numerico o stepper (formalizado en **F33** `NumberStepper`) | 1–99 |
| Duracion trabajo | mm:ss parser / **F33** `DurationStepper` (sin teclado) | 1–5999 s |
| Duracion descanso | mm:ss parser / **F33** `DurationStepper` (sin teclado, min 0) | 0–5999 s |

**Rondas del workout (nivel entrenamiento, no por ejercicio):**

| Campo | Widget | Validacion |
|---|---|---|
| Rondas | `WorkoutRoundsCard` + `NumberStepper` | 1–99 |

### Navegacion (go_router)

- `/workouts` → `MyWorkoutsScreen`
- `/workouts/new` → dialogo nombre → `/workouts/:id/edit`
- `/workouts/:id/edit` → `WorkoutEditorScreen`
- Accion **Entrenar** → `flattenWorkout` + `TimerController.loadFlattenedWorkout` → navegar a ruta F01 (`/timer`)

Entrada minima: tab o item de navegacion **Entrenamientos** visible desde shell principal de la app.

## Diagrama de flujo — F32

```
[MyWorkoutsScreen]
    |-- crear --> [WorkoutRepository.create] --> [WorkoutEditorScreen]
    |-- editar --> [WorkoutEditorScreen]
    |                    |
    |                    +-- CRUD ejercicios (sets, work, rest)
    |                    +-- ReorderableListView --> reorderExercises
    |
    |-- Entrenar --> [WorkoutFlattener.flatten] --> [TimerController.loadFlattenedWorkout]
    |                                                      |
    |                                                      v
    |                                              [F01 pantalla ejecucion]
    |
    |-- duplicar --> [duplicateWorkout] --> [WorkoutEditorScreen]
    |
    |-- eliminar --> [AlertDialog] --> deleteWorkout
```

## Riesgos y consideraciones

- Coordinar `schemaVersion` (actual codigo: v6 → **v7** con `workouts.rounds`).
- Tests del aplanado deben ser exhaustivos (sets=1, rest=0, multiples ejercicios, orden, **rounds=1 vs N**, final rest del ultimo ejercicio entre rondas si > 0, sin trailing final rest tras ultima ronda, metadata de ronda).
- Documentar en F04 que `routineId` en eventos puede ser `workoutId` cuando la sesion proviene de F32.
- No duplicar logica mm:ss: reutilizar parser de `core/utils/` de F01.
- F08 sigue pendiente para circuitos parciales; no reutilizar `Workout.rounds` como si fuera circuito.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Persistir secuencia aplanada en `routines` | Duplica datos; editar ejercicio invalidaria intervalos derivados. |
| Reutilizar `Routine` + `Block` (F08) para sets | F08 agrupa intervalos genericos; no modela work/rest por ejercicio de forma declarativa. |
| Depender de F05 | F05 es intervalos planos; el modelo ejercicio+sets es independiente y mas claro para el usuario. |
| Entidad `Exercise` de F03 en drift | F03 es catalogo empaquetado con media; F32 es ejercicio textual creado por el usuario. |
| Solo F08 para cualquier "ronda" | El caso simple (repetir todo el bloque) no necesita multi-select ni circuitos; F32 lo cubre con un int. |
| Cooldown inventado entre rondas (campo nuevo / valor fijo) | Inventaria un descanso no modelado; R20 reutiliza el `restAfterExerciseSeconds` del ultimo ejercicio del pase cuando hay ronda siguiente. |