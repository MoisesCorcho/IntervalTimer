# Requirements: Vibracion como Feedback

**ID:** F18 &nbsp;|&nbsp; **Slug:** `18-vibration-feedback` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Vibracion (haptics) en momentos clave del temporizador — inicio de intervalo y ticks de cuenta
regresiva — como alternativa o complemento al audio. Util en gimnasios ruidosos o cuando el
usuario prefiere feedback táctil sin mirar la pantalla. Independiente del mute de voz (F02).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** sentir una vibracion al cambiar de intervalo, **para que** sepa
  cuando cambia la seccion aunque no escuche el audio.
- **Como** usuario, **quiero** sentir vibraciones distintas en la cuenta regresiva final,
  **para que** me prepare al cambio sin mirar el telefono.
- **Como** usuario, **quiero** activar o desactivar la vibracion sin afectar la voz ni el timer,
  **para que** controle el feedback táctil de forma independiente.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Vibracion al iniciar intervalo

CUANDO el temporizador avanza a un nuevo intervalo (inicio de sesion, avance automatico o skip)
y `vibrationEnabled` es `true` y `vibrationOnIntervalStart` es `true` y la sesion esta en estado
`running`, EL SISTEMA DEBE emitir un patron de vibracion de **inicio de intervalo** (patron A:
pulso unico breve; ver `design.md`).

### R2 — Vibracion en cuenta regresiva

CUANDO el tiempo restante del intervalo actual cruza por primera vez un segundo entero `S` donde
`1 <= S <= vibrationCountdownSeconds` y `vibrationCountdownSeconds > 0` y `vibrationEnabled` es
`true` y `vibrationOnCountdown` es `true` y la sesion esta en estado `running`, EL SISTEMA DEBE
emitir un patron de vibracion de **tick de cuenta regresiva** (patron B: pulso mas corto o
repetido, distinto del patron A) **una sola vez** por cada valor de `S` en ese intervalo.

### R3 — Toggle independiente del audio

DONDE el usuario esta en la pantalla o seccion de ajustes de vibracion (shell `features/settings/`
si existe; si no, UI minima bajo `features/vibration/`), CUANDO activa o desactiva
`vibrationEnabled`, EL SISTEMA DEBE aplicar el cambio de inmediato a ticks/eventos futuros sin
modificar `voiceEnabled` (F02), el volumen del sistema ni la maquina de estados del temporizador
(F01).

### R4 — Toggles granulares de eventos

DONDE el usuario esta en la configuracion de vibracion, CUANDO desactiva
`vibrationOnIntervalStart`, EL SISTEMA DEBE omitir el patron A (R1) en intervalos siguientes
manteniendo el patron B (R2) si `vibrationOnCountdown` y `vibrationEnabled` lo permiten.

CUANDO desactiva `vibrationOnCountdown`, EL SISTEMA DEBE omitir el patron B manteniendo el
patron A si `vibrationOnIntervalStart` y `vibrationEnabled` lo permiten.

### R5 — Ventana de cuenta regresiva configurable

DONDE el usuario esta en la configuracion de vibracion, CUANDO configura
`vibrationCountdownSeconds` en el rango 0–10 inclusive, EL SISTEMA DEBE persistir el valor de
forma global y usarlo en ticks futuros de la sesion activa y en sesiones siguientes. Valor `0`
desactiva solo la vibracion de cuenta regresiva (R2) sin desactivar el patron de inicio (R1).
Default de fabrica: `3`.

### R6 — Persistencia de preferencias de vibracion

CUANDO el usuario cambia `vibrationEnabled`, `vibrationOnIntervalStart`, `vibrationOnCountdown`
o `vibrationCountdownSeconds`, EL SISTEMA DEBE persistir los valores de forma global
(`PreferencesRepository` / `app_preferences`; ver `design.md` y `_global/05-data-model.md`) y
restaurarlos al reiniciar la app.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R7 — Hardware o restriccion del sistema: fallo silencioso

SI el dispositivo no tiene vibrador, `hasVibrator` es `false`, el SO deniega la vibracion
(ahorro de bateria, modo no molestar con haptics desactivados, permiso denegado) o la API de
vibracion lanza error, ENTONCES EL SISTEMA DEBE continuar el temporizador sin error bloqueante
de UI, sin dialogos de fallo y sin reintentos infinitos; el fallo de haptics no debe cambiar el
estado de la sesion F01 ni las preferencias de voz F02.

### R8 — Valor de countdown invalido en UI

CUANDO el usuario intenta guardar `vibrationCountdownSeconds` fuera del rango 0–10, EL SISTEMA
DEBE rechazar el valor (clamp o mensaje de validacion visible) y no persistir un valor fuera de
rango.

### R9 — Intervalo mas corto que N

