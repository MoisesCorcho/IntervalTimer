# Requirements: Efectos de Sonido del Temporizador (SFX)

> Estado: En progreso

**ID:** F36 &nbsp;|&nbsp; **Slug:** `36-timer-sound-effects` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Efectos de sonido cortos (SFX empaquetados) en momentos clave del temporizador: ticks de
preparacion, inicio de trabajo, inicio de descanso, cuenta regresiva final de fase y fin de
sesion. El usuario puede activar/desactivar por tipo de evento, configurar la ventana de
cuenta regresiva (espejo de F18) y elegir el clip por situacion desde un catalogo local con
preview. Canal **independiente** de voz TTS (F02) y de vibracion (F18).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F35 - Navegacion de Secciones, Preparacion y Ajustes (estado `preparing`, shell Settings,
  preferencia `prep_seconds`)

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente
- **Dependencia blanda / nota para F17:** al implementar ducking de musica externa, contemplar
  tambien reproduccion de SFX (no solo TTS), sin que F17 sea prerequisito de F36

## User Stories

- **Como** usuario, **quiero** oir un sonido al empezar trabajo y otro al empezar descanso,
  **para que** distinga el cambio de fase sin mirar la pantalla.
- **Como** usuario, **quiero** oir ticks en la preparacion y en los ultimos segundos de cada
  intervalo, **para que** me prepare al arranque y al cambio de fase.
- **Como** usuario, **quiero** un sonido al completar la sesion, **para que** sepa que termine
  aunque no mire el telefono.
- **Como** usuario, **quiero** elegir que clip suena en cada situacion y preescucharlo en
  Ajustes, **para que** personalice la experiencia sin salir a buscar archivos.
- **Como** usuario, **quiero** silenciar o granularizar los SFX sin tocar la voz ni la
  vibracion, **para que** controle cada canal de feedback por separado.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — SFX al iniciar intervalo de trabajo (u otros no-rest)

CUANDO el temporizador avanza a un nuevo intervalo cuyo `type` es distinto de `rest`
(p. ej. `work`, `warmup`, `stretch`, `custom`), la sesion esta en estado `running`,
`soundEnabled` es `true` y `soundOnWorkStart` es `true`, EL SISTEMA DEBE reproducir el clip
asignado al slot `work_start` (default de fabrica: `sfx_work_start_01`).

Esto incluye avance automatico al terminar preparacion, skip/siguiente desde `preparing` hacia
el primer intervalo, skip entre intervalos, y reinicio del intervalo actual que dispare un
nuevo inicio de intervalo segun contratos F01/F35. No incluye reanudar desde `paused` sobre el
mismo intervalo ya iniciado (ver R17).

### R2 — SFX al iniciar intervalo de descanso

CUANDO el temporizador avanza a un nuevo intervalo cuyo `type` es `rest`, la sesion esta en
estado `running`, `soundEnabled` es `true` y `soundOnRestStart` es `true`, EL SISTEMA DEBE
reproducir el clip asignado al slot `rest_start` (default: `sfx_rest_start_01`).

Mismas fuentes de avance que R1 (automatico, skip, fin de prep), excluyendo resume del mismo
intervalo.

### R3 — SFX al completar la sesion

CUANDO el temporizador emite el contrato de sesion completada (`SessionCompleted` / equivalente
F01) y `soundEnabled` es `true` y `soundOnSessionComplete` es `true`, EL SISTEMA DEBE
reproducir el clip asignado al slot `session_complete` (default: `sfx_session_complete_01`)
**una sola vez** por sesion completada.

### R4 — Ticks de preparacion

CUANDO la sesion esta en estado `preparing` (no `paused`), el tiempo restante de preparacion
cruza por primera vez un segundo entero `S` con `S >= 1`, `soundEnabled` es `true` y
`soundOnPrepTick` es `true`, EL SISTEMA DEBE reproducir el clip del slot `prep_tick`
(default: `sfx_tick_01`) **una sola vez** por cada valor de `S` en esa fase de preparacion.

