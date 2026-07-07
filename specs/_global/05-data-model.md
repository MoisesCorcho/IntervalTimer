# Modelo de Datos Global

Este documento consolida las entidades que se van agregando a lo largo de las features. Cada feature
que introduce o modifica una entidad debe reflejarlo aqui **antes** de implementar migraciones drift.

## Politica de identificadores

- Todos los IDs de entidades persistidas en drift son **UUID v4** representados como `String`.
- Generar con el paquete `uuid` en la capa de repositorio al crear registros.
- No usar autoincrement integer como ID publico de dominio.

## Entidades principales (por feature de origen)

| Entidad | Origen | Descripcion breve |
|---|---|---|
| `Interval` | F01 | Unidad basica: nombre, duracion, color, tipo. |
| `Routine` | F01 | Coleccion ordenada de `RoutineItem` (intervalos y/o bloques). |
| `RoutineItem` | F01/F08 | Union discriminada: `interval(Interval)` en F01; `block(Block)` en F08. |
| `Block` | F08 | Agrupacion de intervalos con numero de repeticiones. |
| `Exercise` | F03 | Ejercicio con metadata y referencia a media (Lottie/video/imagen). |
| `PresetRoutine` | F03 | Rutina prediseñada con categoria y ejercicios asociados (assets, no drift). |
| `SessionLog` | F04 | Registro de una sesion ejecutada (completa o abortada). |
| `ProgressionPlan` / `WeekAdjustment` | F09 | Plan de incremento automatico de dificultad. |
| `Achievement` / `UnlockedAchievement` | F13 | Catalogo de logros y su estado de desbloqueo. |
| `Reminder` | F14 | Configuracion de notificaciones recurrentes. |
| `BodyMeasurement` | F15 | Registro de peso/medidas en el tiempo. |
| `FavoriteRoutine` | F24 | Marca de rutina favorita (referencia por id + tipo preset/user). |

## Schema F01 (drift) — fundacional

### Enums de dominio

```dart
enum IntervalType { warmup, work, rest, stretch, custom }
enum RoutineItemType { interval }  // F08 agrega: block
```

### Entidades de dominio

```
Interval {
  id: String              // UUID v4
  name: String            // max 50 chars (validacion en UI)
  durationSeconds: int    // 1..5999 (00:01..99:59)
  colorArgb: int          // 0xAARRGGBB
  type: IntervalType
}

Routine {
  id: String              // UUID v4
  name: String
  createdAt: DateTime     // UTC al persistir
  items: List<RoutineItem> // orden por position
}

RoutineItem (sealed class / freezed union) {
  F01: solo variante IntervalItem { interval: Interval }
  F08: agrega BlockItem { block: Block }
}
```

### Tablas drift (schema version 1 — F01)

| Tabla | Columnas | Notas |
|---|---|---|
| `intervals` | `id` TEXT PK, `name` TEXT, `duration_seconds` INTEGER, `color_argb` INTEGER, `type` TEXT | `type` almacena nombre del enum |
| `routines` | `id` TEXT PK, `name` TEXT, `created_at` INTEGER | `created_at` = millisecondsSinceEpoch UTC |
| `routine_items` | `id` TEXT PK, `routine_id` TEXT FK→routines, `position` INTEGER, `item_type` TEXT, `interval_id` TEXT FK→intervals NULL | F01: solo `item_type='interval'` |

**Integridad referencial:**

- `routine_items.routine_id` → `routines.id` ON DELETE CASCADE
- `routine_items.interval_id` → `intervals.id` ON DELETE RESTRICT (no borrar intervalo referenciado sin reasignar)
- Indice unico: `(routine_id, position)` para garantizar orden sin duplicados

### Mapper drift ↔ dominio

- Tablas drift generan clases `*Data` o `*Row` via drift.
- Mappers en `data/local/` o junto al DAO convierten row → entidad de dominio en `data/models/`.
- La capa `presentation/` nunca importa clases generadas por drift directamente.

### Alcance F01 vs F05

- **F01:** una unica rutina activa (draft de trabajo) persistida en drift; CRUD de intervalos dentro de esa rutina.
- **F05:** biblioteca multi-rutina, duplicar presets, reordenar con drag & drop, eliminar rutinas.

## RoutineItem — union discriminada

Implementar como `sealed class` (Dart 3) o `@freezed sealed class`:

```dart
sealed class RoutineItem { ... }
class IntervalRoutineItem extends RoutineItem { final Interval interval; }
// F08: class BlockRoutineItem extends RoutineItem { final Block block; }
```

En drift, `routine_items.item_type` discrimina la variante; F01 solo persiste `interval`.

## PresetRoutine (F03) — excepcion de persistencia

- **No** se almacena en drift en el MVP.
- Catalogo empaquetado como JSON en `assets/routines/` + media en `assets/media/`.
- Al seleccionar un preset, el sistema **mapea** su estructura a una `Routine` temporal o copia en drift (F05 define duplicacion persistente).
- `PresetRoutine` puede modelar intervalos como `List<Interval>` en JSON; al cargar en el timer, convertir a `List<RoutineItem>` con `IntervalRoutineItem`.

## Motor de persistencia

| Capa | Tecnologia | Que vive ahi |
|---|---|---|
| **Local principal** | drift (SQLite) | Rutinas usuario, intervalos, session logs, mediciones, logros, etc. |
| **Assets read-only** | JSON en bundle | Presets F03, catalogo de ejercicios |
| **Preferencias** | shared_preferences | Flags de UI, tema, ajustes ligeros |
| **Remoto (F25/F26)** | Firestore o Supabase | Rutinas publicadas, retos grupales — opt-in |

## Relaciones clave

- `Routine` 1-N `RoutineItem` (union de `Interval` y, desde F08, `Block`).
- `PresetRoutine` N-N `Exercise` (en assets; no FK en drift).
- `SessionLog` N-1 `Routine` (por id + snapshot del nombre y duracion total).
- `FavoriteRoutine` referencia `routineId` + `routineSource` enum (`user` | `preset`) — resolver join en repositorio (F24).

## Convenciones drift

- Nombres de tabla y columna: `snake_case` en SQL; clases Dart generadas en `PascalCase`.
- Una migracion aditiva por feature que toque schema; incrementar `schemaVersion` en `database.dart`.
- Documentar cada migracion en el `design.md` de la feature y reflejar cambios aqui.
- Toda migracion debe ser aditiva siempre que sea posible.
- Migraciones destructivas requieren backup previo (F29) documentado en el `design.md` de la feature.

## Estrategia de migraciones

- Toda migracion de `drift` debe ser aditiva siempre que sea posible.
- Migraciones destructivas requieren un paso de backup previo (ver F29), documentado en el `design.md`
  de la feature que la introduce.

## Snapshot vs referencia

Cuando una entidad se usa como registro historico (ej. `SessionLog` referenciando una `Routine`), se debe
guardar un snapshot minimo (nombre, duracion total) ademas del id.