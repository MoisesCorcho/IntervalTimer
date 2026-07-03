# Design: Interval Timer Core

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Modelo `Interval { id, name, durationSeconds, color, type }` donde `type` in {warmup, work, rest, stretch, custom}.
- Modelo `Routine { id, name, intervals: List<Interval>, createdAt }`.
- State machine del timer: idle -> running -> paused -> running -> completed, implementada con Riverpod/Bloc (definir en conventions.md).
- El calculo de tiempo restante se basa en `DateTime.now()` delta contra un `startTimestamp` guardado, NO en decrementos por tick, para evitar drift.
- Uso de `Ticker`/`Stream.periodic` solo para refrescar UI, la fuente de verdad del tiempo es el timestamp.
- Color picker: paquete `flutter_colorpicker` o implementacion propia con paleta predefinida + custom (HSV).

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
