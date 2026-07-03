# Requirements: Pantalla Siempre Encendida

**ID:** F19 &nbsp;|&nbsp; **Slug:** `19-always-on-screen` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Evita que la pantalla se apague automaticamente mientras hay una sesion de entrenamiento activa.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F20 - Widget de Pantalla de Bloqueo / Notificacion Persistente
- F21 - Soporte para Smartwatch (Wear OS / Apple Watch)

## User Stories

- **Como** usuario, **quiero** que la pantalla no se apague durante mi entrenamiento, **para que** puedo ver el timer sin tener que tocar el telefono constantemente.

## Criterios de Aceptacion (formato EARS)

1. MIENTRAS el timer esta en estado running, EL SISTEMA DEBE evitar que la pantalla se apague por inactividad.
2. CUANDO la sesion termina, se pausa, o el usuario sale de la pantalla de ejecucion, EL SISTEMA DEBE restaurar el comportamiento normal de apagado de pantalla.
3. ESTE comportamiento DEBE ser configurable (on/off) para usuarios que prefieran ahorrar bateria.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
