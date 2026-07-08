# Requirements: Editor de Rutinas Propias

> Estado: No iniciada

**ID:** F05 &nbsp;|&nbsp; **Slug:** `05-custom-routine-builder` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Biblioteca multi-rutina del usuario: crear, editar, duplicar (incluidos presets de F03), reordenar intervalos y eliminar rutinas propias. Reutiliza la estructura de intervalos de F01 y el catalogo de presets empaquetados de F03 como fuente de duplicacion (sin modificar assets).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F03 - Sesiones Preestablecidas con Animacion/Video

## Postrequisitos (features que dependen de esta)

- F08 - Repeticion de Circuitos (Rounds)
- F09 - Progresion Automatica
- F11 - Ajuste Rapido de Intensidad
- F24 - Favoritos
- F25 - Compartir Rutinas con Otros Usuarios

## User Stories

- **Como** usuario, **quiero** ver y gestionar mis rutinas propias en una biblioteca, **para que** puedo alternar entre distintos entrenamientos sin rearmarlos cada vez.
- **Como** usuario, **quiero** crear una rutina desde cero agregando y ordenando intervalos, **para que** puedo adaptar la app a mi entrenamiento personal.
- **Como** usuario, **quiero** duplicar y modificar una rutina preestablecida o propia, **para que** no tengo que empezar de cero cada vez.
- **Como** usuario, **quiero** seleccionar una rutina de mi biblioteca como activa para el timer, **para que** puedo entrenar con la rutina que elijo.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Listado de rutinas propias

DONDE el usuario esta en la pantalla **Mis rutinas**, EL SISTEMA DEBE mostrar todas las rutinas persistidas con `source` distinto de preset empaquetado (es decir, rutinas `custom` y `presetDerived`), ordenadas por `updatedAt` descendente, mostrando nombre y cantidad de intervalos de cada una.

### R2 — Crear rutina vacia

DONDE el usuario esta en la pantalla **Mis rutinas**, CUANDO el usuario inicia la creacion de una rutina nueva con un nombre no vacio (maximo 80 caracteres), EL SISTEMA DEBE crear una rutina persistida con lista de intervalos vacia, `source = custom`, y abrir la pantalla de edicion (builder) de esa rutina.

### R3 — Agregar, editar y eliminar intervalos en el builder

DONDE el usuario esta en la pantalla de edicion de una rutina propia, CUANDO agrega, modifica o elimina intervalos usando el formulario reutilizado de F01 (nombre, duracion mm:ss, color), EL SISTEMA DEBE aplicar los cambios en memoria y persistirlos al confirmar guardado de la rutina, respetando las validaciones de intervalo de F01 (R11, R12).

### R4 — Reordenar intervalos

DONDE el usuario esta en la pantalla de edicion de una rutina propia, CUANDO reordena intervalos mediante arrastre en la lista, EL SISTEMA DEBE actualizar el orden (`position`) y persistir el nuevo orden en la base de datos local en el mismo gesto (sin accion "Guardar orden" adicional).

### R5 — Guardar rutina con intervalos

DONDE el usuario esta en la pantalla de edicion de una rutina propia, CUANDO confirma guardar una rutina con al menos un intervalo valido, EL SISTEMA DEBE persistir nombre, intervalos y `updatedAt` (UTC) y regresar a **Mis rutinas** mostrando la rutina actualizada.

### R6 — Duplicar rutina propia

DONDE el usuario esta en la pantalla **Mis rutinas** o en el detalle de una rutina propia, CUANDO el usuario duplica una rutina `custom` o `presetDerived`, EL SISTEMA DEBE crear una copia persistida independiente con nombre `"Copia de {nombre}"` (agregando sufijo numerico ` (2)`, ` (3)`, etc. si ya existe conflicto), copiar todos los intervalos con nuevos IDs, asignar `source = custom` y `originId = null`, y abrir el builder de la copia.

### R7 — Duplicar rutina preestablecida

DONDE el usuario esta en el catalogo de presets (F03), CUANDO el usuario elige duplicar una rutina preestablecida, EL SISTEMA DEBE mapear su estructura de intervalos a una rutina persistida nueva con `source = presetDerived`, `originId` igual al `id` del `PresetRoutine` de origen, nombre por defecto `"Copia de {nombre}"` (con sufijo numerico si hay conflicto), y abrir el builder de la copia sin modificar el JSON ni assets del preset original.

### R8 — Edicion de preset sin mutar el original

CUANDO el usuario edita una rutina con `source = presetDerived` o inicia edicion desde un preset de F03, EL SISTEMA DEBE operar unicamente sobre la copia persistida en drift; el contenido empaquetado del preset (assets/JSON) DEBE permanecer inalterado.

### R9 — Seleccionar rutina activa para el timer

DONDE el usuario esta en **Mis rutinas**, CUANDO el usuario selecciona "Usar" sobre una rutina propia con al menos un intervalo, EL SISTEMA DEBE establecer esa rutina como rutina activa del timer (ver `design.md`), cargar sus intervalos en `TimerController` (F01) en estado `idle`, y navegar a la pantalla de creacion/ejecucion de F01.

### R10 — Eliminar rutina propia

