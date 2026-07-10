# Design: Descanso entre Sets y Descanso Final del Ejercicio

**ID:** F34 &nbsp;|&nbsp; **Slug:** `34-exercise-rest-between-and-final`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias.

F34 **extiende** F32: no crea un feature module nuevo. Toca el modelo `WorkoutExercise`, migracion drift, `WorkoutFlattener`, repositorio, validadores, formulario de ejercicio y tests existentes.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; entrenamientos estructurados.
- `_global/02-architecture-and-structure.md` — `features/workout_builder/`, `data/models/`, `data/local/`.
- `_global/03-conventions.md` — freezed, drift, Riverpod, tests con `ProviderContainer`.
- `_global/04-design-system.md` — `DurationStepper` (F33), validacion inline, SnackBar DB.
- `_global/05-data-model.md` — `Workout` / `WorkoutExercise`; schema F32 v3.
- `features/32-workout-exercise-builder/design.md` — aplanado base y CRUD.
- `features/33-premium-numeric-steppers/design.md` — integracion steppers en form.

## Decisiones de diseno

### Modelo de datos (delta sobre F32)

```dart
class WorkoutExercise {
  final String id;                      // UUID v4
  final String workoutId;               // FK
  final int position;                   // 0..n-1
  final String name;                    // max 50
  final int sets;                       // 1..99
  final int workSeconds;                // 1..5999
  final int restSeconds;                // 0..5999 — entre sets del mismo ejercicio
  final int restAfterExerciseSeconds;   // 0..5999 — tras ultimo set si hay ejercicio siguiente
}
```

| Campo | Semantica | Emision en aplanado |
|---|---|---|
| `restSeconds` | Descanso entre set i e i+1 del mismo ejercicio | Si `set < sets` y valor > 0 |
| `restAfterExerciseSeconds` | Descanso tras completar todos los sets del ejercicio | Si el ejercicio **no** es el ultimo del workout y valor > 0 |

**No** se renombra `restSeconds` (evita churn y mantiene compatibilidad con F32/F33). El nombre nuevo es explicito en Dart y SQL.

### Migracion drift

Schema actual en codigo: `schemaVersion => 3` (F32 tablas workouts + workout_exercises + app_preferences).

F34 introduce **schema version 4**, migracion **aditiva**:

| Cambio | Detalle |
|---|---|
| Columna nueva | `workout_exercises.rest_after_exercise_seconds` INTEGER NOT NULL DEFAULT 0 |
| Backfill | Filas existentes reciben 0 automaticamente por DEFAULT |
| Destructivo | No |

Documentar en `database.dart` (`onUpgrade` v3→v4) y actualizar `_global/05-data-model.md` **antes** del primer PR de codigo (politica SDD).

### Algoritmo de aplanado (`WorkoutFlattener`)

Ubicacion: `lib/features/workout_builder/domain/workout_flattener.dart` (reemplaza el cuerpo actual manteniendo la firma publica salvo necesidad de tests).

```dart
List<Interval> flattenWorkout(
  Workout workout, {
  required int workColorArgb,
  required int restColorArgb,
  Uuid? uuid,
}) {
  final idGen = uuid ?? const Uuid();
  final result = <Interval>[];
  final exercises = workout.exercises; // orden por position (asumido en dominio)

  for (var i = 0; i < exercises.length; i++) {
    final exercise = exercises[i];
    final isLastExercise = i == exercises.length - 1;

    for (var set = 1; set <= exercise.sets; set++) {
      result.add(Interval(
        id: idGen.v4(),
        name: exercise.name,
        durationSeconds: exercise.workSeconds,
        colorArgb: workColorArgb,
        type: IntervalType.work,
      ));

      final isLastSet = set == exercise.sets;
      if (!isLastSet && exercise.restSeconds > 0) {
        result.add(Interval(
          id: idGen.v4(),
          name: 'Descanso',
          durationSeconds: exercise.restSeconds,
          colorArgb: restColorArgb,
          type: IntervalType.rest,
        ));
      }
    }

    if (!isLastExercise && exercise.restAfterExerciseSeconds > 0) {
      result.add(Interval(
        id: idGen.v4(),
        name: 'Descanso entre ejercicios',
        durationSeconds: exercise.restAfterExerciseSeconds,
        colorArgb: restColorArgb,
        type: IntervalType.rest,
      ));
    }
  }

  return result;
}
```

**Invariantes:**

1. La secuencia aplanada sigue **sin persistirse** (efimera al iniciar entrenamiento).
2. Ambos rests usan `IntervalType.rest` y color `rest` de tema.
3. Labels distintos permiten a F02 (voz) y a la UI de ejecucion (F01) anunciar/mostrar contextos distintos sin logica extra.
4. Orden de ejercicios: el de `workout.exercises` (ya ordenado por `position` en repositorio).

**Ejemplos de cardinalidad:**

