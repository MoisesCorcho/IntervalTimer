# Requirements: Widget de Pantalla de Bloqueo / Notificacion Persistente

> Estado: Completado

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Notificacion (o Live Activity en iOS) persistente durante una sesion de entrenamiento, visible
con la app en segundo plano y en pantalla de bloqueo cuando el SO lo permite, mostrando
intervalo actual, tiempo restante y controles basicos (pausa/reanudar, saltar). Permite
controlar el timer sin desbloquear del todo el telefono. Complementa F19 (screen wakelock en
primer plano); **no** reimplementa el motor de tiempo de F01.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F19 - Pantalla Siempre Encendida (misma fase de experiencia; F20 asume politicas de lifecycle
  de sesion documentadas y no deja wakelocks de F19 como sustituto de notificacion)

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente
- F21 (smartwatch) puede reutilizar contratos de estado de sesion expuestos hacia afuera, pero
  no es postrequisito formal de F20

## User Stories

- **Como** usuario, **quiero** ver el intervalo actual y el tiempo restante en una notificacion
  o pantalla de bloqueo mientras entreno, **para que** no necesite abrir la app solo para mirar
  el contador.
- **Como** usuario, **quiero** pausar, reanudar y saltar el intervalo desde esa notificacion,
  **para que** controle la sesion sin desbloquear del todo el telefono.
- **Como** usuario, **quiero** que la notificacion desaparezca al terminar o cancelar la
  sesion, **para que** no quede basura en la barra de notificaciones.
- **Como** usuario, **quiero** poder desactivar los controles/notificacion de sesion si no los
  uso, **para que** no me molesten ni consuman recursos de notificacion.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Mostrar superficie de sesion activa

MIENTRAS la sesion del temporizador esta en estado `running`, `paused` o `preparing` (F35 si
existe) y `sessionLockScreenEnabled` es `true` y el permiso de notificaciones (o equivalente
de plataforma) esta concedido, EL SISTEMA DEBE mostrar una superficie persistente de sesion
(Android: notificacion ongoing / foreground; iOS: Live Activity o notificacion segun fase —
ver R12 y decisiones de producto) con al menos: nombre del intervalo actual (o label de
preparacion), tiempo restante legible, e indicacion de estado (running / paused / preparing).

### R2 — Actualizacion del tiempo restante

MIENTRAS la sesion esta en estado `running` y la superficie de R1 esta visible,
EL SISTEMA DEBE actualizar el tiempo restante mostrado al menos **una vez por segundo**,
derivado del tiempo de F01 (timestamps), no de un contador independiente que drifte.

### R3 — Congelamiento visual en pausa

MIENTRAS la sesion esta en estado `paused` y la superficie de R1 esta visible,
EL SISTEMA DEBE mostrar el tiempo restante congelado (sin decrementar) y el control de
reanudacion (no el de pausa).

### R4 — Accion pausar / reanudar

CUANDO el usuario activa la accion **Pausar** desde la superficie de sesion y el estado es
`running`, EL SISTEMA DEBE transicionar el temporizador a `paused` via la misma semantica que
F01 (sin reimplementar la maquina de estados en F20).

CUANDO el usuario activa la accion **Reanudar** desde la superficie y el estado es `paused`,
EL SISTEMA DEBE transicionar a `running` con la misma semantica que F01.

### R5 — Accion saltar intervalo

CUANDO el usuario activa la accion **Siguiente** / **Saltar** desde la superficie de sesion y
el estado es `running` o `paused`, EL SISTEMA DEBE aplicar el skip de F01 (R7 de F01): avanzar
al siguiente intervalo o completar la sesion si era el ultimo.

### R6 — Sincronizacion bidireccional con la app

CUANDO el estado de la sesion cambia desde la app (UI de ejecucion) o desde la superficie
externa (notificacion / Live Activity), EL SISTEMA DEBE reflejar el nuevo estado y el tiempo
restante en **ambas** superficies en menos de **2 segundos** (app abierta en foreground o
background, y notificacion/Live Activity).

### R7 — Remocion al terminar o cancelar

