# Requirements: Repeticion de Circuitos (Rounds)

> Estado: Absorbida por F32 (Workout.rounds)

**ID:** F08 &nbsp;|&nbsp; **Slug:** `08-circuit-repetition-rounds` &nbsp;|&nbsp; **Fase:** Fase 2 · Profundidad de Entrenamiento

> **Nota:** La repetición de rondas a nivel de entrenamiento fue completamente implementada en F32 (`Workout.rounds`, `WorkoutFlattener`, `WorkoutRoundsCard`), haciendo innecesaria una especificación separada.

## Resumen

Extiende el **constructor de entrenamientos (F32)** para que el usuario pueda **agrupar ejercicios en un circuito** y repetir ese grupo **N rondas** sin duplicar a mano la lista.

- **Sets** (F32) = repetir **un** ejercicio.
- **Rondas** (F08) = repetir un **grupo ordenado** de ejercicios (circuito).

Los tiempos de trabajo y descanso **se heredan** de cada ejercicio (F32/F34). F08 no introduce un segundo editor de duraciones. La ejecucion reutiliza el timer (F01/F35) sobre la secuencia **ya expandida** por `WorkoutFlattener`.

No se agrega seccion nueva en el shell (Entrenamientos / Historial / Ajustes). El circuito vive **dentro del editor del entrenamiento**.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F32 - Constructor de Entrenamientos por Ejercicios
- F34 - Descanso entre Sets y Descanso Final del Ejercicio (aplanado dual de rests; F08 lo consume)

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** agrupar varios ejercicios de un entrenamiento en un circuito con N rondas, **para que** no tengo que copiar a mano la misma secuencia varias veces.
- **Como** usuario, **quiero** editar las rondas de un circuito o desagrupar los ejercicios, **para que** puedo ajustar la sesion sin rearmar el entrenamiento.
- **Como** usuario, **quiero** ver en ejecucion en que ronda voy (ej. "Ronda 2 de 3"), **para que** se donde estoy dentro del circuito.
- **Como** usuario, **quiero** que al entrenar se respeten sets y descansos ya configurados en cada ejercicio, **para que** no reconfiguro tiempos al armar el circuito.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Multi-seleccion en el editor de entrenamiento

DONDE el usuario esta en la pantalla de edicion de un entrenamiento (F32) con al menos dos ejercicios, CUANDO activa el modo de seleccion multiple, EL SISTEMA DEBE permitir marcar y desmarcar ejercicios individuales de la lista.

### R2 — Agrupar seleccion en circuito

DONDE el usuario tiene dos o mas ejercicios seleccionados en el editor, CUANDO confirma **Agrupar en circuito**, EL SISTEMA DEBE:

1. crear un circuito con esos ejercicios en un orden estable (ver Decisiones de producto);
2. asignar `rounds = 1` por defecto;
3. persistir el circuito y la membresia de ejercicios;
4. salir del modo seleccion y mostrar el circuito como grupo visual en la lista;
5. actualizar `updatedAt` del entrenamiento.

### R3 — Visualizacion del circuito en el editor

DONDE el entrenamiento tiene al menos un circuito, CUANDO el usuario ve la lista del editor, EL SISTEMA DEBE mostrar cada circuito como un contenedor anidado con:

- etiqueta **Circuito**;
- control o resumen de **rondas** (valor actual);
- los ejercicios miembros en orden, reutilizando el look de fila de ejercicio F32 (nombre, sets, resumen de duraciones).

Los ejercicios **fuera** de circuito se muestran como filas de nivel superior (comportamiento F32).

### R4 — Configurar numero de rondas

DONDE el usuario edita un circuito (desde el header del grupo o sheet de configuracion), CUANDO establece un numero de rondas entero entre **1 y 99** inclusive y confirma, EL SISTEMA DEBE persistir ese valor y reflejarlo en el header del circuito.

### R5 — Desagrupar circuito

