# Roadmap y Grafo de Dependencias

## Indice completo de features

| ID | Feature | Fase | Estado | Prerequisitos |
|---|---|---|---|---|
| F01 | [Interval Timer Core](../features/01-interval-timer-core/requirements.md) | Fase 0 · Fundacion | En progreso | - |
| F02 | [Voz: Cuenta Regresiva y Anuncios](../features/02-voice-countdown-announcements/requirements.md) | Fase 0 · Fundacion | No iniciada | F01 |
| F03 | [Sesiones Preestablecidas con Animacion/Video](../features/03-preset-workout-sessions/requirements.md) | Fase 0 · Fundacion | No iniciada | F01 |
| F04 | [Calendario e Historial de Sesiones](../features/04-workout-calendar-history/requirements.md) | Fase 0 · Fundacion | No iniciada | F01 |
| F05 | [Editor de Rutinas Propias](../features/05-custom-routine-builder/requirements.md) | Fase 1 · Personalizacion | No iniciada | F01, F03 |
| F06 | [Capa Pro / Compras In-App](../features/06-pro-tier-iap/requirements.md) | Fase 1 · Personalizacion | No iniciada | F01 |
| F07 | [Seleccion de Voces (Sistema y Premium)](../features/07-multiple-tts-voices/requirements.md) | Fase 1 · Personalizacion | No iniciada | F02 |
| F08 | [Repeticion de Circuitos (Rounds)](../features/08-circuit-repetition-rounds/requirements.md) | Fase 2 · Profundidad de Entrenamiento | No iniciada | F01, F05 |
| F09 | [Progresion Automatica](../features/09-automatic-progression/requirements.md) | Fase 2 · Profundidad de Entrenamiento | No iniciada | F05, F04 |
| F10 | [Modo por Repeticiones](../features/10-rep-based-mode/requirements.md) | Fase 2 · Profundidad de Entrenamiento | No iniciada | F01 |
| F11 | [Ajuste Rapido de Intensidad](../features/11-quick-intensity-scaling/requirements.md) | Fase 2 · Profundidad de Entrenamiento | No iniciada | F01, F05 |
| F12 | [Estadisticas y Progreso](../features/12-statistics-progress/requirements.md) | Fase 3 · Seguimiento y Motivacion | No iniciada | F04 |
| F13 | [Logros y Badges](../features/13-achievements-badges/requirements.md) | Fase 3 · Seguimiento y Motivacion | No iniciada | F12 |
| F14 | [Recordatorios y Notificaciones](../features/14-reminders-notifications/requirements.md) | Fase 3 · Seguimiento y Motivacion | No iniciada | F04 |
| F15 | [Registro de Peso y Medidas](../features/15-body-measurements-tracking/requirements.md) | Fase 3 · Seguimiento y Motivacion | No iniciada | F04 |
| F16 | [Compartir Resumen de Sesion](../features/16-session-summary-sharing/requirements.md) | Fase 3 · Seguimiento y Motivacion | No iniciada | F04, F12 |
| F17 | [Integracion de Musica / Audio Ducking](../features/17-background-music-ducking/requirements.md) | Fase 4 · Audio y Experiencia | No iniciada | F01 |
| F18 | [Vibracion como Feedback](../features/18-vibration-feedback/requirements.md) | Fase 4 · Audio y Experiencia | No iniciada | F01 |
| F19 | [Pantalla Siempre Encendida](../features/19-always-on-screen/requirements.md) | Fase 4 · Audio y Experiencia | No iniciada | F01 |
| F20 | [Widget de Pantalla de Bloqueo / Notificacion Persistente](../features/20-lock-screen-widget/requirements.md) | Fase 4 · Audio y Experiencia | No iniciada | F01, F19 |
| F21 | [Soporte para Smartwatch (Wear OS / Apple Watch)](../features/21-smartwatch-support/requirements.md) | Fase 4 · Audio y Experiencia (Futuro) | No iniciada | F01, F19 |
| F22 | [Filtros de Rutinas](../features/22-routine-filters/requirements.md) | Fase 5 · Descubrimiento de Contenido | No iniciada | F03 |
| F23 | [Modo Sin Video](../features/23-no-video-mode/requirements.md) | Fase 5 · Descubrimiento de Contenido | No iniciada | F03 |
| F24 | [Favoritos](../features/24-favorites/requirements.md) | Fase 5 · Descubrimiento de Contenido | No iniciada | F03, F05 |
| F25 | [Compartir Rutinas con Otros Usuarios](../features/25-routine-sharing/requirements.md) | Fase 6 · Social (Futuro) | No iniciada | F05, F06 |
| F26 | [Retos Grupales](../features/26-group-challenges/requirements.md) | Fase 6 · Social (Futuro) | No iniciada | F25, F12 |
| F27 | [Modo Oscuro](../features/27-dark-mode/requirements.md) | Fase 7 · Calidad y Pulido | No iniciada | F01 |
| F28 | [Multilenguaje (i18n)](../features/28-multi-language-i18n/requirements.md) | Fase 7 · Calidad y Pulido | No iniciada | F01 |
| F29 | [Backup y Exportacion de Datos](../features/29-backup-export/requirements.md) | Fase 7 · Calidad y Pulido | No iniciada | F04, F12 |
| F30 | [Onboarding](../features/30-onboarding/requirements.md) | Fase 7 · Calidad y Pulido | No iniciada | F01 |
| F31 | [Accesibilidad](../features/31-accessibility/requirements.md) | Fase 7 · Calidad y Pulido | No iniciada | F01 |
| F32 | [Constructor de Entrenamientos por Ejercicios](../features/32-workout-exercise-builder/requirements.md) | Fase 1 · Personalizacion | No iniciada | F01 |
| F33 | [Controles Numericos y de Duracion (Steppers Premium)](../features/33-premium-numeric-steppers/requirements.md) | Fase 7 · Calidad y Pulido | Completado | F01, F32 |
| F34 | [Descanso entre Sets y Descanso Final del Ejercicio](../features/34-exercise-rest-between-and-final/requirements.md) | Fase 1 · Personalizacion | Completado | F32 |
| F35 | [Navegacion de Secciones, Preparacion y Ajustes](../features/35-timer-navigation-prep-settings/requirements.md) | Fase 0 · Fundacion | En progreso | F01 |

