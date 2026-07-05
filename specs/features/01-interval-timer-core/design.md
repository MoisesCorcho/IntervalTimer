# Design: Interval Timer Core

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; el timer no depende de red.
- `_global/02-architecture-and-structure.md` — estructura `features/timer/`, capas presentation/application.
- `_global/03-conventions.md` — Riverpod como unico enfoque de estado; tests obligatorios.
- `_global/04-design-system.md` — `CountdownRing`, jerarquia visual, contraste dinamico, controles 48dp.
- `_global/05-data-model.md` — entidades y relaciones; actualizar al introducir tablas drift.

## Decisiones de diseno

### Modelo de datos

Alineado con `_global/05-data-model.md`. F01 introduce las entidades base; F08 agregara `Block` al union type.

- `Interval { id, name, durationSeconds, colorArgb, type }` donde `type` ∈ {warmup, work, rest, stretch, custom}.
- `RoutineItem` — union discriminada: en F01 solo existe la variante `interval(Interval)`; F08 agrega `block(Block)`.
- `Routine { id, name, items: List<RoutineItem>, createdAt }`.

Persistencia via **drift** (SQLite tipado), no JSON como almacenamiento primario. Tablas: `intervals`, `routines`, `routine_items` (orden por `position`). Actualizar `05-data-model.md` antes de implementar las migraciones.

### Gestion de estado

- **Riverpod** (`Notifier` / `AsyncNotifier`) — unico enfoque, segun `_global/03-conventions.md`.
- `TimerController` expone la maquina de estados: `idle` → `running` ↔ `paused` → `running` → `completed`.
- Transiciones invalidas (R15) se ignoran en el controller sin side effects.

### Calculo de tiempo (implementacion de R4, R5, R14)

- Fuente de verdad: `DateTime.now()` delta contra `segmentStartTimestamp` + `pausedAccumulatedMs`, **no** decrementos por tick.
- `Ticker` o `Stream.periodic(Duration(milliseconds: 100))` solo refresca UI (R2); nunca decrementa el contador.
- Background (R5): al volver a foreground, recalcular `remainingMs` desde timestamps; umbral de aceptacion ±1000ms tras 60 min documentado en R5.
- Condicion de carrera (R16): flag `isPausePending` evaluado antes de transicion de intervalo en el tick de dominio.

### Eventos de sesion (contratos observables — R6, R8)

```dart
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

Expuestos como `Stream` en `TimerController` (o `ref.listen` en capa presentation). F02/F04 se suscriben sin acoplar UI.

### UI

- Pantalla creacion/edicion: lista de intervalos, formulario nombre + duracion mm:ss + color picker.
- Pantalla ejecucion: `CountdownRing` o `ProgressBar` (`04-design-system.md`), preview siguiente intervalo (R9), controles play/pause/skip/cancel con area de toque >= 48dp.
- Pantalla o overlay post-completado (R18): confirmacion de sesion finalizada + accion que resetea `TimerController` a `idle` y navega a creacion/edicion.
- Contraste dinamico (R17): funcion util `contrastTextColor(Color background)` en `core/utils/`, reutilizable en F27/F31.

### Color picker

- Paquete `flutter_colorpicker` v1.1.0 (`ColorPicker` con `onColorChanged`, soporte HSV).
- Alternativa documentada si el paquete deja de mantenerse: `flex_color_picker`.
- Paleta predefinida de tipos de intervalo + selector custom HSV.

## Diagrama de flujo — F01

```
[Pantalla creacion] --guardar--> [RoutineRepository (drift)]
        |
        v (Start, R10)
[Pantalla ejecucion] <--> [TimerController (Riverpod)]
        |                        |
        |                        +-- timestamps (fuente de verdad)
        |                        +-- SessionCompleted / SessionCancelled streams
        v
[CountdownRing + preview + controles 48dp]
```

## Riesgos y consideraciones

- Primera migracion drift de F01 debe ser aditiva; documentar schema en `05-data-model.md` antes de codificar.
- Probar R5 (background) en dispositivo fisico Android e iOS; emuladores no reproducen suspension de app de forma fiable.
- `RoutineItem` union desde F01 evita refactor destructivo cuando F08 introduzca `Block`.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| JSON en shared_preferences para rutinas | Contradice steering docs; drift ofrece queries relacionales para F04/F05. |
| Bloc en lugar de Riverpod | `03-conventions.md` ya fija Riverpod como enfoque unico del proyecto. |
| Decremento por tick como fuente de verdad | Causa drift en background y bajo carga de UI; timestamps son mas fiables. |