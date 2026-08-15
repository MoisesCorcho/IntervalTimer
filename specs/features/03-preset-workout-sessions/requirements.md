# Requirements: Sesiones Preestablecidas con Animacion/Video

> Estado: Implementada (Specs corregidas - Gold Standard)

**ID:** F03 &nbsp;|&nbsp; **Slug:** `03-preset-workout-sessions` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundación

## Resumen

Catálogo de rutinas prediseñadas organizadas por categoría y nivel de dificultad, estructuradas a partir de un catálogo maestro de ejercicios con instrucciones paso a paso y demostraciones visuales (imágenes/animaciones). Permite la exploración fluida en 3 niveles de UI, la previsualización de la técnica de cada ejercicio, el inicio directo de la sesión en el motor de temporizador (`TimerController` de F01) mediante un aplanador efímero en memoria, y la duplicación a "Mis Rutinas" (Drift) como copia editable.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F05 - Editor de Rutinas Propias
- F22 - Filtros de Rutinas
- F23 - Modo Sin Video
- F24 - Favoritos

## User Stories

- **Como** usuario, **quiero** explorar rutinas prediseñadas organizadas por categoría y ver sus detalles principales (duración, dificultad, lista de ejercicios), **para que** pueda empezar a entrenar inmediatamente sin tener que estructurar una rutina desde cero.
- **Como** usuario, **quiero** consultar la técnica detallada y la animación o demostración gráfica de cada ejercicio paso a paso, **para que** realice los movimientos con la postura y ejecución correctas evitando lesiones.
- **Como** usuario, **quiero** iniciar una rutina preestablecida en el temporizador sin alterar mi base de datos de rutinas personalizadas, **para que** el flujo de entrenamiento sea instantáneo y limpio.
- **Como** usuario, **quiero** duplicar una rutina preestablecida hacia mi biblioteca ("Mis Rutinas"), **para que** pueda personalizar sus tiempos, nombres e intervalos según mis necesidades particulares.

## Criterios de Aceptación — Happy path (formato EARS)

### R1 — Carga y deserialización de catálogo maestro

CUANDO la aplicación inicia o accede a la sección de rutinas preestablecidas, EL SISTEMA DEBE cargar y deserializar los archivos JSON independientes `exercises.json` (catálogo maestro de ejercicios) y `presets.json` (rutinas preestablecidas) ubicados en `assets/routines/`, indexando los ejercicios por su `id` para la resolución de referencias.

### R2 — Navegación y visualización Nivel 1: Exploración de catálogo

DONDE el usuario está en la pantalla principal de rutinas preestablecidas, EL SISTEMA DEBE mostrar un carrusel superior con rutinas destacadas y un grid interactivo de categorías (`PresetCategory`) que permita filtrar el catálogo.

### R3 — Navegación y visualización Nivel 2: Detalle de rutina preestablecida

DONDE el usuario selecciona una rutina preestablecida del catálogo o carrusel, EL SISTEMA DEBE navegar a la pantalla `PresetDetailScreen` y mostrar:
1. Resumen ejecutivo: título, descripción, categoría, nivel de dificultad (`DifficultyLevel`), duración total calculada y número total de ejercicios.
2. Lista ordenada de bloques de ejercicios con sus series, tiempos de trabajo, descansos e imágenes miniaturas.
3. Botón flotante prominente de acción principal "Iniciar Entrenamiento".

### R4 — Navegación y visualización Nivel 3: Modal de técnica de ejercicio

DONDE el usuario presiona un ejercicio en la pantalla de detalle `PresetDetailScreen` o durante la previsualización, EL SISTEMA DEBE desplegar el modal `ExerciseTechniqueBottomSheet` mostrando:
1. Demostración gráfica (animación/GIF/Lottie o imagen).
2. Título del ejercicio y categoría muscular.
3. Instrucciones de ejecución paso a paso (1, 2, 3...).
4. Consejos de técnica y errores comunes (tips).

### R5 — Carga de entrenamiento efímera a TimerController

DONDE el usuario está en `PresetDetailScreen`, CUANDO presiona el botón "Iniciar Entrenamiento", EL SISTEMA DEBE aplanar la estructura del preset a una lista ordenada de `Interval`s efímeros en memoria mediante `PresetRoutineFlattener` e iniciar la sesión directamente en el `TimerController` de F01 sin registrar filas en la base de datos local Drift.

### R6 — Duplicar rutina preestablecida a "Mis Rutinas"

DONDE el usuario está en `PresetDetailScreen` o en el menú de opciones del preset, CUANDO presiona la acción "Duplicar a Mis Rutinas", EL SISTEMA DEBE clonar el preset aplanado y crear registros persistentes en las tablas `routines` e `intervals` de Drift asignando `source = RoutineSource.presetDerived` y `originId = preset.id`.

### R7 — Inmutabilidad de rutinas preestablecidas