Al llegar a 0 en preparacion e iniciar el primer intervalo, EL SISTEMA DEBE **no** emitir un
tick adicional de “go” por R4; el arranque del primer intervalo se cubre con R1/R2 segun el
`type` del intervalo.

### R5 — Cuenta regresiva final de fase (ultimos N segundos)

CUANDO el tiempo restante del intervalo actual en estado `running` cruza por primera vez un
segundo entero `S` donde `1 <= S <= soundCountdownSeconds` y `soundCountdownSeconds > 0` y
`soundEnabled` es `true` y `soundOnPhaseWarning` es `true`, EL SISTEMA DEBE reproducir el clip
del slot `phase_warning` (default de fabrica: el mismo archivo que `prep_tick`,
`sfx_tick_01`) **una sola vez** por cada valor de `S` en ese intervalo.

Aplica a **work y rest** (y demas tipos) mientras el intervalo este en `running`.

### R6 — Ventana N configurable (espejo F18)

DONDE el usuario esta en la configuracion de efectos de sonido, CUANDO configura
`soundCountdownSeconds` en el rango 0–10 inclusive, EL SISTEMA DEBE persistir el valor de
forma global y usarlo en ticks futuros de R5. Valor `0` desactiva solo R5 sin desactivar R1–R4
ni R3. Default de fabrica: `3`.

La clave **no** reutiliza `countdown_seconds` (F02) ni `vibration_countdown_seconds` (F18):
el usuario puede querer N distintos por canal.

### R7 — Master e independencia de voz y vibracion

DONDE el usuario esta en la seccion de ajustes de SFX (shell `features/settings/`), CUANDO
activa o desactiva `soundEnabled`, EL SISTEMA DEBE aplicar el cambio de inmediato a eventos
futuros sin modificar `voiceEnabled` (F02), `vibrationEnabled` (F18), el volumen del sistema
ni la maquina de estados del temporizador (F01/F35).

### R8 — Toggles granulares de eventos

DONDE el usuario esta en la configuracion de SFX, CUANDO desactiva un toggle granular
(`soundOnWorkStart`, `soundOnRestStart`, `soundOnSessionComplete`, `soundOnPrepTick`,
`soundOnPhaseWarning`), EL SISTEMA DEBE omitir solo el evento correspondiente (R1–R5) y
mantener los demas si el master y sus toggles lo permiten.

### R9 — Seleccion de clip por slot (catalogo)

DONDE el usuario esta en la configuracion de SFX, CUANDO elige un `soundId` valido del
catalogo empaquetado para un slot
(`work_start` | `rest_start` | `session_complete` | `prep_tick` | `phase_warning`),
EL SISTEMA DEBE persistir la asignacion y usarla en reproducciones futuras de ese slot.

El picker de cada slot DEBE listar **todo** el catalogo unificado (defaults + variantes de
catalogo empaquetadas, incluidos clips como `sfx_click_*` aunque no tengan slot de fabrica).
No filtrar por “sugerido para este evento”: el usuario puede asignar cualquier id a cualquier
slot. El catalogo empaquetado se documenta en `assets/sfx/ATTRIBUTION.md` y el empaquetado en
`design.md`.

### R10 — Preview en Ajustes

DONDE el usuario esta en la configuracion de SFX, CUANDO solicita preescucha de un clip
(desde el picker o control de preview del slot), EL SISTEMA DEBE reproducir ese clip una vez
sin alterar el estado del temporizador, respetando fallo silencioso (R12) si el asset no carga.

### R11 — Persistencia de preferencias SFX

CUANDO el usuario cambia master, toggles granulares, `soundCountdownSeconds` o el `soundId`
de cualquier slot, EL SISTEMA DEBE persistir los valores de forma global
(`PreferencesRepository` / `app_preferences`; ver `design.md` y `_global/05-data-model.md`) y
restaurarlos al reiniciar la app.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R12 — Fallo de reproduccion silencioso

