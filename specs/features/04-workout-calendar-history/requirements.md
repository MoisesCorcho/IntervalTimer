# Requirements: Calendario e Historial de Sesiones

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Registro persistente de cada sesion completada (o abandonada) y vista de calendario para consultar que se entreno cada dia.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F09 - Progresion Automatica
- F12 - Estadisticas y Progreso
- F14 - Recordatorios y Notificaciones
- F15 - Registro de Peso y Medidas
- F16 - Compartir Resumen de Sesion
- F29 - Backup y Exportacion de Datos

## User Stories

- **Como** usuario, **quiero** ver un calendario con los dias en que entrene, **para que** puedo revisar mi consistencia de un vistazo.
- **Como** usuario, **quiero** tocar un dia y ver que sesiones hice, **para que** puedo recordar mi historial de entrenamiento.

## Criterios de Aceptacion (formato EARS)

1. CUANDO una sesion termina (completa o cancelada), EL SISTEMA DEBE guardar un registro con fecha, rutina, duracion real y estado (completada/incompleta).
2. EL SISTEMA DEBE mostrar un calendario mensual marcando visualmente los dias con al menos una sesion registrada.
3. CUANDO el usuario selecciona un dia con registros, EL SISTEMA DEBE listar todas las sesiones de ese dia con detalle (nombre, hora, duracion).
4. EL SISTEMA DEBE persistir el historial localmente de forma que sobreviva a reinicios de la app.
5. SI el usuario elimina un registro, ENTONCES EL SISTEMA DEBE pedir confirmacion antes de borrar.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
