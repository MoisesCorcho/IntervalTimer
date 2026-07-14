# Tasks: Vibracion como Feedback

**ID:** F18 &nbsp;|&nbsp; **Slug:** `18-vibration-feedback`

## Definition of Done

- [x] Todos los criterios R1–R14 de `requirements.md` estan implementados y verificados. _(cubre R1–R14)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Preferencias documentadas en `_global/05-data-model.md`.
- [x] No se rompieron F01 (timer, skip, pause, cancel, completed) ni el mute de voz F02 si esta presente.
- [x] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, sin acoplar UI F01↔vibration).
- [ ] Patrones A/B validados en **dispositivo fisico** Android y/o iOS (no solo emulador).

## Checklist de implementacion

### Datos y persistencia

- [x] Persistir preferencias globales `vibration_enabled`, `vibration_on_interval_start`, `vibration_on_countdown`, `vibration_countdown_seconds` con defaults y rangos del data model. _(cubre R3, R4, R5, R6, R8)_
- [x] Actualizar `_global/05-data-model.md` con la seccion Preferencias F18 (si aun no esta). _(cubre R6)_

### Contratos F01 (minima extension si falta)

- [x] Asegurar `IntervalStartedEvent` (o equivalente documentado en design F02/F18) desde `TimerController` en cada inicio de intervalo. _(cubre R1, R10)_
- [x] Asegurar que `remainingMs` y `status` sean observables de forma estable para countdown (listen Riverpod). _(cubre R2, R9, R11)_

### Logica de vibracion

- [x] Agregar dependencia `vibration` ^3.2.0 y permiso Android `VIBRATE`. _(cubre R1, R7)_
- [x] Implementar `VibrationDriver` + `PluginVibrationDriver` + `NoOpVibrationDriver` (hasVibrator/vibrate/cancel; excepciones → no-op). _(cubre R1, R7, R11, R12)_
- [x] Implementar `VibrationPatternResolver` para patrones A (inicio) y B (countdown). _(cubre R1, R2)_
- [x] Implementar `VibrationFeedbackController` (Riverpod): suscripcion a F01, gates de prefs, idempotencia de ticks. _(cubre R1, R2, R4, R5, R9, R10, R13, R14)_
- [x] Aplicar politicas pause / cancel / complete: `cancel()` + no nuevos patrones. _(cubre R11, R12)_
- [x] Respetar master off y toggles granulares; independencia de `voiceEnabled`. _(cubre R3, R4, R14)_

### UI

- [x] Seccion de configuracion de vibracion: master toggle, toggles de eventos, stepper countdown 0–10; validacion de rango. _(cubre R3, R4, R5, R6, R8)_
- [x] Controles con area de toque >= 48dp segun design system. _(cubre R3)_
- [x] Deshabilitar controles granulares cuando master esta off (UX). _(cubre R3, R4)_

### Tests

- [x] **Unit — happy path:** IntervalStarted con vibration on → patron A; ticks S=3,2,1 una vez cada uno con vibrationCountdownSeconds=3 → patron B. _(cubre R1, R2)_
- [x] **Unit — toggles:** vibrationEnabled=false no vibra; onIntervalStart=false omite A pero permite B; onCountdown=false omite B; countdownSeconds=0 omite B. _(cubre R3, R4, R5)_
- [x] **Unit — independencia voz:** voiceEnabled=false y vibrationEnabled=true sigue emitiendo A/B (mock). _(cubre R14)_
- [x] **Unit — error/edge:** driver.hasVibrator=false o vibrate lanza → timer no afectado; intervalo de 2s con N=5 solo emite S alcanzables; idle/completed no vibra; pause cancel + no ticks; completed/cancelled cancel. _(cubre R7, R9, R10, R11, R12)_
- [x] **Unit — idempotencia:** mismo S no se emite dos veces en el mismo intervalo. _(cubre R13)_
- [x] **Unit — prefs:** guardar countdown fuera de 0–10 se rechaza/clamp; prefs se restauran. _(cubre R6, R8)_
- [x] **Widget — settings:** toggles y stepper actualizan estado visible y validan rango. _(cubre R3, R4, R5, R8)_

### QA dispositivo

- [ ] Verificar en dispositivo fisico Android y/o iOS que patrones A y B son perceptiblemente distintos y que R7 no muestra errores. _(cubre R1, R2, R7)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | IntervalStartedEvent, PatternResolver A, FeedbackController, unit happy path, QA fisico |
| R2 | remainingMs listen, PatternResolver B, idempotencia, unit happy path, QA fisico |
| R3 | Prefs master, UI settings, unit toggles, widget settings |
| R4 | Prefs granulares, FeedbackController, unit toggles, widget settings |
| R5 | Prefs countdown, FeedbackController, unit toggles/prefs |
| R6 | Persistencia prefs, unit prefs, data model |
| R7 | VibrationDriver no-op/errors, unit error/edge, QA fisico |
| R8 | Validacion UI + persistencia, unit prefs, widget settings |
| R9 | Logica ticks + unit error/edge |
| R10 | Gate por status, unit error/edge |
| R11 | Politica pause, unit error/edge |
| R12 | SessionCompleted/Cancelled → cancel, unit error/edge |
| R13 | Set de segundos, unit idempotencia |
| R14 | Gate independiente de voice, unit independencia voz |

## Notas de secuenciacion

Esta feature depende de: **F01** (Done como prerequisito de producto).

Orden recomendado: prefs + data model → asegurar eventos F01 → `VibrationDriver`/patterns →
`VibrationFeedbackController` → UI settings → tests unit/widget → QA fisico.

No iniciar tasks de este archivo hasta que F01 este en estado Done.
No implementar patrones customizables por el usuario ni haptics de botones UI en estas tasks.
No acoplar a la cola TTS de F02; solo reutilizar contratos de timer.