SI el asset no existe, el plugin de audio falla, el SO bloquea audio, o cualquier error de
I/O/codec ocurre al reproducir SFX o preview, ENTONCES EL SISTEMA DEBE continuar el
temporizador sin error bloqueante de UI, sin dialogos de fallo y sin reintentos infinitos;
el fallo de SFX no debe cambiar el estado de la sesion ni las preferencias de voz/vibracion.

### R13 — Valor de countdown invalido en UI

CUANDO el usuario intenta guardar `soundCountdownSeconds` fuera del rango 0–10, EL SISTEMA
DEBE rechazar el valor (clamp o mensaje de validacion visible) y no persistir un valor fuera
de rango.

### R14 — `soundId` invalido o asset faltante

SI la preferencia de un slot apunta a un `soundId` desconocido o a un path no presente en el
catalogo empaquetado, ENTONCES EL SISTEMA DEBE usar el default de fabrica de ese slot para la
reproduccion (y puede reparar la preferencia al default) sin crashear.

### R15 — Intervalo mas corto que N

CUANDO la duracion del intervalo actual es menor o igual que `soundCountdownSeconds`, EL
SISTEMA DEBE emitir R1/R2 si aplican y solo emitir ticks de R5 para los segundos enteros `S`
que realmente se alcanzan con `remaining` en ese intervalo (sin inventar ticks ni retrasar F01).

### R16 — Sin SFX de fase en idle / completed (salvo complete)

MIENTRAS la sesion esta en estado `idle`, EL SISTEMA DEBE no emitir R1, R2, R4 ni R5.

CUANDO la sesion pasa a `completed`, EL SISTEMA DEBE permitir R3 (session complete) segun
gates y **no** emitir mas R1/R2/R4/R5 hasta un nuevo inicio de sesion.

### R17 — Pausa suprime ticks; no re-emite al reanudar

CUANDO la sesion transiciona a `paused` (incluyendo pausa durante `preparing`), EL SISTEMA
DEBE no emitir nuevos ticks de R4/R5 ni SFX de inicio de intervalo mientras permanezca en
`paused`. No se requiere detener un one-shot ya en curso de forma agresiva, pero no se encolan
eventos nuevos.

CUANDO la sesion reanuda a `running` o retoma `preparing`, EL SISTEMA DEBE emitir solo ticks
futuros (no repetir valores `S` ya emitidos en ese intervalo o en esa preparacion, ni
re-emitir el SFX de inicio del intervalo actual).

### R18 — Cancelacion detiene futuros SFX de sesion

CUANDO la sesion emite `SessionCancelled` (contrato F01), EL SISTEMA DEBE no emitir R3 ni
nuevos R1/R2/R4/R5 hasta un nuevo inicio de sesion.

### R19 — Idempotencia de ticks

CUANDO dos evaluaciones se disparan en el mismo segundo de reloj para el mismo valor entero
`S` del mismo intervalo (R5) o de la misma preparacion (R4), EL SISTEMA DEBE reproducir como
maximo un SFX por valor `S` por contexto (intervalo o prep).

### R20 — Independencia de mute de voz y vibracion

MIENTRAS `voiceEnabled` es `false` (F02) y/o `vibrationEnabled` es `false` (F18) y
`soundEnabled` es `true`, EL SISTEMA DEBE seguir reproduciendo SFX segun R1–R5. El mute de un
canal no implica mute de los otros.

MIENTRAS un utterance TTS y un SFX coinciden en el tiempo, EL SISTEMA DEBE permitir el
solapamiento en v1 (no cancelar uno por el otro).

### R21 — Assets empaquetados y offline

