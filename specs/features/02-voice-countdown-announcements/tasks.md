# Tasks: Voz: Cuenta Regresiva y Anuncios

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements`

## Definition of Done

- [x] Todos los criterios R1–R15 de `requirements.md` estan implementados y verificados. _(cubre R1–R15)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Schema / preferencias documentados en `_global/05-data-model.md` y migracion aditiva aplicada.
- [x] No se rompieron F01 (timer, skip, pause, cancel, completed).
- [x] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, sin acoplar UI F01↔voice).

## Checklist de implementacion

### Datos y persistencia

- [x] Extender modelo `Interval` con `announceText` opcional (max 80) y mapper dominio. _(cubre R5, R15)_
- [x] Migracion drift aditiva: columna `intervals.announce_text` TEXT NULL; actualizar `05-data-model.md`. _(cubre R5)_
- [x] Persistir preferencias globales `voice_enabled`, `countdown_seconds`, `announce_interval_name` con defaults y rangos del data model. _(cubre R3, R4, R6, R7, R9)_

### Contratos F01 (minima extension)

- [x] Exponer `IntervalStartedEvent` (o equivalente documentado en design) desde `TimerController` en cada inicio de intervalo. _(cubre R1, R11)_
- [x] Asegurar que `remainingMs` y `status` sean observables de forma estable para countdown (listen Riverpod). _(cubre R2, R10, R13)_

### Logica de voz

- [x] Agregar dependencia `flutter_tts` ^4.2.5 y configurar Android `queries` TTS_SERVICE. _(cubre R1, R8)_
- [x] Implementar `TtsEngine` + `SystemTtsEngine` (speak/stop/isAvailable, setLanguage, error handler). _(cubre R1, R8, R14)_
- [x] Implementar `VoiceAnnouncer` (Riverpod): suscripcion a F01, resolveAnnounceText, idempotencia de ticks. _(cubre R1, R2, R5, R10, R11, R12)_
- [x] Aplicar politicas mute / pause / cancel / complete: stop + no nuevos speaks. _(cubre R4, R13, R14)_
- [x] Respetar `announceIntervalName` y `countdownSeconds == 0`. _(cubre R3, R6)_

### UI

- [x] Pantalla/seccion de configuracion de voz: toggle voz, countdown 0–10, toggle anunciar nombre; validacion rango. _(cubre R3, R4, R6, R7, R9)_
- [x] Campo opcional `announceText` en formulario de intervalo (creacion/edicion F01) con validacion max 80. _(cubre R5, R15)_
- [x] Controles con area de toque >= 48dp segun design system. _(cubre R3, R4)_

### Tests

- [x] **Unit — happy path:** IntervalStarted con voice on → speak de name; ticks S=3,2,1 una vez cada uno con countdownSeconds=3. _(cubre R1, R2)_
- [x] **Unit — announceText:** custom no vacio se habla; null/blank cae a name. _(cubre R5)_
- [x] **Unit — mute y toggles:** voiceEnabled=false no habla y stop; announceIntervalName=false omite R1 pero permite countdown; countdownSeconds=0 omite R2. _(cubre R3, R4, R6)_
- [x] **Unit — error/edge:** TtsEngine.speak falla → timer no afectado (mock engine); intervalo de 2s con N=5 solo emite S alcanzables; idle/completed no habla; pause stop + no ticks; completed/cancelled stop. _(cubre R8, R10, R11, R13, R14)_
- [x] **Unit — solapamiento:** nuevo IntervalStarted interrumpe speak en curso; mismo S no se repite dos veces. _(cubre R12)_
- [x] **Unit — prefs:** guardar countdown fuera de 0–10 se rechaza/clamp; prefs se restauran. _(cubre R7, R9)_
- [x] **Widget — settings:** toggles y stepper de countdown actualizan estado visible y validan rango. _(cubre R3, R4, R6, R9)_
- [x] **Widget — formulario intervalo:** announceText >80 muestra validacion y no persiste. _(cubre R15)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | IntervalStartedEvent, VoiceAnnouncer, SystemTtsEngine, unit happy path |
| R2 | remainingMs listen, idempotencia ticks, unit happy path |
| R3 | Prefs countdown, UI settings, unit mute/toggles, widget settings |
| R4 | Prefs voice_enabled, politicas mute, unit mute, widget settings |
| R5 | Modelo announceText, resolveAnnounceText, unit announceText, UI form |
| R6 | Prefs announce_interval_name, VoiceAnnouncer, unit mute/toggles |
| R7 | Persistencia prefs, unit prefs |
| R8 | SystemTtsEngine error handler, unit error/edge |
| R9 | Validacion UI + persistencia, unit prefs, widget settings |
| R10 | Logica ticks + unit error/edge |
| R11 | Gate por status, unit error/edge |
| R12 | stop+speak, idempotencia, unit solapamiento |
| R13 | Politica pause, unit error/edge |
| R14 | SessionCompleted/Cancelled → stop, unit error/edge |
| R15 | Validacion announceText, widget form |

## Notas de secuenciacion

Esta feature depende de: **F01** (Done).

Orden recomendado: data model + migracion + prefs → extension eventos F01 → `TtsEngine`/`VoiceAnnouncer` → UI settings + campo formulario → tests.

No iniciar tasks de este archivo hasta que F01 este en estado Done.
No implementar seleccion multi-voz ni premium (F07) en estas tasks.
