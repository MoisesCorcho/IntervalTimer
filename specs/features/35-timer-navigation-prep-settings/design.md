# Design: Navegacion de Secciones, Preparacion y Ajustes

**ID:** F35 &nbsp;|&nbsp; **Slug:** `35-timer-navigation-prep-settings`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F35. Extiende `TimerController` y la pantalla de ejecucion de F01; introduce el shell de `features/settings/` y preferencias globales de preparacion.

Antes de implementar: revisar steering docs de la seccion Referencias y el codigo actual de `lib/features/timer/`.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; controles usables en movimiento.
- `_global/02-architecture-and-structure.md` — `features/timer/`, `features/settings/`.
- `_global/03-conventions.md` — Riverpod unico; tests con `fake_async`; strings en `ui_strings.dart`.
- `_global/04-design-system.md` — jerarquia timer, 48dp, radius, `NumberStepper`.
- `_global/05-data-model.md` — preferencias F35; sin tabla drift nueva.
- `features/01-interval-timer-core/design.md` — timestamps, eventos de sesion, maquina de estados base.
- `features/33-premium-numeric-steppers/` — API de `NumberStepper`.

## Decisiones de diseno

### Extension de la maquina de estados

Estado actual F01: `idle` → `running` ↔ `paused` → `completed`.

F35:

```
idle
  | start()
  +-- prepSeconds > 0 --> preparing  ↔  paused (segmento prep)
  |                            |
  |                            +-- prep → 0 o skipForward --> running (intervalo 0)
  +-- prepSeconds == 0 -------> running (intervalo 0)
running ↔ paused
  | skipForward / auto
  +--> running (siguiente) | completed
  | skipBack
  +--> running (anterior o reinicio intervalo 0)
cancel (confirmado) --> idle + SessionCancelled
```

Campos de estado sugeridos (extender `TimerState` freezed/equatable existente):

| Campo | Uso |
|---|---|
| `status` | incluye `preparing` (nuevo valor en `TimerStatus`) |
| `currentIndex` | indice de intervalo; irrelevante o -1 durante prep pura |
| `segmentKind` | enum `preparation` \| `interval` (alternativa a inferir solo por status) |
| `prepDurationMs` / restante via timestamps | duracion fijada al `start()` desde preferencias |
| timestamps existentes | `segmentStartTimestamp`, `pausedAccumulatedMs` — reutilizar para prep e intervalos |

**Regla:** al llamar `start()`, leer `prepSeconds` **una vez** y copiar a estado de sesion (`sessionPrepSeconds`). Cambios posteriores en preferencias no mutan la sesion activa (R20).

### Calculo de tiempo (preserva F01)

- Misma fuente de verdad: `DateTime.now()` − `segmentStartTimestamp` − `pausedAccumulatedMs`.
- `remainingMs` del segmento actual (prep o intervalo).
- **`totalRemainingMs`** (R8):

```
if segment == preparation:
  remainingPrep + sum(durationMs of all intervals)
else:
  remainingCurrentInterval + sum(durationMs of intervals with index > currentIndex)
```

Exponer getters en `TimerController` / estado: `remainingMs`, `totalRemainingMs`, `canSkipBack`, `canSkipForward` (forward casi siempre true hasta completar; back false solo si se prefiere deshabilitar en prep).

### API del controller (extensiones)

| Metodo | Comportamiento |
|---|---|
| `start(...)` | Si `sessionPrepSeconds > 0` → `preparing`; si 0 → intervalo 0 `running` |
| `pause()` / `resume()` | Incluye prep; sin reset de indice ni de restante (R4) |
| `skipForward()` | Prep → intervalo 0 full; intervalo → F01 R7; tras salto → `running` |
| `skipBack()` | Prep → no-op; index 0 → reinicia intervalo actual full; index > 0 → index-1 full; → `running` |
| `requestCancel()` | No cancela solo: UI muestra modal; o el controller expone `cancel()` solo tras confirmacion de UI |
| `cancel()` | F01 R8 sin cambios de contrato de eventos |

**Modal:** la confirmacion es **UI** (`showDialog` / modal route). El controller solo cancela cuando la UI invoca `cancel()` tras confirmar (R6/R7). No meter dialogs en el controller.

### Preferencias de preparacion

Sin drift. Reutilizar patron de preferencias (como F05 `active_routine_id`):

| Clave | Tipo | Default | Rango |
|---|---|---|---|
| `prep_seconds` | `int` | `10` | `0..60` |

Capa:

```
features/settings/
  application/settings_controller.dart   # Notifier o AsyncNotifier
  application/settings_state.dart
  domain/app_settings.dart               # opcional: value object { prepSeconds }
  data/settings_repository.dart          # shared_preferences
  presentation/settings_screen.dart
```

`SettingsRepository`:

- `Future<int> getPrepSeconds()`
- `Future<void> setPrepSeconds(int value)` con clamp 0–60

Inyectar via Riverpod. `TimerController.start` lee a traves del repositorio o de un provider de settings (override en tests).

