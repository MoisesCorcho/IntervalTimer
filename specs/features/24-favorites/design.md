# Design: Favoritos

**ID:** F24 &nbsp;|&nbsp; **Slug:** `24-favorites`

## Contexto

Este documento define la arquitectura y el diseño técnico para implementar el sistema de favoritos (F24) según los requerimientos de `requirements.md`.
Alineado con `_global/02-architecture-and-structure.md`, `_global/03-conventions.md` (Principio Anti-Parches) y `_global/05-data-model.md`.

## Decisiones de Arquitectura y Persistencia

1. **Entidad de Dominio e Inmutabilidad (`data/models/favorite_routine.dart`):**
   - Se crea la entidad inmutable `FavoriteRoutine` con campos tipados: `id` (UUID v4), `targetId` (String), `targetType` (`FavoriteTargetType` enum: `preset`, `workout`) y `createdAt` (`DateTime` UTC).
2. **Tabla Drift tipada (`data/local/tables/favorite_routines_table.dart`):**
   - Tabla `favorite_routines` con columnas:
     - `id`: TEXT PK (UUID v4)
     - `target_id`: TEXT NOT NULL
     - `target_type`: TEXT NOT NULL ('preset' | 'workout')
     - `created_at`: INTEGER NOT NULL (ms epoch UTC)
   - Índice compuesto único en `(target_id, target_type)` para garantizar idempotencia e integridad referencial lógica.
3. **Repositorio Unificado (`FavoriteRepository`):**
   - Expone métodos declarativos y reactivos basados en `Stream`:
     - `Stream<Set<String>> watchFavoriteTargetIds()`: Permite a los widgets saber si un ID dado es favorito en O(1).
     - `Stream<List<FavoriteRoutine>> watchAllFavorites()`: Retorna todos los favoritos ordenados por `created_at DESC`.
     - `Future<void> toggleFavorite({required String targetId, required FavoriteTargetType targetType})`: Transacción segura de inserción/eliminación.
     - `Future<void> deleteByTargetId(String targetId)`: Utilizado para borrado en cascada al eliminar un entrenamiento (Workout).
4. **Hidratación Reactiva de Modelos para la UI (`FavoriteHydrator` / Provider):**
   - Para la sección de Home, un provider combina el stream de `FavoriteRoutine` con el catálogo de `PresetCatalogRepository` (assets) y `WorkoutRepository` (Drift), generando una lista polimórfica `FavoriteDisplayItem` ordenada por `createdAt DESC`.
5. **Reutilización y Separación de Capas:**
   - Botón genérico `FavoriteToggleButton` en `shared/widgets/favorite_toggle_button.dart` con microanimación de escala y manejo de estado optimista vía Riverpod.

## Modelo de Datos

### Enum de Dominio
```dart
enum FavoriteTargetType {
  preset,
  workout,
}
```

### Entidad de Dominio
```dart
@freezed
class FavoriteRoutine with _$FavoriteRoutine {
  const factory FavoriteRoutine({
    required String id,
    required String targetId,
    required FavoriteTargetType targetType,
    required DateTime createdAt,
  }) = _FavoriteRoutine;
}
```

### Modelo de Presentación Polimórfico (Home & Cards)
```dart
sealed class FavoriteDisplayItem {
  final String id;
  final String title;
  final String subtitle;
  final FavoriteTargetType targetType;
  final DateTime favoritedAt;

  const FavoriteDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.targetType,
    required this.favoritedAt,
  });
}

class PresetFavoriteItem extends FavoriteDisplayItem {
  final PresetRoutine preset;
  PresetFavoriteItem({required this.preset, required super.favoritedAt})
      : super(
          id: preset.id,
          title: preset.title,
          subtitle: preset.category.displayName,
          targetType: FavoriteTargetType.preset,
        );
}

class WorkoutFavoriteItem extends FavoriteDisplayItem {
  final Workout workout;
  WorkoutFavoriteItem({required this.workout, required super.favoritedAt})
      : super(
          id: workout.id,
          title: workout.name,
          subtitle: '${workout.exercises.length} ejercicios · ${workout.rounds} rondas',
          targetType: FavoriteTargetType.workout,
        );
}
```

### Tabla Drift
```dart
class FavoriteRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get targetId => text()();
  TextColumn get targetType => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {targetId, targetType},
  ];
}
```

## Arquitectura de Providers (Riverpod)

```
[FavoriteRepository] (drift_favorite_repository.dart)
       |
       v
[favoriteIdsStreamProvider] -> Stream<Set<String>> (IDs activos en memoria)
       |
       +---> [isFavoriteProvider.family(id)] -> bool (O(1) para ToggleButtons)
       |
       v
[homeFavoritesProvider] -> FutureProvider / StreamProvider<List<FavoriteDisplayItem>>
  (Cruza FavoriteRoutine con PresetCatalogRepository y WorkoutRepository)
```

## Diagrama de Flujo: Toggle de Favorito e Hidratación en Home

```
[Usuario presiona FavoriteToggleButton]
              |
              v (Optimistic UI update)
[FavoriteToggleButton invoca favoriteController.toggle(targetId, type)]
              |
              v
[FavoriteRepository ejecuta transaccion Drift]
  - Si existe (target_id, type) -> DELETE
  - Si no existe               -> INSERT (UUID, target_id, type, now_utc)
              |
              v
[Drift emite nuevo stream en FavoriteRoutines]
              |
              +-----------------------------------+
              |                                   |
              v                                   v
[favoriteIdsStreamProvider se actualiza]  [homeFavoritesProvider se recalcula]
              |                                   |
              v                                   v
[Todos los ToggleButtons sincronizados]    [Home actualiza / oculta carrusel]
```

## Riesgos, Mitigaciones y Causa Raíz

1. **Riesgo: Entidad Workout borrada dejando favorito huérfano:**
   - **Solución Causa Raíz:** Al llamar a `WorkoutRepository.deleteWorkout(id)`, dentro de la misma transacción o método de repositorio se invoca `FavoriteRepository.deleteByTargetId(id)`. Adicionalmente, `homeFavoritesProvider` descarta de forma defensiva cualquier registro cuyo workout o preset no exista.
2. **Riesgo: Presets estáticos modificados o eliminados en assets:**
   - **Solución Causa Raíz:** `homeFavoritesProvider` realiza un filtrado de existencia contra el catálogo en memoria. Si un preset ya no existe en los assets empaquetados, se ignora limpiamente y se purga el registro huérfano.
3. **Riesgo: Parpadeo visual en botones de favorito al hacer scroll:**
   - **Solución Causa Raíz:** El provider `favoriteIdsStreamProvider` mantiene un `Set<String>` en memoria. Cada `FavoriteToggleButton` consulta `ref.watch(isFavoriteProvider(id))` con complejidad O(1) sin disparar consultas SQL individuales por tarjeta.

## Alternativas Descartadas

- **Campo `is_favorite` booleano dentro de las tablas `workouts` y JSON de presets:**
  - *Descartada:* Los presets son assets JSON de solo lectura y no pueden modificarse en runtime; agregar columnas booleanas dispersas viola la separación de responsabilidades y dificulta consultas consolidadas para la pantalla Home.
- **Speed Dial / Menú desplegable en el FAB de Entrenamientos:**
  - *Descartada:* Viola las guías de UX móvil y Material Design al mezclar una acción de creación (constructiva) con un modo de visualización/filtro, penalizando la acción principal con doble tap.