CUANDO la sesion emite `SessionCompleted` o `SessionCancelled` (contratos F01), o el estado
pasa a `idle` o `completed`, EL SISTEMA DEBE remover la notificacion persistente y/o finalizar
la Live Activity (si aplica) en menos de **2 segundos**.

### R8 — Android: foreground service

DONDE la plataforma es Android y se muestra la notificacion de sesion (R1),
EL SISTEMA DEBE asociarla a un **foreground service** con tipo de servicio documentado en
`design.md`, de modo que el proceso no quede en un background generico sin notificacion
ongoing mientras la sesion este activa segun R1.

### R9 — Preferencia global on/off

DONDE el usuario esta en la seccion de ajustes (shell `features/settings/` si existe; si no,
UI minima bajo `features/lock_screen/`),
CUANDO activa o desactiva `sessionLockScreenEnabled`, EL SISTEMA DEBE aplicar el cambio de
inmediato: si se desactiva con sesion activa, remover la superficie (R7 semantica de limpieza);
si se activa con sesion ya activa y permiso concedido, mostrar la superficie (R1).

### R10 — Persistencia de la preferencia

CUANDO el usuario cambia `sessionLockScreenEnabled`, EL SISTEMA DEBE persistir el valor de
forma global (`PreferencesRepository` / `app_preferences`; ver `design.md` y
`_global/05-data-model.md`) y restaurarlo al reiniciar la app. Default de fabrica: `true`.

### R11 — Tap en la notificacion abre la sesion

CUANDO el usuario toca el cuerpo de la notificacion de sesion (no una action button),
EL SISTEMA DEBE traer la app a primer plano y navegar a la pantalla de ejecucion de la sesion
activa (o a la ruta de timer si la sesion ya no esta activa).

### R12 — iOS: Live Activities (fase B dentro de F20)

DONDE la plataforma es iOS 16.1 o superior y la fase B de F20 esta implementada y
`sessionLockScreenEnabled` es `true` y hay sesion activa segun R1,
EL SISTEMA DEBE mostrar una Live Activity (pantalla de bloqueo y Dynamic Island cuando el
hardware lo soporte) con intervalo actual, tiempo restante y acciones equivalentes a R4–R5
segun lo que ActivityKit/App Intents permitan.

DONDE iOS es anterior a 16.1 o la Live Activity no puede iniciarse,
EL SISTEMA DEBE degradar de forma documentada (notificacion local best-effort o solo controles
in-app) **sin** romper el timer F01 (ver R14–R15).

### R13 — Canal de notificacion de sesion aislado de F14

MIENTRAS F14 (recordatorios) y F20 coexisten,
EL SISTEMA DEBE usar un **canal de notificacion distinto** (Android) / categoria distinta
(iOS) para la sesion activa respecto de los recordatorios de entrenamiento, de modo que el
usuario pueda silenciar recordatorios sin silenciar la sesion (y viceversa) a nivel de
ajustes del sistema cuando el SO lo permita.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R14 — Permiso de notificaciones denegado

SI el usuario deniega el permiso de notificaciones (Android 13+ / iOS) o revoca el permiso
despues,
ENTONCES EL SISTEMA DEBE continuar la sesion del timer sin error bloqueante de UI, no mostrar
la superficie de R1, y ofrecer en ajustes de F20 un estado visible de "permiso requerido" con
camino a reintentar o abrir ajustes del sistema (copy no bloqueante).

### R15 — Fallo de servicio / plugin: silencioso respecto al timer

SI el foreground service no arranca, la notificacion no se puede postear, la Live Activity
falla al crear/actualizar, o el plugin lanza error,
ENTONCES EL SISTEMA DEBE no crashear la app, no alterar la maquina de estados F01, y registrar
el fallo de forma no intrusiva (log / telemetria local opcional). El entrenamiento in-app
sigue funcionando.

### R16 — App killed por el usuario o el SO

