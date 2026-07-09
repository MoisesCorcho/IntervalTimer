# Requirements: Controles Numericos y de Duracion (Steppers Premium)

> Estado: Completado

**ID:** F33 &nbsp;|&nbsp; **Slug:** `33-premium-numeric-steppers` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Componentes de UI reutilizables para ingresar **enteros** (sets) y **duraciones** (minutos + segundos) mediante botones de aumentar/disminuir, sin teclado ni parseo de texto libre. Sustituyen los `TextField` de sets y duracion en el formulario de ejercicios (F32) y el de intervalos (F01), eliminando errores de formato (ej. borrar `:`) y elevando la calidad visual de los controles.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F32 - Constructor de Entrenamientos por Ejercicios

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente (F05 y otras pantallas de formulario pueden reutilizar los widgets sin prerequisito formal)

## User Stories

- **Como** usuario, **quiero** ajustar la cantidad de sets con botones + y −, **para que** no tenga que tipear ni arriesgar valores invalidos.
- **Como** usuario, **quiero** ajustar minutos y segundos de una duracion con botones propios (minutos de a 1, segundos de a 5), **para que** configure tiempos rapido y sin errores de formato mm:ss.
- **Como** usuario, **quiero** controles numericos con aspecto premium y areas de toque grandes, **para que** la edicion de ejercicios se sienta solida y profesional.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — NumberStepper: valor visible y paso ±1

DONDE el usuario ve un control `NumberStepper` configurado para sets (rango 1–99, paso 1), CUANDO el valor actual es N (1 ≤ N ≤ 99), EL SISTEMA DEBE mostrar N de forma legible y no editable por teclado.

### R2 — NumberStepper: incrementar y decrementar

DONDE el usuario ve un `NumberStepper` con valor N dentro de rango, CUANDO activa el boton de incrementar, EL SISTEMA DEBE fijar el valor en N + step (step = 1 para sets). CUANDO activa el boton de decrementar, EL SISTEMA DEBE fijar el valor en N − step.

### R3 — DurationStepper: layout minutos y segundos

DONDE el usuario ve un `DurationStepper`, CUANDO el control esta visible, EL SISTEMA DEBE mostrar dos grupos de control independientes: uno para minutos y uno para segundos, mas el valor total formateado como `mm:ss` (o minutos y segundos claramente etiquetados), sin campo de texto libre editable.

### R4 — DurationStepper: minutos ±1

DONDE el usuario ve un `DurationStepper` con valor total T segundos, CUANDO activa incrementar minutos, EL SISTEMA DEBE sumar 60 segundos a T (equivalente a +1 minuto). CUANDO activa decrementar minutos, EL SISTEMA DEBE restar 60 segundos a T.

### R5 — DurationStepper: segundos ±5

DONDE el usuario ve un `DurationStepper` con valor total T segundos, CUANDO activa incrementar segundos, EL SISTEMA DEBE sumar 5 segundos a T. CUANDO activa decrementar segundos, EL SISTEMA DEBE restar 5 segundos a T. El ajuste opera sobre el total en segundos (ej. 00:58 + 5 s → 01:03), no como columna de segundos aislada 0–59 con wrap de negocio distinto.

### R6 — Display de duracion formateado

DONDE el usuario ve un `DurationStepper` con valor total T (0 ≤ T ≤ 5999), CUANDO T cambia, EL SISTEMA DEBE mostrar la duracion en formato `mm:ss` con ceros a la izquierda (ej. 65 s → `01:05`), usando la misma convencion de formato que F01 (`formatDurationMmSs` o equivalente observable).

### R7 — Integracion formulario de ejercicio (F32)

DONDE el usuario esta en el formulario de agregar o editar ejercicio (F32), CUANDO el formulario esta visible, EL SISTEMA DEBE presentar:

- sets mediante `NumberStepper` (1–99, paso 1);
- duracion de trabajo mediante `DurationStepper` (minimo 1 s, maximo 5999 s);
- duracion de descanso mediante `DurationStepper` (minimo 0 s, maximo 5999 s);

y NO debe presentar `TextField` editables para esos tres campos.

### R8 — Integracion formulario de intervalo (F01)

DONDE el usuario esta en el formulario de agregar o editar intervalo (F01), CUANDO el formulario esta visible, EL SISTEMA DEBE presentar la duracion del intervalo mediante `DurationStepper` (minimo 1 s, maximo 5999 s) y NO debe presentar un `TextField` editable de duracion mm:ss.

### R9 — Area de toque minima

DONDE el usuario interactua con un boton + o − de `NumberStepper` o `DurationStepper`, CUANDO el boton esta habilitado, EL SISTEMA DEBE exponer un area de toque de al menos 48×48 dp (alineado a `_global/04-design-system.md`).

### R10 — Propagacion de valor al formulario

CUANDO el usuario cambia el valor de un stepper (sets o duracion), EL SISTEMA DEBE entregar al formulario padre un valor entero valido en dominio (sets 1–99; duracion en segundos dentro del min/max del control) sin requerir parseo de string por parte del padre en el camino feliz.

