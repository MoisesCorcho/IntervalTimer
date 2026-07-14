# Design: Editor de Rutinas Propias

**ID:** F05 &nbsp;|&nbsp; **Slug:** `05-custom-routine-builder`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias.

## Referencias

- `_global/01-vision-and-principles.md` — F01 = rutina activa; F05 = biblioteca multi-rutina.
- `_global/02-architecture-and-structure.md` — carpeta `features/routine_builder/`, capas presentation/application.
- `_global/03-conventions.md` — Riverpod unico; tests con `ProviderContainer` y mocks.
- `_global/04-design-system.md` — dialogo destructivo, SnackBar de error DB, estado vacio.
- `_global/05-data-model.md` — schema drift F05 (`source`, `origin_id`, `updated_at`); actualizar antes de migrar.

## Decisiones de diseno

### Modelo de datos (extension F01)

Alineado con `_global/05-data-model.md`. F05 extiende `Routine` sin cambiar `Interval` ni `RoutineItem` (union interval-only). F08 de circuitos vive en el eje Workout (`WorkoutCircuit`), no en Routine.

```dart
enum RoutineSource { custom, presetDerived }

// Extension sobre Routine de F01:
// + source: RoutineSource (default custom para filas existentes)
// + originId: String?  — PresetRoutine.id cuando source == presetDerived
// + updatedAt: DateTime (UTC al persistir)
```

**Migracion drift (schema version 2 — F05):** columnas aditivas en `routines`:

| Columna | Tipo | Notas |
|---|---|---|
| `source` | TEXT NOT NULL DEFAULT `'custom'` | `custom` \| `presetDerived` |
| `origin_id` | TEXT NULL | FK logica a `PresetRoutine.id` en assets; sin constraint SQL |
| `updated_at` | INTEGER NOT NULL | millisecondsSinceEpoch UTC; backfill con `created_at` en migracion |

Indice recomendado: `(source, updated_at DESC)` para listado de **Mis rutinas**.

**Rutina activa (R9, R17):** clave `active_routine_id` en `shared_preferences` (String UUID). No es columna drift.

### Persistencia y repositorio

- Extender `RoutineRepository` en `data/repositories/`:
  - `watchUserRoutines()` — stream ordenado por `updated_at` DESC, filtra solo filas drift del usuario (excluye presets empaquetados).
  - `createEmptyRoutine(name)` → `Routine` con `source: custom`.
  - `duplicateRoutine(Routine source)` / `duplicateFromPreset(PresetRoutine preset)` — deep copy de intervalos con nuevos UUIDs.
  - `deleteRoutine(id)` — CASCADE via `routine_items` + limpieza de intervalos huerfanos segun politica F01 (ON DELETE RESTRICT en intervalos referenciados: eliminar items primero).
  - `reorderItems(routineId, orderedItemIds)` — transaccion unica actualizando `position`.
  - `setActiveRoutineId` / `getActiveRoutineId` — wrapper sobre `shared_preferences`.

- Presets F03: lectura via `PresetRoutineRepository` (assets JSON); **nunca** escritura. Duplicacion mapea `PresetRoutine.intervals` → nuevos `Interval` + `RoutineItem` en drift.

### Gestion de estado (Riverpod)

Ubicacion: `features/routine_builder/application/`.

| Provider | Responsabilidad |
|---|---|
| `userRoutinesProvider` | `AsyncNotifier` — lista R1 desde drift |
| `routineBuilderControllerProvider` | `Notifier` — edicion en memoria de una rutina (intervalos, nombre); expone `save()`, `reorder()`, validaciones R12–R13 |
| `activeRoutineIdProvider` | Lee/escribe `active_routine_id`; invalida `TimerController` al cambiar |

**Integracion con F01 (R9, R17):**

