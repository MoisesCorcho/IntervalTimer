# Design: Estadisticas y Progreso

**ID:** F12 &nbsp;|&nbsp; **Slug:** `12-statistics-progress`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F12: metricas y graficas derivadas de `SessionLog` (F04), embebidas en `HistoryScreen` sin tab nuevo.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; datos locales.
- `_global/02-architecture-and-structure.md` — `features/stats/`; comunicacion por providers, no acoplar widgets del timer.
- `_global/03-conventions.md` — Riverpod unico; dominio en ingles.
- `_global/04-design-system.md` — theme tokens, estados AsyncNotifier, touch >= 48 dp.
- `_global/05-data-model.md` — `SessionLog`; documentar tipos derivados de stats (no tabla).
- F04 `design.md` — `HistoryScreen`, `HistoryController`, `SessionLogRepository`.

## Decisiones de diseno

### Sin persistencia nueva

- Todas las metricas se **derivan en memoria** desde `SessionLogRepository` (F04).
- **No** crear tabla drift ni migracion para F12.
- Exponer modelos de lectura (`StatsSummary`, series de barras) en dominio de `features/stats/`.

### Modulo y capas

```
features/stats/
  domain/
    stats_models.dart          # StatsSummary, DayMinutes, ChartPeriod
    stats_service.dart         # pure / testable aggregation
  application/
    stats_providers.dart       # Riverpod: summary + chart series
  presentation/
    progress_summary_section.dart
    activity_bar_chart.dart
    chart_period_toggle.dart
```

`HistoryScreen` (F04, `features/calendar_history/presentation/`) **compone** los widgets de `stats/presentation/` debajo del chrome de mes. Dependencia de presentation: calendar_history → stats (aceptable; stats no importa UI de calendar ni de timer).

### `StatsService` (dominio)

Responsabilidades:

| Metodo | Salida |
|---|---|
| `summarize(logs, {focusedMonth, now, weightKg})` | `StatsSummary` |
| `weekSeries(logs, {now})` | `List<DayMinutes>` length 7 (lun–dom) |
| `monthSeries(logs, {focusedMonth})` | `List<DayMinutes>` un entry por dia del mes |

Reglas alineadas a R2–R6:

- Filtrar por `localDate` (string `yyyy-MM-dd` o equivalente F04).
- Minutos: `floor(sum(totalDurationSeconds) / 60)`.
- Kcal por log: `MET * weightKg * (totalDurationSeconds / 3600)` con `MET = 8.0`.
- Racha: algoritmo de ancla hoy/ayer de R6 (inyectar `DateTime now` y zona local para tests).

Constantes (design, no magic numbers en UI):

```dart
const double kDefaultMet = 8.0;
const double kDefaultWeightKg = 70.0;
```

### Peso (F15 opcional)

- Interfaz delgada: `WeightReader` / provider `userWeightKgProvider` que:
  - SI F15 existe y tiene ultimo peso → ese valor;
  - SI no → `kDefaultWeightKg` + flag `isWeightEstimated: true` para R12.
- F12 **no** implementa CRUD de peso.

### Riverpod

| Provider | Rol |
|---|---|
| `sessionLogsForStatsProvider` | Stream/future de logs necesarios (todos o rango amplio desde repo F04) |
| `statsSummaryProvider` | `AsyncValue<StatsSummary>`; depende de logs + `focusedMonth` (leer de `HistoryController` o parametro) |
| `activityChartProvider(ChartPeriod)` | Series de barras semana/mes |
| `chartPeriodProvider` | Estado UI local: `week` \| `month` (default `week`) |

Invalidacion: al mutar `SessionLog` (insert F04 listener, delete nota no afecta stats salvo delete log), invalidar/refrescar providers de stats. Preferir `ref.watch` del mismo repositorio/stream que usa el historial.

### Graficas — `fl_chart`

