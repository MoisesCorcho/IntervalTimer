# Design: Vibracion como Feedback

**ID:** F18 &nbsp;|&nbsp; **Slug:** `18-vibration-feedback`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en Referencias y los contratos de eventos
de F01 (`SessionCompleted`, `SessionCancelled`, estado del timer) y, si existe, el
`IntervalStartedEvent` documentado en F02.

## Referencias

- `_global/01-vision-and-principles.md` — feedback manos-libres; cero friccion; offline-first.
- `_global/02-architecture-and-structure.md` — carpeta `features/vibration/`; Riverpod; sin acoplar UI entre features.
- `_global/03-conventions.md` — Riverpod unico; tests unitarios del dominio de haptics.
- `_global/04-design-system.md` — UI de ajustes (toggles, steppers 48dp).
- `_global/05-data-model.md` — claves de preferencias de vibracion.
- `features/01-interval-timer-core/design.md` — `TimerController`, timestamps, streams de sesion.
- `features/02-voice-countdown-announcements/design.md` — `IntervalStartedEvent`, patron de suscripcion desacoplada.

## Decisiones de diseno

### Paquete de vibracion (verificado pub.dev)

- **`vibration` ^3.2.0** (pub.dev; ~368k downloads; plataformas Android/iOS/web/OpenHarmony).
- APIs usadas en F18:
  - `Vibration.hasVibrator()` — gate de hardware (R7)
  - `Vibration.hasCustomVibrationsSupport()` — decidir pattern vs fallback simple
  - `Vibration.vibrate(duration: …)` / `Vibration.vibrate(pattern: …)` / presets opcionales
  - `Vibration.cancel()` — R11, R12
- Android: declarar permiso en `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.VIBRATE"/>
  ```
- iOS: CoreHaptics en dispositivos compatibles; en hardware antiguo el plugin emula patrones con
  pulsos ~500 ms — documentar en QA que el **timming percibido** puede diferir; la distincion
  semantica A vs B sigue siendo obligatoria cuando haya soporte custom.
- **No** usar solo `HapticFeedback` de Flutter como unica implementacion: no cubre patterns
  multi-segment ni `hasVibrator` de forma portable. Se permite un **fallback** a
  `HapticFeedback.lightImpact` / `mediumImpact` solo si `hasVibrator == false` pero se desea
  feedback en simuladores de desarrollo (opcional, no requisito de AC).

### Capas y ubicacion de codigo

Segun `_global/02-architecture-and-structure.md`:

```
features/vibration/
  application/   → VibrationFeedbackController (Riverpod), VibrationSettingsController
  domain/        → VibrationDriver (abstract), VibrationPatternResolver, tick idempotency
  presentation/  → VibrationSettingsSection (toggles + countdown 0–10)
data/repositories/ → PreferencesRepository (claves de vibracion)
```

### Abstraccion del driver (testeable)

```dart
abstract class VibrationDriver {
  Future<bool> hasVibrator();
  Future<void> vibrate({int? durationMs, List<int>? pattern});
  Future<void> cancel();
}

class PluginVibrationDriver implements VibrationDriver {
  // envuelve package:vibration; captura excepciones → no-op (R7)
}

class NoOpVibrationDriver implements VibrationDriver {
  // tests / web sin hardware
}
```

### Patrones A y B (contrato observable de feedback)

| Patron | Uso | Implementacion sugerida |
|---|---|---|
| **A — inicio de intervalo** | R1 | `duration: 60` ms **o** `VibrationPreset.singleShortBuzz` / `quickSuccessAlert` si se prefiere preset estable |
| **B — tick countdown** | R2 | `duration: 25` ms **o** pattern `[0, 20, 40, 20]` (doble pulse corto) — **distinto** de A |

Resolver en un unico sitio (`VibrationPatternResolver`) para no hardcodear ms en el controller.
Si `hasCustomVibrationsSupport() == false`, degradar B a un unico `vibrate()` corto (sigue siendo
un evento por tick; R7 si incluso eso falla).

### Integracion con F01 (contratos observables)

Misma filosofia que F02:

```dart
// Ya documentado en F02 — reutilizar, no duplicar:
class IntervalStartedEvent {
  final String intervalId;
  final String name;
  final String? announceText;
  final int durationSeconds;
  final int index;
}
```

**Responsabilidades:**

| Componente | Hace | No hace |
|---|---|---|
| `TimerController` (F01) | Emite `IntervalStartedEvent`; expone `remainingMs`, `status`; streams completed/cancelled | No llama a `vibration` |
| `VibrationFeedbackController` (F18) | Escucha eventos/estado; aplica prefs; llama a `VibrationDriver` | No muta estado del timer ni prefs de voz |
| UI ajustes | Lee/escribe prefs de vibracion | No vibra directo (salvo preview opcional fuera de alcance v1) |