CUANDO el proceso de la app es terminado durante una sesion (swipe away / kill),
EL SISTEMA DEBE alinear con la politica global de `_global/01-vision-and-principles.md`:
sesion parcial descartada al reabrir (`idle`); la notificacion/FGS/Live Activity no debe
quedar huerfana de forma indefinida. **F20 v1 no implementa reanudacion de sesion tras kill**
(eso queda como posible refinamiento futuro, no AC de esta version).

### R17 — Sin superficie en idle / completed

MIENTRAS la sesion esta en estado `idle` o `completed`, EL SISTEMA DEBE no mostrar la
notificacion persistente de sesion ni una Live Activity de entrenamiento activa.

### R18 — Independencia de F19 y de audio/haptics

MIENTRAS `sessionLockScreenEnabled` es `true` o `false`, EL SISTEMA DEBE no alterar
`keepScreenOnEnabled` (F19), `voiceEnabled` (F02) ni `vibrationEnabled` (F18). La superficie
de bloqueo no sustituye el screen wakelock de F19 ni el feedback de voz/vibracion.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Nombre de la feature | "Widget de pantalla de bloqueo" en el producto = **notificacion ongoing / Live Activity**, no un home-screen widget Android/iOS (fuera de alcance). |
| Alcance v1 por plataforma | **Fase A (MVP, bloqueante):** Android FGS + notificacion ongoing con acciones. **Fase B:** iOS Live Activities (ActivityKit) + degradacion en iOS < 16.1. Ambas en el mismo slug F20; tasks ordenan A antes que B. |
| Controles en superficie | Solo **Pausar/Reanudar** y **Siguiente (skip)**. Sin cancelar sesion desde lock screen en v1 (evita taps accidentales destructivos). Cancelar sigue en la app. |
| Estados que muestran superficie | `preparing`, `running`, `paused`. No `idle` ni `completed`. |
| Fuente de verdad del tiempo | Solo F01 (`remainingMs` / timestamps). F20 solo **presenta** y **despacha** acciones hacia F01. |
| Preferencia | Global `session_lock_screen_enabled` (bool, default `true`). Sin override por rutina. |
| F19 como prerequisito | Se mantiene por roadmap/fase. Tecnicamente F20 no usa `wakelock_plus`; coordina lifecycle: al ir a background con sesion activa, F19 ya libero wakelock de pantalla; F20 es la superficie de control. |
| App killed | Sin resume de sesion en v1 (politica global vision). |
| Permisos | Solicitar notificaciones de forma explicita la primera vez que se necesita la superficie (inicio de sesion con pref on), no en cold start agresivo sin contexto. |
| F14 | Canales/categorias distintos; no mezclar IDs de notificacion de recordatorio con el ID fijo de sesion. |
| Actualizacion UI notificacion | >= 1 Hz en `running`; en `paused` actualizar solo al cambiar metadata (estado/controles). |
| MediaStyle | Preferido en Android si el estilo mejora controles en lock screen; no requiere MediaSession.Token real de audio (limitacion documentada de `flutter_local_notifications`). |

## Fuera de alcance (explicito)

- Home screen widget (Android App Widget / iOS WidgetKit home).
- Reanudacion de sesion tras kill del proceso (v1).
- Accion "Cancelar sesion" en la notificacion/Live Activity (v1).
- Controles de volumen, musica (F17) o seleccion de intervalo arbitrario desde la notificacion.
- Smartwatch (F21).
- Notificaciones de recordatorio de entrenamiento (F14).
- Sustituir o reimplementar el calculo de tiempo de F01.
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion; politica app killed; offline-first.
- `_global/02-architecture-and-structure.md` — carpeta `features/lock_screen/`; contratos;
  lifecycle F01/F19/F20.
- `_global/03-conventions.md` — EARS, Riverpod, testing.
- `_global/04-design-system.md` — copy y controles de ajustes.
- `_global/05-data-model.md` — preferencia `session_lock_screen_enabled`.
- `features/01-interval-timer-core/` — estados y eventos de sesion; skip/pause.
- `features/19-always-on-screen/` — screen wakelock en ejecucion foreground; no sustituye F20.
- `features/14-reminders-notifications/` — no mezclar canales de recordatorio con sesion.
