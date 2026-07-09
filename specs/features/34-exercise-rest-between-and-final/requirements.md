# Requirements: Descanso entre Sets y Descanso Final del Ejercicio

> Estado: No iniciada

**ID:** F34 &nbsp;|&nbsp; **Slug:** `34-exercise-rest-between-and-final` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Unifica y completa la semantica de descansos en entrenamientos estructurados (F32):

1. **Descanso entre sets** (`restSeconds`, ya existente): pausa corta entre set 1→2, 2→3, etc. del **mismo** ejercicio. Se omite tras el ultimo set del ejercicio y cuando el valor es 0.
2. **Descanso final del ejercicio** (`restAfterExerciseSeconds`, campo nuevo): pausa mas larga (o la que el usuario elija) **despues del ultimo set** de un ejercicio, **solo si** hay un ejercicio siguiente en el entrenamiento. No se emite para el ultimo ejercicio del workout. Valor 0 = omitir.

Corrige el caso habitual: ejercicio A con `sets = 1` + ejercicio B — el descanso entre sets nunca aplica; el **descanso final de A** si puede ejecutarse antes de B cuando `restAfterExerciseSeconds > 0`.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F32 - Constructor de Entrenamientos por Ejercicios

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente (F08 u otras features de rounds/circuitos pueden consumir el aplanado extendido sin prerequisito formal)

## User Stories

- **Como** usuario, **quiero** configurar el descanso entre sets de un ejercicio por separado del descanso al terminar el ejercicio, **para que** puedo recuperar poco entre series y mas entre movimientos distintos.
- **Como** usuario, **quiero** que al pasar de un ejercicio al siguiente se respete el descanso final del ejercicio que acabo de terminar (si lo configure), **para que** no salte de golpe al siguiente trabajo cuando solo tenia un set o acabe el ultimo set.
- **Como** usuario, **quiero** que el ultimo ejercicio del entrenamiento no agregue un descanso final automatico, **para que** la sesion termine al completar el ultimo trabajo sin cooldown inventado.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Campo descanso final en el modelo de ejercicio

DONDE el usuario crea o edita un ejercicio de un entrenamiento (F32), CUANDO guarda valores validos, EL SISTEMA DEBE persistir `restSeconds` (descanso entre sets, 0–5999) y `restAfterExerciseSeconds` (descanso final del ejercicio, 0–5999) junto con nombre, sets y `workSeconds`.

### R2 — Formulario de ejercicio: dos controles de descanso

DONDE el usuario esta en el formulario de agregar o editar ejercicio, CUANDO el formulario esta visible, EL SISTEMA DEBE presentar:

- un control de duracion para **descanso entre sets** (`restSeconds`, minimo 0 s, maximo 5999 s);
- un control de duracion para **descanso final del ejercicio** (`restAfterExerciseSeconds`, minimo 0 s, maximo 5999 s);

ambos reutilizando el patron de steppers de F33 (`DurationStepper`) cuando ese control ya esta integrado en el form de F32, con etiquetas distinguibles (ej. "Descanso entre sets" y "Descanso final" / "Descanso tras el ejercicio").

### R3 — Aplanado: descanso entre sets

CUANDO el sistema aplana un `Workout` para ejecucion (F32 R8 / `WorkoutFlattener`), EL SISTEMA DEBE, por cada ejercicio en orden de `position` y por cada set `s` de 1 a `sets`:

1. emitir un intervalo `work` con nombre del ejercicio y duracion `workSeconds`;
2. SI `s < sets` Y `restSeconds > 0`, ENTONCES emitir un intervalo `rest` con nombre `"Descanso"` y duracion `restSeconds`.

### R4 — Aplanado: descanso final del ejercicio

CUANDO el sistema aplana un `Workout` y termina de emitir los sets de un ejercicio que **no es el ultimo** del entrenamiento, SI `restAfterExerciseSeconds > 0`, ENTONCES EL SISTEMA DEBE emitir un intervalo `rest` con nombre `"Descanso entre ejercicios"` (o etiqueta de producto documentada en `design.md`) y duracion `restAfterExerciseSeconds` **despues** del ultimo `work` de ese ejercicio y **antes** del primer `work` del ejercicio siguiente.

### R5 — Ultimo ejercicio sin descanso final

