# Design: Repeticion de Circuitos (Rounds)

**ID:** F08 &nbsp;|&nbsp; **Slug:** `08-circuit-repetition-rounds`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F08. Re-ancla el valor de "circuit rounds" al eje **Workout (F32/F34)**, abandonando el diseno historico sobre `Routine` + F05.

Antes de implementar: `_global/02-architecture-and-structure.md`, `_global/03-conventions.md`, `_global/05-data-model.md`, y designs de F32/F34/F35.

## Referencias

- `_global/01-vision-and-principles.md` — workout-first; F05 es eje opcional de intervalos planos.
- `_global/02-architecture-and-structure.md` — `features/workout_builder/`; capas domain/data/presentation.
- `_global/03-conventions.md` — Riverpod unico; tests con `ProviderContainer` y mocks.
- `_global/04-design-system.md` — chips, dialogos, SnackBar, steppers.
- `_global/05-data-model.md` — `WorkoutCircuit`, membresia, aplanado con metadata de ronda.
- `32-workout-exercise-builder/design.md` — editor, repo, `WorkoutFlattener` base.
- `34-exercise-rest-between-and-final/design.md` — dual rest.
- `35-timer-navigation-prep-settings/design.md` — secuencia efectiva y `totalRemainingMs`.
- `33-premium-numeric-steppers/` — `NumberStepper` para rondas.

## Decisiones de diseno

### 1. Eje Workout, no Routine

| Enfoque | Decision |
|---|---|
| `RoutineItem` + `Block` (spec historica F08) | **Descartado** para esta version: acopla F05 y no modela sets/rest declarativos. |
| `circuitRounds` global del workout entero | **Descartado** como unico modelo: menos flexible que bloques; se puede agregar despues si hace falta. |
| `WorkoutCircuit` + ejercicios miembros | **Elegido**: varios circuitos por workout, mezcla con ejercicios sueltos, 1 nivel. |

### 2. Ubicacion de codigo (mismo patron F34)

- **No** crear modulo feature obligatorio `features/circuit_rounds/` en el MVP.
- Extender `features/workout_builder/`:
  - `domain/workout_circuit.dart` (entidad)
  - `domain/workout_flattener.dart` (expansion de rondas + metadata)
  - `domain/` validators de agrupar/rondas
  - `data/` tablas drift + mappers + metodos de `WorkoutRepository`
  - `presentation/` multi-select, card de circuito, sheet de rondas, chip en timer (o callback/metadata leida por pantalla timer en `features/timer/`)
- Si `02-architecture` lista `circuit_rounds/`, tratarla como **reservada/no usada** o actualizar el arbol en el mismo PR de implementacion para no mentir el mapa.

### 3. Modelo de datos

Alineado con `_global/05-data-model.md` (schema **v6** sugerido; el codigo hoy esta en schema 5 por F04).

```dart
class WorkoutCircuit {
  final String id;          // UUID v4
  final String workoutId;   // FK → workouts
  final int position;       // orden entre elementos de nivel superior (0..n-1)
  final int rounds;         // 1..99
}

// WorkoutExercise (F32/F34) + F08:
//   circuitId: String?  — null = ejercicio suelto (top-level)
//   position: int       — si circuitId == null: orden top-level entre sueltos y circuitos
//                         si circuitId != null: orden dentro del circuito (0..k-1)
//   (ver nota de orden top-level abajo)
```

**Orden de nivel superior unificado:**

Una lista logica `List<WorkoutTopLevelItem>`:

```dart
sealed class WorkoutTopLevelItem {
  int get position;
}
class TopLevelExercise extends WorkoutTopLevelItem {
  final WorkoutExercise exercise; // circuitId == null
}
class TopLevelCircuit extends WorkoutTopLevelItem {
  final WorkoutCircuit circuit;
  final List<WorkoutExercise> members; // mismo circuitId, orden por position
}
```

Persistencia:

| Tabla | Cambio F08 |
|---|---|
| `workout_circuits` | **Nueva:** `id`, `workout_id`, `position`, `rounds` |
| `workout_exercises` | + `circuit_id` TEXT NULL FK → `workout_circuits.id` ON DELETE SET NULL o CASCADE controlado |

**Integridad:**

- `workout_circuits.workout_id` → `workouts.id` ON DELETE CASCADE
- `workout_exercises.circuit_id` → `workout_circuits.id` ON DELETE CASCADE (al borrar circuito se puede preferir desagrupar en app antes de delete; si CASCADE, reasignar a sueltos en la misma transaccion de "desagrupar" es preferible a borrar ejercicios)
- **Desagrupar (R5):** en una transaccion: set `circuit_id = null` en miembros, reasignar `position` top-level, delete fila `workout_circuits`
- Indice: `(workout_id, position)` en circuitos; miembros ordenados por `(circuit_id, position)`
- Constraint de app: un ejercicio pertenece a **como maximo** un circuito; `circuit_id` null o un id

