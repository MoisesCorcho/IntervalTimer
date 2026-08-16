# Tasks: Sesiones Preestablecidas con Animación/Video

**ID:** F03 &nbsp;|&nbsp; **Slug:** `03-preset-workout-sessions`

## Definition of Done

- [x] Todos los criterios R1–R11 de `requirements.md` están implementados y verificados. _(cubre R1–R11)_
- [x] Tests unitarios, de widget e integración pasan en local y CI.
- [x] Catálogo inicial de 6 presets validado y empaquetado en `assets/routines/`.
- [x] No se rompieron features previas (verificado con suite de tests de F01).
- [x] Código revisado contra `_global/03-conventions.md`.

---

## Checklist de Implementación

### Capa de Dominio (Domain)

- [x] Definir enums `PresetCategory` y `DifficultyLevel` con mappers `fromId(...)` y valores fallback. _(cubre R10, R11)_
- [x] Definir modelos inmutables `Exercise`, `PresetRoutine` y `PresetExerciseRef`. _(cubre R1, R7)_
- [x] Implementar servicio de dominio `PresetRoutineFlattener` para aplanar `PresetRoutine` a `List<Interval>`. _(cubre R5)_

### Capa de Datos y Assets (Data & Assets)

- [x] Producir y estructurar `assets/routines/exercises.json` (catálogo maestro de ejercicios). _(cubre R1, R4)_
- [x] Producir y estructurar `assets/routines/presets.json` con el catálogo maestro inicial de 6 presets. _(cubre R1, R8)_
- [x] Configurar carpeta `assets/media/` con la jerarquía de imágenes/animaciones y placeholders por categoría. _(cubre R9)_
- [x] Registrar rutas de assets en `pubspec.yaml`. _(cubre R1, R9)_
- [x] Implementar `PresetRepository` e `PresetRepositoryImpl` para la lectura y deserialización de los JSONs. _(cubre R1, R10)_
- [x] Implementar manejo de excepciones en `PresetRepositoryImpl` ante archivos corruptos o faltantes. _(cubre R10)_

### Capa de Aplicación (Application / Riverpod)

- [x] Implementar `presetRepositoryProvider` y `exerciseMapProvider`. _(cubre R1)_
- [x] Implementar `presetCatalogProvider` y `selectedCategoryFilterProvider`. _(cubre R2)_
- [x] Implementar `filteredPresetsProvider` para el filtrado dinámico por categoría. _(cubre R2)_
- [x] Implementar provider o notifier para la acción "Duplicar a Mis Rutinas" integrando `RoutineRepository` (Drift). _(cubre R6)_

### Capa de Presentación (Presentation)

- [x] **Nivel 1 — Pantalla de Catálogo (`PresetCatalogScreen`):**
  - [x] Construir carrusel superior con rutinas destacadas (`isFeatured`). _(cubre R2)_
  - [x] Construir grid interactivo de categorías (`PresetCategory`) con selección y resaltado. _(cubre R2)_
  - [x] Construir tarjetas de rutinas con badges de dificultad, duración total calculada y cantidad de ejercicios. _(cubre R2, R3)_
  - [x] Construir vista de error amigable con botón "Reintentar" ante fallos de carga. _(cubre R10)_
- [x] **Nivel 2 — Pantalla de Detalle (`PresetDetailScreen`):**
  - [x] Construir resumen ejecutivo (título, descripción, categoría, dificultad, duración, ejercicios). _(cubre R3)_
  - [x] Construir lista ordenada de ejercicios con sus series, trabajo, descanso e imágenes miniaturas. _(cubre R3)_
  - [x] Implementar widget de renderizado de imagen con resiliencia y fallback en 3 niveles. _(cubre R9)_
  - [x] Construir Botón Flotante (FAB) prominente "Iniciar Entrenamiento". _(cubre R3, R5)_
  - [x] Agregar opción de menú / acción secundaria "Duplicar a Mis Rutinas". _(cubre R6)_
