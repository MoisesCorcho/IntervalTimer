# Design: Calendario e Historial de Sesiones

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Base de datos local: `drift` (SQLite) o `isar`, definir eleccion final en data-model.md global.
- Modelo `SessionLog { id, routineId, routineName, date, startedAt, completedAt, status(completed/aborted), totalDurationSeconds }`.
- UI con paquete `table_calendar` para el widget de calendario + marcadores por dia.
- Repositorio `SessionLogRepository` como capa de acceso a datos, desacoplado de la UI (para poder cambiar de SQLite a Firestore en el futuro sin tocar UI).
- El `TimerController` (F01) emite un evento `onSessionEnd` que este modulo escucha para persistir el log.

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
