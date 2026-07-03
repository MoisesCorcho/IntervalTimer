# Requirements: Recordatorios y Notificaciones

**ID:** F14 &nbsp;|&nbsp; **Slug:** `14-reminders-notifications` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Notificaciones locales configurables para recordar al usuario entrenar y no perder su racha.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** recibir un recordatorio a una hora que yo elija, **para que** no se me olvida entrenar.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir configurar uno o mas recordatorios con hora y dias de la semana.
2. CUANDO llega la hora configurada Y el usuario aun no entreno ese dia, EL SISTEMA DEBE enviar una notificacion local.
3. SI el usuario ya completo una sesion ese dia, ENTONCES EL SISTEMA NO DEBE enviar el recordatorio de ese dia.
4. EL SISTEMA DEBE solicitar el permiso de notificaciones de forma explicita y manejar el caso de rechazo con gracia.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
