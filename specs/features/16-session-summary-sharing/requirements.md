# Requirements: Compartir Resumen de Sesion

**ID:** F16 &nbsp;|&nbsp; **Slug:** `16-session-summary-sharing` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Genera una imagen resumen de la sesion completada (rutina, duracion, calorias, racha) para compartir en redes sociales.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones
- F12 - Estadisticas y Progreso

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** compartir un resumen visual de mi entrenamiento, **para que** puedo motivar a otros y llevar registro publico de mi progreso.

## Criterios de Aceptacion (formato EARS)

1. CUANDO una sesion termina exitosamente, EL SISTEMA DEBE ofrecer un boton 'Compartir resumen'.
2. EL SISTEMA DEBE generar una imagen (no solo texto) con: nombre de rutina, duracion, calorias estimadas y racha actual.
3. EL SISTEMA DEBE usar el share sheet nativo del sistema operativo para compartir la imagen generada.
4. LA generacion de la imagen DEBE funcionar completamente offline.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
