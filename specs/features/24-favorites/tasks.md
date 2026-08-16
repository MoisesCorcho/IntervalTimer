# Tasks: Favoritos

**ID:** F24 &nbsp;|&nbsp; **Slug:** `24-favorites`

## Definition of Done

- [x] Todos los criterios de aceptación R1 a R15 de `requirements.md` están implementados y verificados.
- [x] Tests unitarios de modelos, repositorio y providers pasando al 100%.
- [x] Tests de widget para `FavoriteToggleButton`, Filter Chip en listas y sección de Home pasando.
- [x] Cumplimiento estricto del Principio Anti-Parches de `_global/03-conventions.md`.
- [x] Documentación de persistencia reflejada en `_global/05-data-model.md`.
- [x] No se rompió ninguna funcionalidad de las features previas (F03, F32).

## Checklist de implementacion

### 1. Capa de Datos y Modelos (Data & Models)
- [x] Crear entidad de dominio `FavoriteRoutine` y enum `FavoriteTargetType` en `lib/data/models/favorite_routine.dart`. _(cubre R1, R3, R5)_
- [x] Definir tabla Drift `FavoriteRoutines` en `lib/data/local/tables/favorite_routines_table.dart`. _(cubre R5, R14)_
- [x] Registrar tabla en `AppDatabase` (`database.dart`) y configurar migración de esquema. _(cubre R5)_
- [x] Implementar interfaz `FavoriteRepository` y su clase concreta `DriftFavoriteRepository` con soporte para streams reactivos y borrado por target ID. _(cubre R1, R2, R3, R4, R5, R10, R12, R14)_

### 2. Capa de Aplicación y Lógica (Application & State)
- [x] Crear providers de Riverpod (`favoriteRepositoryProvider`, `favoriteIdsStreamProvider`, `isFavoriteProvider`) en `lib/features/favorites/application/favorite_providers.dart`. _(cubre R1, R2, R3, R4, R14, R15)_
- [x] Implementar `HomeFavoritesNotifier` / `homeFavoritesProvider` para hidratar polimórficamente `PresetFavoriteItem` y `WorkoutFavoriteItem` ordenados por `created_at DESC`. _(cubre R6, R7, R10, R11)_
- [x] Implementar borrado en cascada en `WorkoutRepository.deleteWorkout` invocando la limpieza en `FavoriteRepository`. _(cubre R12)_

### 3. Componentes Compartidos y UI (Presentation & Widgets)
- [x] Crear widget reutilizable `FavoriteToggleButton` con estrella (`Icons.star` / `Icons.star_border`), microanimación de escala y optimistic update en `lib/shared/widgets/favorite_toggle_button.dart`. _(cubre R1, R2, R3, R4, R14, R15)_
- [x] Integrar `FavoriteToggleButton` en las tarjetas y vista de detalle de Presets (F03). _(cubre R1, R2)_
- [x] Integrar `FavoriteToggleButton` en las tarjetas y vista de detalle de Entrenamientos (F32). _(cubre R3, R4)_
- [x] Agregar Filter Chip `[ ★ Favoritos ]` en la cabecera del catálogo de Presets (`PresetCatalogScreen`). _(cubre R8, R13)_
- [x] Agregar Filter Chip `[ ★ Favoritos ]` en la cabecera de la lista de Entrenamientos (`WorkoutsScreen`) manteniendo el FAB exclusivo para creación. _(cubre R9, R13)_
- [x] Implementar `HomeFavoritesSection` (carrusel horizontal) en `HomeScreen` con navegación directa al entrenamiento/preset. _(cubre R6, R7, R10, R11)_
- [x] Implementar estado vacío ilustrado cuando el filtro de favoritos está activo y no hay resultados en las listas. _(cubre R13)_

### 4. Tests y Validación (Testing)
- [x] **Unit Tests (Data & Repository):**
  - [x] Test de toggle de favorito (insertar y eliminar) en base de datos Drift en memoria. _(cubre R1, R2, R3, R4, R5)_
  - [x] Test de ordenamiento cronológico inverso (`created_at DESC`). _(cubre R10)_
  - [x] Test de idempotencia ante llamadas concurrentes rápidas. _(cubre R14)_
  - [x] Test de borrado en cascada al eliminar un Workout. _(cubre R12)_
- [x] **Unit Tests (Application Providers):**
  - [x] Test de `homeFavoritesProvider` hidratando presets y workouts combinados. _(cubre R6, R10)_
  - [x] Test de omisión/limpieza de elementos huérfanos en `homeFavoritesProvider`. _(cubre R12)_
- [x] **Widget Tests (UI):**
  - [x] Test de interacción con `FavoriteToggleButton` (cambio inmediato de ícono y estado). _(cubre R1, R2, R15)_
  - [x] Test de filtrado por Filter Chip en `PresetCatalogScreen` y `WorkoutsScreen`. _(cubre R8, R9, R13)_
  - [x] Test de visibilidad condicional de `HomeFavoritesSection` (oculto con 0 favoritos, visible con >= 1). _(cubre R6, R7)_

## Mapa de trazabilidad

| Criterio EARS | Tareas que lo cubren |
|---|---|
| **R1** (Marcar Preset) | Data (1.1, 1.4), App (2.1), UI (3.1, 3.2), Tests (4.1, 4.3) |
| **R2** (Desmarcar Preset) | Data (1.4), App (2.1), UI (3.1, 3.2), Tests (4.1, 4.3) |
| **R3** (Marcar Workout) | Data (1.1, 1.4), App (2.1), UI (3.1, 3.3), Tests (4.1) |
| **R4** (Desmarcar Workout) | Data (1.4), App (2.1), UI (3.1, 3.3), Tests (4.1) |
| **R5** (Persistencia Drift) | Data (1.1, 1.2, 1.3, 1.4), Tests (4.1) |
| **R6** (Sección Home) | App (2.2), UI (3.6), Tests (4.2, 4.3) |
| **R7** (Ocultar Home vacío) | App (2.2), UI (3.6), Tests (4.3) |
| **R8** (Filtro en Presets) | UI (3.4), Tests (4.3) |
| **R9** (Filtro en Workouts) | UI (3.5), Tests (4.3) |
| **R10** (Orden cronológico) | Data (1.4), App (2.2), UI (3.6), Tests (4.1, 4.2) |
| **R11** (Inicio directo Home) | App (2.2), UI (3.6) |
| **R12** (Borrado en cascada) | Data (1.4), App (2.3), Tests (4.1, 4.2) |
| **R13** (Estado vacío en filtros) | UI (3.4, 3.5, 3.7), Tests (4.3) |
| **R14** (Idempotencia) | Data (1.2, 1.4), App (2.1), UI (3.1), Tests (4.1) |
| **R15** (Optimistic UI & Feedback) | App (2.1), UI (3.1), Tests (4.3) |

## Notas de secuenciacion

Esta feature depende de: **F03** (Sesiones Preestablecidas) y **F32** (Constructor de Entrenamientos por Ejercicios).
No iniciar tareas de implementación en código hasta que ambos prerrequisitos estén en estado "Done".