- [x] **Nivel 3 — Modal de Técnica (`ExerciseTechniqueBottomSheet`):**
  - [x] Construir modal desplegable de técnica con animación/imagen principal. _(cubre R4)_
  - [x] Mostrar instrucciones paso a paso (1, 2, 3...) y consejos de postura (tips). _(cubre R4)_

### Capa de Integración

- [x] Conectar el Botón Flotante de `PresetDetailScreen` con `PresetRoutineFlattener` y pasar los intervalos efímeros a `TimerController` (F01). _(cubre R5)_
- [x] Conectar la acción "Duplicar a Mis Rutinas" con `RoutineRepository` de Drift creando una fila con `source = presetDerived` y `originId = preset.id`. _(cubre R6)_

### Tests

- [x] **Unit — Deserialización y Mappers:** Carga de `exercises.json` y `presets.json`, verificación de tipos e IDs. _(cubre R1, R8, R10)_
- [x] **Unit — Enums & Fallbacks:** Verificación de `fromId(...)` en `PresetCategory` y `DifficultyLevel` ante cadenas desconocidas. _(cubre R11)_
- [x] **Unit — Flattener:** Transformación de `PresetRoutine` a `List<Interval>` verificando secuencia exacta de trabajo y descansos. _(cubre R5)_
- [x] **Unit — Cálculo de Duración:** Validación de `calculateTotalDurationSeconds()` contra los 6 presets del catálogo. _(cubre R3, R8)_
- [x] **Widget — Nivel 1 Catálogo:** Renderizado de carrusel, grid de categorías y filtrado de lista. _(cubre R2)_
- [x] **Widget — Nivel 2 Detalle:** Renderizado de resumen, lista de ejercicios y presencia del FAB. _(cubre R3)_
- [x] **Widget — Nivel 3 Modal:** Despliegue de `ExerciseTechniqueBottomSheet` y visualización de pasos y tips. _(cubre R4)_
- [x] **Widget — Fallback de Media:** Verificación de que ante un path inválido se muestra el placeholder de categoría o el icono del sistema sin crash. _(cubre R9)_
- [x] **Integration — Iniciar Entrenamiento:** Flujo completo desde presionar FAB en Nivel 2 hasta la transición a estado `running` en `TimerController`. _(cubre R5)_
- [x] **Integration — Duplicar Preset:** Flujo de clonación a Drift y verificación de fila insertada en `routines` con `source = presetDerived`. _(cubre R6)_


---

## Mapa de Trazabilidad (Resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Deserialización JSONs, PresetRepository, Modelos |
| R2 | PresetCatalogScreen, Carrusel, Grid de Categorías, Riverpod Providers |
| R3 | PresetDetailScreen, Resumen ejecutivo, Lista de ejercicios, Unit test duración |
| R4 | ExerciseTechniqueBottomSheet, Pasos 1-2-3, Tips, Widget test modal |
| R5 | PresetRoutineFlattener, FAB Iniciar, Carga efímera a TimerController |
| R6 | Duplicar a Mis Rutinas, Inserción en Drift (`presetDerived`), Integration test |
| R7 | Modelos inmutables, UI de solo lectura sin edición directa |
| R8 | Archivo `presets.json` con 6 presets iniciales, Unit tests de carga |
| R9 | Widget de media con fallback 3 niveles, Assets en pubspec, Widget test fallback |
| R10 | Manejo de excepciones en PresetRepository, Vista de error UI, Unit test error |
| R11 | Enums Dart (`PresetCategory`, `DifficultyLevel`), mappers `fromId`, Unit tests |

---

## Notas de Secuenciación

Esta feature depende de: **F01 (Interval Timer Core)**.
No iniciar las tareas de esta feature hasta que F01 se encuentre en estado "Completado".
Orden recomendado: Domain -> Data & Assets -> Application -> Presentation (Nivel 1 -> Nivel 2 -> Nivel 3) -> Integración -> Tests.
