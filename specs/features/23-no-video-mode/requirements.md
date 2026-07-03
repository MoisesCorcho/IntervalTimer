# Requirements: Modo Sin Video

**ID:** F23 &nbsp;|&nbsp; **Slug:** `23-no-video-mode` &nbsp;|&nbsp; **Fase:** Fase 5 · Descubrimiento de Contenido

## Resumen

Alternativa liviana que muestra solo texto/imagen estatica en vez de animacion/video, para ahorrar datos o para usuarios que ya conocen los ejercicios.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F03 - Sesiones Preestablecidas con Animacion/Video

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** desactivar los videos de los ejercicios, **para que** ahorro datos/bateria y voy directo a entrenar sin distracciones.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE ofrecer una configuracion global 'Modo sin video' (on/off).
2. CUANDO el modo sin video esta activo, EL SISTEMA DEBE mostrar imagen estatica + nombre del ejercicio en lugar de Lottie/video en todas las pantallas relevantes.
3. EL CAMBIO de configuracion DEBE aplicarse inmediatamente sin necesidad de reiniciar la app.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