Sincronizar la columna **Estado** con el bloque `> Estado:` al inicio de cada `requirements.md`.

## Notas de alcance entre features

### F01 vs F05 (rutinas)

- **F01:** motor del timer + una rutina activa (draft); CRUD de intervalos dentro de esa rutina.
- **F05:** biblioteca multi-rutina; duplicar presets (requiere F03); reordenar; eliminar.
- F05 depende de F03 porque la duplicacion de rutinas preestablecidas requiere el catalogo `PresetRoutine`.

### F32 vs F01 / F05 (entrenamientos estructurados)

- **F32:** apartado **Entrenamientos** — modelo ejercicio + sets + duracion trabajo/descanso; aplanado efimero a intervalos para F01.
- **F05:** rutinas con intervalos planos (sin entidad ejercicio+sets).
- F32 **no depende** de F03 ni F05; solo de F01 para ejecutar el timer.
- Priorizar F32 si el flujo principal del producto es crear entrenamientos con ejercicios; F05 queda para usuarios avanzados que prefieren intervalos sueltos.

### F33 vs F01 / F32 (steppers de formulario)

- **F33:** widgets compartidos `NumberStepper` / `DurationStepper` (sin teclado; min ±1, seg ±5, sets ±1) y migracion de formularios de F32 y F01.
- No introduce persistencia; depende de F01 y F32 porque esos forms son los consumers obligatorios.
- Puede adelantarse dentro de Fase 7 apenas F01 y F32 tengan formularios estables en codigo.
- F05 y otros forms futuros pueden reutilizar los widgets sin ser prerequisito de F33.

### F34 vs F32 (descansos duales del ejercicio)