CUANDO el sistema aplana un `Workout` y procesa el **ultimo** ejercicio de la lista (mayor `position` / ultimo en orden), EL SISTEMA DEBE **no** emitir intervalo de descanso final de ese ejercicio, aunque `restAfterExerciseSeconds > 0`.

### R6 — sets=1 con ejercicio siguiente y descanso final

DONDE un entrenamiento tiene al menos dos ejercicios y el primero tiene `sets = 1`, `restSeconds` cualquiera y `restAfterExerciseSeconds = N` con N > 0, CUANDO se aplana el entrenamiento, EL SISTEMA DEBE producir la secuencia:

1. `work` del ejercicio A;
2. `rest` final de A con duracion N;
3. intervalos del ejercicio B (y siguientes);

sin emitir descanso entre sets de A (porque no hay set intermedio).

### R7 — Multi-set con ambos descansos

DONDE un ejercicio no final tiene `sets = 3`, `restSeconds = R` (R > 0) y `restAfterExerciseSeconds = F` (F > 0), CUANDO se aplana, EL SISTEMA DEBE emitir:

`work, rest(R), work, rest(R), work, rest(F)`

y luego el primer intervalo del ejercicio siguiente (si existe).

### R8 — restAfterExerciseSeconds = 0 omite final

DONDE un ejercicio no final tiene `restAfterExerciseSeconds = 0`, CUANDO se aplana, EL SISTEMA DEBE pasar del ultimo `work` de ese ejercicio al primer intervalo del siguiente **sin** intervalo de descanso final entre ellos (los descansos entre sets de ese ejercicio siguen R3).

### R9 — restSeconds = 0 omite entre sets (regresion F32)

DONDE un ejercicio tiene `restSeconds = 0` y `sets > 1`, CUANDO se aplana, EL SISTEMA DEBE emitir solo intervalos `work` consecutivos para esos sets, sin `rest` entre sets (comportamiento F32 preservado).

### R10 — Listado / resumen del ejercicio en el editor

DONDE el usuario ve un ejercicio en la lista del editor de entrenamiento, CUANDO el item muestra metricas de duracion, EL SISTEMA DEBE hacer visibles de forma distinguible el descanso entre sets y el descanso final (o al menos no ocultar el final si es > 0), sin romper el layout existente de F32 de forma confusa.

### R11 — Duplicar entrenamiento copia ambos descansos

DONDE el usuario duplica un entrenamiento (F32 R10), CUANDO la copia se crea, EL SISTEMA DEBE copiar `restSeconds` y `restAfterExerciseSeconds` de cada ejercicio a la copia con nuevos IDs.

### R12 — Migracion de ejercicios existentes

CUANDO el usuario actualiza la app y existen filas de `workout_exercises` previas a F34, EL SISTEMA DEBE asignar `restAfterExerciseSeconds = 0` por defecto a esos registros, de modo que el aplanado y la UX se comporten como antes de F34 (sin descanso final nuevo).

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R13 — Rango invalido de restAfterExerciseSeconds

CUANDO el usuario intenta guardar un ejercicio con `restAfterExerciseSeconds` fuera de 0–5999, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir el ejercicio.

### R14 — Validacion de restSeconds sin regresion

CUANDO el usuario intenta guardar un ejercicio con `restSeconds` fuera de 0–5999, EL SISTEMA DEBE rechazar la operacion como en F32 (R15 de F32) y no persistir.

### R15 — Error de persistencia al guardar descanso final

CUANDO falla el guardado del ejercicio por error de base de datos local al incluir el nuevo campo, EL SISTEMA DEBE mostrar un SnackBar con mensaje claro y opcion de reintentar, sin dejar la UI inconsistente respecto a lo persistido (`_global/04-design-system.md`).

## Escenarios de aceptacion (Given / When / Then)

### Escenario A — sets=1 + siguiente ejercicio (bugfix principal)

| | |
|---|---|
| **Given** | Workout con ejercicio A (`sets=1`, `workSeconds=40`, `restSeconds=20`, `restAfterExerciseSeconds=90`) y ejercicio B (`sets=1`, `workSeconds=30`, ambos rests 0) |
| **When** | El usuario inicia el entrenamiento (aplanado) |
| **Then** | Secuencia: work A (40) → rest "Descanso entre ejercicios" (90) → work B (30). No hay rest de 20 s (entre sets no aplica) |

### Escenario B — multi-set + descanso final

