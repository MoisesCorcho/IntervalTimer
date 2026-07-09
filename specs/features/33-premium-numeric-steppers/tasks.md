# Tasks: Controles Numericos y de Duracion (Steppers Premium)

**ID:** F33 &nbsp;|&nbsp; **Slug:** `33-premium-numeric-steppers`

## Definition of Done

- [x] Todos los criterios R1–R17 de `requirements.md` estan implementados y verificados. _(cubre R1–R17)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] `NumberStepper` y `DurationStepper` documentados en `_global/04-design-system.md`.
- [x] Formularios F32 y F01 ya no usan TextField editables para sets/duraciones.
- [x] Tests previos de F01/F32 de formularios actualizados y en verde.
- [x] Codigo revisado contra `_global/03-conventions.md` (Theme tokens, sin hex hardcode).

## Checklist de implementacion

### Utilidades y widgets compartidos

- [x] Extraer o implementar `clampStep` / `canApplyStep` (logica pura testeable) en `core/utils/` o junto a los widgets. _(cubre R2, R4, R5, R12, R13)_
- [x] Implementar `NumberStepper` en `lib/shared/widgets/number_stepper.dart` (value, min, max, step, onChanged, label, semantics). _(cubre R1, R2, R9, R10, R11, R12, R15, R16)_
- [x] Implementar `DurationStepper` en `lib/shared/widgets/duration_stepper.dart` (totalSeconds, min/max, minuteStep=1, secondStep=5, display `formatDurationMmSs`). _(cubre R3, R4, R5, R6, R9, R10, R11, R13, R14, R15, R16)_
- [x] Asegurar area de toque >= 48dp y UI con tokens de tema (contenedor unificado, no TextField plano). _(cubre R9, R11)_
- [x] Registrar ambos componentes en `_global/04-design-system.md` (si no quedo al crear la feature). _(cubre R11)_

### Integracion F32

- [x] Migrar `exercise_form.dart`: sets → `NumberStepper`; work/rest → `DurationStepper` con rangos 1–5999 y 0–5999. _(cubre R7, R10, R14, R15, R17)_
- [x] Eliminar `TextEditingController` y parseo de string para sets/work/rest; defaults iniciales coherentes con el form actual. _(cubre R7, R15, R17)_
- [x] Actualizar `UiStrings` / mensajes de error de formato mm:ss que ya no apliquen al form de ejercicio. _(cubre R7, R15)_
- [x] Verificar guardar ejercicio persiste enteros mostrados por steppers. _(cubre R17)_

### Integracion F01

- [x] Migrar `interval_form.dart`: duracion → `DurationStepper` (1–5999 s). _(cubre R8, R10, R14, R15, R17)_
- [x] Eliminar TextField de duracion mm:ss y flujo de parse en el form. _(cubre R8, R15)_
- [x] Actualizar strings de label/error del form de intervalo si describen tipeo mm:ss. _(cubre R8)_

### Tests

- [x] **Unit — clamp/step happy path:** +1/−1 en NumberStepper math; +60/−60 y +5/−5 en Duration math dentro de rango. _(cubre R2, R4, R5)_
- [x] **Unit — clamp/step bordes:** en min/max no sale de rango; `canApplyStep` false en borde; work min 1 vs rest min 0. _(cubre R12, R13, R14)_
- [x] **Widget — NumberStepper:** muestra valor; tap +/− cambia; botones disabled en min/max; no hay TextField. _(cubre R1, R2, R12, R15)_
- [x] **Widget — DurationStepper:** muestra mm:ss; + min y + seg; disabled en bordes; sin TextField. _(cubre R3, R4, R5, R6, R13, R15)_
- [x] **Widget — exercise form:** sets/work/rest usan steppers; guardar con valores ajustados por botones persiste enteros validos. _(cubre R7, R17)_
- [x] **Widget — interval form:** duracion usa DurationStepper; no acepta 00:00 via UI. _(cubre R8, R14, R17)_
- [x] **Widget — semantics (smoke):** botones ± exponen labels semanticos no vacios. _(cubre R16)_
- [x] Actualizar o retirar tests F01/F32 que tipeeaban strings invalidos en campos eliminados (mantener unit tests del parser en `duration_parser` si siguen siendo utiles). _(cubre R15, R17)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | NumberStepper widget, widget test NumberStepper |
| R2 | clamp/step util, NumberStepper, unit happy, widget NumberStepper |
| R3 | DurationStepper layout, widget DurationStepper |
| R4 | DurationStepper min ±, unit happy |
| R5 | DurationStepper seg ±, unit happy |
| R6 | formatDurationMmSs en DurationStepper, widget DurationStepper |
| R7 | Migracion exercise_form, widget exercise form |
| R8 | Migracion interval_form, widget interval form |
| R9 | Widgets shared 48dp |
| R10 | onChanged int en ambos widgets + forms |
| R11 | UI tokens en widgets, design-system doc |
| R12 | canApplyStep NumberStepper, unit bordes, widget NumberStepper |
| R13 | canApplyStep DurationStepper, unit bordes, widget DurationStepper |
| R14 | minSeconds work/rest/intervalo, unit bordes, widget interval form |
| R15 | sin TextField en widgets y forms, tests actualizados |
| R16 | Semantics en botones, widget semantics smoke |
| R17 | Integracion forms + widget tests guardar |

## Notas de secuenciacion

Esta feature depende de: **F01** y **F32** (formularios y rangos existentes).

Orden recomendado:

1. Utilidades clamp/step + tests unit
2. `NumberStepper` + tests widget
3. `DurationStepper` + tests widget
4. Migrar `exercise_form` + tests F32
5. Migrar `interval_form` + tests F01
6. Semantics smoke + design-system + DoD

No iniciar tasks de este archivo hasta que F01 y F32 esten en estado usable (forms existentes en codigo).