- Al "Usar" rutina: `activeRoutineIdProvider` persiste id → `TimerController.loadRoutine(routineId)` (nuevo metodo o via `RoutineRepository`) → `go_router` navega a ruta F01 (`/timer` o equivalente).
- `TimerController` consulta `getActiveRoutineId()` al arranque si no hay rutina en memoria.
- Eliminar rutina activa en idle: repository delete + clear `active_routine_id` + `TimerController` reset a rutina vacia.

No importar widgets de `features/timer/` desde `routine_builder/`; solo providers/repositorios compartidos en `data/`.

### UI

Ubicacion: `features/routine_builder/presentation/`.

| Pantalla | Criterios | Notas |
|---|---|---|
| `MyRoutinesScreen` | R1, R6, R9, R10, R15–R18 | Lista con `ListTile` o cards; acciones Usar / Editar / Duplicar / Eliminar |
| `RoutineBuilderScreen` | R2–R5, R11–R14 | `ReorderableListView` para R4; formulario intervalo reutilizado de F01 (`shared/widgets/` o export desde timer) |
| Dialogo eliminar | R10, R16 | `AlertDialog` con boton destructivo separado (`04-design-system.md`) |

**Reordenamiento (R4):** `onReorder` llama a `routineBuilderController.reorder(oldIndex, newIndex)` que persiste via `RoutineRepository.reorderItems` en la misma transaccion.

**Duplicar preset (R7):** accion en catalogo F03 (`features/preset_routines/`) invoca `duplicateFromPreset` del repositorio compartido y navega a `RoutineBuilderScreen` con el id de la copia.

### Navegacion (go_router)

Rutas sugeridas en `app/router.dart`:

- `/routines` → `MyRoutinesScreen`
- `/routines/new` → flujo crear (dialogo nombre) → `/routines/:id/edit`
- `/routines/:id/edit` → `RoutineBuilderScreen`

Entrada a **Mis rutinas** desde drawer, tab o boton en pantalla F01 (decision UX local; minimo un acceso navegable).

### Manejo de errores (R14)

- Capturar excepciones de drift en repository; propagar `Result` o re-lanzar con tipo dominio.
- UI: `ScaffoldMessenger` SnackBar + accion "Reintentar" que reejecuta la ultima operacion fallida.
- Log en `debugPrint` / logger en modo debug (`03-conventions.md`).

## Diagrama de flujo — F05

```
[MyRoutinesScreen] --crear/duplicar--> [RoutineRepository.create / duplicate]
        |                                        |
        |--editar--> [RoutineBuilderScreen] <----'
        |                    |
        |                    +-- ReorderableListView --> reorderItems (persist inmediato)
        |                    +-- guardar --> save routine (R5)
        |
        |--Usar (R9)--> [active_routine_id prefs] --> [TimerController.loadRoutine] --> [F01 pantalla]
        |
        |--eliminar--> [AlertDialog] --confirm--> deleteRoutine (+ clear active si aplica R17)

[F03 Preset catalog] --duplicar--> duplicateFromPreset --> [RoutineBuilderScreen]
                                              (preset JSON/assets intactos)
```

## Riesgos y consideraciones

- Migracion schema v2 debe ser aditiva con DEFAULTs; backfill `updated_at = created_at` para rutinas F01 existentes.
- `reorderItems` y `duplicate` deben ser transacciones drift para evitar posiciones duplicadas o intervalos huerfanos.
- Coordinar con F03 si ambas features tocan `database.dart` en el mismo sprint — una sola migracion secuencial.
- Probar R15 consultando estado de `timerControllerProvider` antes de permitir delete.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Tabla separada `user_routines` | Duplica entidad `Routine`; extender tabla existente es mas simple y compatible con F04/F24. |
| Presets copiados en biblioteca como solo lectura | Confunde con assets; **Mis rutinas** solo muestra filas drift editables. |
| Boton "Guardar orden" para reordenar | Peor UX; R4 exige persistencia inmediata al soltar. |
| `activeRoutineId` en tabla `routines` con flag `is_active` | Un solo activo global; `shared_preferences` evita migracion y race al listar. |