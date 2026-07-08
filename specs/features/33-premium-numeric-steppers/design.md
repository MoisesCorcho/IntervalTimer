# Design: Controles Numericos y de Duracion (Steppers Premium)

**ID:** F33 &nbsp;|&nbsp; **Slug:** `33-premium-numeric-steppers`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias.

F33 no introduce dominio ni persistencia: solo widgets compartidos y migracion de formularios F01/F32 que hoy usan `TextField` + `parseDurationMmSs`.

## Referencias

- `_global/01-vision-and-principles.md` — friccion minima en configuracion.
- `_global/02-architecture-and-structure.md` — `lib/shared/widgets/`, features `timer` y `workout_builder`.
- `_global/03-conventions.md` — Riverpod solo para estado de app; widgets presentacionales con `setState`/callbacks locales permitidos.
- `_global/04-design-system.md` — tokens, 48dp, registrar `NumberStepper` / `DurationStepper`.
- `_global/05-data-model.md` — sin cambios; consumir enteros existentes.
- `features/01-interval-timer-core/design.md` — formulario intervalo.
- `features/32-workout-exercise-builder/design.md` — formulario ejercicio.

## Decisiones de diseno

### Modelo de datos

**Ninguno nuevo.** Los valores siguen siendo:

| Contexto | Campo | Tipo |
|---|---|---|
| F32 ejercicio | `sets` | `int` 1–99 |
| F32 ejercicio | `workSeconds` | `int` 1–5999 |
| F32 ejercicio | `restSeconds` | `int` 0–5999 |
| F01 intervalo | `durationSeconds` | `int` 1–5999 |

No migracion drift. No actualizar `05-data-model.md` por entidades.

### Ubicacion de codigo

```
lib/shared/widgets/
  number_stepper.dart
  duration_stepper.dart

lib/features/workout_builder/presentation/widgets/
  exercise_form.dart          # migrar sets / work / rest

lib/features/timer/presentation/widgets/
  interval_form.dart          # migrar duration

lib/core/utils/
  duration_parser.dart        # reutilizar formatDurationMmSs (y parse solo si queda legacy)

lib/core/constants/
  ui_strings.dart             # labels / semantics; ajustar textos "mm:ss" si ya no se tipea
```

Logica de clamp/step **pura** (funciones top-level o clase sin Flutter) en el mismo archivo del widget o en `core/utils/stepper_math.dart` si se testea unitariamente sin binding de UI:

```dart
int clampStep({
  required int value,
  required int delta,
  required int min,
  required int max,
}) {
  final next = value + delta;
  if (next < min) return min;
  if (next > max) return max;
  return next;
}

bool canApplyStep({
  required int value,
  required int delta,
  required int min,
  required int max,
}) {
  final next = value + delta;
  return next >= min && next <= max;
}
```

### NumberStepper (API)

Widget presentacional controlado por el padre (`value` + `onChanged`):

```dart
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.step = 1,
    this.label,
    this.semanticsLabel,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? label;
  final String? semanticsLabel;
}
```

- Boton −: `onChanged(clampStep(..., delta: -step))` si `canApplyStep`; si no, `onPressed: null`.
- Boton +: analogo con `+step`.
- Valor centrado, tipografia tabular si es numerica.
- Keys de test sugeridas: `number_stepper_decrement`, `number_stepper_increment`, `number_stepper_value` (o prefix por label).

### DurationStepper (API)

```dart
class DurationStepper extends StatelessWidget {
  const DurationStepper({
    super.key,
    required this.totalSeconds,
    required this.onChanged,
    required this.minSeconds,
    required this.maxSeconds,
    this.minuteStep = 1,
    this.secondStep = 5,
    this.label,
  });

  final int totalSeconds;
  final ValueChanged<int> onChanged;
  final int minSeconds;
  final int maxSeconds;
  final int minuteStep; // en minutos → delta = minuteStep * 60
  final int secondStep; // en segundos
  final String? label;
}
```

Layout sugerido (premium, no TextField):

```
┌─ label ──────────────────────────────────────┐
│  [ − ]  mm  [ + ]     [ − ]  ss  [ + ]       │
│              01:05  (display tabular)          │
└──────────────────────────────────────────────┘
```

- Minutos: delta = `± minuteStep * 60`.
- Segundos: delta = `± secondStep`.
- Display: `formatDurationMmSs(totalSeconds)` de `lib/core/utils/duration_parser.dart`.
- Sin `TextEditingController` para el valor.
- Deshabilitar cada boton si `!canApplyStep` para su delta.

### Gestion de estado

- **No** Riverpod global para el valor del stepper: el formulario padre mantiene `int` en `State` (o controlador de editor ya existente) y pasa `value`/`onChanged`.
- Alineado a `03-conventions.md`: estado visual/formulario local con `setState` esta permitido.