**Nota de `position` dual:**

Para evitar ambiguedad entre position top-level de ejercicios sueltos y position dentro de circuito:

- **Opcion A (recomendada):** tabla `workout_circuits` tiene `position` top-level; ejercicios con `circuit_id != null` usan `position` solo intra-circuito; ejercicios sueltos usan `position` en el mismo espacio top-level que los circuitos (0..n-1 compartido entre sueltos y circuitos).
- Al construir la lista top-level: unir ejercicios sueltos + circuitos, ordenar por `position`.

### 4. Algoritmo de aplanado (R9–R11)

Extender `WorkoutFlattener` (logica pura, sin Flutter).

```dart
class FlattenedInterval {
  final Interval interval;
  final int? roundIndex;   // 1-based; null si no es de circuito
  final int? roundCount;   // null si no es de circuito
  final String? circuitId;
}

List<FlattenedInterval> flattenWorkoutWithRounds(Workout workout, { ...colors }) {
  final topLevel = buildTopLevel(workout); // ejercicios sueltos + circuitos ordenados
  final out = <FlattenedInterval>[];

  for (var i = 0; i < topLevel.length; i++) {
    final item = topLevel[i];
    final hasNextTopLevel = i < topLevel.length - 1;

    if (item is TopLevelExercise) {
      out.addAll(flattenExercise(
        item.exercise,
        emitFinalRest: hasNextTopLevel,
        roundIndex: null,
        roundCount: null,
        circuitId: null,
      ));
    } else if (item is TopLevelCircuit) {
      final members = item.members;
      final R = item.circuit.rounds;
      for (var r = 1; r <= R; r++) {
        for (var e = 0; e < members.length; e++) {
          final isLastMember = e == members.length - 1;
          final isLastRound = r == R;
          // Hay "siguiente trabajo" distinto del mismo ejercicio?
          final hasNext =
              !isLastMember ||
              !isLastRound ||
              hasNextTopLevel;
          out.addAll(flattenExercise(
            members[e],
            emitFinalRest: hasNext && /* F34: restAfter > 0 handled inside */,
            // emitFinalRest true solo si hay siguiente work no-set del mismo ejercicio
            // y se aplica la regla F34 de restAfterExerciseSeconds
            roundIndex: r,
            roundCount: R,
            circuitId: item.circuit.id,
          ));
        }
      }
    }
  }
  return out;
}
```

**`flattenExercise` (por ejercicio):**

1. Por set `s = 1..sets`:
   - emitir `work` con metadata de ronda del contexto
   - si `s < sets` y `restSeconds > 0`: emitir `rest` "Descanso" con misma metadata de ronda
2. Tras ultimo set: si `emitFinalRest` y `restAfterExerciseSeconds > 0`: emitir `rest` "Descanso entre ejercicios" con misma metadata

**Casos de `emitFinalRest` dentro del circuito:**

| Situacion | emitFinalRest |
|---|---|
| Miembro no ultimo en la ronda | `true` (si restAfter > 0) |
| Ultimo miembro, ronda `r < R` | `true` (puente a la siguiente ronda) |
| Ultimo miembro, ultima ronda, hay siguiente top-level | `true` |
| Ultimo miembro, ultima ronda, fin de workout | `false` (F34 fin de sesion) |

**Contrato con F01:**

- Convertir `List<FlattenedInterval>` → `List<Interval>` para `loadFlattenedWorkout`.
- Conservar metadata en paralelo (lista espejo o mapa `intervalId → RoundMeta`) en el controller o en un holder de sesion para que la UI de timer lea `roundIndex/roundCount` del intervalo actual (R12).
- No persistir la secuencia expandida.

**Contrato con F35:**

- `totalRemainingMs` suma duraciones de la lista expandida (R13).
- Skip back/forward recorre la lista expandida (incluye cambios de ronda).
- Prep se aplica una vez al inicio sobre esa lista.

### 5. Persistencia y repositorio

Extender `WorkoutRepository` (no repo nuevo):

| Metodo | Comportamiento |
|---|---|
| `groupIntoCircuit(workoutId, exerciseIds, {rounds})` | Valida ≥2, todos sueltos, mismo workout; crea `WorkoutCircuit`; asigna `circuit_id`; reordena posiciones (R2, R17, R19) |
| `updateCircuitRounds(circuitId, rounds)` | Clamp/validar 1–99 (R4, R18) |
| `ungroupCircuit(circuitId)` | Transaccion desagrupar (R5) |
| `reorderTopLevel(...)` | Actualiza positions de sueltos + circuitos (R7) |
| `reorderWithinCircuit(circuitId, orderedExerciseIds)` | R6 |
| `getWorkout(id)` | Incluye circuitos + miembros |
| `duplicateWorkout` | Copia circuitos con nuevos IDs (R14) |

