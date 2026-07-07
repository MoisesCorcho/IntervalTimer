# Tasks: Editor de Rutinas Propias

**ID:** F05 &nbsp;|&nbsp; **Slug:** `05-custom-routine-builder`

## Definition of Done

- [ ] Todos los criterios R1–R18 de `requirements.md` estan implementados y verificados manualmente. _(cubre R1–R18)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] Schema drift F05 documentado en `_global/05-data-model.md` y migracion v2 aplicada.
- [ ] No se rompieron features previas F01 ni F03 (timer, presets, duplicacion).
- [ ] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Datos y persistencia

- [ ] Extender modelo `Routine` con `source`, `originId`, `updatedAt` y enum `RoutineSource`. _(cubre R6, R7, R8)_
- [ ] Crear migracion drift v2 (columnas `source`, `origin_id`, `updated_at` en `routines`) con backfill de filas F01. _(cubre R1, R2)_
- [ ] Actualizar `_global/05-data-model.md` con schema F05 antes del primer PR de codigo. _(cubre R1–R11)_
- [ ] Extender `RoutineRepository`: listar, crear vacia, guardar, duplicar (custom y preset), reordenar, eliminar. _(cubre R1–R8, R10–R11)_
- [ ] Implementar `active_routine_id` en `shared_preferences` (get/set/clear). _(cubre R9, R17)_
- [ ] Implementar `duplicateFromPreset(PresetRoutine)` mapeando intervalos a nuevos UUIDs sin tocar assets. _(cubre R7, R8)_

### Logica / controllers

- [ ] Implementar `userRoutinesProvider` (`AsyncNotifier`) para listado ordenado. _(cubre R1)_
- [ ] Implementar `routineBuilderControllerProvider` con save, reorder, validaciones de nombre e intervalos. _(cubre R3–R5, R11–R13)_
- [ ] Implementar `activeRoutineIdProvider` e integracion con `TimerController.loadRoutine` / reset. _(cubre R9, R17)_
- [ ] Bloquear eliminacion si `TimerController` esta en `running` o `paused`. _(cubre R15)_
- [ ] Manejar errores de persistencia con SnackBar + reintentar. _(cubre R14)_

### UI

- [ ] Construir `MyRoutinesScreen` con lista, acciones Usar / Editar / Duplicar / Eliminar. _(cubre R1, R6, R9, R10)_
- [ ] Construir flujo crear rutina vacia (nombre) → `RoutineBuilderScreen`. _(cubre R2, R13)_
- [ ] Construir `RoutineBuilderScreen` con `ReorderableListView` y formulario intervalo reutilizado de F01. _(cubre R3, R4, R5, R11)_
- [ ] Implementar renombrado de rutina en builder. _(cubre R11, R13)_
- [ ] Implementar dialogo de confirmacion destructiva para eliminar. _(cubre R10, R16)_
- [ ] Agregar accion "Duplicar" en catalogo F03 que invoque `duplicateFromPreset`. _(cubre R7, R8)_
- [ ] Registrar rutas `/routines`, `/routines/:id/edit` en `go_router` y acceso desde F01. _(cubre R1, R9)_
- [ ] Mostrar estado vacio en F01 tras eliminar rutina activa (R17). _(cubre R17)_

### Integracion

- [ ] Al "Usar", persistir `active_routine_id`, cargar rutina en timer idle y navegar a F01. _(cubre R9, R18)_
- [ ] Impedir "Usar" en rutinas sin intervalos con mensaje visible. _(cubre R18)_

### Tests

- [ ] **Unit — happy path:** crear rutina vacia; guardar con intervalos; duplicar custom con nombre `"Copia de …"`; duplicar preset con `source=presetDerived` y `originId` correcto. _(cubre R2, R5, R6, R7)_
- [ ] **Unit — happy path:** `reorderItems` actualiza posiciones 0..n-1 sin huecos; listado ordenado por `updatedAt` DESC. _(cubre R1, R4)_
- [ ] **Unit — happy path:** `setActiveRoutineId` + `loadRoutine` deja timer en idle con intervalos correctos. _(cubre R9)_
- [ ] **Unit — error/edge:** guardar sin intervalos rechazado; nombre vacio/>80 chars rechazado. _(cubre R12, R13)_
- [ ] **Unit — error/edge:** delete bloqueado en running/paused; delete en idle limpia `active_routine_id` si coincide. _(cubre R15, R17)_
- [ ] **Unit — error/edge:** duplicar preset no escribe en assets; `originId` inmutable en copia editada. _(cubre R8)_
- [ ] **Widget — Mis rutinas:** lista muestra nombre y conteo; dialogo eliminar tiene boton destructivo separado; cancelar no borra. _(cubre R1, R10, R16)_
- [ ] **Widget — builder:** reordenar dispara persistencia; guardar sin intervalos muestra mensaje. _(cubre R4, R12)_
- [ ] **Widget — usar rutina:** tap Usar con 0 intervalos muestra mensaje; con intervalos navega a F01. _(cubre R9, R18)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Modelo, migracion, repository list, userRoutinesProvider, MyRoutinesScreen, unit listado, widget lista |
| R2 | Repository create, flujo crear, widget crear |
| R3 | Builder screen, formulario F01, controller save |
| R4 | ReorderableListView, reorderItems, unit reorder, widget reorder |
| R5 | Controller save, builder guardar |
| R6 | duplicateRoutine, MyRoutinesScreen, unit duplicar custom |
| R7 | duplicateFromPreset, accion F03, unit duplicar preset |
| R8 | duplicateFromPreset, unit preset intacto |
| R9 | activeRoutineId, TimerController, Usar, rutas, unit/widget usar |
| R10 | Dialogo eliminar, repository delete, widget dialogo |
| R11 | Renombrar builder, controller validacion nombre |
| R12 | Validacion guardar, unit/widget sin intervalos |
| R13 | Validacion nombre rutina, unit/widget nombre invalido |
| R14 | Manejo errores SnackBar + reintentar |
| R15 | Bloqueo delete en sesion activa, unit delete bloqueado |
| R16 | Dialogo cancelar, widget dialogo |
| R17 | Clear active id, reset timer, estado vacio F01, unit delete activa |
| R18 | Bloqueo Usar sin intervalos, unit/widget usar |

## Notas de secuenciacion

Esta feature depende de: F01, F03.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
Orden recomendado: datos/migracion → repository → providers → UI Mis rutinas → builder → integracion timer/F03 → tests.