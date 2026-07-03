# Design: Voz: Cuenta Regresiva y Anuncios

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Paquete `flutter_tts` como capa de abstraccion sobre voces nativas.
- Servicio `VoiceAnnouncer` desacoplado del `TimerController`, escucha eventos (onIntervalStart, onCountdownTick) via stream/callbacks.
- Cola de anuncios simple para evitar solapamiento si dos eventos disparan casi simultaneo.
- Configuracion persistida: `countdownSeconds`, `voiceEnabled`, `announceIntervalName`.
- Prever hook de extension para voces premium (ver F07) sin acoplar esta feature a esa logica.

## Diagrama de flujo (alto nivel)

```
[Trigger / Evento de usuario]
        |
        v
[Capa UI: Widget/Screen] --> [Capa de estado: Controller/Provider]
        |                              |
        v                              v
[Servicio de dominio especifico]   [Repositorio / Persistencia local]
        |
        v
[Efecto observable: UI actualizada / evento emitido a otras features]
```

*Nota: Este diagrama es una plantilla generica. Ajustar segun la naturaleza de la feature al
implementar (algunas features son puramente UI, otras solo backend/servicios, etc).*

## Riesgos y consideraciones

- Validar que los cambios de datos sean compatibles con versiones anteriores de la base de datos local
  (definir estrategia de migracion en `_global/05-data-model.md` si esta feature agrega/modifica tablas).
- Si esta feature interactua con hardware (audio, vibracion, notificaciones), probar en dispositivo fisico,
  no solo en emulador/simulador.

## Alternativas consideradas

*(Completar durante la implementacion si se descartan enfoques relevantes, para dejar registro de por que
se eligio el enfoque actual.)*
