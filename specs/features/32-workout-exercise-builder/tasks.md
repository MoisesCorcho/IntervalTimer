# Tasks: Constructor de Entrenamientos por Ejercicios

**ID:** F32 &nbsp;|&nbsp; **Slug:** `32-workout-exercise-builder`

## Definition of Done

- [x] Todos los criterios R1–R18 de `requirements.md` estan implementados y verificados manualmente. _(cubre R1–R18)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Schema drift F32 documentado en `_global/05-data-model.md` y migracion aplicada.
- [x] No se rompio F01 (timer, eventos de sesion, validaciones de intervalo).
- [x] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Datos y persistencia

- [x] Definir modelos `Workout` y `WorkoutExercise` en `data/models/`. _(cubre R3, R7)_
- [x] Crear tablas drift `workouts` y `workout_exercises` + `WorkoutRepository`. _(cubre R1–R11)_
- [x] Actualizar `_global/05-data-model.md` con entidades F32 antes del primer PR de codigo. _(cubre R1–R12)_
- [x] Implementar `active_workout_id` en drift (`app_preferences` / `PreferencesRepository`). _(cubre R8, R9)_

### Dominio — aplanado

- [x] Implementar `WorkoutFlattener.flattenWorkout` en `domain/workout_flattener.dart` segun algoritmo de `design.md`. _(cubre R8)_
- [x] Asignar colores `work`/`rest` desde tema al aplanar. _(cubre R8, R9)_

### Logica / controllers

- [x] Implementar `workoutsListProvider` (`AsyncNotifier`). _(cubre R1)_
- [x] Implementar `workoutEditorControllerProvider` (CRUD ejercicios, reorder, validaciones). _(cubre R3–R7, R12–R15)_
- [x] Extender `TimerController` con `loadFlattenedWorkout(workoutId, intervals)` sin persistir aplanado. _(cubre R8, R9)_
- [x] Bloquear eliminacion de entrenamiento si timer en `running`/`paused`. _(cubre R17)_
- [x] Manejar errores DB con SnackBar + reintentar. _(cubre R16)_

### UI

- [x] Construir `MyWorkoutsScreen` con listado y acciones Entrenar / Editar / Duplicar / Eliminar. _(cubre R1, R10, R11, R13)_
- [x] Construir flujo crear entrenamiento (nombre) → `WorkoutEditorScreen`. _(cubre R2, R14)_
- [x] Construir `WorkoutEditorScreen` con lista de ejercicios y `ReorderableListView`. _(cubre R6)_
- [x] Construir formulario de ejercicio: nombre, sets, duracion trabajo, duracion descanso. _(cubre R3, R4, R15)_
- [x] Implementar renombrado de entrenamiento en editor. _(cubre R12, R14)_
- [x] Implementar dialogo de confirmacion destructiva al eliminar entrenamiento. _(cubre R11, R18)_
- [x] Registrar rutas `/workouts`, `/workouts/:id/edit` en `go_router` + entrada **Entrenamientos** en navegacion principal. _(cubre R1, R8)_
- [x] Accion **Entrenar**: aplanar, cargar timer, navegar a F01. _(cubre R8, R9, R13)_

### Integracion

- [x] Documentar en `TimerController` / eventos que `routineId` puede ser `workoutId` cuando origen es F32. _(cubre R9)_
- [x] Reutilizar parser mm:ss y validaciones de duracion de `core/utils/` (F01). _(cubre R15)_

### Tests

- [x] **Unit — aplanado happy path:** 1 ejercicio 3 sets 40s/20s → 5 intervalos (3 work + 2 rest). _(cubre R8)_
- [x] **Unit — aplanado edge:** sets=1 sin descanso; restSeconds=0 omite descanso; 2 ejercicios mantiene orden. _(cubre R8)_
- [x] **Unit — repository:** crear entrenamiento, agregar/editar/eliminar ejercicio, reorder, duplicar con nombre Copia de. _(cubre R2–R7, R10)_
- [x] **Unit — validacion:** sets 0 o 100 rechazado; nombre ejercicio vacio rechazado; entrenamiento sin ejercicios no inicia. _(cubre R13, R15)_
- [x] **Unit — integracion timer:** loadFlattenedWorkout deja timer en idle con N intervalos; SessionCompleted usa workoutId. _(cubre R8, R9)_
- [x] **Unit — error/edge:** delete bloqueado en running/paused; cancelar dialogo no borra. _(cubre R17, R18)_
- [x] **Widget — listado:** Mis entrenamientos muestra nombre y conteo de ejercicios. _(cubre R1)_
- [x] **Widget — editor:** formulario rechaza sets invalidos y nombre vacio con mensaje visible. _(cubre R15)_
- [x] **Widget — eliminar:** dialogo tiene boton destructivo separado; cancelar mantiene item. _(cubre R11, R18)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Modelos, drift, workoutsListProvider, MyWorkoutsScreen, widget listado |
| R2 | Repository create, flujo crear |
| R3 | Formulario ejercicio, editor controller, repository add |
| R4 | Formulario editar, repository update |
| R5 | Editor eliminar ejercicio, repository delete |
| R6 | ReorderableListView, reorderExercises |
| R7 | Editor persistencia completa |
| R8 | WorkoutFlattener, loadFlattenedWorkout, Entrenar |
| R9 | TimerController, navegacion F01, unit integracion timer |
| R10 | duplicateWorkout, unit repository duplicar |
| R11 | Dialogo eliminar, repository delete, widget eliminar |
| R12 | Renombrar editor |
| R13 | Bloqueo Entrenar sin ejercicios, unit validacion |
| R14 | Validacion nombre entrenamiento, flujo crear |
| R15 | Validacion formulario ejercicio, unit/widget |
| R16 | SnackBar + reintentar |
| R17 | Bloqueo delete en sesion, unit error |
| R18 | Cancelar dialogo, widget eliminar |

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que F01 este en estado "Done".
Orden recomendado: modelos/migracion → WorkoutFlattener → repository → providers → UI listado → UI editor → integracion TimerController → tests.

**Post-feature:** la semantica de descanso final entre ejercicios y el campo `restAfterExerciseSeconds` se implementan en **F34** (`34-exercise-rest-between-and-final/`), que extiende el flattener y el form de esta feature sin reemplazar el resto del CRUD F32.