MIENTRAS el usuario explora, visualiza o entrena una rutina preestablecida, EL SISTEMA DEBE mantenerla como inmutable (Read-Only), impidiendo su modificación, reordenamiento o eliminación dentro del catálogo maestro de presets.

### R8 — Soporte de catálogo base inicial de 6 presets

EL SISTEMA DEBE incluir en el paquete de assets de la aplicación un catálogo maestro inicial con al menos los siguientes 6 presets estructurados:
1. **HIIT Quema Calórica 15m** (Categoría: `hiit`, Dificultad: `intermediate`)
2. **Abs de Acero 10m** (Categoría: `core`, Dificultad: `beginner`)
3. **Piernas & Glúteos 15m** (Categoría: `lowerBody`, Dificultad: `intermediate`)
4. **Full Body Express 12m** (Categoría: `fullBody`, Dificultad: `beginner`)
5. **Upper Body Pump 15m** (Categoría: `upperBody`, Dificultad: `advanced`)
6. **Cardio Tabata 8m** (Categoría: `cardio`, Dificultad: `advanced`)

## Criterios de Aceptación — Validación y error (formato EARS)

### R9 — Resiliencia y fallback visual en 3 niveles

CUANDO el sistema intenta renderizar la demostración gráfica de un ejercicio, EL SISTEMA DEBE evaluar en cascada y sin fallar:
1. Nivel 1: Asset específico del ejercicio (`assets/media/exercises/{exercise_id}.png` o `.json`/`.gif`).
2. Nivel 2: Asset placeholder por categoría (`assets/media/categories/{category_id}.png`).
3. Nivel 3: Icono vectorial por defecto del sistema Flutter (ej. `Icons.fitness_center`).

EL SISTEMA DEBE funcionar 100% offline y garantizar cero cierres inesperados (crashes) ante assets faltantes.

### R10 — Captura y manejo de errores de JSONs corruptos o faltantes

CUANDO el sistema intenta leer los archivos `exercises.json` o `presets.json` y alguno de ellos no existe, está corrupto o malformado, EL SISTEMA DEBE capturar la excepción en el repositorio, emitir un estado de error observable en Riverpod y mostrar en la UI una vista amigable de fallo con un botón de "Reintentar" sin colapsar la app.

### R11 — Fallback en mapeo de enums fuertemente tipados

CUANDO el deserializador procesa valores de `category` o `difficulty` en los JSONs, SI el identificador de cadena no coincide con ningún valor conocido de los enums Dart (`PresetCategory`, `DifficultyLevel`), ENTONCES EL SISTEMA DEBE asignar los valores fallback predeterminados (`PresetCategory.fullBody` y `DifficultyLevel.intermediate` respectivamente) registrando una advertencia en el log.

## Decisiones de producto (resuelven ambigüedades)

| Tema | Decisión |
|---|---|
| Almacenamiento maestro | 2 archivos JSON independientes en `assets/routines/`: `exercises.json` (ejercicios únicos con técnica/media) y `presets.json` (rutinas que referencian `exerciseId`). |
| Jerarquía de UI | 3 niveles definidos: Nivel 1 (Catálogo con Carrusel + Grid Categorías) -> Nivel 2 (`PresetDetailScreen` con resumen + lista + FAB Iniciar) -> Nivel 3 (`ExerciseTechniqueBottomSheet` modal). |
| Estado del temporizador | Inicia de forma efímera en memoria en `TimerController` (F01). No ensucia Drift ni requiere limpieza posterior. |
| Personalización de presets | Presets 100% inmutables. Para editar, el usuario usa "Duplicar a Mis Rutinas", creando un clon en Drift con `source = presetDerived` y `originId = preset.id`. |
| Tipado de Enums | Enums Dart fuertemente tipados (`PresetCategory`, `DifficultyLevel`) con mappers `fromId(String id)` y fallback seguro para evitar excepciones de formato. |
| Resiliencia de media | Estrategia offline de fallback en 3 niveles (Imagen Ejercicio -> Placeholder Categoría -> Icono Sistema). Cero dependencias de red en MVP. |

## Fuera de alcance (explícito)

- Descarga dinámica de videos o assets desde servidores remotos o CDN en MVP (100% offline via bundle assets).
- Edición directa sobre las rutinas preestablecidas nativas del catálogo.
- Filtrado complejo de múltiples etiquetas avanzadas (reservado para F22).
- Favoritos o marcado de me gusta en presets (reservado para F24).

## Referencias

- `_global/01-vision-and-principles.md` — Principio offline-first y ejecución sin fricción.
- `_global/02-architecture-and-structure.md` — Arquitectura en capas y patrones de proyectos Flutter.
- `_global/03-conventions.md` — Convenciones de Riverpod, testing y formato EARS.
- `_global/04-design-system.md` — Componentes de UI, bottom sheets, botones flotantes y diseño atómico.
- `_global/05-data-model.md` — Definición de `PresetRoutine`, `Exercise`, `Interval` y `RoutineSource`.
