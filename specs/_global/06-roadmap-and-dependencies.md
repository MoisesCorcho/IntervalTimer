# Roadmap y Grafo de Dependencias

## Indice completo de features

| ID | Feature | Fase | Prerequisitos |
|---|---|---|---|
| F01 | [Interval Timer Core](../specs/features/01-interval-timer-core/requirements.md) | Fase 0 · Fundacion | - |
| F02 | [Voz: Cuenta Regresiva y Anuncios](../specs/features/02-voice-countdown-announcements/requirements.md) | Fase 0 · Fundacion | F01 |
| F03 | [Sesiones Preestablecidas con Animacion/Video](../specs/features/03-preset-workout-sessions/requirements.md) | Fase 0 · Fundacion | F01 |
| F04 | [Calendario e Historial de Sesiones](../specs/features/04-workout-calendar-history/requirements.md) | Fase 0 · Fundacion | F01 |
| F05 | [Editor de Rutinas Propias](../specs/features/05-custom-routine-builder/requirements.md) | Fase 1 · Personalizacion | F01, F03 |
| F06 | [Capa Pro / Compras In-App](../specs/features/06-pro-tier-iap/requirements.md) | Fase 1 · Personalizacion | F01 |
| F07 | [Seleccion de Voces (Sistema y Premium)](../specs/features/07-multiple-tts-voices/requirements.md) | Fase 1 · Personalizacion | F02 |
| F08 | [Repeticion de Circuitos (Rounds)](../specs/features/08-circuit-repetition-rounds/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01, F05 |
| F09 | [Progresion Automatica](../specs/features/09-automatic-progression/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F05, F04 |
| F10 | [Modo por Repeticiones](../specs/features/10-rep-based-mode/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01 |
| F11 | [Ajuste Rapido de Intensidad](../specs/features/11-quick-intensity-scaling/requirements.md) | Fase 2 · Profundidad de Entrenamiento | F01, F05 |
| F12 | [Estadisticas y Progreso](../specs/features/12-statistics-progress/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F13 | [Logros y Badges](../specs/features/13-achievements-badges/requirements.md) | Fase 3 · Seguimiento y Motivacion | F12 |
| F14 | [Recordatorios y Notificaciones](../specs/features/14-reminders-notifications/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F15 | [Registro de Peso y Medidas](../specs/features/15-body-measurements-tracking/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04 |
| F16 | [Compartir Resumen de Sesion](../specs/features/16-session-summary-sharing/requirements.md) | Fase 3 · Seguimiento y Motivacion | F04, F12 |
| F17 | [Integracion de Musica / Audio Ducking](../specs/features/17-background-music-ducking/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F18 | [Vibracion como Feedback](../specs/features/18-vibration-feedback/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F19 | [Pantalla Siempre Encendida](../specs/features/19-always-on-screen/requirements.md) | Fase 4 · Audio y Experiencia | F01 |
| F20 | [Widget de Pantalla de Bloqueo / Notificacion Persistente](../specs/features/20-lock-screen-widget/requirements.md) | Fase 4 · Audio y Experiencia | F01, F19 |
| F21 | [Soporte para Smartwatch (Wear OS / Apple Watch)](../specs/features/21-smartwatch-support/requirements.md) | Fase 4 · Audio y Experiencia (Futuro) | F01, F19 |
| F22 | [Filtros de Rutinas](../specs/features/22-routine-filters/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03 |
| F23 | [Modo Sin Video](../specs/features/23-no-video-mode/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03 |
| F24 | [Favoritos](../specs/features/24-favorites/requirements.md) | Fase 5 · Descubrimiento de Contenido | F03, F05 |
| F25 | [Compartir Rutinas con Otros Usuarios](../specs/features/25-routine-sharing/requirements.md) | Fase 6 · Social (Futuro) | F05, F06 |
| F26 | [Retos Grupales](../specs/features/26-group-challenges/requirements.md) | Fase 6 · Social (Futuro) | F25, F12 |
| F27 | [Modo Oscuro](../specs/features/27-dark-mode/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F28 | [Multilenguaje (i18n)](../specs/features/28-multi-language-i18n/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F29 | [Backup y Exportacion de Datos](../specs/features/29-backup-export/requirements.md) | Fase 7 · Calidad y Pulido | F04, F12 |
| F30 | [Onboarding](../specs/features/30-onboarding/requirements.md) | Fase 7 · Calidad y Pulido | F01 |
| F31 | [Accesibilidad](../specs/features/31-accessibility/requirements.md) | Fase 7 · Calidad y Pulido | F01 |

## Orden de implementacion sugerido (por fase)

- **Fase 0 - Fundacion:** F01, F02, F03, F04.
- **Fase 1 - Personalizacion y monetizacion:** F05, F06, F07.
- **Fase 2 - Profundidad de entrenamiento:** F08, F09, F10, F11.
- **Fase 3 - Seguimiento y motivacion:** F12, F13, F14, F15, F16.
- **Fase 4 - Audio y experiencia:** F17, F18, F19, F20, F21 (F21 es fase futura/spike).
- **Fase 5 - Descubrimiento de contenido:** F22, F23, F24.
- **Fase 6 - Social (futuro, requiere backend real):** F25, F26.
- **Fase 7 - Calidad y pulido:** F27, F28, F29, F30, F31.

**Nota:** F30 (Onboarding) y F27 (Dark Mode) conviene adelantarlas si el lanzamiento a stores es
inminente, aunque esten en "Fase 7" - el orden de fases es tematico, no estrictamente cronologico.

## Grafo de dependencias (pegar en https://mermaid.live anteponiendo `graph TD`)

```
[inicio] --> F01
F01 --> F02
F01 --> F03
F01 --> F04
F01 --> F05
F03 --> F05
F01 --> F06
F02 --> F07
F01 --> F08
F05 --> F08
F05 --> F09
F04 --> F09
F01 --> F10
F01 --> F11
F05 --> F11
F04 --> F12
F12 --> F13
F04 --> F14
F04 --> F15
F04 --> F16
F12 --> F16
F01 --> F17
F01 --> F18
F01 --> F19
F01 --> F20
F19 --> F20
F01 --> F21
F19 --> F21
F03 --> F22
F03 --> F23
F03 --> F24
F05 --> F24
F05 --> F25
F06 --> F25
F25 --> F26
F12 --> F26
F01 --> F27
F01 --> F28
F04 --> F29
F12 --> F29
F01 --> F30
F01 --> F31
```

## Como agregar una nueva feature al roadmap

1. Asignar el siguiente ID disponible (`F32`, etc.).
2. Crear carpeta `specs/features/NN-slug/` con los 3 archivos usando las existentes como referencia.
3. Declarar sus prerequisitos reales.
4. Actualizar la tabla de este archivo y el grafo de dependencias.
