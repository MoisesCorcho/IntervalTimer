# Design: Compartir Resumen de Sesion

**ID:** F16 &nbsp;|&nbsp; **Slug:** `16-session-summary-sharing`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F16: pantalla de fin de sesion completada
(celebracion, metricas work/rest, share de imagen offline, nota opcional en `SessionLog`, Listo
→ idle). Implementa la confirmacion visible de **F01 R18** sin modificar el contrato de R18.

Antes de implementar: `_global/02-architecture-and-structure.md`, `03-conventions.md`,
`04-design-system.md`, `05-data-model.md`, y contratos de F01/F04/F12.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; compartir opt-in.
- `_global/02-architecture-and-structure.md` — `features/`; sin importar UI entre features.
- `_global/03-conventions.md` — Riverpod; capas; tests.
- `_global/04-design-system.md` — primary/work/rest colors; `AppPrimaryButton`; spacing/radius.
- `_global/05-data-model.md` — `SessionLog`, `StatsSummary`.
- `features/01-interval-timer-core/design.md` — `SessionCompletedEvent`, estados, R18.
- `features/04-workout-calendar-history/design.md` — `SessionLogRepository.updateNote`, listener.
- `features/12-statistics-progress/design.md` — `StatsService` (racha, kcal).

## Decisiones de diseno

### Paquete share (verificado pub.dev)

- **`share_plus` ^13.2.1** (pub.dev; publisher `fluttercommunity.dev`; Flutter Favorite).
- API actual (v13+): **no** usar `Share.share` / `Share.shareXFiles` deprecados.

```dart
import 'package:share_plus/share_plus.dart';

final result = await SharePlus.instance.share(
  ShareParams(
    files: [XFile(path)], // o XFile.fromData(...)
    text: optionalCaption, // opcional; algunas apps ignoran texto+imagen
    sharePositionOrigin: origin, // obligatorio en iPad (R19)
  ),
);
// result.status: success | dismissed | unavailable
```

- Compartir **archivo de imagen** (PNG) generado localmente.
- `path_provider` ya esta en el proyecto (`^2.1.5`): escribir temporal en cache/temp y
  preferir path estable; si se usa `XFile.fromData`, documentar limpieza de cache del plugin.
- **iPad:** siempre pasar `sharePositionOrigin` desde el `RenderBox` del boton Compartir (R19).
- **Linux:** share de archivos no soportado por el plugin — en desktop no primario: feedback
  graceful o solo texto; QA objetivo = Android/iOS.
- Compatibilidad Meta/Facebook: el plugin documenta limitaciones con apps Meta; no es bug de
  producto F16 (fuera de alcance garantizar cada destino).

**SDK note:** `share_plus` 13.x puede exigir Flutter/Dart recientes. Pinnear la version maxima
compatible con el SDK del repo **sin** cambiar la semantica `SharePlus.instance.share` +
`ShareParams(files: ...)`.

### Secuencia UI fin de sesion (R2)

```
[status=completed] → SessionCompleteScreen
   │
   ├─ t0: fondo marca + AnimatedFlameHero CENTRADO
   │      anillos blancos en loop (AnimationController.repeat)
   │
   ├─ t ≈ 1.4s: sheetVisible=true
   │      SlideTransition + DraggableScrollableSheet
   │      initial/min ≈ 0.50, max ≈ 0.92, snap
   │      llama se alinea al tercio superior
   │
   └─ sheet: metricas | CTA Compartir → SessionShareStudioScreen
              | nota | Listo → idle
```

### Estudio de compartir (R5–R8) — referencia producto

Pantalla full-screen oscura (`SessionShareStudioScreen`):

| Elemento | Comportamiento |
|---|---|
| AppBar | "Compartir" + back (pop; no resetea timer) |
| PageView plantillas | `transparent` (checkerboard + foto opcional), `solidDark`, `solidBrand` |
| Card | `SessionShareCard`: total mm:ss, badge Entrenamiento, Sets / Trabajo / Descanso, branding |
| Foto (solo transparent) | CTA "Anadir foto" → sheet **Hacer foto** / **Seleccionar imagen** (`image_picker`) |
| Con foto | botones trash + edit superpuestos; foto como `BoxFit.cover` bajo el overlay de stats |
| Compartir | captura `RepaintBoundary` → PNG → `SharePlus.instance.share` |
| Guardar galeria | misma captura → `gal` (`Gal.putImage`) con requestAccess |

**Paquetes:** `image_picker`, `gal`, `share_plus`, `path_provider` (ya en proyecto).

**Permisos:** camara / fotos / galeria via plugins; fallos → SnackBar, no crash (R16 analogo).

**Captura:**

1. Plantilla actual dentro de `RepaintBoundary` + `GlobalKey`.
2. `toImage(pixelRatio: 3)` → PNG.
3. Temp file → share o galeria.

### Capas y ubicacion de codigo