DONDE el usuario solicita desagrupar un circuito, CUANDO confirma la accion, EL SISTEMA DEBE:

1. eliminar el circuito;
2. dejar los ejercicios miembros como ejercicios de nivel superior del mismo entrenamiento, en orden relativo estable;
3. no borrar ni resetear sets/tiempos de esos ejercicios;
4. actualizar `updatedAt` del entrenamiento.

### R6 — Reordenar ejercicios dentro del circuito

DONDE el usuario esta en el editor y un circuito tiene dos o mas ejercicios, CUANDO reordena ejercicios **dentro** del circuito por arrastre, EL SISTEMA DEBE persistir el nuevo orden de miembros del circuito en el mismo gesto (sin boton extra de guardar orden).

### R7 — Reordenar circuitos y ejercicios sueltos a nivel entrenamiento

DONDE el entrenamiento tiene una mezcla de circuitos y/o ejercicios sueltos, CUANDO el usuario reordena elementos de **nivel superior** (un circuito completo cuenta como una unidad; un ejercicio suelto cuenta como una unidad), EL SISTEMA DEBE persistir el nuevo orden de nivel superior.

### R8 — Un solo nivel de anidacion

DONDE el usuario intenta agrupar ejercicios, SI alguno de los seleccionados ya pertenece a un circuito, ENTONCES EL SISTEMA DEBE impedir crear un circuito anidado (no hay circuitos dentro de circuitos) y mostrar un mensaje claro (ver R16).

### R9 — Aplanado: expansion de rondas

CUANDO el usuario inicia un entrenamiento que contiene uno o mas circuitos, EL SISTEMA DEBE generar la secuencia lineal de intervalos expandiendo cada circuito **antes** de cargarla en `TimerController` (F01):

Para cada elemento de nivel superior en orden:

- **Ejercicio suelto:** aplanar con las reglas F32/F34 (sets, `restSeconds`, `restAfterExerciseSeconds` respecto del **siguiente** elemento de ejecucion).
- **Circuito con `rounds = R` y miembros E1..Ek en orden:** para `r = 1..R`, aplanar E1..Ek en ese orden con las reglas de sets/rest de F32/F34, donde el "siguiente" tras un ejercicio es el siguiente miembro del circuito en la misma ronda, o el primer miembro de la ronda siguiente, o el siguiente elemento de nivel superior tras la ultima ronda (ver Decisiones de producto y `design.md`).

La secuencia aplanada **no** se persiste en drift.

### R10 — Herencia de tiempos (sin reconfigurar en F08)

CUANDO se aplana un circuito, EL SISTEMA DEBE usar exclusivamente los valores ya persistidos en cada `WorkoutExercise` (`workSeconds`, `sets`, `restSeconds`, `restAfterExerciseSeconds`). F08 **no** introduce campos de duracion propios del circuito.

### R11 — Metadata de ronda en la secuencia efectiva

CUANDO se aplana un circuito con `rounds >= 1`, EL SISTEMA DEBE asociar a cada intervalo emitido **dentro** de ese circuito metadata de ronda (`roundIndex` 1-based, `roundCount = rounds`, y referencia al circuito) suficiente para la UI de ejecucion (R12). Los intervalos de ejercicios sueltos (fuera de circuito) **no** requieren metadata de ronda.

### R12 — Indicador "Ronda X de Y" en ejecucion

DONDE el usuario esta en la pantalla de ejecucion del timer (F01/F35) y el intervalo actual pertenece a un circuito con `rounds >= 1`, CUANDO la sesion esta en `running`, `paused` o en el intervalo activo de ese circuito, EL SISTEMA DEBE mostrar de forma visible el texto **`Ronda {roundIndex} de {roundCount}`** (o chip equivalente con el mismo significado).

SI el intervalo actual no pertenece a un circuito, ENTONCES EL SISTEMA DEBE **no** mostrar ese indicador de ronda.

### R13 — Tiempo restante total sobre secuencia expandida (F35)

