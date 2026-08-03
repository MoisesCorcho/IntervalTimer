# Design: Registro de Peso y Medidas

**ID:** F15 &nbsp;|&nbsp; **Slug:** `15-body-measurements-tracking`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F15: CRUD local de `BodyMeasurement`, grafica de
peso, preferencia kg/lb, y exposicion del ultimo peso al contrato **`WeightReader`** de F12 (sin
onboarding forzado, sin quinto tab).

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; empezar sin configurar; datos del usuario.
- `_global/02-architecture-and-structure.md` — `features/body_tracking/`; providers entre features.
- `_global/03-conventions.md` — Riverpod unico; nombres de dominio en ingles; UUID v4.
- `_global/04-design-system.md` — theme tokens; empty/loading/error; touch ≥ 48 dp.
- `_global/05-data-model.md` — documentar tabla `body_measurements` + clave de preferencia.
- F12 `design.md` — `WeightReader`, `weightReaderProvider`, `userWeightKgProvider`, caption en
  `ProgressSummarySection`.
- F04 `design.md` — `HistoryScreen` scrolleable; composicion de secciones.

## Decisiones de diseno

### Sin onboarding de peso

- F15 **no** toca el arranque de la app ni F30.
- Hasta el primer registro, F12 permanece con `DefaultWeightReader` semantics (70 kg, estimado).

### Persistencia canonica

- Tabla drift **`body_measurements`** (schema **v8**, aditiva sobre v7).
- Campos de peso/medidas **siempre en unidades metricas** en DB:
  - `weight_kg` REAL NOT NULL
  - `waist_cm`, `arm_cm`, `leg_cm` REAL NULL
- `local_date` TEXT NOT NULL (`yyyy-MM-dd` zona local) — **UNIQUE** para upsert por dia.
- `id` TEXT PK (UUID v4); `created_at` / `updated_at` INTEGER (UTC ms).

### Preferencia de unidad (solo presentacion)

| Clave `app_preferences` | Valores | Default |
|---|---|---|
| `body_weight_unit` | `kg` \| `lb` | `kg` |

- Lectura/escritura via `PreferencesRepository` (mismo patron F18/F19/F27/F35).
- Conversion UI:
  - `kg → lb`: `lb = kg * 2.2046226218`
  - `lb → kg`: `kg = lb / 2.2046226218`
- Redondeo de display: 1 decimal en UI salvo que el design system del form use enteros con stepper;
  dominio guarda `double` con precision razonable (no string).

### Upsert por dia

```
save(measurement for localDate D):
  if exists row where local_date = D:
    UPDATE weight_kg, measures, updated_at
  else:
    INSERT new UUID
```

La grafica y el "ultimo peso" leen como maximo una fila por `local_date`.

### Contrato con F12 — WeightReader (no UserProfileService)

F12 ya define:

```dart
abstract class WeightReader {
  WeightReading read(); // weightKg + isEstimated
}

final weightReaderProvider = Provider<WeightReader>(...);
```

F15 implementa:

```dart
class BodyMeasurementWeightReader implements WeightReader {
  // lee repositorio / cache del ultimo weightKg por localDate desc
  // sin filas -> WeightReading(70, isEstimated: true)  // o delegar a DefaultWeightReader
  // con filas  -> WeightReading(latest.weightKg, isEstimated: false)
}
```

**Override:** en el grafo de providers de la app (bootstrap o `body_tracking` providers importado
desde el composition root), reemplazar:

```dart
// Antes (F12)
weightReaderProvider -> DefaultWeightReader()

// Con F15
weightReaderProvider -> BodyMeasurementWeightReader(repo)
```

**Prohibido:** inventar `UserProfileService` como nombre de contrato publico. Si se necesita un
servicio de dominio F15, llamarlo `BodyMeasurementService` y que el adapter implemente `WeightReader`.

Invalidacion: al mutar mediciones, el reader y `userWeightKgProvider` deben re-evaluarse
(`ref.watch` de un `StreamProvider`/`FutureProvider` de latest weight, o invalidar dependents).
`statsSummaryProvider` ya observa `userWeightKgProvider` — debe refrescar kcal al cambiar peso.

### Modulo y capas

```
features/body_tracking/
  domain/
    body_measurement.dart          # entidad + validacion pura (rangos)
    weight_unit.dart               # enum kg/lb + conversion
    body_measurement_weight_reader.dart  # implements WeightReader
  application/
    body_tracking_providers.dart   # repo, list, latest, unit, form controller
  presentation/
    body_weight_section.dart       # bloque en Historial: caption/CTA + chart + empty
    body_measurement_form.dart     # bottom sheet / screen corta
    body_weight_line_chart.dart    # fl_chart LineChart
    measurement_list_tile.dart     # opcional: item lista editar/borrar
```

`HistoryScreen` (F04) **compone** `BodyWeightSection` en el scroll, **debajo** del bloque de
progreso F12 y **encima** del calendario (orden R2 + coherencia con F12 R9):

```
1. Chrome mes F04
2. ProgressSummarySection F12
3. BodyWeightSection F15   ← nuevo
4. Calendario F04
5. Lista del dia F04
```

Dependencia de presentation: `calendar_history` → `body_tracking` (aceptable; body_tracking no
importa widgets del timer). Ajustes: seccion corta para `body_weight_unit`.

### Validacion (dominio)

