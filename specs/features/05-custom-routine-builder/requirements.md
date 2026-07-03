# Requirements: Editor de Rutinas Propias

**ID:** F05 &nbsp;|&nbsp; **Slug:** `05-custom-routine-builder` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Permite al usuario crear, editar, duplicar y eliminar sus propias rutinas desde cero, reutilizando la estructura de intervalos y el catalogo de ejercicios.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F03 - Sesiones Preestablecidas con Animacion/Video

## Postrequisitos (features que dependen de esta)

- F08 - Repeticion de Circuitos (Rounds)
- F09 - Progresion Automatica
- F11 - Ajuste Rapido de Intensidad
- F24 - Favoritos
- F25 - Compartir Rutinas con Otros Usuarios

## User Stories

- **Como** usuario, **quiero** crear una rutina desde cero agregando y ordenando intervalos, **para que** puedo adaptar la app a mi entrenamiento personal.
- **Como** usuario, **quiero** duplicar y modificar una rutina preestablecida, **para que** no tengo que empezar de cero cada vez.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir crear una rutina vacia y agregar intervalos uno a uno con reordenamiento (drag & drop).
2. EL SISTEMA DEBE permitir duplicar cualquier rutina (propia o preestablecida) como punto de partida editable.
3. CUANDO el usuario edita una rutina preestablecida, EL SISTEMA DEBE guardarla como copia nueva sin modificar el contenido original de la app.
4. EL SISTEMA DEBE validar que la rutina tenga al menos un intervalo antes de permitir guardarla.
5. EL SISTEMA DEBE permitir eliminar una rutina propia con confirmacion.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