CUANDO una sesion se inicia desde un entrenamiento con circuitos, EL SISTEMA DEBE calcular `totalRemainingMs` / restante total (F35) sobre la lista de intervalos **ya expandida** (misma secuencia que ejecuta el controller), no sobre la estructura declarativa sin expandir rondas.

### R14 — Duplicar entrenamiento copia circuitos

DONDE el usuario duplica un entrenamiento (F32 R10), CUANDO se crea la copia, EL SISTEMA DEBE copiar circuitos y membresias con **nuevos IDs**, mismos `rounds` y mismo orden relativo de ejercicios/miembros, junto con sets y tiempos de cada ejercicio.

### R15 — Migracion / workouts sin circuito

CUANDO el usuario actualiza la app y existen entrenamientos previos a F08, EL SISTEMA DEBE tratarlos como lista plana de ejercicios sin circuitos (`rounds` no aplica). El aplanado y la UX deben ser **identicos** al comportamiento pre-F08 (equivalente a no haber circuitos).

### R16 — Badge opcional en listado (nice-to-have in-scope)

DONDE el usuario esta en **Mis entrenamientos** y un entrenamiento tiene al menos un circuito con `rounds >= 1`, EL SISTEMA DEBE mostrar un indicador sutil en la card (ej. icono de loop y/o texto `Circuito · ×{maxRounds}` o `N circuitos`) sin saturar el layout F32.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R17 — Agrupar con menos de dos ejercicios

DONDE el usuario esta en modo seleccion, CUANDO intenta agrupar con **menos de 2** ejercicios seleccionados, EL SISTEMA DEBE impedir la accion y mostrar un mensaje indicando que se requieren al menos dos ejercicios.

### R18 — Rondas fuera de rango

CUANDO el usuario intenta guardar un circuito con `rounds < 1` o `rounds > 99`, EL SISTEMA DEBE rechazar el valor y mostrar validacion visible sin persistir el cambio invalido.

### R19 — Seleccion incluye ejercicios de distintos circuitos o ya agrupados

CUANDO el usuario selecciona ejercicios que ya pertenecen a uno o mas circuitos e intenta **Agrupar en circuito**, EL SISTEMA DEBE rechazar la operacion (R8) y mostrar un mensaje claro (desagrupar primero o seleccionar solo ejercicios sueltos).

### R20 — Error de persistencia

CUANDO falla guardar circuito, desagrupar, reordenar o cambiar rondas por error de base de datos local, EL SISTEMA DEBE mostrar un SnackBar con mensaje claro y opcion de reintentar segun `_global/04-design-system.md`, sin dejar la UI inconsistente respecto a lo persistido.

### R21 — Iniciar entrenamiento vacio o sin ejercicios (regresion F32)

DONDE el entrenamiento no tiene al menos un ejercicio (con o sin circuitos), CUANDO el usuario intenta iniciar, EL SISTEMA DEBE impedir la accion como en F32 R13 (mensaje de al menos un ejercicio). Un circuito sin miembros no debe ser posible tras validaciones de agrupar/desagrupar; si ocurre por corrupcion, se trata como error de datos y se impide iniciar con mensaje claro.

### R22 — Cancelar desagrupar

