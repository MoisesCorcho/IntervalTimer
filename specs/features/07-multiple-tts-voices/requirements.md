# Requirements: Seleccion de Voces (Sistema y Premium)

> Estado: No iniciada

**ID:** F07 &nbsp;|&nbsp; **Slug:** `07-multiple-tts-voices` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Permite elegir entre las voces TTS del sistema (gratis) y, en el tier Pro, voces premium generadas por IA con mayor naturalidad.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F02 - Voz: Cuenta Regresiva y Anuncios

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** elegir entre las voces disponibles en mi dispositivo, **para que** personalizo la experiencia de audio.
- **Como** usuario Pro, **quiero** usar voces premium mas naturales, **para que** la experiencia se siente de mejor calidad.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE listar las voces TTS disponibles en el dispositivo del usuario y permitir seleccionar una.
2. EL SISTEMA DEBE reproducir una muestra de audio al seleccionar una voz (preview).
3. SI el usuario es Pro, ENTONCES EL SISTEMA DEBE ofrecer voces premium adicionales (requiere conexion a internet).
4. SI el usuario no es Pro e intenta seleccionar una voz premium, ENTONCES EL SISTEMA DEBE redirigir a la pantalla de upgrade (F06).
5. SI la voz premium falla por falta de conexion, ENTONCES EL SISTEMA DEBE hacer fallback automatico a la voz del sistema.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
