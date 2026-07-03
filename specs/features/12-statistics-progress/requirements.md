# Requirements: Estadisticas y Progreso

**ID:** F12 &nbsp;|&nbsp; **Slug:** `12-statistics-progress` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Vistas agregadas del historial: minutos totales entrenados, calorias estimadas, racha de dias consecutivos, graficas semanales/mensuales.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones

## Postrequisitos (features que dependen de esta)

- F13 - Logros y Badges
- F16 - Compartir Resumen de Sesion
- F26 - Retos Grupales
- F29 - Backup y Exportacion de Datos

## User Stories

- **Como** usuario, **quiero** ver cuantos minutos entrene esta semana y mi racha actual, **para que** me mantengo motivado viendo mi progreso.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE calcular y mostrar: minutos totales entrenados (semana/mes/total), numero de sesiones, y racha de dias consecutivos.
2. EL SISTEMA DEBE mostrar una grafica de actividad semanal y mensual basada en `SessionLog` (F04).
3. EL SISTEMA DEBE estimar calorias quemadas por sesion usando una formula simple configurable (MET x peso x tiempo), marcando el resultado como estimacion.
4. SI el usuario no ha registrado su peso (F15), ENTONCES EL SISTEMA DEBE usar un valor por defecto razonable para el calculo de calorias y avisarlo.
5. LA racha DEBE romperse si pasa un dia calendario completo sin ninguna sesion registrada.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