- Paquete: **`fl_chart`** ([pub.dev](https://pub.dev/packages/fl_chart), verificado; API estable `BarChart` / `BarChartData`).
- Version: fijar en `pubspec` la caret actual al implementar (ej. `fl_chart: ^1.2.0` o la latest compatible con el SDK del proyecto).
- Usar **`BarChart`** para minutos/dia.
- Colores desde `Theme.of(context).colorScheme` (primary para barras con valor > 0; `onSurfaceVariant` / outline para ejes y labels).
- Altura sugerida del chart card: ~160–200 dp; no dominar la pantalla sobre el calendario.

### UI / UX (wireframe logico)

Orden en `HistoryScreen` scrolleable:

```
┌──────────────────────────────────────────┐
│  [ Julio ▾ ]              [ 📅 15 ]      │  ← F04 R4
├──────────────────────────────────────────┤
│  Tu progreso                             │  ← F12
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐         │
│  │  7  │ │ 48  │ │ 12  │ │1240 │         │  ← R2
│  │racha│ │min  │ │ses. │ │kcal │         │
│  │     │ │sem. │ │mes  │ │est. │         │
│  └─────┘ └─────┘ └─────┘ └─────┘         │
│  Total: 18 h · 186 sesiones              │  ← R3
│  [ Semana | Mes ]                        │  ← R4 toggle
│  ┌────────────────────────────────────┐  │
│  │  ▂  ·  ▅  ▃  ·  ▆  ▄   (barras)   │  │
│  │  L  M  X  J  V  S  D               │  │
│  │  Minutos por dia                   │  │
│  └────────────────────────────────────┘  │
│  Peso estimado 70 kg (si aplica R12)     │
├──────────────────────────────────────────┤
│  LUN MAR MIÉ … calendario F04            │
├──────────────────────────────────────────┤
│  Entrenamientos                          │
│  (cards SessionLog F04)                  │
├──────────────────────────────────────────┤
│ ⏱ │ 📘 │ 📅 Historial │ ⚙               │
└──────────────────────────────────────────┘
```

#### Componentes presentation (stats)

| Widget | Rol |
|---|---|
| `ProgressSummarySection` | Titulo "Tu progreso" + 4 metric cards + linea totales + caption peso |
| `StatMetricCard` | Valor grande + etiqueta; reutilizable |
| `ChartPeriodToggle` | Segmented Semana/Mes; touch >= 48 dp por opcion |
| `ActivityBarChart` | Wrapper `fl_chart` BarChart |

No extraer a `shared/widgets/` en MVP salvo que otro feature lo pida en el mismo PR.

### Contratos hacia F16 / F13

Exponer desde `StatsService` (o provider de solo lectura) metodos/campos reutilizables:

- `currentStreak`
- `estimatedKcalForSession(SessionLog)` / total
- `weekMinutes` / etc.

F16 **no** debe recalcular racha con reglas distintas; importar el mismo servicio de dominio.

### Diagrama de flujo

```
[HistoryScreen mount / watch]
        |
        v
[SessionLogRepository.watchAll o watchRange]
        |
        v
[StatsService.summarize + week/monthSeries]
        |
        +--> [statsSummaryProvider] --> ProgressSummarySection
        |
        +--> [activityChartProvider] --> ActivityBarChart
        |
        v
[Usuario cambia mes F04] --> recalcula sesiones mes + series mes
[Usuario toggle Semana/Mes] --> solo chart series
[Usuario borra/completa sesion] --> repo emite --> providers refresh
```

### Riesgos y consideraciones

| Riesgo | Mitigacion |
|---|---|
| Muchos `SessionLog` → agregar en UI thread | Agregar en isolate solo si profiling lo exige; MVP in-memory en service sincrono |
| `focusedMonth` acoplado a HistoryController | Leer estado de F04 via provider publico; no duplicar estado de mes en stats |
| F15 no existe | `WeightReader` con default 70 kg + flag estimado |
| Doble scroll / viewport corto | Stats compactas (cards en fila o 2×2); chart altura acotada |
| Zona horaria / ISO week | Usar `clock`/`DateTime` local; tests con fechas fijas |

### Alternativas consideradas

| Alternativa | Por que se descarto |
|---|---|
| Tab "Progreso" en bottom nav | Aprieta shell (ya 4 tabs); duplica dominio con Historial |
| Segmented Calendario \| Progreso (dos vistas) | Aceptable a futuro si el scroll crece; MVP prefiere un solo scroll |
| Tabla materializada de stats diarias | Complejidad de migracion sin beneficio; volumen local bajo |
| `charts_flutter` / syncfusion | `fl_chart` liviano, mantenido, suficiente para barras |
| MET por categoria F03 | F03 no es prerequisito; MET fijo 8.0 en MVP |

## Modelos de dominio (lectura)

```dart
enum ChartPeriod { week, month }

class DayMinutes {
  final String localDate; // yyyy-MM-dd
  final int minutes;
}

class StatsSummary {
  final int currentStreakDays;
  final int weekMinutes;
  final int monthSessionCount;
  final int totalMinutes;
  final int totalSessionCount;
  final int totalEstimatedKcal;
  final bool isWeightEstimated;
  final double weightKgUsed;
}
```

Documentar en `_global/05-data-model.md` como **derivados F12** (no tablas).