```
features/session_summary/
  application/   → SessionSummaryController (Riverpod), nota/listo/bootstrap
  domain/        → SessionPhaseBreakdown, ShareCardData, ShareTemplateStyle,
                   ShareImageRenderer, ShareSheetDriver, GallerySaver
  presentation/  → SessionCompleteScreen, AnimatedFlameHero,
                   SessionShareStudioScreen, SessionShareCard, metric tiles
data/repositories/ → SessionLogRepository (F04); StatsService (F12)
```

- **No** carpeta `features/16-...` en `lib/`; slug de codigo: `session_summary`.
- **Prohibido:** `TimerController` importa `session_summary`.
- **Host:** la capa de navegacion / pantalla de ejecucion (F01 presentation) detecta
  `status == completed` o el evento y **navega/reemplaza** a `SessionCompleteScreen` (o muestra
  como ruta full-screen). F16 posee el UI; F01 solo expone estado/evento + `resetToIdle()`.

### Cumplir F01 R18 sin tocar el texto de R18

| Responsabilidad | Owner |
|---|---|
| Emitir `SessionCompleted`, estado `completed` | F01 |
| Confirmacion visible + boton Listo/Volver → idle + volver a editor | **F16** (esta pantalla) |
| Texto formal de R18 en specs F01 | **Sin reescritura** (cross-ref en Decisiones de producto F16) |

Al implementar F16, eliminar o no montar cualquier placeholder generico de "sesion terminada"
que compita con esta pantalla (R14).

### Desglose entrenamiento / descanso (R3)

Funcion pura (testeable):

```dart
class SessionPhaseBreakdown {
  final int trainingSeconds; // work + warmup + stretch + custom
  final int restSeconds;     // rest
}

SessionPhaseBreakdown breakdownFromIntervals(List<Interval> intervals) {
  var training = 0;
  var rest = 0;
  for (final i in intervals) {
    switch (i.type) {
      case IntervalType.rest:
        rest += i.durationSeconds;
      default:
        training += i.durationSeconds;
    }
  }
  return SessionPhaseBreakdown(trainingSeconds: training, restSeconds: rest);
}
```

- Fuente: lista de intervalos del plan de la sesion **completada** (misma fuente que uso el
  timer al iniciar; snapshot en memoria del controller o del argumento de navegacion).
- Sesion completada ⇒ se asume plan completo para el desglose por tipo.
- `totalDurationSeconds` del log/evento puede diferir levemente del sum(plan) si hubo pausas
  largas o precision de reloj: **mostrar desglose por plan** en tiles R3; **total del evento/log**
  en la card de share. Documentar en UI si se prefiere una sola fuente: decision default =
  tiles = plan por tipo; share total = `SessionLog.totalDurationSeconds`.

### Resolucion del SessionLog (R15)

F04 `SessionHistoryListener` inserta al `SessionCompleted`. Orden tipico:

```
SessionCompleted
  → F04 insert SessionLog (async)
  → nav a SessionCompleteScreen(payload del evento + intervalos)
  → F16 resuelve logId
```

Estrategias aceptadas (elegir una y testear):

1. **Preferida:** repositorio expone `Future<SessionLog?> latestCompletedForSource(sourceId)`
   ordenado por `endedAt DESC`, reintento corto (poll 2–5 veces / watch stream) tras el evento.
2. **Alternativa:** listener F04 publica el `id` insertado en un provider one-shot
   `lastInsertedSessionLogIdProvider` que F16 consume (sin que F04 importe UI de F16).

Si no hay `logId` tras timeout acotado: nota deshabilitada + SnackBar suave; share y Listo
siguen (R15, R18).

### Nota (R9–R11, R18)

- Reutilizar reglas F04: max **500** chars, `updateNote(id, note)`.
- UI: campo multilinea en la misma pantalla o bottom sheet ligero; label de pregunta.
- Guardado: al perder foco + debounce, al boton Guardar del campo, o al pulsar Listo si hay
  texto dirty — **decision de implementacion:** al Listo si hay texto no vacio y distinto del
  persistido, intentar `updateNote` antes de idle; si falla, R18 (feedback + no bloquear cierre
  si el usuario confirma "salir igual", o mantener en pantalla con reintentar — **default:**
  mostrar error y **no** forzar idle hasta Listo de nuevo o descarte explicito del draft).

**Default de producto simplificado para MVP:**  
- Boton secundario "Guardar nota" opcional **o** auto-save al Listo si `note.trim().isNotEmpty`.  
- Si auto-save en Listo falla → SnackBar reintentar; usuario puede Listo de nuevo sin nota
  (descartar draft) o reintentar. Preferir no perder texto en el field hasta exito o descarte.

### Kcal y racha (R6)

- Inyectar / llamar `StatsService` de F12:
  - `estimateKcal(totalDurationSeconds)` con MET 8.0 y peso default/F15.
  - `currentStreakDays` **despues** del insert del log (la sesion de hoy cuenta).
- No copiar formulas distintas en F16.

### ShareImageRenderer (testeable)

```dart
abstract class ShareImageRenderer {
  Future<Uint8List> renderPng(ShareCardData data, {double pixelRatio = 3});
}

abstract class ShareSheetDriver {
  Future<ShareOutcome> shareImage({
    required XFile file,
    Rect? sharePositionOrigin,
    String? text,
  });
}
```

