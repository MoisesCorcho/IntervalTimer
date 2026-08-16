# Requirements: Filtros de Rutinas

> Estado: No iniciada

**ID:** F22 &nbsp;|&nbsp; **Slug:** `22-routine-filters` &nbsp;|&nbsp; **Fase:** Fase 5 · Descubrimiento de Contenido

## Resumen

Filtrar el catalogo de rutinas preestablecidas por grupo muscular, duracion, nivel y equipo necesario.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F03 - Sesiones Preestablecidas con Animacion/Video

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** filtrar rutinas por duracion y nivel, **para que** encuentro rapido una rutina que se ajuste a mi tiempo disponible y condicion fisica.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir filtrar el catalogo por: categoria/grupo muscular, duracion aproximada, nivel (principiante/intermedio/avanzado) y equipo requerido.
2. EL SISTEMA DEBE permitir combinar multiples filtros simultaneamente (AND logico).
3. CUANDO no hay resultados para la combinacion de filtros, EL SISTEMA DEBE mostrar un estado vacio claro con sugerencia de quitar filtros.
4. EL SISTEMA DEBE recordar los ultimos filtros usados durante la sesion de navegacion (no necesariamente entre sesiones).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
