# Requirements: Voz: Cuenta Regresiva y Anuncios

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Texto a voz (TTS) que anuncia el nombre de la seccion al iniciar y cuenta regresiva en los ultimos segundos de cada intervalo.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F07 - Seleccion de Voces (Sistema y Premium)

## User Stories

- **Como** usuario, **quiero** escuchar el nombre de la seccion al empezar (ej. 'Calentamiento'), **para que** no necesito mirar la pantalla para saber que sigue.
- **Como** usuario, **quiero** escuchar una cuenta regresiva en los ultimos N segundos, **para que** puedo prepararme para el cambio de intervalo sin mirar el telefono.

## Criterios de Aceptacion (formato EARS)

1. CUANDO inicia un intervalo, EL SISTEMA DEBE anunciar por voz el nombre configurado del intervalo.
2. CUANDO quedan N segundos configurables (default 3) para terminar el intervalo, EL SISTEMA DEBE iniciar la cuenta regresiva hablada.
3. EL SISTEMA DEBE permitir configurar el numero de segundos de cuenta regresiva (0 para desactivar) por rutina o global.
4. SI el usuario silencia la app, ENTONCES EL SISTEMA DEBE respetar el estado mute sin detener el timer.
5. EL SISTEMA DEBE soportar mensaje de anuncio personalizado por intervalo (no solo el nombre por defecto).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
