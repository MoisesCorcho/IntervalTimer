# Design: Calendario e Historial de Sesiones

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F04: capturar `SessionLog` desde eventos de F01 y exponer la pantalla **Historial** (calendario + lista + notas + acciones).

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; datos del usuario locales.
- `_global/02-architecture-and-structure.md` — `features/calendar_history/`; contratos `SessionCompletedEvent` / `SessionCancelledEvent`.
- `_global/03-conventions.md` — Riverpod unico; nombres de dominio en ingles.
- `_global/04-design-system.md` — theme tokens, estados vacio/carga/error, confirmacion destructiva, touch >= 48 dp.
- `_global/05-data-model.md` — documentar schema `session_logs` antes de migrar.

## Decisiones de diseno

### Modelo de datos

Alineado con `_global/05-data-model.md`. F04 introduce:

```dart
enum SessionLogStatus { completed, aborted }

class SessionLog {
  final String id;                 // UUID v4
  final String sourceId;           // routineId o workoutId del evento
  final String displayName;        // snapshot del nombre al cerrar sesion
  final DateTime endedAt;          // UTC en persistencia; display en local
  final DateTime localDate;        // fecha calendario local (solo dia; ver nota)
  final SessionLogStatus status;
  final int totalDurationSeconds;
  final int itemCount;             // intervalCount / completedIntervalCount
  final String? note;              // max 500 chars; null = sin nota
}
```

**Nota `localDate`:** persistir como `INTEGER` (milliseconds del **inicio del dia local** en UTC ms, o `TEXT` `yyyy-MM-dd` local). Preferido: **`TEXT yyyy-MM-dd` en zona local** para queries por dia sin ambiguedad de DST. Documentar en migracion.

**Snapshot vs referencia:** se guarda `displayName` + metricas aunque el `sourceId` se borre despues (historial no se rompe). **Empezar** (R14) si requiere filas vivas en repositorio de rutinas/workouts.

### Tabla drift (migracion aditiva)

| Tabla | Columnas | Notas |
|---|---|---|
| `session_logs` | `id` TEXT PK, `source_id` TEXT NOT NULL, `display_name` TEXT NOT NULL, `ended_at` INTEGER NOT NULL, `local_date` TEXT NOT NULL, `status` TEXT NOT NULL, `total_duration_seconds` INTEGER NOT NULL, `item_count` INTEGER NOT NULL, `note` TEXT NULL | Indices: `(local_date)`, `(ended_at DESC)` |

- Sin FK obligatoria a `routines`/`workouts` (el origen puede borrarse).
- `schemaVersion`: incrementar en `database.dart` con la **siguiente** version aditiva del proyecto al momento de implementar (hoy F34 documenta v4; F04 usa la siguiente libre, tipicamente **v5** si no hay otra migracion intermedia). Actualizar `_global/05-data-model.md` en el mismo PR.

### Gestion de estado (Riverpod)

| Provider / tipo | Responsabilidad |
|---|---|
| `SessionLogRepository` | CRUD drift; queries por `local_date`, por mes (`local_date` BETWEEN), delete, update note |
| `sessionHistoryListener` / bootstrap | `ref.listen` a streams de `TimerController` (F01); mapea eventos → `insert` |
| `HistoryController` (`Notifier`) | estado UI: `focusedMonth`, `selectedDate`, carga de logs del mes, set seleccionado |
| `sessionLogsForSelectedDayProvider` | lista derivada del dia seleccionado, orden `endedAt` desc |
| `sessionMarkerDatesProvider` | `Set<DateTime>` o `Set<String yyyy-MM-dd>` del mes visible |

No acoplar widgets de `features/timer/` desde presentation de historial; solo contratos de eventos y navegacion via router / callbacks de app shell.

### Resolucion de `displayName` al persistir

Al recibir el evento:

1. Intentar resolver nombre desde rutina activa / workout activo (providers o repositorios ya cargados en sesion).
2. Si no hay nombre: `displayName = ''` → la UI aplica fallback R10 (`Entrenamiento a las HH:mm`).

Opcional futuro: extender payload de eventos F01 con `routineName` — **no** es prerequisito de F04; evitar cambiar F01 si se puede resolver en el listener.

### Integracion con eventos F01 (contratos)

