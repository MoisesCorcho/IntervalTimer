# Tasks: Descanso entre Sets y Descanso Final del Ejercicio

**ID:** F34 &nbsp;|&nbsp; **Slug:** `34-exercise-rest-between-and-final`

## Definition of Done

- [x] Todos los criterios R1–R15 de `requirements.md` estan implementados y verificados. _(cubre R1–R15)_
- [x] Escenarios A–F de `requirements.md` cubiertos por tests unitarios del flattener (y migracion/default donde aplique).
- [x] `_global/05-data-model.md` refleja `restAfterExerciseSeconds` y el algoritmo de aplanado F34.
- [x] Migracion drift v3→v4 aditiva con default 0; workouts existentes no cambian de secuencia al aplanar sin editar.
- [x] Tests previos de F32 (flattener, repo, form, controller) actualizados y en verde.
- [x] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Datos y persistencia

- [x] Actualizar entidad freezed `WorkoutExercise` con `restAfterExerciseSeconds` (default 0 en dominio donde aplique). _(cubre R1, R12)_
- [x] Agregar columna `rest_after_exercise_seconds` en tabla drift `workout_exercises` + `schemaVersion` 4 + migracion aditiva DEFAULT 0. _(cubre R1, R12)_
- [x] Regenerar codigo drift/freezed (`build_runner` o flujo del proyecto). _(cubre R1)_
- [x] Extender `WorkoutRepository`: add / update / get map / duplicate copian y leen el campo. _(cubre R1, R11, R15)_
- [x] Confirmar que `_global/05-data-model.md` ya documenta el delta F34 (hecho al crear la feature; revalidar si el schema real difiere). _(cubre R1, R3, R4)_

### Dominio — aplanado y validacion

- [x] Actualizar `flattenWorkout` con el algoritmo dual (entre sets + final si no es ultimo ejercicio). _(cubre R3, R4, R5, R6, R7, R8, R9)_
- [x] Labels: entre sets `"Descanso"`; final `"Descanso entre ejercicios"`. _(cubre R3, R4)_
- [x] Agregar/extender `WorkoutValidators` (o equivalente) para `restAfterExerciseSeconds` en 0–5999. _(cubre R13, R14)_

### Application / UI

- [x] Extender `workout_editor_controller` add/update con `restAfterExerciseSeconds`. _(cubre R1, R2)_
- [x] Extender `exercise_form` con segundo `DurationStepper` (min 0, max 5999), labels distinguibles, default 0 en alta. _(cubre R2, R13)_
- [x] Actualizar tile/resumen en `workout_editor_screen` para mostrar descanso final de forma distinguible. _(cubre R10)_
- [x] Strings/labels en `UiStrings` (o constantes del feature) para el nuevo campo y error de validacion. _(cubre R2, R13)_
- [x] Manejo de error DB al guardar con SnackBar + reintentar (reutilizar patron F32). _(cubre R15)_

### Tests

- [x] **Unit — flattener multi-set + final:** sets=3, rest R, final F, no ultimo → W R W R W + rest F. _(cubre R7)_
- [x] **Unit — flattener sets=1 + siguiente:** A sets=1 final N + B → WA, rest N, WB (sin rest entre sets). _(cubre R6, Escenario A)_
- [x] **Unit — flattener final=0:** no emite rest entre ejercicios. _(cubre R8, Escenario C)_
- [x] **Unit — flattener ultimo ejercicio:** final > 0 no se emite. _(cubre R5, Escenario D)_
- [x] **Unit — flattener restSeconds=0:** omite entre sets (regresion F32). _(cubre R9)_
- [x] **Unit — flattener cadena A/B/C:** ambos rests en A y B; C sin final. _(cubre Escenario E)_
- [x] **Unit — flattener un solo ejercicio multi-set:** sin final; con rests entre si restSeconds > 0. _(cubre R5)_
- [x] **Unit — validacion:** restAfterExerciseSeconds fuera de rango rechazado. _(cubre R13)_
- [x] **Unit — repository:** add/update/duplicate persisten y copian `restAfterExerciseSeconds`; filas default 0 si aplica. _(cubre R1, R11, R12)_
- [x] **Widget — exercise form:** muestra dos steppers de descanso; guardar propaga ambos enteros. _(cubre R2, R1)_
- [x] Actualizar tests F32 existentes (constructores `WorkoutExercise`, expects de longitud) con el nuevo campo en 0 salvo casos F34. _(cubre R9, regresion)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | freezed, drift, repository, form, controller |
| R2 | exercise_form DurationStepper dual, UiStrings |
| R3 | flattenWorkout entre sets, unit restSeconds=0 / multi-set |
| R4 | flattenWorkout final, unit multi-set + final |
| R5 | flattenWorkout skip ultimo, unit ultimo / un solo ej |
| R6 | unit sets=1 + siguiente |
| R7 | unit multi-set + final |
| R8 | unit final=0 |
| R9 | unit restSeconds=0 + update tests F32 |
| R10 | tile editor |
| R11 | repository duplicate + unit |
| R12 | migracion DEFAULT 0 + unit repo/migracion |
| R13 | validators + form + unit validacion |
| R14 | validators restSeconds (regresion) |
| R15 | SnackBar error DB (patron F32) |

## Notas de secuenciacion

Esta feature depende de: **F32** (modelo, flattener, form, repo).

F33 no es prerequisito formal del roadmap, pero si el form de ejercicio ya usa `DurationStepper`, el nuevo control **debe** seguir ese patron.

Orden recomendado:

1. Modelo freezed + data model doc (ya actualizado en globals al crear F34)
2. Drift schema v4 + migracion
3. Repository + validators
4. `WorkoutFlattener` + tests de aplanado (Escenarios A–F)
5. Controller + form + tile editor
6. Actualizar tests residuales F32
7. Verificacion manual: crear workout A(sets=1, final>0)+B → Entrenar → secuencia correcta
