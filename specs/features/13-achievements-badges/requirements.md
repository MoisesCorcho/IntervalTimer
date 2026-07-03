# Requirements: Logros y Badges

**ID:** F13 &nbsp;|&nbsp; **Slug:** `13-achievements-badges` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Sistema simple de gamificacion: insignias desbloqueables por hitos (ej. 10 sesiones, 7 dias seguidos, primera rutina HIIT).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F12 - Estadisticas y Progreso

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** desbloquear logros al cumplir hitos de entrenamiento, **para que** me siento motivado a seguir entrenando.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE incluir un catalogo inicial de al menos 10 logros con condicion de desbloqueo clara y verificable contra `SessionLog`/`StatsService`.
2. CUANDO se cumple la condicion de un logro, EL SISTEMA DEBE desbloquearlo y notificar al usuario con una animacion/mensaje.
3. EL SISTEMA DEBE mostrar una pantalla de logros con los desbloqueados y los pendientes (con progreso, ej. '5/10 sesiones').
4. LOS logros ya desbloqueados NO DEBEN poder revertirse aunque el historial cambie despues (ej. borrar una sesion antigua).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
