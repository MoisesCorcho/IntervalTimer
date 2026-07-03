# Design: Sesiones Preestablecidas con Animacion/Video

**ID:** F03 &nbsp;|&nbsp; **Slug:** `03-preset-workout-sessions`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Modelo `Exercise { id, name, category, mediaType(lottie/video/image), mediaPath, description }`.
- Modelo `PresetRoutine { id, name, category, intervals: List<Interval>, exercises: List<ExerciseRef> }`.
- Contenido versionado como JSON + assets en `assets/routines/` y `assets/media/`, cargado al build (no requiere backend en v1).
- Reproductor de video ligero con `video_player`, animaciones con `lottie` (mas liviano que video para loops cortos).
- Estructura pensada para migrar a fuente remota (CDN/Firebase Storage) en v2 sin cambiar el modelo de datos.

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
