# Requirements: Vibracion como Feedback

**ID:** F18 &nbsp;|&nbsp; **Slug:** `18-vibration-feedback` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Vibracion en momentos clave (inicio/fin de intervalo, cuenta regresiva) como alternativa o complemento al audio, util en gimnasios ruidosos.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** sentir una vibracion al cambiar de intervalo, **para que** se cuando cambia la seccion aunque no escuche el audio.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE vibrar brevemente al iniciar cada nuevo intervalo.
2. EL SISTEMA DEBE vibrar con un patron distinto (mas corto/repetido) durante los ultimos segundos de cuenta regresiva.
3. EL SISTEMA DEBE permitir activar/desactivar la vibracion de forma independiente al audio.
4. SI el dispositivo no soporta vibracion o el usuario tiene restricciones del sistema activas, ENTONCES EL SISTEMA DEBE fallar silenciosamente sin error visible.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