MIENTRAS el dispositivo no tiene red, EL SISTEMA DEBE poder reproducir todos los clips del
catalogo empaquetado (defaults + catalogo local). No hay descarga remota de packs en F36 v1.

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| Feature nueva | **F36**; no estirar F02 (TTS-only, sin assets) ni F18 (haptics). |
| Alcance de configuracion | **Solo global** en F36. Sin overrides por rutina ni por intervalo. |
| Canales | Voz ≠ vibracion ≠ SFX. Tres masters independientes. |
| Ventana countdown SFX | `soundCountdownSeconds` 0–10, default 3; propia, no compartida con F02/F18. |
| Prep ticks | **Cada** segundo de `preparing` con `S >= 1` si toggle on; no usa el stepper N. |
| Phase warning | Ultimos N s de **cada** intervalo en `running` (work, rest y demas). |
| Mismo default, dos slots | `prep_tick` y `phase_warning` default al mismo archivo `sfx_tick_01`; IDs de preferencia y pickers **separados**. |
| Mapeo type → slot inicio | `rest` → `rest_start`; cualquier otro `IntervalType` → `work_start`. |
| Skip / fin de prep | Disparan R1/R2 igual que un avance de intervalo; resume no. |
| Catalogo + picker + preview | **In scope** v1. Picker = **catalogo completo** unificado (no filtro por slot). |
| Solape de clips | Permitido en v1: varios one-shots pueden sonar a la vez (p. ej. warning + work_start, SFX + TTS). Ver politica de player en `design.md`. |
| Silent switch / DND | Respetar silenciamiento del SO; si no se oye, aplica R12 (sin error de UI). No forzar audio sobre el switch de silencio. |
| Volumen relativo SFX | **Fuera** de v1; se usa volumen del sistema / stream del player. |
| Pause / resume SFX | **Fuera** de alcance; el feedback de pause/resume queda en vibracion (F18) y UI. |
| Packs remotos / Pro / import usuario | **Fuera** de v1. |
| Ducking musica externa | **No** prerequisito; nota blanda hacia F17 para incluir SFX cuando se implemente. |
| Default de fabrica | Ver tabla de defaults en `design.md` (master y toggles `true`, N=3, IDs `*_01`). |
| Persistencia | Preferencias globales via `PreferencesRepository` / `app_preferences`. |
| Integracion F01/F35 | Controller de SFX se suscribe a estado/eventos del timer; F01 no importa UI ni player de SFX. |
| Fallos | Silenciosos; el timer nunca se frena por audio. |

## Fuera de alcance (explicito)

- SFX al pausar o reanudar la sesion (botones de ejecucion).
- Volumen dedicado SFX vs TTS, equalizer, o mixer avanzado.
- Packs descargables, IAP/gate Pro de sonidos, importar archivos del usuario.
- Sincronizacion forzada 1:1 con cola TTS (F02) o cancelacion mutua voz↔SFX.
- Overrides de sonido por rutina, por ejercicio o por intervalo individual.
- Ducking de musica de otras apps (F17); solo nota de seguimiento.
- Sonidos de UI genericos fuera de los slots del timer (navegacion, formularios).
- Smartwatch / lock screen audio (F20/F21).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — feedback manos-libres; offline-first; cero friccion.
- `_global/02-architecture-and-structure.md` — carpeta `features/sound_effects/`; capas; desacoplamiento F01.
- `_global/03-conventions.md` — EARS, Riverpod, testing, assets en pubspec.
- `_global/04-design-system.md` — controles de ajustes, areas de toque >= 48dp.
- `_global/05-data-model.md` — preferencias globales SFX (actualizar al implementar).
- `_global/06-roadmap-and-dependencies.md` — F36 en Fase 4.
- `features/01-interval-timer-core/` — contratos de sesion y maquina de estados.
- `features/02-voice-countdown-announcements/` — TTS-only; no assets; independencia de mute.
- `features/18-vibration-feedback/` — patron master + granulares + N countdown; haptics no audio.
- `features/35-timer-navigation-prep-settings/` — `preparing`, Settings shell, `prep_seconds`.
- `features/17-background-music-ducking/` — ducking futuro; contemplar SFX al implementar.
- `assets/sfx/ATTRIBUTION.md` — naming y procedencia CC0 de los clips.