| Input | Output (# intervalos) |
|---|---|
| 1 ej, 3 sets, rest 20, final 90 | 5 (3W+2R entre) — sin final (ultimo ej) |
| 2 ej, A sets=1 final 90; B sets=1 final 0 | 3 (WA, R90, WB) |
| 1 ej, sets=2, rest 0, final 60 (solo) | 2 (W W) — sin final |
| A 2s rest10 final60 + B 1s | 4 (WA R10 WA R60 WB) |

### Persistencia y repositorio

Archivos principales:

| Archivo | Cambio |
|---|---|
| `lib/data/models/workout_exercise.dart` | + `restAfterExerciseSeconds` (freezed; re-codegen) |
| `lib/data/local/database.dart` | columna + `schemaVersion` 4 + migracion |
| `lib/data/repositories/workout_repository.dart` | `addExercise` / `updateExercise` / `duplicateWorkout` / mappers leen y escriben el campo |
| `lib/features/workout_builder/domain/workout_validators.dart` (o equivalente) | validar rango 0–5999 para el nuevo campo |
| `lib/features/workout_builder/application/workout_editor_controller.dart` | propagar parametro en add/update |

Firma orientativa de add:

```dart
Future<WorkoutExercise> addExercise({
  required String workoutId,
  required String name,
  required int sets,
  required int workSeconds,
  required int restSeconds,
  required int restAfterExerciseSeconds,
});
```

`duplicateWorkout` debe copiar ambos campos al deep-copy de filas.

### UI

| Superficie | Cambio |
|---|---|
| `exercise_form.dart` | Segundo `DurationStepper` (min 0, max 5999) para `restAfterExerciseSeconds`; labels claros; default inicial 0 en alta, valor actual en edicion |
| Resultado del form | Tipo/`ExerciseFormResult` (o equivalente) incluye ambos rests |
| `workout_editor_screen.dart` | Tile del ejercicio muestra ambos (ej. "Sets · trabajo · entre · final") sin saturar; si final es 0 puede ocultarse o mostrar 00:00 segun claridad |
| `UiStrings` / constantes | Labels y mensajes de validacion del nuevo campo |

Reutilizar F33; no reintroducir `TextField` de duracion.

### Gestion de estado

Sin providers nuevos. `workoutEditorControllerProvider` y flujos de **Entrenar** (flatten → `loadFlattenedWorkout`) reutilizan el flattener actualizado transparentemente.

### Integracion F01

Ningun cambio de contrato en `TimerController`: sigue recibiendo `List<Interval>` aplanada. Los rests finales son intervalos `rest` mas en la lista.

### Strings / i18n

Textos en español hardcodeados o via `UiStrings` como el resto de F32. F28 (i18n) podra externalizar `"Descanso entre ejercicios"` mas adelante; no bloquear F34.

## Diagrama de flujo — aplanado F34

```
for exercise in exercises (orden position):
    for set in 1..sets:
        emit work(exercise)
        if set < sets AND restSeconds > 0:
            emit rest("Descanso", restSeconds)
    if NOT last exercise AND restAfterExerciseSeconds > 0:
        emit rest("Descanso entre ejercicios", restAfterExerciseSeconds)
```

## Riesgos y consideraciones

| Riesgo | Mitigacion |
|---|---|
| Tests F32 de flattener/repo asumen solo `restSeconds` | Actualizar factories/const con `restAfterExerciseSeconds: 0` y agregar casos R6–R8 |
| freezed + drift codegen olvidado | Tasks explicitas de `build_runner` / regen |
| Confusión UX entre los dos descansos | Labels cortos + helper text en form; tile del editor distinguible |
| Alguien espera cooldown al final del workout | Documentado fuera de alcance; R5 lo prohíbe |
| Orden de ejercicios no estable | Asegurar que `getWorkout` / watch devuelven orden por `position` (ya F32) |
| F33 form ya migrado a steppers | Agregar stepper sin reintroducir TextField |

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Un solo `restSeconds` con regla "entre sets o entre ejercicios" | Ambiguedad; no permite 20 s entre sets y 90 s entre ejercicios |
| Descanso a nivel `Workout` entre todos los ejercicios | Menos flexible; no cubre "solo entre A y B" con valores distintos |
| Emitir final tambien en el ultimo ejercicio (cooldown) | Producto rechazo: no inventar cooldown de sesion |
| Renombrar `restSeconds` → `restBetweenSetsSeconds` | Churn de API/SQL/tests sin beneficio inmediato; se documenta semantica |
| IntervalType nuevo (`restBetweenExercises`) | Sobreingenieria; label + tipo `rest` alcanza para F01/F02 |

## Impacto en archivos (implementacion)

```
lib/data/models/workout_exercise.dart          # + campo freezed
lib/data/local/database.dart                   # schema v4, columna, migration
lib/data/local/tables/...                      # si tablas declarativas separadas
lib/data/repositories/workout_repository.dart  # CRUD + duplicate + map
lib/features/workout_builder/domain/
  workout_flattener.dart                       # algoritmo dual rest
  workout_validators.dart                      # validateRestAfterExerciseSeconds
lib/features/workout_builder/application/
  workout_editor_controller.dart
lib/features/workout_builder/presentation/
  widgets/exercise_form.dart
  workout_editor_screen.dart
test/features/workout_builder/domain/workout_flattener_test.dart
test/... (repo, form, controller)
specs/_global/05-data-model.md                 # ya en esta feature (docs)
```
