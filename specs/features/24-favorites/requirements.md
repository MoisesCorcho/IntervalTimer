# Requirements: Favoritos

> Estado: No iniciada

**ID:** F24 &nbsp;|&nbsp; **Slug:** `24-favorites` &nbsp;|&nbsp; **Fase:** Fase 5 · Descubrimiento de Contenido

## Resumen

Sistema de favoritos que permite al usuario fijar y acceder rápidamente a sus rutinas preestablecidas (Presets) y entrenamientos personalizados (Workouts) más utilizados, tanto desde la pantalla principal (Home) como mediante filtros dedicados en sus respectivos catálogos.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F03 - Sesiones Preestablecidas con Animacion/Video
- F32 - Constructor de Entrenamientos por Ejercicios

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** marcar y desmarcar presets y entrenamientos como favoritos con un solo toque, **para que** pueda identificarlos y organizarlos visualmente en toda la app.
- **Como** usuario, **quiero** ver una sección destacada de favoritos en la pantalla de inicio, **para que** pueda iniciar mis sesiones recurrentes inmediatamente sin navegar por múltiples pantallas.
- **Como** usuario, **quiero** filtrar por favoritos en el catálogo de presets y en la biblioteca de entrenamientos, **para que** pueda encontrar rápido mis rutinas guardadas dentro de cada sección.

## Decisiones de producto (registradas en auditoria)

| Tema | Decision | Justificacion |
|---|---|---|
| **Alcance de entidades** | Solo Presets (`PresetRoutine`) y Entrenamientos (`Workout`). Rutinas planas F01/F05 quedan excluidas. | F32 es el modelo estructurado de entrenamientos del usuario y F03 el de presets empaquetados. Las rutinas planas son transicionales. |
| **Acceso en Home** | Carrusel / sección horizontal superior en Home, visible solo cuando hay >= 1 favorito. | Reduce fricción de inicio (1 toque) sin ensuciar la pantalla principal si el usuario aún no tiene favoritos. |
| **Filtrado en listas** | Filter Chip `[ ★ Favoritos ]` en cabeceras de listas; FAB exclusivo para creación. | Respeta ergonomía móvil y Material Design: FAB para acción constructiva única, Chip para modo de consulta/filtro. |
| **Iconografía** | Estrella (`Icons.star` activo / `Icons.star_border` inactivo). | Evita confusión con métricas de salud/cardio (corazón) y mantiene semántica universal de "destacado/marcador". |
| **Ordenamiento** | Cronológico inverso por fecha de marcado (`created_at DESC`). | Los entrenamientos y presets marcados más recientemente aparecen primero de forma natural. |
| **Borrado de entidad** | Limpieza automática / cascada al eliminar un Workout. | Previene referencias huérfanas o errores de carga al consultar favoritos de entidades eliminadas. |

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Marcado de Preset como favorito

DONDE el usuario visualiza una tarjeta o el detalle de una rutina preestablecida (Preset),  
CUANDO presiona el botón de favorito (`FavoriteToggleButton` inactivo),  
EL SISTEMA DEBE guardar el registro de favorito para dicho preset y actualizar el ícono a estado activo de forma inmediata.

### R2 — Desmarcado de Preset como favorito

DONDE el usuario visualiza una rutina preestablecida marcada como favorita,  
CUANDO presiona el botón de favorito (`FavoriteToggleButton` activo),  
EL SISTEMA DEBE eliminar el registro de favorito correspondiente y actualizar el ícono a estado inactivo.

### R3 — Marcado de Entrenamiento (Workout) como favorito

DONDE el usuario visualiza una tarjeta o el detalle de un entrenamiento personalizado (`Workout`),  
CUANDO presiona el botón de favorito (`FavoriteToggleButton` inactivo),  
EL SISTEMA DEBE persistir el registro de favorito asociado al ID del entrenamiento y reflejar el estado activo inmediatamente.

### R4 — Desmarcado de Entrenamiento (Workout) como favorito

DONDE el usuario visualiza un entrenamiento personalizado marcado como favorito,  
CUANDO presiona el botón de favorito (`FavoriteToggleButton` activo),  
EL SISTEMA DEBE remover el registro de favorito de la base de datos local y reflejar el estado inactivo.

### R5 — Persistencia local de favoritos

CUANDO se crea o elimina un favorito,  
EL SISTEMA DEBE persistir el cambio en la base de datos Drift local de modo que el estado se mantenga consistente entre reinicios de la aplicación.

