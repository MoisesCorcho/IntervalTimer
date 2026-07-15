# Requirements: Pantalla Siempre Encendida

> Estado: Completado

**ID:** F19 &nbsp;|&nbsp; **Slug:** `19-always-on-screen` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Mantiene la pantalla del dispositivo encendida (evita el apagado por inactividad del SO)
mientras hay una sesion de entrenamiento activa en estado `running`, para que el usuario pueda
ver el timer sin tocar el telefono. Preferencia global on/off para quienes priorizan bateria.
Alineado al principio de **cero friccion durante el entrenamiento** (`_global/01-vision-and-principles.md`).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F20 - Widget de Pantalla de Bloqueo / Notificacion Persistente
- F21 - Soporte para Smartwatch (Wear OS / Apple Watch)

## User Stories

- **Como** usuario, **quiero** que la pantalla no se apague durante mi entrenamiento en curso,
  **para que** pueda ver el timer sin tocar el telefono constantemente.
- **Como** usuario, **quiero** desactivar la pantalla siempre encendida si lo prefiero,
  **para que** ahorre bateria cuando no necesito mirar el contador de forma continua.
- **Como** usuario, **quiero** que al pausar, terminar o salir de la sesion se restaure el
  apagado normal, **para que** el telefono no quede consumiendo bateria por error.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Pantalla encendida en sesion running

MIENTRAS la sesion del temporizador esta en estado `running` y `keepScreenOnEnabled` es `true`,
EL SISTEMA DEBE mantener activo el screen wakelock del dispositivo (la pantalla no se apaga por
el timeout de inactividad del SO).

### R2 — Liberacion al pausar

CUANDO la sesion transiciona a estado `paused`, EL SISTEMA DEBE desactivar el screen wakelock y
restaurar el comportamiento normal de apagado por inactividad del SO.

### R3 — Liberacion al completar o cancelar

CUANDO la sesion emite `SessionCompleted` o `SessionCancelled` (contratos F01), o transiciona a
estado `idle` o `completed`, EL SISTEMA DEBE desactivar el screen wakelock (si estaba activo).

### R4 — Liberacion al salir de la pantalla de ejecucion

DONDE el usuario esta en la pantalla de ejecucion del temporizador,
CUANDO navega fuera de esa pantalla (pop, cambio de ruta, cierre del widget de sesion),
EL SISTEMA DEBE desactivar el screen wakelock aunque la sesion pudiera seguir en memoria en
otro estado, para evitar fugas de wakelock atadas a un widget ya desmontado.

### R5 — Toggle de configuracion global

DONDE el usuario esta en la pantalla o seccion de ajustes del shell `features/settings/`
(si existe; si no, UI minima bajo `features/always_on/`),
CUANDO activa o desactiva `keepScreenOnEnabled`, EL SISTEMA DEBE aplicar el cambio de inmediato
a la politica de wakelock de la sesion activa (si hay) y a sesiones futuras, sin modificar la
maquina de estados del temporizador (F01), la voz (F02) ni la vibracion (F18).

### R6 — Persistencia de la preferencia

CUANDO el usuario cambia `keepScreenOnEnabled`, EL SISTEMA DEBE persistir el valor de forma
global (`PreferencesRepository` / `app_preferences`; ver `design.md` y
`_global/05-data-model.md`) y restaurarlo al reiniciar la app.

### R7 — Aplicacion inmediata del toggle durante sesion running

CUANDO la sesion esta en estado `running` y el usuario cambia `keepScreenOnEnabled` de `true` a
`false`, EL SISTEMA DEBE desactivar el wakelock de inmediato.

CUANDO la sesion esta en estado `running` y el usuario cambia `keepScreenOnEnabled` de `false`
a `true`, EL SISTEMA DEBE activar el wakelock de inmediato.

### R8 — Default de fabrica

CUANDO la app no tiene valor persistido de `keepScreenOnEnabled` (primer uso o store vacio),
EL SISTEMA DEBE tratar `keepScreenOnEnabled` como `true` (alineado al principio de cero friccion
durante el entrenamiento).

### R9 — Reafirmacion al volver a primer plano

SI la app pasa a segundo plano y vuelve a primer plano (`AppLifecycleState.resumed`) mientras la
sesion sigue en estado `running` y `keepScreenOnEnabled` es `true`, ENTONCES EL SISTEMA DEBE
volver a solicitar el screen wakelock (el SO puede haberlo liberado externamente).

### R10 — Independencia de otras preferencias