- Tests unitarios con fake renderer/driver.
- Widget tests de `SessionCompleteScreen` con fakes (no abrir sheet real en CI).

### Navegacion y Listo (R12)

```
[Execution host] --completed--> [SessionCompleteScreen]
                                      |
                                      | Listo (exito)
                                      v
                              timer.resetToIdle()
                              pop / goNamed(editor)
```

- Usar la API publica de F01 para volver a `idle` (metodo existente de reset/ack completed).
- No dejar la ruta de ejecucion debajo en estado ambiguo (preferir `pushReplacement` o pop
  hasta editor segun el grafo actual del proyecto).

### Modelo de presentacion (no persistido)

```dart
class SessionCompleteViewData {
  final String sourceId;
  final String displayName;
  final int totalDurationSeconds;
  final int trainingSeconds;
  final int restSeconds;
  final String? sessionLogId; // null hasta resolver
  final int estimatedKcal;
  final int currentStreakDays;
}

class ShareCardData {
  final String displayName;
  final int totalDurationSeconds;
  final int estimatedKcal;
  final int currentStreakDays;
}
```

No nuevas tablas drift. Opcional documentar en `05-data-model.md` como modelos derivados F16.

## Diagrama de flujo — F16

```
[Timer running]
      |
      v  ultimo intervalo → 0
[F01: status=completed + SessionCompletedEvent]
      |
      +-----> [F04 SessionHistoryListener] --> insert SessionLog (note=null)
      |
      v
[Nav → SessionCompleteScreen]
      |
      +-- load breakdown (intervals) → tiles training/rest
      +-- StatsService → kcal + streak
      +-- resolve sessionLogId (retry/watch)
      |
      |-- Compartir → render PNG → SharePlus.instance.share → (success|dismissed|error UI)
      |-- Nota → updateNote(sessionLogId) → visible en F04 Historial
      |
      v Listo
[reset idle + volver a editor de rutina]
```

## UI — wireframe logico

```
┌─────────────────────────────────────┐
│  [← opcional]     hero primary      │
│         (icono celebracion)         │
│                                     │
│  ¡Gran trabajo!                     │
│  ┌──────────┐  ┌──────────┐         │
│  │ train    │  │ rest     │         │
│  │ 12:00    │  │ 03:00    │         │
│  └──────────┘  └──────────┘         │
│  ┌─────────────────────────────┐    │
│  │ Compartir  [preview card]   │    │
│  └─────────────────────────────┘    │
│  ¿Como fue tu entrenamiento?        │
│  [  nota multilinea ...         ]   │
│                                     │
│  [        ✓ Listo               ]   │
└─────────────────────────────────────┘
```

- Hero: color de marca / `work` green del design system (referencia producto).
- Tiles: `surfaceContainer` + labels con color work (verde) / rest (azul) del design system.
- CTA Listo: `AppPrimaryButton` o equivalente full-width.
- Preview de card de share: miniatura opcional a la derecha del CTA Compartir (R5).

### Componentes

| Widget | Rol |
|---|---|
| `SessionCompleteScreen` | Pantalla full R1–R12 |
| `SessionMetricTile` | Tile entrenamiento / descanso |
| `SessionShareCard` | Plantilla capturable (puede ir offstage al compartir) |
| `SessionNoteField` | Nota max 500; reutiliza validacion F04 si se extrajo shared |
| `ShareSessionButton` | CTA Compartir + ancla iPad |

Si el editor de nota de F04 es reusable, extraer a `shared/widgets/` solo si se usa en 2+ sitios
sin acoplar features (ver `03-conventions.md`).

## Riesgos y consideraciones

- **Carrera F04 insert vs nota:** R15; tests con delay artificial del repositorio.
- **Doble pantalla de cierre:** auditar placeholders F01 al integrar (R14).
- **iPad crash sin origin:** R19 obligatorio en codigo de share.
- **Memoria al toImage:** pixelRatio 2–3; card de tamaño acotado (~1080px ancho logico max).
- **F12 no montado en tests:** fake `StatsService`.
- **Permisos:** share_plus no requiere permiso de almacenamiento tipico para temp+sheet; no
  pedir galeria en F16.
- QA en **dispositivo fisico** del sheet real (emulador puede variar destinos).

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Solo boton Compartir sin pantalla celebratoria | No cubre referencia de producto ni motivacion post-sesion |
| Feature nueva F36 "post-workout" | Duplica el slot F16 del roadmap; expandir F16 es correcto |
| Reescribir F01 R18 con detalle UI | Contrato de F01 debe quedar estable; UI rica es F16 |
| Texto plano en share sin imagen | AC original y referencia exigen imagen |
| SDKs Instagram/WhatsApp | Fragil, permisos, fuera de offline-first; sheet nativo basta |
| Guardar nota en SharedPreferences aparte | Rompe unicidad con F04 `SessionLog.note` |
| `Share.shareXFiles` estatico | Deprecado en share_plus 13; usar `SharePlus.instance.share` |