| | |
|---|---|
| **Given** | Ejercicio A (`sets=2`, `work=30`, `restSeconds=10`, `restAfterExerciseSeconds=60`) seguido de B |
| **When** | Aplanado |
| **Then** | work A → rest 10 → work A → rest 60 → …B |

### Escenario C — descanso final en 0

| | |
|---|---|
| **Given** | A (`sets=2`, `restSeconds=15`, `restAfterExerciseSeconds=0`) + B |
| **When** | Aplanado |
| **Then** | work → rest 15 → work → work de B (sin rest entre ejercicios) |

### Escenario D — ultimo ejercicio ignora final

| | |
|---|---|
| **Given** | Un solo ejercicio, o el ultimo del workout, con `restAfterExerciseSeconds=120` |
| **When** | Aplanado |
| **Then** | No se emite rest final al terminar; la sesion termina en el ultimo work (y rests entre sets solo si aplica) |

### Escenario E — ambos rests en varios ejercicios

| | |
|---|---|
| **Given** | A (3 sets, rest 20, final 45) + B (2 sets, rest 10, final 30) + C (1 set, rest 5, final 99) |
| **When** | Aplanado |
| **Then** | A: W R W R W + final 45; B: W R W + final 30; C: W sin final |

### Escenario F — migracion default 0

| | |
|---|---|
| **Given** | DB con ejercicios creados antes de F34 |
| **When** | Migracion de schema y aplanado de un workout multi-ejercicio sin re-editar |
| **Then** | `restAfterExerciseSeconds` efectivo = 0; secuencia identica a F32 pre-F34 |

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| Dos campos, no uno | `restSeconds` = solo entre sets del mismo ejercicio. `restAfterExerciseSeconds` = solo post-ultimo-set si hay ejercicio siguiente. No reutilizar un unico valor para ambos. |
| Nombre del campo | Dominio Dart: `restAfterExerciseSeconds`. SQL: `rest_after_exercise_seconds`. |
| Default migracion | `0` — seguro; no introduce descansos nuevos en workouts existentes. |
| Default UI al crear ejercicio nuevo | `restAfterExerciseSeconds = 0` (el usuario opt-in). Default de `restSeconds` se mantiene como en F32 (ej. 20 s si el form actual lo usa). |
| Ultimo ejercicio | Nunca emite descanso final. **No** hay cooldown de sesion completo inventado por F34. |
| Label del intervalo aplanado | Entre sets: `"Descanso"` (F32). Final entre ejercicios: `"Descanso entre ejercicios"`. Ambos `IntervalType.rest` y color `rest` de tema. |
| sets=1 | Solo puede emitir descanso final (si aplica); nunca descanso entre sets. |
| Orden de emision | Sets (work + rest entre) **completos**; luego rest final del ejercicio; luego siguiente ejercicio. |
| F32 R8 | F34 **extiende** el algoritmo de aplanado de F32. La frase de F32 "sin descanso tras el ultimo set del ejercicio" queda **reemplazada** por: sin descanso entre-sets tras el ultimo set; si puede haber descanso final si no es el ultimo ejercicio y `restAfterExerciseSeconds > 0`. |
| Cooldown de sesion | Fuera de alcance. No inventar intervalo global al final del workout. |
| Rounds / F08 | Fuera de alcance. F34 opera sobre la lista plana de ejercicios de un `Workout`. |

## Fuera de alcance (explicito)

- Cooldown / stretch global al final de la sesion.
- Descanso distinto por numero de set (solo un valor entre-sets por ejercicio).
- Descanso configurado a nivel `Workout` (solo a nivel `WorkoutExercise`).
- Cambiar la semantica de `IntervalType` ni colores de tema.
- Media, voz o anuncios especificos para "descanso final" vs "entre sets" (F02 puede anunciar el `name` del intervalo aplanado tal cual).
- Limites Pro / IAP (F06).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — friccion minima; offline-first.
- `_global/02-architecture-and-structure.md` — `features/workout_builder/`, drift, Riverpod.
- `_global/03-conventions.md` — EARS, testing, freezed/drift.
- `_global/04-design-system.md` — steppers F33, validacion, SnackBar error.
- `_global/05-data-model.md` — `WorkoutExercise`, aplanado a `Interval`.
- `features/32-workout-exercise-builder/` — modelo base, form, flattener, CRUD.
- `features/33-premium-numeric-steppers/` — `DurationStepper` para el nuevo campo.
- `features/01-interval-timer-core/` — ejecucion de la secuencia aplanada.