| Campo | Regla |
|---|---|
| `weightKg` | finito, `>= 20` y `<= 300` |
| medidas cm | null OK; si present: `> 0` y `<= 300` |
| `localDate` | `yyyy-MM-dd`; `<= today` local |

Mensajes UI en espanol via `UiStrings` (patron del proyecto).

### Riverpod (esqueleto)

| Provider | Rol |
|---|---|
| `bodyMeasurementRepositoryProvider` | DAO/repo drift |
| `bodyMeasurementsProvider` | `AsyncValue<List<BodyMeasurement>>` orden `local_date` asc o desc |
| `latestBodyWeightKgProvider` | ultimo peso o null |
| `bodyWeightUnitProvider` | enum kg/lb desde preferencias |
| `bodyWeightSectionController` | open form, save, delete, edit |
| override `weightReaderProvider` | `BodyMeasurementWeightReader` |

### Graficas — `fl_chart`

- Paquete ya en proyecto: **`fl_chart: ^1.2.0`** (F12 `BarChart`).
- F15 usa **`LineChart`** / `LineChartData` para peso vs tiempo.
- Colores desde `Theme.of(context).colorScheme`.
- Altura acotada (~160–200 dp); no dominar sobre calendario.
- Eje Y en unidad de preferencia (convertir puntos al display).

### UI / UX (wireframe logico)

```
┌──────────────────────────────────────────┐
│  [ Julio ▾ ]              [ 📅 hoy ]     │  ← F04
├──────────────────────────────────────────┤
│  Tu progreso (F12) …                     │
│  Peso 72,5 kg · Actualizar               │  ← CTA F15 (o "estimado 70 kg · Registrar")
├──────────────────────────────────────────┤
│  Tu peso                                 │  ← BodyWeightSection
│  [ LineChart ······ ]                    │
│  o empty: "Registra tu peso para ver…"   │
│  [ + Registrar peso ]                    │
│  Ultimos registros (lista compacta)      │
├──────────────────────────────────────────┤
│  Calendario F04 …                        │
└──────────────────────────────────────────┘

Ajustes:
│  Unidades
│  Peso: ( kg | lb )   segmented / list tile
```

Form (bottom sheet):

```
Fecha: [ hoy ▾ ]
Peso:  [ 72.5 ] kg|lb
Medidas (opcional, expandible):
  Cintura / Brazo / Pierna (cm)
[ Guardar ]  [ Cancelar ]
```

Edit = mismo form precargado. Delete = confirm dialog breve.

### Controles numericos

- Preferir `NumberStepper` / campos alineados a F33 si el valor es peso con un decimal; si el
  stepper actual es solo enteros, usar input numerico validado con teclado decimal (documentar en
  implementacion). No bloquear F15 por F33.

### Diagrama de flujo

```
[HistoryScreen]
    |
    +--> ProgressSummarySection (F12) --watch--> userWeightKgProvider
    |
    +--> BodyWeightSection (F15)
              |
              v
         bodyMeasurementsProvider --> LineChart / empty / list
              |
    [Usuario: Registrar / Editar / Borrar]
              |
              v
         BodyMeasurementRepository (upsert/delete)
              |
              +--> refresh measurements stream
              +--> WeightReader latest --> userWeightKgProvider
              +--> statsSummaryProvider recalcula kcal (F12)
              |
    [Ajustes: body_weight_unit]
              |
              v
         PreferencesRepository --> rebuild form + chart labels
```

### Migracion Drift

| Version | Cambio |
|---|---|
| 7 (actual) | workouts.rounds, etc. |
| **8 (F15)** | CREATE TABLE `body_measurements`; UNIQUE(`local_date`) |

Documentar columnas en `_global/05-data-model.md` **antes** de merge de codigo.

### Riesgos y consideraciones

| Riesgo | Mitigacion |
|---|---|
| Olvidar override de `weightReaderProvider` | Task explicita + test que latest weight alimenta `WeightReading` |
| Doble fuente de verdad de peso | Solo F15 escribe peso; F12 solo lee via WeightReader |
| Precision lb ↔ kg | Convertir en bordes UI; comparar con tolerancia en tests |
| Scroll largo en Historial | Seccion compacta; lista "ultimos N" (ej. 5) + ver mas opcional MVP-simple |
| UNIQUE local_date vs edit de fecha a dia ocupado | Upsert merge: guardar en fecha destino reemplaza esa fila; borrar origen si se movio de dia |

### Alternativas consideradas

| Alternativa | Por que se descarto |
|---|---|
| `UserProfileService` generico | F12 ya tiene `WeightReader`; evitar segundo contrato |
| Pedir peso en primer launch | Viola "empezar sin configurar"; F12 R12 ya cubre estimado |
| Tab "Cuerpo" en bottom nav | Shell de 4 tabs; F12 rechazo el 5.º tab |
| Multiples pesos/dia | Ruido en grafica; upsert por dia suficiente MVP |
| Health Connect / Apple Health | Fuera de alcance; permisos y platform variance |
| Solo preferencia de "peso actual" sin historial | No cumple grafica de evolucion R5 |

## Modelos de dominio

```dart
enum BodyWeightUnit { kg, lb }

class BodyMeasurement {
  final String id;           // UUID v4
  final String localDate;    // yyyy-MM-dd
  final double weightKg;     // canonico
  final double? waistCm;
  final double? armCm;
  final double? legCm;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

Validacion pura en `domain/` (testable sin Flutter).
