# Design: Seleccion de Voces (Sistema y Premium)

**ID:** F07 &nbsp;|&nbsp; **Slug:** `07-multiple-tts-voices`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Extiende `VoiceAnnouncer` (F02) con una interfaz `TtsProvider` con dos implementaciones: `SystemTtsProvider` (flutter_tts) y `PremiumTtsProvider` (API externa).
- Voces premium requieren backend ligero (Cloud Function / endpoint serverless) que oculte la API key del proveedor (ElevenLabs/Google Cloud TTS/Amazon Polly) — ver global/architecture.md seccion 'Backend minimo'.
- Cache local de audios premium generados frecuentemente (nombres de intervalos repetidos) para reducir costos y latencia.
- Gate de la seleccion de voces premium usando `ProGate` (F06).

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