DONDE el usuario ve una confirmacion de desagrupar (si el producto usa dialogo), CUANDO cancela o cierra el dialogo, EL SISTEMA DEBE mantener el circuito y sus miembros sin cambios.

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| Eje de dominio | **Workout (F32)**, no `Routine` / F05. F05 **no** es prerequisito. |
| Donde se configura | **Dentro del editor de entrenamiento** (multi-select + Agrupar). **No** opcion aparte "Crear rutina" en el menu Entrenar/Editar/Duplicar/Eliminar. **No** tab nuevo en el shell. |
| Sets vs rondas | **Sets** = repeticion de un ejercicio. **Rondas** = repeticion del grupo (circuito). Coexisten: un ejercicio del circuito puede tener 3 sets y el circuito 4 rondas. |
| Tiempos / descansos | **Heredados** de cada ejercicio (`workSeconds`, `restSeconds`, `restAfterExerciseSeconds`). F08 no edita duraciones del circuito. |
| Min ejercicios por circuito | **2**. |
| Rango de rondas | **1–99**; default al agrupar = **1** (mismo orden de ejecucion que lista plana de esos ejercicios una vez). |
| Anidacion | **Maximo un nivel** (sin circuitos dentro de circuitos). |
| Seleccion no contigua | Permitida. Al agrupar, los miembros quedan en un bloque contiguo: se reordenan al final de la zona de insercion (posicion del primer seleccionado en el orden de lista actual) conservando el **orden relativo** en que aparecian en la lista. |
| Varios circuitos por workout | **Si**. Un entrenamiento puede mezclar circuitos y ejercicios sueltos. |
| `restAfterExerciseSeconds` en circuito | Se emite cuando hay un **siguiente trabajo** que no es otro set del mismo ejercicio: siguiente miembro del circuito en la misma ronda; o primer miembro de la **siguiente ronda**; o primer intervalo del **siguiente** elemento de nivel superior tras la ultima ronda. **No** se emite tras el ultimo ejercicio del **ultimo** elemento del workout (regla F34 de fin de sesion). |
| Ultimo ejercicio del circuito y ultima ronda | Si el circuito **no** es el ultimo elemento del workout y `restAfterExerciseSeconds > 0`, emitir descanso final antes del siguiente elemento de nivel superior. Si el circuito **es** el ultimo elemento, no emitir descanso final tras su ultimo work (fin de sesion). |
| Metadata de ronda | Solo intervalos pertenecientes a un circuito expandido; ejercicios sueltos sin chip de ronda. |
| Skip / prep / remaining (F35) | Operan sobre la secuencia expandida; prep una vez al inicio (F35). |
| Modulo de codigo | Extender `features/workout_builder/` (mismo patron que F34). La carpeta `circuit_rounds/` en architecture queda como alias documentado o se omite en favor de `workout_builder` (ver design). |
| F05 / Routine.Block | **Fuera de alcance.** El `Block` historico sobre `RoutineItem` no se implementa en F08. Si en el futuro se quieren rounds en rutinas planas, sera otra iteracion. |
| Menu de card del listado | Sin accion nueva "Crear circuito"; solo badge (R16). Entrar por **Editar**. |

## Fuera de alcance (explicito)

- Biblioteca de rutinas planas (F05) y bloques sobre `Routine` / intervalos sueltos.
- Nueva pestana o seccion del shell para circuitos.
- Pantalla separada "Crear rutina/circuito" desde el menu de acciones del listado (Entrenar/Editar/Duplicar/Eliminar).
- Reconfigurar work/rest a nivel circuito (usa F32/F34).
- Circuitos anidados (mas de un nivel).
- Rondas a nivel de set individual distintas del modelo sets (eso ya es F32).
- Media / animaciones de ejercicio (F03).
- Progresion automatica de rondas (F09).
- Limites Pro (F06).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; flujo principal de entrenamientos.
- `_global/02-architecture-and-structure.md` — `features/workout_builder/`, capas, Riverpod/drift.
- `_global/03-conventions.md` — EARS, testing, providers.
- `_global/04-design-system.md` — SnackBar error, dialogos, chips/labels.
- `_global/05-data-model.md` — `Workout`, `WorkoutExercise`, `WorkoutCircuit`, aplanado.
- `32-workout-exercise-builder/` — editor, CRUD, load al timer.
- `34-exercise-rest-between-and-final/` — dual rest y semantica de aplanado.
- `35-timer-navigation-prep-settings/` — prep, skip, `totalRemainingMs` sobre secuencia efectiva.
- `33-premium-numeric-steppers/` — `NumberStepper` para rondas.