### R6 — Sección de Favoritos en Pantalla Principal (Home)

DONDE el usuario se encuentra en la pantalla de inicio (Home) y existe al menos 1 favorito registrado,  
EL SISTEMA DEBE mostrar una sección destacada horizontal de "Favoritos" con las tarjetas de los presets y entrenamientos guardados.

### R7 — Ocultamiento de la sección de Favoritos en Home sin elementos

DONDE el usuario se encuentra en la pantalla de inicio (Home) y no existen favoritos registrados,  
EL SISTEMA DEBE ocultar completamente la sección de Favoritos para optimizar el espacio visual.

### R8 — Filtrado por favoritos en Catálogo de Presets

DONDE el usuario se encuentra en la pantalla del catálogo de rutinas preestablecidas (F03),  
CUANDO activa el Filter Chip `[ ★ Favoritos ]`,  
EL SISTEMA DEBE mostrar únicamente los presets que hayan sido marcados como favoritos.

### R9 — Filtrado por favoritos en Biblioteca de Entrenamientos

DONDE el usuario se encuentra en la pantalla de entrenamientos (F32),  
CUANDO activa el Filter Chip `[ ★ Favoritos ]`,  
EL SISTEMA DEBE mostrar únicamente los entrenamientos del usuario que hayan sido marcados como favoritos.

### R10 — Ordenamiento cronológico inverso

CUANDO se presenta cualquier lista o sección de favoritos (Home, catálogo o entrenamientos filtrados),  
EL SISTEMA DEBE ordenar los elementos por fecha de marcado descendente (`created_at DESC`), mostrando los más recientes primero.

### R11 — Inicio directo de sesión desde Favoritos

DONDE el usuario pulsa sobre una tarjeta de favorito en la pantalla Home,  
EL SISTEMA DEBE abrir la vista previa / preparación del entrenamiento o preset seleccionado para permitir su inicio inmediato.

## Criterios de Aceptacion — Validacion, casos borde y error (formato EARS)

### R12 — Eliminación en cascada de favoritos al borrar un Workout

CUANDO el usuario elimina un entrenamiento personalizado desde la pantalla de entrenamientos (F32),  
EL SISTEMA DEBE eliminar automáticamente cualquier registro de favorito asociado a dicho `workoutId`, garantizando que no aparezca en listas ni en Home.

### R13 — Estado vacío con filtro de favoritos activo en listas

DONDE el usuario activa el Filter Chip `[ ★ Favoritos ]` en el catálogo de presets o en la pantalla de entrenamientos y no hay coincidencias,  
EL SISTEMA DEBE mostrar un estado vacío explicativo con un mensaje claro que indique que no hay favoritos guardados en esa sección.

### R14 — Idempotencia en concurrencia de marcado

SI ocurren pulsaciones rápidas consecutivas sobre el botón de favorito,  
ENTONCES EL SISTEMA DEBE procesar la acción de forma idempotente sin duplicar registros en la base de datos ni generar inconsistencias de estado en la UI.

### R15 — Optimistic update y feedback interactivo

CUANDO el usuario interactúa con el botón de favorito,  
EL SISTEMA DEBE actualizar el estado visual de la UI de forma optimista e inmediata (< 50ms) y ejecutar una microanimación sutil de escala en el ícono.

## Fuera de alcance (explicito)

- Marcado de favoritos para rutinas planas de intervalos (`Routine` F01/F05).
- Reordenamiento manual tipo drag & drop de favoritos (se ordenan por fecha de marcado).
- Sincronización en la nube de favoritos (reservado para F25/F26 en caso de habilitar cuentas de usuario).
- Menú Speed Dial / FAB compuesto en la pantalla de Entrenamientos.

## Referencias

- Ver `_global/01-vision-and-principles.md` (Principio 2: Cero fricción durante el uso diario; Principio 4: Datos locales).
- Ver `_global/02-architecture-and-structure.md` (Separación de capas, Riverpod y Drift).
- Ver `_global/03-conventions.md` (Principio anti-parches, DRY, UI reutilizable).
- Ver `_global/04-design-system.md` (Tokens de color, espaciado, Filter Chips y microanimaciones).
- Ver `_global/05-data-model.md` (Definición de tabla `favorite_routines` y entidad `FavoriteRoutine`).
