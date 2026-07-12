# Tasks: Calendario e Historial de Sesiones

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history`

## Definition of Done

- [ ] Todos los criterios R1–R22 de `requirements.md` estan implementados y verificados. _(cubre R1–R22)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] Schema `session_logs` documentado en `_global/05-data-model.md` y migracion aditiva aplicada.
- [ ] No se rompieron F01 (eventos) ni consumidores futuros; listener no acopla UI del timer.
- [ ] Codigo revisado contra `_global/03-conventions.md`.
- [ ] UI alineada a wireframe de `design.md` y criterios R4–R13 y R22 (mes izq, hoy der, cards, sheet, tab en bottom bar).

## Checklist de implementacion

### Datos y persistencia

- [ ] Definir modelo de dominio `SessionLog` + enum `SessionLogStatus`. _(cubre R1, R2)_
- [ ] Crear tabla drift `session_logs`, DAO e indices (`local_date`, `ended_at`). _(cubre R1, R3)_
- [ ] Implementar `SessionLogRepository` (insert, watch/get by day, get marker dates for month, updateNote, delete). _(cubre R1, R3, R9, R10, R11, R15)_
- [ ] Actualizar `_global/05-data-model.md` con schema F04 y version de migracion. _(cubre R3)_

### Integracion con F01

- [ ] Implementar `SessionHistoryListener`: mapear `SessionCompletedEvent` → insert completed. _(cubre R1)_
- [ ] Mapear `SessionCancelledEvent` → insert aborted solo si `elapsedSeconds > 0`. _(cubre R2)_
- [ ] Resolver `displayName` desde rutina/workout activo al persistir; fallback vacio. _(cubre R1, R10)_
- [ ] Manejar fallo de insert sin crashear (log + continuar). _(cubre R18)_
- [ ] Registrar el listener una sola vez en bootstrap de app (no en rebuild de pantalla). _(cubre R1, R2)_

### Logica de UI (controller)

- [ ] Implementar `HistoryController` (Riverpod): `focusedMonth`, `selectedDate`, carga de mes. _(cubre R5, R6, R7, R17)_
- [ ] Cambiar mes desde selector; clamp de dia invalido (ej. 31→ultimo dia). _(cubre R5)_
- [ ] Accion "hoy": mes actual + seleccionar hoy. _(cubre R6)_
- [ ] Providers derivados: logs del dia (orden desc), set de fechas con actividad. _(cubre R9, R10, R16)_

### UI

- [ ] Construir `HistoryScreen` con layout: header → calendario → lista. _(cubre R4, R7, R10)_
- [ ] `HistoryMonthHeader`: selector de mes izquierda + boton hoy derecha (>= 48 dp). _(cubre R4, R5, R6)_
- [ ] Integrar `table_calendar` (^3.2.0): month only, Monday start, header del paquete oculto, estilos theme. _(cubre R7, R8, R9)_
- [ ] Marcadores en dias con logs; estilos selected / today segun R7. _(cubre R7, R9)_
- [ ] Lista de `SessionLogCard` con titulo/fallback, duracion, `Ejercicios: N`, overflow. _(cubre R10)_
- [ ] Zona de nota + editor (max 500) con persistencia `updateNote`. _(cubre R11, R12)_
- [ ] Bottom sheet acciones: cabecera info, Empezar, Eliminar. _(cubre R13)_
- [ ] Flujo Empezar: resolver sourceId → cargar timer → navegar; error si no existe. _(cubre R14)_
- [ ] Dialog confirmacion + delete + refresh markers/lista. _(cubre R15)_
- [ ] Estado vacio del dia y loading inicial. _(cubre R16, R17)_
- [ ] SnackBars de error en nota / delete. _(cubre R19, R20)_
- [ ] Mes sin datos sin error (solo sin markers + vacio). _(cubre R21)_
- [ ] Registrar destino **Historial** en el shell (`NavigationBar` / `StatefulShellRoute`): orden Temporizador | Entrenamientos | **Historial** | Ajustes; icono calendario; ruta a `HistoryScreen`. _(cubre R22)_

### Tests

- [ ] **Unit — happy path:** completed event inserta log completed con campos correctos y `local_date`. _(cubre R1, R3)_
- [ ] **Unit — cancel:** cancelled con elapsed > 0 inserta aborted; elapsed == 0 no inserta. _(cubre R2)_
- [ ] **Unit — note:** updateNote persiste y rechaza/limita > 500 chars. _(cubre R11, R12)_
- [ ] **Unit — delete:** delete elimina registro; queries del dia vacias. _(cubre R15)_
- [ ] **Unit — markers:** set de fechas del mes solo incluye dias con logs. _(cubre R9)_
- [ ] **Unit — edge:** fallo de insert no propaga crash al listener (R18). _(cubre R18)_
- [ ] **Widget — header/calendar:** selector de mes y boton hoy actualizan focused/selected. _(cubre R4, R5, R6)_
- [ ] **Widget — cards:** con logs del dia muestra titulo/duracion/ejercicios y placeholder de nota. _(cubre R10, R11)_
- [ ] **Widget — sheet:** overflow abre sheet con Empezar y Eliminar; no muestra Compartir/Guardar. _(cubre R13)_
- [ ] **Widget — vacio:** dia sin logs muestra mensaje vacio. _(cubre R16)_
- [ ] **Widget — shell:** barra inferior incluye 4 destinos en orden correcto; activar Historial muestra `HistoryScreen` y estado selected. _(cubre R22)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Modelo, repo insert, listener completed, unit happy path |
| R2 | Listener cancel, unit cancel |
| R3 | Tabla drift, repo, unit happy path |
| R4 | HistoryMonthHeader, HistoryScreen, widget header |
| R5 | HistoryController mes, widget header |
| R6 | Accion hoy, widget header |
| R7 | HistoryCalendar table_calendar styles |
| R8 | onDaySelected / controller |
| R9 | markers provider, calendar builders, unit markers |
| R10 | SessionLogCard, lista, widget cards |
| R11 | Zona nota, editor, updateNote, unit note, widget cards |
| R12 | Validacion 500, unit note |
| R13 | SessionLogActionsSheet, widget sheet |
| R14 | Flujo Empezar + navegacion |
| R15 | Dialog + delete + refresh, unit delete |
| R16 | Estado vacio, widget vacio |
| R17 | Loading AsyncNotifier / screen |
| R18 | Listener error handling, unit edge |
| R19 | SnackBar nota |
| R20 | SnackBar delete |
| R21 | Mes sin markers + vacio |
| R22 | Shell NavigationBar + ruta Historial, widget shell |

## Notas de secuenciacion

Esta feature depende de: **F01** (streams de sesion estables).

- No iniciar hasta que F01 exponga `SessionCompletedEvent` / `SessionCancelledEvent` segun contrato global.
- Si F32 ya esta en el codebase, el flujo Empezar debe soportar `workoutId` en `sourceId` (ver `05-data-model.md`).
- Coordinar numero de `schemaVersion` con migraciones existentes al implementar.
- **R22 es obligatorio en F04:** insertar tab Historial entre Entrenamientos y Ajustes en `app/` (shell/`go_router`). `HistoryScreen` vive en `features/calendar_history/`.