Errores de drift → superficie UI R20.

### 6. UI / UX

#### Editor (`WorkoutEditorScreen` — F32)

- App bar o boton: **Seleccionar** → modo multi-select con checkboxes (R1).
- Bottom bar en modo seleccion: CTA primario **Agrupar en circuito** (disabled si &lt; 2).
- Card de circuito (R3):
  - header: icono loop + "Circuito" + `NumberStepper` o chip tappable "Rondas: N"
  - body: lista de ejercicios miembros (mismo row widget F32)
  - menu: Desagrupar, (opcional) Editar rondas
- Sheet **Configurar circuito** (R4): `NumberStepper` 1–99, helper text, Cancelar / Guardar.
- Desagrupar: confirmacion ligera o directa; si dialogo, R22.

#### Timer (F01/F35 presentation)

- Bajo el nombre del intervalo (o chip superior): **Ronda X de Y** solo si metadata presente (R12).
- No rediseñar el layout F35 completo; agregar un slot de texto/chip.

#### Mis entrenamientos (R16)

- Badge sutil si `circuits.isNotEmpty`.

### 7. Migracion drift (schema v6)

1. Crear `workout_circuits`.
2. Agregar `workout_exercises.circuit_id` NULL.
3. Workouts existentes: sin filas de circuito → R15.

No tocar tablas `routines` / `routine_items` / `Block` historico.

### 8. Estado Riverpod

- Extender providers del editor de workout (selection mode, selected ids).
- Providers de detalle de workout deben emitir circuitos + miembros.
- No nuevo `CircuitController` global de sesion: la metadata viaja con la sesion del timer al cargar.

## Diagrama de flujo (alto nivel)

```
[Editor F32: multi-select ejercicios]
        |
        v
[Agrupar en circuito] --> [WorkoutRepository.groupIntoCircuit]
        |                           |
        v                           v
[UI: card Circuito + rounds]   [drift: workout_circuits + circuit_id]
        |
        v
[Usuario: Entrenar]
        |
        v
[WorkoutFlattener.flattenWorkoutWithRounds]
        |  expande rondas + rest F32/F34 + RoundMeta
        v
[TimerController.loadFlattenedWorkout + meta]
        |
        +--> [UI timer: "Ronda X de Y"]
        +--> [F35: totalRemainingMs sobre lista expandida]
        +--> [F01: play/pause/skip sobre lista lineal]
```

## Riesgos y consideraciones

- **Orden top-level compartido** entre sueltos y circuitos: tests de reordenar son criticos.
- **Desagrupar vs CASCADE:** preferir logica de app que preserve ejercicios; no borrar miembros al desagrupar.
- **Duplicar workout:** mapear oldCircuitId → newCircuitId al copiar miembros.
- **Performance:** expansion de rondas en memoria (ej. 10 ejercicios × 10 sets × 20 rondas) sigue siendo pequena frente a UI; no optimizar prematuro.
- **Compatibilidad F04:** `SessionCompletedEvent.routineId` sigue siendo `workoutId`; no requiere circuit id en el log MVP.
- **Regresion F32/F34:** workout sin circuitos debe producir la misma secuencia de intervalos (nombres/tipos/duraciones) que antes de F08 (salvo IDs efimeros).

## Alternativas consideradas

| Alternativa | Por que se descarto |
|---|---|
| Prerequisito F05 + builder de intervalos | Producto workout-first; F05 no aporta al valor de circuitos con sets. |
| Opcion "Crear circuito" en menu de card del listado + pantalla nueva | Duplica el concepto de edicion; mas friccion; confunde con F05. |
| Rondas solo como multiplo del workout entero | No permite "circuito A×3 + ejercicio suelto de enfriamiento". |
| Reutilizar `Routine.Block` para sets | Sets ya modelados en F32; Block no es declarativo work/rest por ejercicio. |
| Segundo editor de descansos del circuito | Duplica F34; decision de producto: heredar tiempos. |
| Modulo feature `circuit_rounds/` aislado | F34 demostro que extender `workout_builder` reduce boilerplate y acopla mejor al flattener. |

## Contratos observables

| Contrato | Productor | Consumidor |
|---|---|---|
| `List<FlattenedInterval>` / meta de ronda al cargar | `WorkoutFlattener` + load path F32 | Timer presentation (R12), F35 remaining (R13) |
| Workout aggregate con circuitos | `WorkoutRepository.watch/get` | Editor UI |
| Errores de persistencia | Repository | SnackBar R20 |

No se agregan nuevos eventos de sesion F01 en el MVP.
