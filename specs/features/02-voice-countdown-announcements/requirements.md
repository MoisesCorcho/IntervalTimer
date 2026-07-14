# Requirements: Voz: Cuenta Regresiva y Anuncios

> Estado: No iniciada

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Texto a voz (TTS) del sistema que anuncia el nombre (o mensaje custom) del intervalo al iniciar y
reproduce una cuenta regresiva hablada en los ultimos N segundos de cada intervalo, sin detener el
temporizador si el audio falla o esta silenciado.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F07 - Seleccion de Voces (Sistema y Premium)

## User Stories

- **Como** usuario, **quiero** escuchar el nombre de la seccion al empezar (ej. "Calentamiento"),
  **para que** no necesito mirar la pantalla para saber que sigue.
- **Como** usuario, **quiero** escuchar una cuenta regresiva en los ultimos N segundos, **para que**
  puedo prepararme para el cambio de intervalo sin mirar el telefono.
- **Como** usuario, **quiero** silenciar la voz de la app sin detener el entrenamiento, **para que**
  controlo el audio sin perder el progreso del timer.
- **Como** usuario, **quiero** definir un mensaje de anuncio distinto al nombre del intervalo,
  **para que** puedo dar instrucciones cortas por voz (ej. "Empuja fuerte").

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Anuncio al iniciar intervalo

CUANDO el temporizador avanza a un nuevo intervalo (inicio de sesion o avance automatico/skip) y
`voiceEnabled` es `true` y `announceIntervalName` es `true`, EL SISTEMA DEBE anunciar por voz el
texto de anuncio del intervalo (ver R5) usando el motor TTS del sistema.

### R2 — Cuenta regresiva hablada

CUANDO el tiempo restante del intervalo actual cruza por primera vez un segundo entero `S` donde
`1 <= S <= countdownSeconds` y `countdownSeconds > 0` y `voiceEnabled` es `true` y la sesion esta
en estado `running`, EL SISTEMA DEBE pronunciar el numero `S` una sola vez por cada valor de `S`
en ese intervalo.

### R3 — Configuracion global de cuenta regresiva

DONDE el usuario esta en la pantalla de configuracion de voz (o ajustes de app que expongan esta
opcion), CUANDO configura `countdownSeconds` en el rango 0–10 inclusive, EL SISTEMA DEBE persistir
el valor de forma global (preferencias de app) y usarlo en la siguiente sesion y en la sesion
activa para ticks futuros. Valor `0` desactiva la cuenta regresiva hablada sin desactivar el
anuncio de inicio (R1). Default de fabrica: `3`.

### R4 — Mute de voz sin detener el timer

CUANDO el usuario activa mute de voz (`voiceEnabled = false`) durante una sesion `running` o
`paused`, EL SISTEMA DEBE detener cualquier utterance en curso, no emitir nuevos anuncios ni
cuenta regresiva, y dejar la maquina de estados del temporizador (F01) sin cambios.

### R5 — Mensaje de anuncio personalizado por intervalo

CUANDO un intervalo tiene `announceText` no nulo y no vacio (tras trim), EL SISTEMA DEBE usar ese
texto como utterance de inicio en R1.

SI `announceText` es nulo, vacio o solo espacios, ENTONCES EL SISTEMA DEBE usar el `name` del
intervalo como utterance de inicio.

### R6 — Toggle de anuncio de nombre

DONDE el usuario esta en la configuracion de voz, CUANDO desactiva `announceIntervalName`, EL
SISTEMA DEBE omitir el anuncio de inicio (R1) en intervalos siguientes manteniendo la cuenta
regresiva (R2) si `countdownSeconds > 0` y `voiceEnabled` es `true`.

### R7 — Persistencia de preferencias de voz

CUANDO el usuario cambia `voiceEnabled`, `countdownSeconds` o `announceIntervalName`, EL SISTEMA
DEBE persistir los valores de forma global (mismas preferencias de app que el resto de ajustes
ligeros; ver `design.md` y `_global/05-data-model.md`) y restaurarlos al reiniciar la app.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R8 — Motor TTS no disponible o error de speak

SI el motor TTS del sistema no esta disponible, el idioma no se puede configurar, o `speak` falla,
ENTONCES EL SISTEMA DEBE continuar el temporizador sin error bloqueante de UI y sin reintentos
infinitos; el fallo de audio no debe cambiar el estado de la sesion F01.

### R9 — Valor de countdown invalido en UI

CUANDO el usuario intenta guardar `countdownSeconds` fuera del rango 0–10, EL SISTEMA DEBE
rechazar el valor (clamp o mensaje de validacion visible) y no persistir un valor fuera de rango.

