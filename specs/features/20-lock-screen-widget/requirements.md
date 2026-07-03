# Requirements: Widget de Pantalla de Bloqueo / Notificacion Persistente

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Notificacion persistente con controles basicos (pausa/siguiente) visible sin abrir la app, incluyendo pantalla de bloqueo.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F19 - Pantalla Siempre Encendida

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** ver y controlar el timer desde la pantalla de bloqueo, **para que** no necesito desbloquear el telefono para pausar o avanzar.

## Criterios de Aceptacion (formato EARS)

1. MIENTRAS hay una sesion activa, EL SISTEMA DEBE mostrar una notificacion persistente con: intervalo actual, tiempo restante y controles (pausa/reanudar, siguiente).
2. CUANDO el usuario interactua con los controles de la notificacion, EL SISTEMA DEBE reflejar el cambio de estado tanto en la notificacion como en la app si esta abierta.
3. AL terminar o cancelar la sesion, EL SISTEMA DEBE remover la notificacion persistente.
4. EN Android, la notificacion DEBE implementarse como parte de un foreground service para evitar que el sistema mate el proceso del timer.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