- **F32:** introduce `restSeconds` (descanso entre sets) y un aplanado que **omite** cualquier rest tras el ultimo set del ejercicio.
- **F34:** mantiene `restSeconds` como entre-sets y agrega `restAfterExerciseSeconds` (descanso final del ejercicio, solo si hay ejercicio siguiente). Extiende `WorkoutFlattener` y el formulario de ejercicio; no crea modulo nuevo.
- F34 **no** inventa cooldown de sesion al terminar el workout.
- Default de migracion `restAfterExerciseSeconds = 0` preserva el comportamiento pre-F34.
- Caso clave: `sets = 1` + ejercicio siguiente → el descanso entre sets no aplica; el descanso final de A si puede ejecutarse antes de B.
- Depende solo de F32; F33 no es prerequisito formal, pero el form debe reutilizar `DurationStepper` si ya esta integrado.

### F35 vs F01 (ejecucion, prep y settings)

- **F01:** motor base (pause/resume, skip forward, cancel, pantalla de ejecucion, eventos de sesion).
- **F35:** skip back, fase `preparing` pre-sesion, tiempo restante total, modal de salida, redesenio de controles, shell `features/settings/` y preferencia global `prep_seconds`.
- Pausa sin reinicio **no** se reespecifica: se preserva y se regresa F01 R4/R14.
- F33 no es prerequisito formal de F35, pero el control de prep en Settings **debe** reutilizar `NumberStepper` si ya esta en `shared/widgets/`.
- Prep se aplica **una vez** al inicio de la secuencia efectiva del controller (rutina F01 o lista aplanada F32/F34), no por ejercicio.

### F01 vs F04 (eventos de sesion)

- F04 consume `SessionCompletedEvent` y `SessionCancelledEvent` expuestos por `TimerController` (F01).
- Ver contrato en `02-architecture-and-structure.md` — no usar nombres alternativos (`onSessionEnd`).

### Dependencias blandas (no bloqueantes en roadmap)

| Feature | Depende blando de | Motivo |
|---|---|---|
| F06 | F03, F07 | IAP puede gatear contenido premium y voces |
| F25 | F06 | Compartir rutinas puede ser feature Pro |

## Orden de implementacion sugerido (por fase)

- **Fase 0 - Fundacion:** F01, luego F35 (extiende ejecucion de F01: nav, prep, settings), luego F02 / F03 / F04 en paralelo (migraciones drift coordinadas).
- **Fase 1 - Personalizacion y monetizacion:** F32, F34 (tras F32), F05, F06, F07 (F32 puede implementarse antes que F05; no comparten prerequisitos; F34 extiende el aplanado/rest de F32).
- **Fase 2 - Profundidad de entrenamiento:** F08, F09, F10, F11.
- **Fase 3 - Seguimiento y motivacion:** F12, F13, F14, F15, F16.
- **Fase 4 - Audio y experiencia:** F17, F18, F19, F20, F21 (F21 es fase futura/spike).
- **Fase 5 - Descubrimiento de contenido:** F22, F23, F24.
- **Fase 6 - Social (futuro, requiere backend real):** F25, F26.
- **Fase 7 - Calidad y pulido:** F27, F28, F29, F30, F31, F33.

**Nota:** F30 (Onboarding) y F27 (Dark Mode) conviene adelantarlas si el lanzamiento a stores es
inminente — el orden de fases es tematico, no estrictamente cronologico.

### Checklist para adelantar F27 / F30 antes de Fase 7

Adelantar solo si se cumplen **todos**:

- [ ] F01 completa y estable (timer + rutina activa).
- [ ] Hay fecha de submission a App Store / Play Store confirmada.
- [ ] Screenshots y assets de store requieren tema claro/oscuro o flujo de primer uso.
- [ ] El equipo tiene capacidad sin retrasar F02–F04 criticos para MVP funcional.

Si no se cumplen, mantener F27/F30 en Fase 7.

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
F01 --> F32
F01 --> F33
F32 --> F33
F32 --> F34
F01 --> F35
```

## Como agregar una nueva feature al roadmap

1. Asignar el siguiente ID disponible (`F35`, etc.).
2. Crear carpeta `specs/features/NN-slug/` con los 3 archivos usando las existentes como referencia.
3. Declarar sus prerequisitos reales.
4. Actualizar la tabla de este archivo (con columna Estado) y el grafo de dependencias.
5. Agregar bloque `> Estado: No iniciada` al inicio de `requirements.md`.