```dart
// Ya definidos en F01 design / 02-architecture
class SessionCompletedEvent {
  final String routineId;
  final DateTime completedAt;
  final int totalElapsedSeconds;
  final int intervalCount;
}

class SessionCancelledEvent {
  final String routineId;
  final DateTime cancelledAt;
  final int elapsedSeconds;
  final int completedIntervalCount;
}
```

- Completada → R1 siempre.
- Cancelada → R2 solo si `elapsedSeconds > 0`.
- Suscripcion en capa application de `calendar_history` (o bootstrap en `main`/`App`) via `ref.listen`, **nunca** import de widgets del timer.

**Correccion respecto a draft previo de esta feature:** no existe `onSessionEnd`; usar los dos eventos nombrados arriba.

### Paquete de calendario

- **`table_calendar` ^3.2.0** (pub.dev, verificado).
- Uso:
  - `CalendarFormat.month` fijo (sin toggle week/two weeks en MVP).
  - `startingDayOfWeek: StartingDayOfWeek.monday`.
  - `focusedDay` / `selectedDay` controlados por `HistoryController`.
  - `eventLoader` o `calendarBuilders.markerBuilder` para R9.
  - Header del paquete **oculto** (`headerVisible: false`); chrome custom R4 (mes + hoy) encima.
- Personalizar `CalendarStyle` con colores de `Theme.of(context).colorScheme` (selected = primary o tertiary de acento; today = border; markers = onSurfaceVariant).

### Shell de navegacion inferior (R22)

F35 dejo el shell con **3** destinos: Temporizador/Rutina | Entrenamientos | Ajustes.

F04 **inserta** un cuarto destino:

| Indice | Destino | Ruta (sugerida) | Icono (sugerido) | Label |
|---|---|---|---|---|
| 0 | Timer / Rutina | existente | existente | existente |
| 1 | Entrenamientos | existente | existente | Entrenamientos |
| 2 | **Historial** | `/history` (o branch shell equivalente) | `Icons.calendar_month` (preferido; alt. `Icons.calendar_today`) | Historial |
| 3 | Ajustes | existente | existente | Ajustes |

Implementacion tipica:

- Extender `StatefulShellRoute` / `AppShell` / `NavigationBar` en `lib/app/` (no en `features/timer/`).
- Branch del shell que monta `HistoryScreen`.
- Area de toque del destino >= 48 dp; estado selected con color del theme.
- La pantalla de **ejecucion** del timer puede seguir ocultando la barra (comportamiento F01/F35); R22 aplica al shell principal.

### UI / UX detallada (wireframe logico)

```
┌──────────────────────────────────────────┐
│  [ Julio ▾ ]              [ 📅 12 ]      │  ← R4
├──────────────────────────────────────────┤
│  LUN MAR MIÉ JUE VIE SÁB DOM             │
│  [29][30][ 1][ 2][ 3][ 4][ 5]            │  ← R7
│   💪      ...                            │  ← R9 marcador
│  [ 6][ 7][ 8][ 9][10][11][12]            │
│   💪          [sel]          [hoy]       │
│  ...                                     │
├──────────────────────────────────────────┤
│  (banner PRO opcional — fuera F04/F06)   │
├──────────────────────────────────────────┤
│  Entrenamientos                          │  ← R10
│  ┌────────────────────────────────────┐  │
│  │ Titulo                    ⋮        │  │
│  │ [15s]  Ejercicios: 1               │  │
│  │                                    │  │
│  │ 📝 Anadir una nota...  / nota     │  │  ← R11
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ ...                                │  │
│  └────────────────────────────────────┘  │
├──────────────────────────────────────────┤
│ ⏱ Timer │ 📘 Entr. │ 📅 Historial │ ⚙ Ajustes │  ← R22
└──────────────────────────────────────────┘
         ▲ bottom sheet (R13)
┌──────────────────────────────────────────┐
│  ──────────                              │
│  Titulo                                  │
│  15s                                     │
│  ▶ Empezar                               │
│  🗑 Eliminar del historial                │
└──────────────────────────────────────────┘
```

#### Componentes de presentation