### Integracion F32 — `exercise_form.dart`

Estado actual: tres `TextEditingController` + `parseDurationMmSs` / `int.tryParse`.

Migracion:

1. Reemplazar controllers de sets/work/rest por `int _sets`, `int _workSeconds`, `int _restSeconds` inicializados desde `initial` o defaults (ej. 3, 40, 20 — los mismos defaults actuales del form).
2. Renderizar `NumberStepper` y dos `DurationStepper`.
3. Al guardar: validar con validators existentes (defensa en profundidad); en camino feliz los steppers ya garantizan rango.
4. Eliminar mensajes de error de "formato mm:ss" en el camino de estos campos; mantener validacion de nombre.
5. Keys de test: conservar/adaptar `exercise_sets_field` → keys de steppers; actualizar widget tests.

### Integracion F01 — `interval_form.dart`

1. Reemplazar controller de duracion por `int _durationSeconds`.
2. `DurationStepper(minSeconds: 1, maxSeconds: 5999)`.
3. Nombre y color picker sin cambios funcionales.
4. Actualizar widget tests de validacion R12 de F01: ya no aplica "string no parseable" desde este form; el criterio de duracion invalida de F01 se cumple al **no poder** fijar 00:00 ni >99:59 via UI (R14/R13 de F33). Tests F01 de string `abc` pueden moverse a unit tests del parser legacy o eliminarse del form si el campo desaparece.

### UI premium (tokens)

Usar `Theme.of(context)` y tokens de `AppTheme` / `04-design-system.md`:

| Elemento | Guia |
|---|---|
| Contenedor | `surfaceContainerHighest` o `colorScheme.surface` + border sutil `outlineVariant`; `radius.md` |
| Padding / gap | `spacing.sm` / `spacing.md` |
| Botones ± | `IconButton` o `FilledButton.tonal` con minimo 48dp |
| Valor | `titleMedium` o `headlineSmall` + tabular figures |
| Label | `labelLarge` / `bodySmall` `onSurfaceVariant` |

No hardcodear hex. F27 dark mode heredara automaticamente si se usan tokens del scheme.

### Accesibilidad (R16)

- `Semantics` / `tooltip` en cada boton: "Aumentar sets", "Disminuir sets", "Aumentar minutos", etc.
- Valor con `Semantics(liveRegion: true)` opcional al cambiar (no obligatorio si produce ruido).
- Respetar `textScaler` del contexto; layout en `Row`/`Wrap` que no desborde con scale 1.3 (smoke manual; F31 profundiza).

### Strings

Actualizar `UiStrings` donde diga "Duracion (mm:ss)" / "Usa mm:ss entre..." si el copy ya no describe tipeo. Ejemplos:

- Label: "Duracion trabajo", "Duracion descanso", "Sets".
- Errores de formato mm:ss: dejar de mostrar en forms migrados; parser permanece en `core/utils` para datos legacy/tests.

## Diagrama de flujo — F33

```
[Usuario toca + / −]
        |
        v
[canApplyStep / clampStep] ---> (borde) boton disabled / no-op
        |
        v (valor valido)
[onChanged(int)] --> [State del formulario]
        |
        v (Guardar)
[Validators defensa] --> [Repository F32 / F01] --> drift (sin schema nuevo)
```

## Riesgos y consideraciones

- **Tests F01/F32 existentes** asumen `TextField` y keys de texto: hay que actualizarlos en la misma PR.
- **Valores no multiplos de 5 s** al editar un ejercicio ya guardado (ej. 40 s): el display muestra 00:40; +5 → 00:45; −5 → 00:35. No re-alinear al multiplo mas cercano al abrir (evita mutacion silenciosa).
- **99:59 + 5 s**: clamp a 5999; boton + seg deshabilitado en el borde.
- **00:03 − 5 s** (work min 1): clamp a 1 s o deshabilitar si el paso completo no cabe — usar `canApplyStep` estricto (si `value + delta < min`, disable), no un semi-paso, para UX predecible.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Mantener TextField + mascara mm:ss | Sigue permitiendo borrar `:` y errores de parseo (dolor actual). |
| `showTimePicker` / cupertino timer picker | UX generica del SO; menos control visual "premium"; minutos/segundos no alineados a pasos 1/5. |
| Teclado numerico opcional ademas de steppers | Complejidad y reabre caminos de error; fuera de alcance v1. |
| Segundos como columna 0–59 con carry a minutos | Mas complejo de explicar; el modelo de total segundos es mas simple y testeable. |
| Widget solo en F32 sin F01 | Deja inconsistencia UX; F01 es el otro form de duracion activo. |

## Paquetes

Ningun paquete nuevo. Solo Flutter SDK (`material`) + codigo del proyecto.