MIENTRAS `keepScreenOnEnabled` es `true` o `false`, EL SISTEMA DEBE no alterar `voiceEnabled`
(F02), `vibrationEnabled` (F18), tema ni otras preferencias de ajustes. El flag es exclusivo de
pantalla siempre encendida.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R11 — Fallo del plugin o plataforma: silencioso

SI la API de wakelock lanza error, no esta disponible en la plataforma, o el SO ignora la
solicitud, ENTONCES EL SISTEMA DEBE continuar el temporizador sin error bloqueante de UI, sin
dialogos de fallo y sin reintentos infinitos; el fallo de wakelock no debe cambiar el estado de
la sesion F01 ni las preferencias de voz/vibracion.

### R12 — Preferencia desactivada: nunca activar

MIENTRAS `keepScreenOnEnabled` es `false`, EL SISTEMA DEBE no activar el screen wakelock aunque
la sesion este en estado `running` o el usuario este en la pantalla de ejecucion.

### R13 — Estados idle / completed: sin wakelock

MIENTRAS la sesion esta en estado `idle` o `completed`, EL SISTEMA DEBE mantener el screen
wakelock desactivado (o desactivarlo si quedara residual).

### R14 — Fase preparing (F35) con pantalla de ejecucion

DONDE existe la fase `preparing` de F35 y el usuario esta en la pantalla de ejecucion,
MIENTRAS el estado de sesion es `preparing` y `keepScreenOnEnabled` es `true`,
EL SISTEMA DEBE mantener el screen wakelock activo (misma politica que `running`: el usuario
esta a punto de entrenar y mira la pantalla).

CUANDO la fase `preparing` termina y la sesion pasa a `running`, EL SISTEMA DEBE mantener el
wakelock segun R1. Si pasa a `idle`/`cancelled`, aplicar R3.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Alcance de configuracion | **Solo global** en F19. Sin override por rutina ni por entrenamiento. |
| Default de fabrica | `keepScreenOnEnabled = true` (cero friccion; principio 2 de vision). |
| Clave de preferencia | `keep_screen_on_enabled` (bool). Store: `PreferencesRepository` / `app_preferences` (mismo patron F02/F18/F35), **no** un store paralelo solo para F19. |
| Cuando activar | Sesion en `running` **o** `preparing` (F35) **y** pref `true` **y** la logica de always-on esta montada/activa en el flujo de ejecucion. |
| Cuando desactivar | `paused`, `idle`, `completed`, `SessionCancelled`/`SessionCompleted`, dispose/salida de pantalla de ejecucion, o pref `false`. |
| Anclaje lifecycle | Preferir un **controller/servicio** en `features/always_on/` que reacciona a estado F01 + lifecycle app + dispose del host de ejecucion — **no** llamar `WakelockPlus` desde `TimerController` (F01 no importa always_on). Evita fugas si el usuario sale de la pantalla. |
| Pausa | Wakelock **off** en `paused` (ahorro de bateria y AC original). Al reanudar a `running`, reactivar si pref on. |
| Background | El SO puede liberar wakelock; en `resumed` reafirmar si aun corresponde (R9). No mantener CPU wakelock parcial (fuera de alcance del plugin de pantalla). |
| Emulador / desktop | Misma API; fallo → R11. QA de apagado real de pantalla en **dispositivo fisico**. |
| F20 / F21 | F19 no implementa notificacion persistente ni smartwatch; solo screen wakelock. F20 asume que F19 no deja wakelocks colgados. |

## Fuera de alcance (explicito)

- Wake lock de CPU / mantener la app viva en background sin pantalla (eso es territorio F20 u
  otras soluciones de foreground service).
- Widget de pantalla de bloqueo o notificacion persistente (F20).
- Soporte smartwatch (F21).
- Brillo automatico, modo noche de pantalla, o dimming custom de UI.
- Override por rutina / por tipo de intervalo.
- Pedir permisos especiales de bateria (el plugin de screen wakelock no requiere permisos).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion; wakelock como soporte del entrenamiento.
- `_global/02-architecture-and-structure.md` — carpeta `features/always_on/`; contratos entre features;
  ciclo de vida.
- `_global/03-conventions.md` — formato EARS, Riverpod, testing.
- `_global/04-design-system.md` — controles de ajustes, areas de toque >= 48dp.
- `_global/05-data-model.md` — preferencia global `keep_screen_on_enabled`.
- `features/01-interval-timer-core/` — maquina de estados y eventos de sesion.
- `features/35-timer-navigation-prep-settings/` — estado `preparing` y shell de settings (si aplica).