CUANDO la duracion del intervalo actual es menor o igual que `vibrationCountdownSeconds`, EL
SISTEMA DEBE emitir el patron de inicio segun R1 (si aplica) y solo emitir ticks de R2 para los
segundos enteros `S` que realmente se alcanzan con `remaining` en ese intervalo (sin inventar
ticks futuros ni retrasar el avance de F01).

### R10 — Sin vibracion en idle / completed

MIENTRAS la sesion esta en estado `idle` o `completed`, EL SISTEMA DEBE no emitir patrones A ni B.

### R11 — Pausa detiene y suprime vibracion

CUANDO la sesion transiciona a `paused`, EL SISTEMA DEBE cancelar cualquier vibracion en curso
(`cancel`) y no emitir ticks de cuenta regresiva ni patrones de inicio mientras permanezca en
`paused`.

CUANDO la sesion reanuda a `running`, EL SISTEMA DEBE reanudar solo ticks futuros de R2 (no
repetir ticks `S` ya emitidos en ese intervalo ni re-emitir el patron de inicio del intervalo
actual).

### R12 — Cancelacion / fin de sesion detiene vibracion

CUANDO la sesion emite `SessionCancelled` o `SessionCompleted` (contratos F01), EL SISTEMA DEBE
cancelar cualquier vibracion en curso y no emitir mas patrones hasta un nuevo inicio de sesion.

### R13 — Idempotencia de ticks de countdown

CUANDO dos evaluaciones de cuenta regresiva se disparan en el mismo segundo de reloj para el
mismo valor entero `S` del mismo intervalo, EL SISTEMA DEBE emitir como maximo un patron B por
valor `S` por intervalo.

### R14 — Independencia de mute de voz

MIENTRAS `voiceEnabled` es `false` (F02) y `vibrationEnabled` es `true`, EL SISTEMA DEBE seguir
emitiendo patrones A/B segun R1–R2. El mute de voz no implica mute de vibracion y viceversa.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Alcance de configuracion | **Solo global** en F18. Sin overrides por rutina ni por intervalo. |
| Independencia del audio | Un solo master `vibrationEnabled` + toggles granulares de eventos. **No** comparte flag con `voiceEnabled` (F02). |
| Ventana de countdown | Preferencia **propia** `vibrationCountdownSeconds` (0–10, default 3). No reutiliza la clave `countdown_seconds` de F02 para evitar acoplamiento de producto (el usuario puede querer voz con N=5 y haptic con N=3). |
| Patron A (inicio) | Pulso unico breve (~40–80 ms o preset equivalente documentado en design). |
| Patron B (countdown) | Pulso mas corto o doble-tap breve, **distinguible** del A; un pulse por tick `S`. |
| Default de fabrica | `vibrationEnabled = true`, `vibrationOnIntervalStart = true`, `vibrationOnCountdown = true`, `vibrationCountdownSeconds = 3`. |
| Persistencia | Preferencias globales via `PreferencesRepository` / `app_preferences` (mismo patron F02/F35). |
| Integracion F01 | `HapticsService` / `VibrationFeedbackController` se suscribe a eventos/estado de `TimerController` sin acoplar UI; F01 no importa widgets de vibration. |
| Evento de inicio de intervalo | Reutilizar `IntervalStartedEvent` (introducido/documentado por F02 sobre F01). Si F02 aun no expuso el evento en codigo, F18 debe asegurar el mismo contrato minimo en F01 (no inventar un segundo bus de eventos). |
| Emulador | Sin vibrador real: R7 aplica; tests unitarios con mock del driver de vibracion; QA de patrones en dispositivo fisico. |
| Intensidad / amplitude custom | Fuera de alcance v1; amplitude por defecto de plataforma. |

## Fuera de alcance (explicito)

- Patrones personalizables por el usuario (elegir ms, amplitude, presets desde UI).
- Vibracion en smartwatch (F21) o notificacion de lock screen (F20).
- Sincronizacion forzada 1:1 con utterances TTS (F02); solo comparten la semántica de
  "inicio de intervalo" y "ticks de segundos restantes", no la cola de audio.
- Overrides de vibracion por rutina o por tipo de intervalo.
- Feedback haptico en botones de UI (play/pause) — solo eventos de sesion del timer.
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion durante el entrenamiento; feedback
  manos-libres; offline-first.
- `_global/02-architecture-and-structure.md` — carpeta `features/vibration/`; capas; desacoplamiento F01.
- `_global/03-conventions.md` — formato EARS, Riverpod, testing.
- `_global/04-design-system.md` — controles de ajustes, areas de toque >= 48dp.
- `_global/05-data-model.md` — preferencias globales de vibracion.
- `features/01-interval-timer-core/` — contratos de sesion y maquina de estados del timer.
- `features/02-voice-countdown-announcements/` — `IntervalStartedEvent`, independencia de mute de voz.