DONDE el usuario esta en **Mis rutinas**, CUANDO el usuario solicita eliminar una rutina propia, EL SISTEMA DEBE mostrar un dialogo de confirmacion destructiva segun `_global/04-design-system.md` (accion destructiva separada de cancelar) y, solo si el usuario confirma, eliminar la rutina y sus intervalos referenciados de drift.

### R11 — Renombrar rutina

DONDE el usuario esta en la pantalla de edicion de una rutina propia, CUANDO el usuario modifica el nombre y guarda con un valor no vacio de hasta 80 caracteres, EL SISTEMA DEBE persistir el nuevo nombre y actualizar `updatedAt`.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R12 — Guardar rutina sin intervalos

DONDE el usuario esta en la pantalla de edicion de una rutina propia, CUANDO intenta guardar sin al menos un intervalo en la lista, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir cambios parciales de intervalos.

### R13 — Nombre de rutina invalido

CUANDO el usuario intenta crear o renombrar una rutina con nombre vacio, solo espacios en blanco, o longitud superior a 80 caracteres, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin crear ni renombrar la rutina.

### R14 — Error de persistencia

CUANDO una operacion de guardado, reordenamiento o eliminacion falla por error de la base de datos local, EL SISTEMA DEBE mostrar un SnackBar con mensaje claro y opcion de reintentar, sin dejar la UI en un estado inconsistente respecto a lo persistido (ver `_global/04-design-system.md`).

### R15 — Eliminar durante sesion activa

CUANDO el temporizador esta en estado `running` o `paused`, EL SISTEMA DEBE impedir eliminar cualquier rutina (incluida la activa) y mostrar un mensaje indicando que debe finalizar o cancelar la sesion primero.

### R16 — Cancelar eliminacion

DONDE el usuario esta en el dialogo de confirmacion de eliminacion de rutina, CUANDO el usuario cancela o cierra el dialogo, EL SISTEMA DEBE mantener la rutina sin cambios.

### R17 — Eliminar rutina activa en idle

CUANDO el usuario elimina en estado `idle` la rutina que coincide con `activeRoutineId`, EL SISTEMA DEBE borrar la rutina, limpiar `activeRoutineId`, y mostrar en la pantalla de F01 un estado de rutina vacia con CTA para crear o elegir otra rutina (patron estado vacio de `_global/04-design-system.md`).

### R18 — Usar rutina sin intervalos

DONDE el usuario esta en **Mis rutinas**, CUANDO intenta seleccionar "Usar" sobre una rutina con cero intervalos, EL SISTEMA DEBE impedir la accion y mostrar un mensaje indicando que la rutina necesita al menos un intervalo.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Rutina activa vs biblioteca | `activeRoutineId` (UUID) en `shared_preferences`. F01 sigue editando/ejecutando la rutina activa; F05 gestiona la biblioteca y el cambio de activa via R9. |
| Migracion desde F01 | Al implementar F05, la rutina unica existente de F01 se marca `source = custom` sin `originId`. No se pierden datos. |
| Nombre al duplicar | `"Copia de {nombre}"`; si existe, `"Copia de {nombre} (2)"`, `(3)`, etc. |
| `originId` | `String?` — cuando `source = presetDerived`, guarda el `id` del `PresetRoutine` en assets (UUID v4). |
| Persistencia del reordenamiento | Inmediata al soltar (R4); no requiere boton adicional. |
| Contenido copiado al duplicar preset | Solo estructura de intervalos (`Interval` / `RoutineItem`); metadata de ejercicios/media de F03 no se persiste en drift en F05. |
| Presets en biblioteca | Los presets empaquetados (F03) no aparecen en **Mis rutinas**; solo rutinas drift del usuario. Duplicar preset crea entrada `presetDerived`. |
| Limite de rutinas Pro (F06) | Fuera de alcance de F05; F06 puede gatear creacion/duplicacion posteriormente sin cambiar contratos de datos. |
| Edicion durante ejecucion | Igual que F01: edicion de rutina/intervalos solo con timer en `idle`. |
| F05 vs F32 | **F05** = rutinas con intervalos planos (**Mis rutinas**). **F32** = entrenamientos con ejercicios, sets y duracion trabajo/descanso (**Mis entrenamientos**). Coexisten; no implementar sets ni modelo ejercicio en F05. |

## Fuera de alcance (explicito)

- Modelo ejercicio + sets + duracion trabajo/descanso por ejercicio (responsabilidad de **F32** — `32-workout-exercise-builder`).
- Modificar o eliminar presets empaquetados (assets de F03).
- Agrupar intervalos en bloques / rounds (F08).
- Asociar ejercicios con media a intervalos en rutinas custom (solo nombres/duraciones/colores como F01).
- Limite de cantidad de rutinas por tier Pro (F06).
- Historial de sesiones (F04).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — delimitacion F01 vs F05; biblioteca multi-rutina.
- `_global/02-architecture-and-structure.md` — `features/routine_builder/`, drift, Riverpod, go_router.
- `_global/03-conventions.md` — formato EARS, testing, providers.
- `_global/04-design-system.md` — confirmacion destructiva, estados vacio/error, validacion inline.
- `_global/05-data-model.md` — entidades `Routine`, `RoutineItem`, `PresetRoutine`; schema F05.
- `32-workout-exercise-builder/requirements.md` (F32) — entrenamientos estructurados; delimitacion frente a F05.