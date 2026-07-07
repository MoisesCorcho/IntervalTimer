# Tasks: Interval Timer Core

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core`

## Definition of Done

- [x] Todos los criterios R1–R18 de `requirements.md` estan implementados y verificados. _(cubre R1–R18)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Schema drift documentado en `_global/05-data-model.md` y migracion inicial aplicada.
- [x] No se rompieron features previas (ninguna — feature fundacional).
- [x] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Datos y persistencia

- [x] Definir modelos `Interval`, `RoutineItem` (union interval-only en F01) y `Routine`. _(cubre R1)_
- [x] Crear tablas drift (`intervals`, `routines`, `routine_items`) y `RoutineRepository`. _(cubre R1, R10)_
- [x] Actualizar `_global/05-data-model.md` con schema y relaciones de F01. _(cubre R1)_

### Logica del temporizador

- [x] Implementar `TimerController` (Riverpod) con maquina de estados idle/running/paused/completed. _(cubre R4, R10, R14, R15)_
- [x] Implementar calculo de tiempo restante basado en timestamps (no decremento por tick). _(cubre R4, R5, R14)_
- [x] Implementar avance automatico entre intervalos al llegar a 0. _(cubre R3, R6)_
- [x] Implementar skip: avanzar al siguiente si hay posteriores; si es el ultimo (o rutina de 1 intervalo), completar sesion. _(cubre R7)_
- [x] Implementar cancelar sesion: volver a idle y emitir `SessionCancelled`. _(cubre R8)_
- [x] Exponer streams `SessionCompleted` y `SessionCancelled` con contrato de `design.md`. _(cubre R6, R8)_
- [x] Manejar condicion de carrera pausa vs avance (pausa prioritaria). _(cubre R16)_

### UI

- [x] Construir pantalla de creacion/edicion con formulario nombre, duracion mm:ss y color picker. _(cubre R1, R11, R12)_
- [x] Implementar validaciones de nombre (vacio, >50 chars), duracion invalida y rutina vacia al iniciar. _(cubre R11, R12, R13)_
- [x] Construir pantalla de ejecucion: `CountdownRing`/barra, intervalo actual, preview siguiente. _(cubre R2, R9)_
- [x] Implementar controles play, pause, resume, skip, cancelar con area de toque >= 48dp. _(cubre R4, R7, R8, R10)_
- [x] Implementar contraste dinamico texto/fondo en pantalla de ejecucion. _(cubre R17)_
- [x] Bloquear edicion de intervalos fuera de estado `idle`. _(decision de producto — ver requirements)_
- [x] Construir pantalla/resumen post-completado con accion para volver a `idle`. _(cubre R18)_

### Ciclo de vida

- [x] Manejar background/foreground recalculando tiempo desde timestamps (tolerancia ±1s / 60 min). _(cubre R5)_

### Tests

- [x] **Unit — happy path:** maquina de estados idle→running→paused→running→completed; avance automatico R3; evento SessionCompleted R6. _(cubre R3, R4, R6, R10)_
- [x] **Unit — error/edge:** rutina vacia bloquea inicio R13; pausa en idle ignorada R15; pausa gana sobre avance R16; skip en ultimo intervalo y en rutina de 1 intervalo completan sesion R7. _(cubre R7, R13, R15, R16)_
- [x] **Unit — tiempo:** calculo remainingMs tras simulacion de 60 min en background dentro de ±1s R5. _(cubre R5)_
- [x] **Widget — ejecucion:** pantalla muestra tiempo dominante, intervalo actual y preview siguiente en estado running R9. _(cubre R2, R9)_
- [x] **Widget — validacion:** formulario rechaza nombre vacio y nombre >50 chars R11, y duracion 00:00 R12, con mensaje visible. _(cubre R11, R12)_
- [x] **Widget — completado:** tras sesion completada, muestra confirmacion y boton volver a idle R18. _(cubre R18)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Modelos, drift, UI creacion |
| R2 | UI ejecucion, widget test ejecucion |
| R3 | Avance automatico, unit happy path |
| R4 | TimerController, controles pause/resume |
| R5 | Timestamps, lifecycle, unit tiempo |
| R6 | Avance automatico, SessionCompleted, unit happy path |
| R7 | Skip, unit error (ultimo intervalo / 1 intervalo) |
| R8 | Cancelar sesion, SessionCancelled |
| R9 | UI ejecucion, widget test ejecucion |
| R10 | TimerController, controles play, unit happy path |
| R11 | Validaciones UI, widget test validacion |
| R12 | Validaciones UI, widget test validacion |
| R13 | Validacion rutina vacia, unit error |
| R14 | TimerController, calculo timestamps |
| R15 | TimerController, unit error |
| R16 | Condicion de carrera, unit error |
| R17 | Contraste dinamico UI ejecucion |
| R18 | Pantalla post-completado, widget test completado |

## Notas de secuenciacion

Esta feature depende de: ninguna (fundacional).
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
Orden recomendado: datos/persistencia → TimerController → UI creacion → UI ejecucion → lifecycle → tests.