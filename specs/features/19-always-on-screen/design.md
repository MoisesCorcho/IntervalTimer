# Design: Pantalla Siempre Encendida

**ID:** F19 &nbsp;|&nbsp; **Slug:** `19-always-on-screen`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en Referencias y los contratos de
estado/eventos de F01 (`TimerController`: `status`, `SessionCompleted`, `SessionCancelled`).
Si F35 esta presente, incluir el estado `preparing` en la politica de activacion (R14).

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion; wakelock como pilar de hands-free.
- `_global/02-architecture-and-structure.md` — carpeta `features/always_on/`; Riverpod; sin acoplar
  UI entre features; ciclo de vida app.
- `_global/03-conventions.md` — Riverpod unico; tests del dominio/servicio de always-on.
- `_global/04-design-system.md` — toggle de ajustes, area de toque >= 48dp.
- `_global/05-data-model.md` — clave `keep_screen_on_enabled`.
- `features/01-interval-timer-core/design.md` — `TimerController`, estados, streams de sesion.
- `features/35-timer-navigation-prep-settings/` — `preparing`, shell settings (si aplica).

## Decisiones de diseno

### Paquete de screen wakelock (verificado pub.dev)

- **`wakelock_plus` ^1.6.1** (pub.dev; publisher `fluttercommunity.dev`; ~1.95M downloads;
  Android / iOS / Web / macOS / Windows / Linux).
- Continuacion mantenida del plugin historico `wakelock` (API renombrada a `WakelockPlus`).
- **No requiere permisos** en ninguna plataforma (solo screen wakelock, no partial CPU wakelock).
- APIs usadas en F19:
  - `WakelockPlus.enable()` — activar (R1, R7, R9, R14)
  - `WakelockPlus.disable()` — desactivar (R2, R3, R4, R7, R12, R13)
  - `WakelockPlus.toggle(enable: bool)` — alternativa idiomatica al par enable/disable
  - `WakelockPlus.enabled` (`Future<bool>`) — lectura opcional para asserts en tests/QA
- Llamadas **async** y tolerantes a error: envolver en try/catch → no-op (R11).
- **No** llamar `enable()` una sola vez en `main()`: el SO puede liberar el wakelock; reafirmar
  segun estado (documentacion oficial del paquete).
- Si se invoca antes de `runApp`, requiere `WidgetsFlutterBinding.ensureInitialized()` — F19
  **no** debe habilitar wakelock en `main()` de forma global.

```dart
import 'package:wakelock_plus/wakelock_plus.dart';

// Activar
await WakelockPlus.enable();
// o
await WakelockPlus.toggle(enable: true);

// Desactivar
await WakelockPlus.disable();
```

**Nota de plataformas de escritorio/web:** el plugin declara soporte; el efecto "pantalla no se
duerme" puede ser no-op o limitado. R11 aplica. QA de apagado real: **dispositivo fisico**
Android/iOS.

**Nota de SDK:** `wakelock_plus` 1.6.x puede exigir Flutter/Dart recientes (ver pubspec del
paquete al pinnear). Si el proyecto no alcanza el SDK minimo, pinnear la ultima version
compatible del paquete **sin** cambiar la semántica de enable/disable/toggle, y documentar el
pin en este design.

### Capas y ubicacion de codigo

Segun `_global/02-architecture-and-structure.md`:

```
features/always_on/
  application/   → AlwaysOnController (Riverpod), AlwaysOnSettingsController
  domain/        → WakelockDriver (abstract), KeepScreenOnPolicy (pure)
  presentation/  → KeepScreenOnSettingsTile / seccion en settings
data/repositories/ → PreferencesRepository (clave keep_screen_on_enabled)
```

**Por que no solo en el widget de ejecucion:** el design esqueleto original ataba el wakelock
solo al lifecycle del `WorkoutSessionScreen`. Eso cubre R4 (dispose) pero dificulta tests,
reafirmacion en `resumed` (R9) y el toggle inmediato (R7). El enfoque F19 es un
**AlwaysOnController** que:

1. Escucha `TimerController.status` (y eventos completed/cancelled).
2. Escucha `keepScreenOnEnabled` desde prefs.
3. Se monta / se enlaza al host de la pantalla de ejecucion (o a un provider scoped a la ruta
   de sesion) para garantizar disable en dispose (R4).
4. Implementa `WidgetsBindingObserver` (o se alimenta de un lifecycle provider existente) para R9.

`TimerController` (F01) **no** importa `wakelock_plus` ni `always_on`.

### Abstraccion del driver (testeable)

```dart
abstract class WakelockDriver {
  Future<void> enable();
  Future<void> disable();
  Future<bool> get isEnabled;
}

class PluginWakelockDriver implements WakelockDriver {
  // envuelve WakelockPlus; captura excepciones → no-op (R11)
}

class NoOpWakelockDriver implements WakelockDriver {
  // tests / plataformas sin efecto
}
```

### Politica pura (testable sin plugins)

