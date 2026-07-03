# Design: Widget de Pantalla de Bloqueo / Notificacion Persistente

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Android: `flutter_background_service` + notificacion tipo `MediaStyle`/custom con acciones (pause/next) via `flutter_local_notifications`.
- iOS: Live Activities (ActivityKit) para pantalla de bloqueo/Dynamic Island; requiere codigo nativo Swift complementario (mayor esfuerzo, evaluar como fase separada dentro de esta feature).
- Comunicacion bidireccional entre el foreground service/Live Activity y el `TimerController` via un canal de eventos compartido (Isolate messaging en Android, App Group/Darwin notifications en iOS).

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