### R10 — Intervalo mas corto que N

CUANDO la duracion del intervalo actual es menor o igual que `countdownSeconds`, EL SISTEMA DEBE
anunciar el inicio segun R1/R5 y solo emitir los ticks de cuenta regresiva para los segundos
enteros `S` que realmente se alcanzan con `remaining` en ese intervalo (sin inventar ticks
futuros ni retrasar el avance de F01).

### R11 — Sin anuncios en idle / completed

MIENTRAS la sesion esta en estado `idle` o `completed`, EL SISTEMA DEBE no emitir anuncios de
inicio ni cuenta regresiva.

### R12 — Cola e interrupcion sin solapamiento audible

CUANDO un nuevo anuncio de inicio (R1) se dispara mientras hay una utterance de cuenta regresiva
en curso, EL SISTEMA DEBE interrumpir la utterance anterior e iniciar el anuncio del nuevo
intervalo, de modo que no se solapen dos utterances de forma audible.

CUANDO dos ticks de cuenta regresiva se evaluan en el mismo segundo de reloj, EL SISTEMA DEBE
emitir como maximo una utterance por valor entero `S` por intervalo (idempotencia de tick).

### R13 — Pausa detiene la voz

CUANDO la sesion transiciona a `paused`, EL SISTEMA DEBE detener la utterance en curso y no
emitir ticks de cuenta regresiva mientras permanezca en `paused`.

CUANDO la sesion reanuda a `running`, EL SISTEMA DEBE reanudar solo ticks futuros de R2 (no
repetir ticks `S` ya anunciados en ese intervalo ni re-anunciar el nombre de inicio).

### R14 — Cancelacion / fin de sesion detiene la voz

CUANDO la sesion emite `SessionCancelled` o `SessionCompleted` (contratos F01), EL SISTEMA DEBE
detener cualquier utterance en curso y no emitir mas anuncios hasta un nuevo inicio de sesion.

### R15 — Campo announceText: longitud

CUANDO el usuario ingresa `announceText` con longitud superior a 80 caracteres, EL SISTEMA DEBE
rechazar la operacion o truncar con validacion visible sin persistir un valor > 80 caracteres.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Alcance de configuracion "por rutina o global" | **Solo global** en F02 (`voiceEnabled`, `countdownSeconds`, `announceIntervalName`). Overrides por rutina quedan fuera de alcance. |
| Mute | Mute **in-app** de voz (`voiceEnabled = false`). No controla el volumen del sistema ni detiene el timer. |
| Motor de voz en F02 | Unica fuente: **TTS nativo del dispositivo** via `flutter_tts`. Sin assets de audio. Seleccion multi-voz y premium → F07. |
| Formato de countdown | Un `speak` por segundo entero `S` (`"3"`, `"2"`, `"1"`) al cruzar ese umbral; no una sola frase concatenada. |
| Idioma TTS | Locale del dispositivo / app (pre-F28: locale del sistema). Fallback silencioso a idioma default del engine si el locale no esta instalado (R8). |
| Persistencia de prefs | Preferencias globales de app (patron `PreferencesRepository` / `app_preferences` o equivalente documentado en data model), no tabla por rutina. |
| `announceText` | Opcional en `Interval`; null/blank → `name`. Max 80 chars (R15). |
| Integracion F01 | `VoiceAnnouncer` se suscribe a eventos/estado de `TimerController` sin acoplar UI; F01 no importa widgets de voice. |
| Extension F07 | Abstraccion `TtsEngine` (o equivalente) con implementacion `SystemTtsEngine` en F02; F07 agrega otras implementaciones. |

## Fuera de alcance (explicito)

- Seleccion de voz del sistema, preview de voces y voces premium (F07).
- Ducking de musica de fondo / sesion de audio avanzada (F17).
- Vibracion sincronizada con countdown (F18).
- Overrides de voz por rutina.
- Assets de audio pregrabados (beeps, packs de voz empaquetados).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — guia por voz, cero friccion durante el entrenamiento, offline-first.
- `_global/02-architecture-and-structure.md` — `features/voice/`, capas, desacoplamiento F01↔F02.
- `_global/03-conventions.md` — formato EARS, Riverpod, testing, reutilizacion.
- `_global/04-design-system.md` — controles de ajustes, areas de toque >= 48dp.
- `_global/05-data-model.md` — `Interval.announceText`, preferencias de voz globales.
- `features/01-interval-timer-core/` — contratos de sesion y maquina de estados del timer.