**Reglas de countdown (R2, R9, R13):**

- Fuente de tiempo: `remainingMs` de F01 (timestamps), no un ticker propio de haptics.
- Tick haptico cuando `status == running`, prefs lo permiten, y
  `ceil(remainingMs / 1000) == S` con `1 <= S <= vibrationCountdownSeconds`, y `S` no fue ya
  emitido en el `intervalId` actual (set `vibratedSecondsForInterval`).
- Al `IntervalStartedEvent`: reset del set de segundos; si corresponde R1, emitir patron A.
- Al `paused` / cancel / complete: `cancel()` y limpiar flags segun R11–R12.
- Condicion de carrera F01 pause-vs-advance: reaccionar al `status` final, no a ticks intermedios.

### Modelo de datos / preferencias

Sin tablas drift nuevas. Preferencias globales (actualizar `_global/05-data-model.md`):

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `vibration_enabled` | bool | `true` | — | Master mute de haptics (R3) |
| `vibration_on_interval_start` | bool | `true` | — | Toggle patron A (R4) |
| `vibration_on_countdown` | bool | `true` | — | Toggle patron B (R4) |
| `vibration_countdown_seconds` | int | `3` | `0..10` | Ventana N de R2/R5 |

Persistir via `PreferencesRepository` / `app_preferences` (mismo patron F02/F35).

**Nota de independencia:** claves distintas de `voice_enabled` / `countdown_seconds` de F02.
No sincronizar automaticamente los dos N de countdown.

### Gestion de estado

- **Riverpod** (`Notifier`): `vibrationSettingsProvider` (prefs) +
  `vibrationFeedbackProvider` (suscripcion al timer).
- Sin `setState` para negocio de haptics.
- UI de configuracion: seccion en shell `features/settings/` (F35) si existe; si no, pantalla
  minima bajo `features/vibration/presentation`.

### UI

- Toggle "Vibracion activada" (`vibrationEnabled`) — area de toque >= 48dp.
- Toggle "Al cambiar de intervalo" (`vibrationOnIntervalStart`).
- Toggle "En cuenta regresiva" (`vibrationOnCountdown`).
- Stepper entero `vibrationCountdownSeconds` 0–10 (reutilizar `NumberStepper` si existe en
  shared/widgets).
- Deshabilitar visualmente toggles granulares y stepper cuando master esta off (UX; el dominio
  ya ignora eventos si master es false).

## Diagrama de flujo — F18

```
[TimerController F01]
   |  IntervalStartedEvent
   |  remainingMs + status (listen)
   |  SessionCompleted / SessionCancelled
   v
[VibrationFeedbackController (Riverpod)]
   |  vibration_enabled / on_interval_start / on_countdown / countdown_seconds (prefs)
   |  vibratedSecondsForInterval (idempotencia R13)
   |  VibrationPatternResolver → patron A | B
   v
[VibrationDriver / PluginVibrationDriver]
   |  hasVibrator?  --no--> no-op (R7)
   v
[package:vibration → Vibrator / CoreHaptics]
```

## Riesgos y consideraciones

- Emuladores y muchos CI runners no tienen vibrador → R7 + `NoOpVibrationDriver` en tests.
- iOS sin CoreHaptics: patterns custom degradan; validar en dispositivo fisico A/B distinguibles.
- Android: sin `VIBRATE` en manifest, las llamadas fallan → capturar en driver (R7).
- No bloquear el isolate UI: `vibrate` es async; errores a handler, no a uncaught futures.
- No acoplar a F02: si F02 no esta, F18 igual funciona con eventos F01; solo reutiliza el contrato
  de `IntervalStartedEvent` si ya existe.
- Doble feedback voz+vibracion en el mismo tick es **intencional** (gimnasio ruidoso); no
  silenciar haptics cuando habla el TTS.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Solo `HapticFeedback` de Flutter | Suficiente para taps UI, insuficiente para patterns multi-segment y `hasVibrator` portable. |
| Llamar `Vibration` desde `TimerController` | Acopla F01 a hardware; rompe limites de features. |
| Reutilizar clave `countdown_seconds` de F02 | Acopla producto voz↔haptic; el usuario puede querer N distintos. |
| Paquete `flutter_vibrate` | Menor adopcion y API menos clara que `vibration` 3.x con presets. |
| Amplitude / sharpness configurables en UI | Scope creep; default de plataforma basta para v1. |