### R11 — Apariencia premium (tokens de tema)

DONDE el usuario ve un `NumberStepper` o `DurationStepper`, CUANDO el control esta renderizado, EL SISTEMA DEBE presentar el control como un contenedor visual distinto de un `TextField` plano: usar colores, radios y espaciados del `ThemeData` / tokens de `_global/04-design-system.md` (sin colores hex hardcodeados en el widget), de modo que el valor y los botones ± se lean como un control unificado.

## Criterios de Aceptacion — Validacion, bordes y accesibilidad (formato EARS)

### R12 — Clamp en limites de NumberStepper

CUANDO el valor de un `NumberStepper` es igual a `max`, EL SISTEMA DEBE deshabilitar el boton de incrementar y no superar `max`. CUANDO el valor es igual a `min`, EL SISTEMA DEBE deshabilitar el boton de decrementar y no bajar de `min`.

### R13 — Clamp en limites de DurationStepper

CUANDO un ajuste de minutos (±60 s) o segundos (±5 s) haria que el total salga del rango `[minSeconds, maxSeconds]`, EL SISTEMA DEBE aplicar clamp al borde del rango (o deshabilitar el boton correspondiente de antemano) y NUNCA exponer un valor fuera de rango al formulario padre.

### R14 — Minimo de trabajo vs descanso en cero

DONDE el `DurationStepper` de **trabajo** (F32) o de **intervalo** (F01) tiene `minSeconds = 1`, CUANDO el valor es 1 s, EL SISTEMA DEBE impedir decrementar por debajo de 1 s (boton − deshabilitado o sin efecto). DONDE el `DurationStepper` de **descanso** tiene `minSeconds = 0`, CUANDO el valor es 0 s, EL SISTEMA DEBE permitir permanecer en 00:00 y deshabilitar el decremento adicional.

### R15 — Sin entrada de texto libre

DONDE el usuario ve un `NumberStepper` o `DurationStepper`, CUANDO intenta editar el valor, EL SISTEMA DEBE no ofrecer teclado de texto ni campo de texto libre para ese valor; el unico mecanismo de cambio son los botones ± (y la deshabilitacion en bordes segun R12–R14).

### R16 — Semantics para lectores de pantalla

DONDE TalkBack o VoiceOver estan activos, CUANDO el foco llega a un boton ± o al valor del stepper, EL SISTEMA DEBE exponer etiquetas semanticas descriptivas (ej. "Aumentar sets", "Disminuir minutos", "Duracion trabajo 01:00") de modo que el control sea operable sin vision.

### R17 — Persistencia de valores al guardar (regresion F32/F01)

CUANDO el usuario configura sets y duraciones solo con steppers y confirma guardar el ejercicio (F32) o el intervalo (F01) con valores dentro de rango, EL SISTEMA DEBE persistir los mismos enteros (sets / segundos) que mostraban los steppers, sin rechazar por error de formato de string.

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| Entrada por teclado | **No** en v1. Display read-only; solo botones ±. |
| Paso de minutos | 1 minuto (= 60 segundos). |
| Paso de segundos | 5 segundos. |
| Modelo de ajuste de segundos | Sobre **total en segundos** (00:58 +5 → 01:03). |
| Sets | Paso 1; rango 1–99 (F32). |
| Rango duracion trabajo / intervalo | 1–5999 s (00:01–99:59). |
| Rango duracion descanso | 0–5999 s (00:00–99:59). |
| Long-press / auto-repeat | **Fuera de alcance v1** (un toque = un paso). |
| Pickers nativos del SO | No; controles propios premium. |
| F05 (rutinas planas) | No es consumer obligatorio de F33; puede adoptar los widgets despues. |
| i18n de labels | Strings via `UiStrings` / constantes existentes; migracion completa es F28. |
| Haptic feedback | No requerido en v1 (puede sumarse sin cambiar AC). |

## Fuera de alcance (explicito)

- Nuevas entidades o tablas de persistencia.
- Long-press con repeticion continua de incremento/decremento.
- Teclado numerico opcional o modo "avanzado" de tipeo mm:ss.
- Rediseño completo de pantallas de editor mas alla de los controles de sets/duracion.
- Integracion obligatoria en F05 u otras features no listadas en R7/R8.
- Cambios al algoritmo de aplanado de F32 o al motor de timer de F01.
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion; UX clara en configuracion.
- `_global/02-architecture-and-structure.md` — `shared/widgets/`, capas presentation.
- `_global/03-conventions.md` — EARS, testing, Theme sin hardcode.
- `_global/04-design-system.md` — tokens, 48dp, componentes reutilizables.
- `_global/05-data-model.md` — sin cambios de schema; reutiliza campos `sets`, `workSeconds`, `restSeconds`, `durationSeconds`.
- `features/01-interval-timer-core/requirements.md` — rangos de duracion R12.
- `features/32-workout-exercise-builder/requirements.md` — rangos sets/work/rest R3, R15.
