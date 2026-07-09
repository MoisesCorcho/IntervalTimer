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
  final List<WorkoutExercise> exercises; // orden por position
}

class WorkoutExercise {
  final String id;           // UUID v4
  final String workoutId;    // FK
  final int position;        // 0..n-1
  final String name;         // max 50 chars
  final int sets;            // 1..99
  final int workSeconds;     // 1..5999
  final int restSeconds;     // 0..5999
}
```

**Migracion drift (schema version — coordinar con F01/F05):** tablas nuevas:

| Tabla | Columnas | Notas |
|---|---|---|
| `workouts` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER, `updated_at` INTEGER | timestamps UTC ms |
| `workout_exercises` | `id` TEXT PK, `workout_id` TEXT FK→workouts ON DELETE CASCADE, `position` INTEGER, `name` TEXT, `sets` INTEGER, `work_seconds` INTEGER, `rest_seconds` INTEGER | indice unico `(workout_id, position)` |
| `app_preferences` | `key` TEXT PK, `value` TEXT nullable | key-value drift; F32 usa clave `active_workout_id` |

**Preferencias F32:** clave `active_workout_id` (String UUID) en tabla drift `app_preferences` via `PreferencesRepository`. No usa `shared_preferences` (evita fallos de build Kotlin en Windows con proyecto y pub cache en discos distintos); comportamiento identico al spec original.

### Servicio de aplanado (R8)

Ubicacion: `features/workout_builder/domain/workout_flattener.dart` (logica pura, sin Flutter).

```dart
List<Interval> flattenWorkout(Workout workout, {required int workColorArgb, required int restColorArgb}) {
  final result = <Interval>[];
  for (final exercise in workout.exercises) {
    for (var set = 1; set <= exercise.sets; set++) {
      result.add(Interval(
        id: uuid.v4(),
        name: exercise.name,
        durationSeconds: exercise.workSeconds,
        colorArgb: workColorArgb,
        type: IntervalType.work,
      ));
      final isLastSet = set == exercise.sets;
      if (!isLastSet && exercise.restSeconds > 0) {
        result.add(Interval(
          id: uuid.v4(),
          name: 'Descanso',
          durationSeconds: exercise.restSeconds,
          colorArgb: restColorArgb,
          type: IntervalType.rest,
        ));
      }
    }
  }
  return result;
}
```

- La secuencia aplanada **no se persiste** en drift; se genera en runtime al iniciar entrenamiento.
- IDs nuevos por intervalo aplanado evitan colisiones con intervalos persistidos de F01.

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
| `addExercise(...)` / `updateExercise(...)` / `deleteExercise(...)` | R3–R5 |
| `reorderExercises(workoutId, orderedIds)` | R6 — transaccion unica |
| `duplicateWorkout(id)` | R10 — deep copy ejercicios |
| `deleteWorkout(id)` | R11 |

### Gestion de estado (Riverpod)

Ubicacion: `features/workout_builder/application/`.

| Provider | Responsabilidad |
|---|---|
| `workoutsListProvider` | `AsyncNotifier` — listado R1 |
| `workoutEditorControllerProvider` | `Notifier` — CRUD ejercicios, reorder, validaciones R13–R15 |
| `activeWorkoutIdProvider` | get/set `active_workout_id` |
| `workoutFlattenerProvider` | expone `flattenWorkout` con colores de tema |

### UI

Ubicacion: `features/workout_builder/presentation/`.

| Pantalla | Criterios |
|---|---|
| `MyWorkoutsScreen` | R1, R10, R11, R13, R17 — lista + acciones Entrenar / Editar / Duplicar / Eliminar |
| `WorkoutEditorScreen` | R2–R7, R12–R16 — lista ejercicios `ReorderableListView`, formulario ejercicio (nombre, sets, trabajo mm:ss, descanso mm:ss) |
| Formulario ejercicio | R3, R4, R15 — validacion inline (`04-design-system.md`) |
| Dialogo eliminar | R11, R18 |

**Campos del formulario de ejercicio:**

| Campo | Widget | Validacion |
|---|---|---|
| Nombre | `TextField` | no vacio, max 50 |
| Sets | `TextField` numerico o stepper (formalizado en **F33** `NumberStepper`) | 1–99 |
| Duracion trabajo | mm:ss parser / **F33** `DurationStepper` (sin teclado) | 1–5999 s |
| Duracion descanso | mm:ss parser / **F33** `DurationStepper` (sin teclado, min 0) | 0–5999 s |

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

- Coordinar `schemaVersion` si F01/F05/F32 migran en paralelo — una migracion aditiva unificada por sprint.
- Tests del aplanado deben ser exhaustivos (sets=1, rest=0, multiples ejercicios, orden).
- Documentar en F04 que `routineId` en eventos puede ser `workoutId` cuando la sesion proviene de F32.
- No duplicar logica mm:ss: reutilizar parser de `core/utils/` de F01.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Persistir secuencia aplanada en `routines` | Duplica datos; editar ejercicio invalidaria intervalos derivados. |
| Reutilizar `Routine` + `Block` (F08) para sets | F08 agrupa intervalos genericos; no modela work/rest por ejercicio de forma declarativa. |
| Depender de F05 | F05 es intervalos planos; el modelo ejercicio+sets es independiente y mas claro para el usuario. |
| Entidad `Exercise` de F03 en drift | F03 es catalogo empaquetado con media; F32 es ejercicio textual creado por el usuario. |