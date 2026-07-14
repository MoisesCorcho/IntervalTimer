# Requirements: Constructor de Entrenamientos por Ejercicios

> Estado: Completado

**ID:** F32 &nbsp;|&nbsp; **Slug:** `32-workout-exercise-builder` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Apartado **Entrenamientos** donde el usuario crea entrenamientos compuestos por uno o mas ejercicios. Cada ejercicio define nombre, cantidad de sets, duracion del trabajo y duracion del descanso entre sets. Al iniciar el entrenamiento, el sistema convierte la estructura en una secuencia lineal de intervalos para el motor del timer (F01).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F04 - Calendario e Historial de Sesiones (puede registrar sesiones originadas en un `Workout`)
- F08 - Repeticion de Circuitos (Rounds) (extiende el editor y el flattener con `WorkoutCircuit`; prereqs de F08: F01, F32, F34)
- F24 - Favoritos (puede marcar entrenamientos favoritos en iteracion futura)
- F33 - Controles Numericos y de Duracion (Steppers Premium) (reemplaza TextField de sets/duracion por steppers)
- F34 - Descanso entre Sets y Descanso Final del Ejercicio (extiende semantica de rest y aplanado; ver nota en R8 / decisiones)

## User Stories

- **Como** usuario, **quiero** un apartado de entrenamientos donde vea mis entrenamientos guardados, **para que** puedo elegir o editar lo que voy a hacer hoy.
- **Como** usuario, **quiero** crear un entrenamiento y agregar ejercicios con sets, duracion de trabajo y duracion de descanso, **para que** armo sesiones estructuradas sin calcular intervalos a mano.
- **Como** usuario, **quiero** iniciar un entrenamiento guardado, **para que** el timer ejecute automaticamente todos los sets y descansos en orden.
- **Como** usuario, **quiero** duplicar un entrenamiento existente, **para que** puedo variar una base sin empezar de cero.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Listado de entrenamientos

DONDE el usuario esta en la pantalla **Mis entrenamientos**, EL SISTEMA DEBE mostrar todos los entrenamientos persistidos del usuario ordenados por `updatedAt` descendente, con nombre y cantidad de ejercicios de cada uno.

### R2 — Crear entrenamiento vacio

DONDE el usuario esta en la pantalla **Mis entrenamientos**, CUANDO el usuario crea un entrenamiento nuevo con un nombre no vacio (maximo 80 caracteres), EL SISTEMA DEBE persistir un `Workout` sin ejercicios y abrir la pantalla de edicion de ese entrenamiento.

### R3 — Agregar ejercicio al entrenamiento

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO agrega un ejercicio con nombre no vacio (maximo 50 caracteres), `sets` entre 1 y 99, `workSeconds` entre 1 y 5999 (00:01–99:59) y `restSeconds` entre 0 y 5999, EL SISTEMA DEBE persistir el ejercicio asociado al entrenamiento con un orden (`position`) al final de la lista.

### R4 — Editar ejercicio existente

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO modifica los campos de un ejercicio existente y confirma guardar, EL SISTEMA DEBE persistir los nuevos valores y actualizar `updatedAt` del entrenamiento.

### R5 — Eliminar ejercicio del entrenamiento

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO el usuario elimina un ejercicio, EL SISTEMA DEBE quitarlo de la lista persistida y recompactar las posiciones restantes sin huecos (0..n-1).

### R6 — Reordenar ejercicios

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO reordena ejercicios mediante arrastre en la lista, EL SISTEMA DEBE actualizar `position` y persistir el nuevo orden en el mismo gesto (sin boton adicional de guardar orden).

### R7 — Guardar entrenamiento con ejercicios

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO confirma guardar o regresa a **Mis entrenamientos** con al menos un ejercicio valido persistido, EL SISTEMA DEBE mantener el entrenamiento completo en drift y reflejarlo en el listado.

### R8 — Aplanar entrenamiento para ejecucion

CUANDO el usuario inicia un entrenamiento desde **Mis entrenamientos** o desde su pantalla de edicion, EL SISTEMA DEBE generar una secuencia lineal de intervalos segun el algoritmo de `design.md` (un intervalo de trabajo por set y un intervalo de descanso entre sets del mismo ejercicio, sin descanso **entre-sets** tras el ultimo set del ejercicio) y cargarla en `TimerController` (F01) en estado `idle`.

> **Extension F34:** el aplanado se amplía con `restAfterExerciseSeconds` (descanso final del ejercicio **solo** si hay ejercicio siguiente). Ver `34-exercise-rest-between-and-final/`. Hasta implementar F34, no hay descanso post-ejercicio (equivalente a `restAfterExerciseSeconds = 0`).

### R9 — Iniciar sesion del entrenamiento

DONDE el usuario esta en la pantalla de creacion/ejecucion de F01 tras cargar un entrenamiento (R8), CUANDO pulsa iniciar sesion, EL SISTEMA DEBE ejecutar la secuencia aplanada con el comportamiento estandar del timer (avance automatico, pausa, skip, cancelar — F01).

### R10 — Duplicar entrenamiento