Paquete: `shared_preferences` (ya tipico en el stack; verificar presencia en `pubspec.yaml` al implementar — si no esta, agregarlo; no inventar otro store).

### UI de ejecucion

Archivo principal existente: `lib/features/timer/presentation/timer_execution_screen.dart` (refactor de layout, no pantalla paralela salvo extraccion de widgets).

Estructura visual (referencia de producto acordada):

```
[ X salir ]     RESTANTE mm:ss      [ opcional spacer simetrico ]
                     |
              nombre fase / intervalo
              progreso n/N
              TIEMPO SEGMENTO (hero)
              [ card siguiente premium ]
                     |
         [ << ]   [ Pausar|Reanudar ]   [ >> ]
```

- Botones: `RoundedRectangleBorder` / `BorderRadius` ~8–12 (`radius.sm`/`md`); no `CircleBorder` para estos controles.
- Centro: `FilledButton` o superficie elevada + acento; laterales: tonal/outlined.
- Card "Siguiente": `surfaceContainer` / elevacion baja, padding md, label caption + title medium + duracion secondary.
- Modal salir: `AlertDialog` o bottom sheet modal segun plataforma; botones Continuar (default) y Salir (destructivo sutil).
- Contraste: mantener `contrastTextColor` de F01 R17 sobre color de intervalo.

Widgets extraibles (opcionales, `presentation/widgets/` o `shared/widgets/` solo si se reutilizan):

- `ExecutionTopBar` (salir + total remaining)
- `SegmentHeroTimer`
- `NextSegmentCard`
- `ExecutionControlBar` (prev / pause-resume / next)

### Entrada a Configuracion

- Ruta GoRouter (o router del proyecto): `/settings`.
- Punto de entrada minimo: icono en AppBar de la home / lista de entrenamientos / creacion de rutina (donde ya haya navegacion principal). Documentar la eleccion en el PR; no requiere tab bar nueva en F35.
- Bloquear navegacion a settings **desde** la pantalla de ejecucion activa no es obligatorio si el stack impide volver atras sin cancelar; preferir que la ejecucion sea ruta full-screen sin drawer de settings.

### Eventos de sesion

Sin cambios de contrato en `SessionCompletedEvent` / `SessionCancelledEvent`.

Notas:

- Cancelar durante prep emite `SessionCancelled` con `completedIntervalCount = 0`.
- Completar sesion solo tras intervalos; prep no cuenta como intervalo completado.

### i18n / strings

Hasta F28, agregar claves en `lib/core/constants/ui_strings.dart`:

- prep label, restante, anterior, siguiente, salir modal titulo/cuerpo/acciones, settings title, prep setting label.

## Diagrama de flujo — F35

```
[SettingsScreen] <--> [SettingsRepository (shared_preferences)]
        ^
        | prepSeconds al start
[Start sesion] --> [TimerController]
        |
        +-- prep>0 --> [preparing UI] --0/skip--> [running intervalos]
        +-- prep=0 ------------------> [running intervalos]
        |
        +-- pause/resume (timestamps)
        +-- skipBack / skipForward
        +-- UI modal --> cancel --> idle + SessionCancelled

[TimerExecutionScreen]
  top: exit + totalRemaining
  hero: segment remaining
  card: next segment
  bar: prev | pause-resume | next
```

## Riesgos y consideraciones

- **Regresion F01:** toda extension de `TimerStatus` y skip debe mantener tests existentes verdes; agregar casos prep y skipBack.
- **Deshabilitar anterior en prep:** preferir boton disabled visible (affordances claras) vs ocultar.
- **totalRemainingMs y rounds (F08 futuro):** F35 calcula sobre la lista plana de intervalos de la sesion actual; cuando F08 expanda items, el calculo debe basarse en la secuencia efectiva de ejecucion ya expandida (misma lista que usa el controller).
- **F32 workouts:** si el start usa lista aplanada de ejercicios, prep se aplica **una vez** al inicio de esa lista, no por ejercicio.
- **NumberStepper:** si F33 no estuviera linkeado en la pantalla de settings, reutilizar el widget de `shared/widgets/`; no reimplementar TextField.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Prep como intervalo sintetico insertado en la lista | Contamina historial/F04 y skip back hacia un "intervalo" que no es del usuario; mejor estado `preparing` dedicado. |
| Tabla drift `app_settings` | Sobredimensionado para un entero; prefs alineadas a F05. |
| Feature solo UI sin settings | Prep configurable es requisito de producto; requiere persistencia. |
| Dos botones separados Pausar y Reanudar | Usuario pidio un solo control toggle. |
| Anterior siempre deshabilitado en index 0 | Peor UX; reiniciar el primer intervalo es util (R3). |

## Plan de actualizacion de steering docs (pre-codigo)

| Documento | Cambio |
|---|---|
| `05-data-model.md` | Seccion preferencias F35: clave `prep_seconds` |
| `06-roadmap-and-dependencies.md` | Fila F35 + grafo |
| `04-design-system.md` | Solo si se extrae widget compartido nuevo documentable (opcional en implementacion) |
| `02-architecture` | Ya menciona `settings/`; no requiere cambio estructural |