```dart
/// Devuelve si el screen wakelock debe estar activo.
bool shouldKeepScreenOn({
  required String sessionStatus, // idle | preparing | running | paused | completed
  required bool keepScreenOnEnabled,
  required bool executionHostMounted, // pantalla/flujo de ejecucion vivo
}) {
  if (!keepScreenOnEnabled) return false;
  if (!executionHostMounted) return false;
  return sessionStatus == 'running' || sessionStatus == 'preparing';
}
```

El controller traduce el booleano a `driver.enable()` / `driver.disable()` de forma **idempotente**
(llamar enable varias veces es seguro segun docs del paquete; igual conviene trackear
`_lastApplied` para no spamear plataforma en cada rebuild).

### Integracion con F01 (contratos observables)

| Componente | Hace | No hace |
|---|---|---|
| `TimerController` (F01) | Expone `status`, streams completed/cancelled | No llama wakelock |
| `AlwaysOnController` (F19) | Aplica politica; enable/disable; lifecycle resumed | No muta estado del timer |
| UI ajustes | Lee/escribe `keep_screen_on_enabled` | No llama al plugin directo |

**Transiciones clave:**

| Evento | Accion wakelock (si pref on y host montado) |
|---|---|
| → `running` / `preparing` | `enable` |
| → `paused` | `disable` |
| → `idle` / `completed` | `disable` |
| `SessionCancelled` / `SessionCompleted` | `disable` |
| Host dispose / pop ejecucion | `disable` (`executionHostMounted=false`) |
| Pref false durante running | `disable` |
| Pref true durante running | `enable` |
| `AppLifecycleState.resumed` y politica true | `enable` (reafirmar) |

### Modelo de datos / preferencias

Sin tablas drift nuevas. Preferencia global (actualizar `_global/05-data-model.md`):

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `keep_screen_on_enabled` | bool | `true` | — | Master on/off de screen wakelock (R5–R8, R12) |

Persistir via `PreferencesRepository` / `app_preferences` (mismo patron F02/F18/F35).

**Nota vs `_global/02-architecture` tabla de persistencia:** esa tabla menciona
`shared_preferences` historicamente para F19. La implementacion canonica del proyecto unifica
flags en `app_preferences` via `PreferencesRepository`. F19 sigue ese patron; no introducir un
segundo store solo para este flag.

### Gestion de estado

- **Riverpod** (`Notifier`):
  - `keepScreenOnSettingsProvider` — lee/escribe pref.
  - `alwaysOnControllerProvider` — aplica politica (depende de timer status + pref + host).
- Sin `setState` para la politica de wakelock.
- UI de configuracion: tile/seccion en shell `features/settings/` (F35) si existe; si no,
  pantalla minima bajo `features/always_on/presentation`.

### UI

- Toggle "Pantalla siempre encendida" / "Keep screen on" (`keepScreenOnEnabled`).
- Area de toque >= 48dp (`_global/04-design-system.md`).
- Subtitulo breve opcional: explica que evita que se apague la pantalla durante el entrenamiento
  y que afecta la bateria (copy i18n queda para F28; string hardcodeado o key provisional ok en F19).

## Diagrama de flujo — F19

```
[TimerController F01]
   |  status (idle|preparing|running|paused|completed)
   |  SessionCompleted / SessionCancelled
   v
[AlwaysOnController (Riverpod)]
   |  keep_screen_on_enabled (prefs)
   |  executionHostMounted (ruta/widget sesion)
   |  AppLifecycle.resumed → reafirmar
   |  KeepScreenOnPolicy.shouldKeepScreenOn(...)
   v
[WakelockDriver / PluginWakelockDriver]
   |  try enable/disable  --error--> no-op (R11)
   v
[package:wakelock_plus → screen wakelock del SO]
```

## Riesgos y consideraciones

- **Fugas de bateria:** si se olvida `disable` al salir, la pantalla puede quedarse forever-on.
  Priorizar dispose del host + tests de todos los flujos de salida (R2–R4, R13).
- **SO libera wakelock:** reafirmar en `resumed` (R9); no asumir un unico `enable` al start.
- **Emuladores:** el timeout de pantalla puede no comportarse como hardware real → QA fisico.
- **No bloquear UI:** `enable`/`disable` async; errores al handler, no a uncaught futures.
- **F20:** al implementar notificacion/lock screen, no duplicar politicas de screen-on; F20
  puede asumir que F19 liberó wakelock al ir a background segun su propio alcance, o coordinar
  en design de F20. F19 v1 no mantiene pantalla on fuera del host de ejecucion.
- **Flutter SDK vs wakelock_plus:** al agregar dependencia, verificar constraint de SDK del
  paquete vs el del proyecto.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| `wakelock` (paquete original) | Deprecado / reemplazado por `wakelock_plus` en la community. |
| Solo `WorkoutSessionScreen` dispose sin controller | Dificulta tests, R7 y R9; peor separacion de capas. |
| Llamar wakelock desde `TimerController` | Acopla F01 a un plugin de plataforma; viola desacoplamiento entre features. |
| Mantener wakelock en `paused` | Contradice AC de ahorro al pausar y el esqueleto original; usuario pausado suele no mirar. |
| Default `false` | Choca con vision "cero friccion"; el usuario tendria que descubrir el toggle. |
| Partial CPU wakelock / foreground service | Fuera de alcance F19; es F20 u otra feature de background. |