DONDE el usuario esta en **Mis entrenamientos**, CUANDO duplica un entrenamiento, EL SISTEMA DEBE crear una copia persistida independiente con nombre `"Copia de {nombre}"` (sufijo numerico `(2)`, `(3)`, etc. si hay conflicto), copiar todos los ejercicios con nuevos IDs, y abrir la pantalla de edicion de la copia.

### R11 — Eliminar entrenamiento

DONDE el usuario esta en **Mis entrenamientos**, CUANDO el usuario solicita eliminar un entrenamiento, EL SISTEMA DEBE mostrar un dialogo de confirmacion destructiva segun `_global/04-design-system.md` y, solo si confirma, eliminar el entrenamiento y sus ejercicios de drift.

### R12 — Renombrar entrenamiento

DONDE el usuario esta en la pantalla de edicion de un entrenamiento, CUANDO modifica el nombre y guarda con un valor no vacio de hasta 80 caracteres, EL SISTEMA DEBE persistir el nuevo nombre y actualizar `updatedAt`.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R13 — Entrenamiento sin ejercicios al iniciar

DONDE el usuario esta en la pantalla de edicion o en **Mis entrenamientos**, CUANDO intenta iniciar un entrenamiento sin al menos un ejercicio persistido, EL SISTEMA DEBE impedir la accion y mostrar un mensaje indicando que se requiere al menos un ejercicio.

### R14 — Nombre de entrenamiento invalido

CUANDO el usuario intenta crear o renombrar un entrenamiento con nombre vacio, solo espacios, o mas de 80 caracteres, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir cambios.

### R15 — Campos de ejercicio invalidos

CUANDO el usuario intenta guardar un ejercicio con nombre invalido (vacio, solo espacios, o >50 caracteres), `sets` fuera de 1–99, o duraciones de trabajo/descanso fuera de los rangos permitidos, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir el ejercicio.

### R16 — Error de persistencia

CUANDO falla guardado, reordenamiento o eliminacion por error de la base de datos local, EL SISTEMA DEBE mostrar un SnackBar con mensaje claro y opcion de reintentar, sin dejar la UI inconsistente respecto a lo persistido (ver `_global/04-design-system.md`).

### R17 — Eliminar durante sesion activa

CUANDO el temporizador esta en estado `running` o `paused`, EL SISTEMA DEBE impedir eliminar cualquier entrenamiento y mostrar un mensaje indicando que debe finalizar o cancelar la sesion primero.

### R18 — Cancelar eliminacion de entrenamiento

DONDE el usuario esta en el dialogo de confirmacion de eliminacion, CUANDO cancela o cierra el dialogo, EL SISTEMA DEBE mantener el entrenamiento sin cambios.

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| F32 vs F05 | **F32** = entrenamientos con ejercicios y sets (modelo estructurado). **F05** = rutinas con intervalos planos. Coexisten; F32 no depende de F05 ni de F03. |
| Algoritmo de aplanado (R8) | Por cada ejercicio en orden de `position`, por cada set de 1 a `sets`: (1) intervalo `work` con nombre del ejercicio y `workSeconds`; (2) si el set no es el ultimo, intervalo `rest` con nombre `"Descanso"` y `restSeconds`. Sin descanso **entre-sets** tras el ultimo set del ejercicio. **F34** agrega, tras completar los sets de un ejercicio no final, un descanso final opcional (`restAfterExerciseSeconds`) si > 0. |
| `restSeconds = 0` | Permitido: el intervalo de descanso entre sets se omite (avance inmediato al siguiente set). |
| Descanso final entre ejercicios | **Fuera del alcance de F32 base;** formalizado en **F34** (`restAfterExerciseSeconds`). F32 solo modela `restSeconds` entre sets. |
| Identificador en sesion (F01/F04) | Al aplanar, `SessionCompletedEvent.routineId` usa el `workoutId` como referencia de origen; el snapshot de sesion guarda el nombre del entrenamiento (F04). |
| Entrenamiento activo | Clave `active_workout_id` en drift (`app_preferences`); independiente de `active_routine_id` de F05. |
| Colores en intervalos aplanados | Trabajo: color `work` por defecto de tema; descanso: color `rest` por defecto (`04-design-system.md`). |
| Media / animaciones de ejercicio | Fuera de alcance (F03 catalogo empaquetado). F32 solo usa nombre textual. |

## Fuera de alcance (explicito)

- Intervalos sueltos sin modelo ejercicio+sets (F01 draft / F05 rutinas planas).
- Duplicar presets empaquetados (F03/F05).
- Bloques anidados y rounds sobre grupos de ejercicios (**alcance de F08**, no de F32 base).
- Conteo automatico de repeticiones (F10).
- Limite de entrenamientos por tier Pro (F06).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; delimitacion F01 vs bibliotecas.
- `_global/02-architecture-and-structure.md` — `features/workout_builder/`, drift, Riverpod.
- `_global/03-conventions.md` — EARS, testing, providers.
- `_global/04-design-system.md` — confirmacion destructiva, estados vacio/error.
- `_global/05-data-model.md` — entidades `Workout`, `WorkoutExercise`; aplanado a `Interval`.