| Widget | Rol |
|---|---|
| `HistoryScreen` | Scaffold de seccion; orquesta chrome + calendar + lista |
| `HistoryMonthHeader` | Selector de mes (left) + boton hoy (right) |
| `HistoryCalendar` | Wrapper de `table_calendar` |
| `SessionLogCard` | Card R10 + zona nota + overflow |
| `SessionLogActionsSheet` | Bottom sheet R13 |
| `SessionNoteEditor` | Campo multilinea max 500, Guardar/Cancelar |
| `DeleteSessionLogDialog` | Confirmacion destructiva R15 |

#### Formatos de display

| Dato | Formato |
|---|---|
| Duracion < 60 s | `{n}s` (como referencia) |
| Duracion >= 60 s | `m:ss` o `mm:ss`; si >= 1 h → `h:mm:ss` |
| Hora en fallback titulo | `HH:mm` local de `endedAt` |
| Mes en header | Nombre completo del mes en locale app (es) |

#### Empezar (R14) — flujo tecnico

1. Resolver si `sourceId` existe como `Workout` (F32) o `Routine` (F01/F05).
2. Si workout: aplanar via `WorkoutFlattener` y cargar en `TimerController` (mismo camino que F32).
3. Si routine: cargar items en timer (camino F01/F05).
4. Navegar a ruta de ejecucion (`go_router`).
5. Si ninguno: SnackBar error; no mutar timer.

#### Eliminar (R15)

1. `showDialog` confirmacion.
2. `repository.delete(id)`.
3. Invalidar providers del mes/dia; si set de marcadores queda vacio para ese dia, quitar marker.

### Diagrama de flujo — F04

```
[TimerController F01]
   | SessionCompleted / SessionCancelled
   v
[SessionHistoryListener] --displayName--> [SessionLogRepository.insert]
   |
   v (drift session_logs)
[AppShell NavigationBar] --tab Historial (R22)--> [HistoryScreen]
   |
   v
[HistoryController] <--> [HistoryScreen]
   |                         |
   | focusedMonth            +-- HistoryMonthHeader (mes / hoy)
   | selectedDate            +-- HistoryCalendar (table_calendar)
   |                         +-- SessionLogCard list
   |                                | note --> updateNote
   |                                | ⋮ --> SessionLogActionsSheet
   |                                         | Empezar --> load source + go execution
   |                                         | Eliminar --> confirm --> delete
   v
[Marcadores del mes]  [Lista del dia]
```

### Estructura de carpetas

```
features/calendar_history/
  presentation/
    history_screen.dart
    widgets/
      history_month_header.dart
      history_calendar.dart
      session_log_card.dart
      session_log_actions_sheet.dart
      session_note_editor.dart
  application/
    history_controller.dart
    session_history_listener.dart
    providers.dart
  domain/   (opcional si hay mappers puros)
data/
  models/session_log.dart
  repositories/session_log_repository.dart
  local/tables/session_logs.dart
  local/daos/session_log_dao.dart
```

### Accesibilidad (minimo pre-F31)

- Labels semantics en boton hoy, overflow, Empezar, Eliminar.
- Targets >= 48 dp.
- Contraste de dia seleccionado via theme / `contrastTextColor` si se usa color custom.

## Riesgos y consideraciones

- **Orden de schema:** coordinar `schemaVersion` con migraciones ya en codigo (F32/F34). Solo aditivo.
- **DST / medianoche:** `local_date` como `yyyy-MM-dd` local evita logs "del dia incorrecto" al persistir solo UTC.
- **Listener duplicado:** un solo subscribe global; no registrar en cada rebuild de `HistoryScreen`.
- **Empezar sin fuente:** UX clara; no inventar intervalos desde el log.
- **Volumen:** indices por `local_date` y `ended_at`; F12 agregara queries pesadas despues.
- Probar bottom sheet y teclado de nota en dispositivo fisico (inset).

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Isar en lugar de drift | Steering docs y F01 ya fijan **drift** como motor principal. |
| Un solo evento `onSessionEnd` | Contradice F01 y `_global/02-architecture`. |
| Header nativo de `table_calendar` | No coincide con referencia (mes izq + hoy der); se oculta y se construye chrome propio. |
| Reconstruir rutina solo desde snapshot de log | Snapshot no incluye intervalos; Empezar requiere fuente viva. |
| Incluir Compartir / Guardar en sheet v1 | Usuario acoto a Empezar + Eliminar; resto F05/F16/F32. |
| Vista custom de grid sin paquete | Reinventa gestos y locale; `table_calendar` 3.2.0 cubre markers y seleccion. |
