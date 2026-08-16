# Tasks: Repeticion de Circuitos (Rounds)

**ID:** F08 &nbsp;|&nbsp; **Slug:** `08-circuit-repetition-rounds`

> **Nota:** Las tareas de esta especificación fueron absorbidas y resueltas completamente por F32 (`Workout.rounds`, `WorkoutFlattener`, `WorkoutRoundsCard`).

## Definition of Done

- [ ] Criterios **R1–R22** de `requirements.md` implementados y verificados.
- [ ] Tests unitarios/widget listados abajo en verde.
- [ ] Workouts **sin** circuito producen el mismo aplanado funcional que pre-F08 (regresion F32/F34).
- [ ] No se rompio F32/F34/F35 (suite existente en verde).
- [ ] Self-review / PR contra `_global/03-conventions.md` y `_global/05-data-model.md`.
- [ ] Checklist de accesibilidad de `_global/03-conventions.md` en controles nuevos (stepper rondas, multi-select, chip de ronda).

## Checklist de implementacion

### Datos y dominio

- [ ] Actualizar `_global/05-data-model.md` ya alineado; implementar entidades `WorkoutCircuit` y `circuitId` en `WorkoutExercise` en domain. _(cubre R2, R4, R5, R15)_
- [ ] Migracion drift schema **v6**: tabla `workout_circuits` + columna `workout_exercises.circuit_id` nullable FK; backfill null. _(cubre R15)_
- [ ] Extender mappers drift ↔ dominio (workout aggregate con top-level + miembros). _(cubre R2, R3, R14)_
- [ ] Extender `WorkoutRepository`: `groupIntoCircuit`, `updateCircuitRounds`, `ungroupCircuit`, `reorderTopLevel`, `reorderWithinCircuit`; `duplicateWorkout` copia circuitos. _(cubre R2, R4, R5, R6, R7, R14, R17, R18, R19, R20)_
- [ ] Validadores de dominio: min 2 ejercicios, solo sueltos, rounds 1–99, no anidacion. _(cubre R8, R17, R18, R19)_

### Aplanado y timer

- [ ] Extender `WorkoutFlattener` con `FlattenedInterval` / metadata de ronda y expansion de circuitos (reglas rest F32/F34 + emitFinalRest entre miembros/rondas/top-level). _(cubre R9, R10, R11)_
- [ ] Path de carga al timer: usar lista expandida + pasar metadata de ronda a estado de sesion / holder legible por UI. _(cubre R9, R11, R12, R13)_
- [ ] Verificar `totalRemainingMs` (F35) y skip operan sobre secuencia expandida (sin cambio de API si ya usan la lista del controller). _(cubre R13)_

### UI editor (F32)

- [ ] Modo multi-seleccion en editor de entrenamiento (checkboxes + entrar/salir de modo). _(cubre R1)_
- [ ] CTA **Agrupar en circuito** + mensajes de validacion (&lt;2, ya agrupados). _(cubre R2, R17, R19)_
- [ ] Card/contenedor visual de circuito (header Circuito + rondas + miembros). _(cubre R3)_
- [ ] Configurar rondas (`NumberStepper` F33) en header o bottom sheet; validacion 1–99. _(cubre R4, R18)_
- [ ] Accion **Desagrupar** (+ dialogo cancelable si aplica). _(cubre R5, R22)_
- [ ] Reorder intra-circuito y reorder top-level (circuito como unidad). _(cubre R6, R7)_
- [ ] SnackBar error DB + reintentar en fallos de persistencia de circuito. _(cubre R20)_
- [ ] Impedir iniciar sin ejercicios (regresion F32 R13 / R21). _(cubre R21)_

### UI listado y ejecucion

- [ ] Badge sutil en card de **Mis entrenamientos** si hay circuitos. _(cubre R16)_
- [ ] Chip/texto **Ronda X de Y** en pantalla de ejecucion del timer cuando hay metadata; oculto si no. _(cubre R12)_

### Tests

- [ ] Unit: aplanado sin circuitos = regresion F32/F34 (mismos tipos/duraciones/orden). _(cubre R9, R10, R15)_
- [ ] Unit: circuito 2 ejercicios × 2 rondas expande orden A,B,A,B (con rests segun F34). _(cubre R9, R10, R11)_
- [ ] Unit: `restAfter` entre miembros, entre rondas, y omitido al fin de workout. _(cubre R9, R10)_
- [ ] Unit: `groupIntoCircuit` / `ungroup` / rounds invalidos / &lt;2 ejercicios / ya en circuito. _(cubre R2, R5, R8, R17, R18, R19)_
- [ ] Unit: `duplicateWorkout` clona circuitos con nuevos IDs y mismos rounds. _(cubre R14)_
- [ ] Unit: metadata `roundIndex/roundCount` en intervalos de circuito; null en sueltos. _(cubre R11)_
- [ ] Widget: editor muestra card de circuito y multi-select + CTA. _(cubre R1, R2, R3)_
- [ ] Widget: timer muestra "Ronda 2 de 3" con meta de prueba; no muestra sin meta. _(cubre R12)_

## Notas de secuenciacion

Esta feature depende de: **F01, F32, F34** (F33 y F35 recomendados en codigo ya presentes).

Orden sugerido:

1. Migracion + entidades + repo  
2. Flattener + tests unitarios de aplanado  
3. Integracion load timer + metadata  
4. UI editor (select → group → rounds → ungroup → reorder)  
5. Badge listado + chip timer  
6. Widget tests + suite completa  

No iniciar hasta prerequisitos en estado **Completado** (F32 y F34 ya lo estan en este repo).

## Mapa de trazabilidad

| Criterio | Tareas (resumen) |
|---|---|
| R1 | Multi-select editor; widget editor |
| R2 | Repo group; CTA agrupar; validadores |
| R3 | Card circuito UI |
| R4 | updateCircuitRounds; stepper/sheet |
| R5 | ungroupCircuit; UI desagrupar |
| R6 | reorderWithinCircuit |
| R7 | reorderTopLevel |
| R8 | Validador no anidacion; R19 |
| R9 | Flattener expansion; tests aplanado |
| R10 | Flattener usa campos ejercicio; tests rest |
| R11 | FlattenedInterval meta; tests meta |
| R12 | Chip timer; widget timer |
| R13 | Load expandido + remaining F35 |
| R14 | duplicateWorkout + test |
| R15 | Migracion v6; test regresion sin circuito |
| R16 | Badge listado |
| R17 | Validacion &lt;2 + UI |
| R18 | Validacion rounds + UI |
| R19 | Validacion ya agrupados + UI |
| R20 | SnackBar error repo |
| R21 | Guard inicio vacio (F32) |
| R22 | Cancelar dialogo desagrupar |
