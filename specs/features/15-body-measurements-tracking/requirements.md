# Requirements: Registro de Peso y Medidas

> Estado: Completado

**ID:** F15 &nbsp;|&nbsp; **Slug:** `15-body-measurements-tracking` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Registro **opcional** y local de peso corporal (y medidas opcionales: cintura, brazo, pierna), con
grafica de evolucion del peso y preferencia de unidad (kg/lb). No se pide peso en el primer arranque:
F12 sigue usando **70 kg estimados** hasta que el usuario registre un valor. La entrada principal es
**Historial** (cerca del bloque de progreso F12); la unidad se configura en **Ajustes**. Offline-first;
sin tab nuevo en la barra de navegacion.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones (`HistoryScreen`, shell Historial)
- F12 - Estadisticas y Progreso (`WeightReader` / `weightReaderProvider`, caption de peso en progreso)
  — **blando pero requerido en codigo actual**: F12 ya expone el contrato de peso; F15 lo implementa

## Postrequisitos / consumidores (no bloquean implementacion de F15)

- F12 - Estadisticas: usa el ultimo peso registrado para kcal (deja de marcar "estimado 70 kg")
- F16 - Resumen de sesion: reutiliza el mismo peso via providers de F12 (sin UI de medidas)

## User Stories

- **Como** usuario, **quiero** registrar mi peso cuando quiera desde Historial, **para que** veo mi
  evolucion y las calorias estimadas reflejan mi peso real sin que la app me lo exija al inicio.
- **Como** usuario, **quiero** ver una grafica de evolucion del peso en el tiempo, **para que**
  entiendo de un vistazo si estoy progresando.
- **Como** usuario, **quiero** elegir kg o lb, **para que** veo y edito en la unidad que me resulta natural.
- **Como** usuario, **quiero** opcionalmente anotar medidas (cintura, brazo, pierna), **para que**
  llevo un registro simple sin apps de fitness separadas.
- **Como** usuario, **quiero** editar o borrar un registro errado, **para que** mis datos me pertenecen
  y un typo no queda permanente.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Feature opcional (sin onboarding de peso)

EL SISTEMA NO DEBE solicitar peso ni medidas en el primer arranque de la app ni bloquear timer,
entrenamientos, historial o ajustes si el usuario nunca usa esta feature.

SI no existe ningun registro de peso, ENTONCES F12 DEBE seguir usando el peso por defecto documentado
en F12 R5/R12 (**70 kg**, marcado como estimado).

### R2 — Entrada principal desde Historial

DONDE el usuario esta en la seccion **Historial** (tab F04 / shell de 4 destinos),
EL SISTEMA DEBE exponer un acceso claro al registro de peso/medidas **dentro del scroll de
Historial**, asociado al bloque de progreso F12 (caption de peso o accion "Registrar peso" /
"Actualizar peso"), **sin** agregar un quinto destino en la barra de navegacion inferior.

### R3 — Formulario de registro

CUANDO el usuario activa el acceso de R2 (o el equivalente desde Ajustes si se ofrece),
EL SISTEMA DEBE mostrar un formulario (bottom sheet o pantalla corta) que permita:

| Campo | Obligatorio | Notas |
|---|---|---|
| Peso | Si | Valor positivo en la unidad de preferencia del usuario (R8) |
| Fecha | Si | Default = **hoy** (zona local); no fechas futuras |
| Cintura | No | Si se ingresa, valor positivo en cm (o conversion si UI en imperial futuro; MVP en cm) |
| Brazo | No | Idem |
| Pierna | No | Idem |

CUANDO el usuario confirma con datos validos, EL SISTEMA DEBE persistir el registro localmente y
cerrar el formulario con feedback no bloqueante (snackbar o actualizacion visible del caption).

### R4 — Un registro de peso por dia (upsert)

CUANDO el usuario guarda un peso para una `localDate` (yyyy-MM-dd zona local) que **ya** tiene un
registro, EL SISTEMA DEBE **reemplazar** ese registro del dia (upsert), no acumular multiples puntos
de peso el mismo dia en la grafica.

SI el usuario cambia solo medidas del mismo dia, ENTONCES el upsert DEBE actualizar el mismo registro
del dia.

### R5 — Gráfica de evolucion del peso

DONDE el usuario ve la seccion de peso en Historial (o pantalla de medidas embebida en el scroll),
EL SISTEMA DEBE mostrar una grafica de **evolucion del peso en el tiempo** basada en los registros
persistidos (un punto por `localDate` tras upsert).

SI hay menos de 1 registro, ENTONCES EL SISTEMA DEBE mostrar un estado vacio amable (mensaje + CTA
registrar), **sin** error bloqueante.

SI hay al menos 1 registro, ENTONCES la grafica DEBE ser legible (eje tiempo + valores en la unidad
preferida del usuario).

### R6 — Listado y edicion / borrado

DONDE hay al menos un registro, EL SISTEMA DEBE permitir al usuario:

1. ver los registros recientes (lista o acceso desde la seccion de peso);
2. **editar** un registro existente (mismos campos y validaciones que R3/R4/R9);
3. **eliminar** un registro con confirmacion breve.

CUANDO se elimina el ultimo registro de peso, EL SISTEMA DEBE volver al comportamiento de R1
(F12 usa 70 kg estimado).

### R7 — Exponer ultimo peso a F12 (contrato WeightReader)

CUANDO existe al menos un registro con peso, EL SISTEMA DEBE exponer el **peso mas reciente por
fecha** (`localDate` maximo; si empate, el de mayor `updatedAt` / unico del dia) en **kilogramos**
al contrato `WeightReader` / `weightReaderProvider` de F12, con `isEstimated = false`.

CUANDO no hay registros, EL SISTEMA DEBE dejar (o restaurar) el default de F12:
`weightKg = 70`, `isEstimated = true`.

CUANDO el usuario crea, edita o borra un registro de peso, EL SISTEMA DEBE invalidar/refrescar los
consumidores de peso (stats F12 y, si aplica, F16 via los mismos providers) **sin reiniciar la app**.

### R8 — Preferencia de unidad kg/lb

DONDE el usuario esta en **Ajustes** (o en el formulario de registro con acceso a unidad),
EL SISTEMA DEBE permitir elegir unidad de **visualizacion y edicion** de peso: **kg** o **lb**.

EL SISTEMA DEBE persistir la preferencia localmente. El almacenamiento canonico del peso en dominio/DB
es siempre **kg** (ver design); la conversion es solo de presentacion/entrada.

CUANDO el usuario cambia la unidad, EL SISTEMA DEBE actualizar labels y valores mostrados en form y
grafica sin perder datos.

### R9 — Medidas opcionales (sin grafica propia en MVP)

EL SISTEMA DEBE permitir guardar cintura, brazo y pierna como campos opcionales del mismo registro
del dia. EL SISTEMA NO DEBE exigir ninguna medida para guardar solo el peso.

EL SISTEMA NO DEBE mostrar graficas de evolucion de medidas en esta version (solo peso, R5).

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R10 — Validacion de peso

SI el peso esta vacio, no es numerico, es ≤ 0, o esta fuera del rango permitido **20–300 kg**
(equivalente en lb al convertir en UI), ENTONCES EL SISTEMA DEBE:

1. no persistir;
2. mostrar error de validacion en el campo o mensaje claro;
3. no crashear.

### R11 — Validacion de medidas y fecha

SI una medida opcional se informa y es ≤ 0 o > **300 cm**, ENTONCES EL SISTEMA DEBE rechazar el
guardado con error de validacion (mismas reglas de no crash).

SI la fecha es **futura** respecto de la fecha local del dispositivo, ENTONCES EL SISTEMA DEBE
rechazar el guardado.

### R12 — Estado vacio y fallo de persistencia

DONDE no hay registros, EL SISTEMA DEBE mostrar empty state de R5 y mantener F12 en peso estimado,
sin pantalla en blanco ni error fatal.

SI falla la lectura o escritura de la base local (error de repositorio/DB), ENTONCES EL SISTEMA DEBE:

1. no crashear la app;
2. mostrar estado de error no bloqueante en la seccion de peso (mensaje breve + reintentar si aplica
   AsyncNotifier);
3. dejar que el resto de Historial (stats F12, calendario F04) siga operativo si la falla es aislada
   al repositorio de medidas.

### R13 — Shell y design system

EL SISTEMA NO DEBE agregar un quinto tab. La UI DEBE usar tokens de `_global/04-design-system.md`
(superficies, tipografia, touch targets ≥ 48 dp) y estados vacio/carga/error coherentes con el resto
de la app.

## Decisiones de producto

| Tema | Decision |
|---|---|
| Onboarding / primer arranque | **No** pedir peso; default F12 70 kg estimado |
| Entrada principal | **Historial**, junto al caption de peso del bloque progreso F12 |
| Entrada secundaria | **Ajustes**: preferencia kg/lb; opcional link a medidas |
| Bottom nav | **Sin** tab nuevo (4 destinos) |
| Registros por dia | **Upsert** un registro por `localDate` |
| Edit / delete | **Si** en MVP |
| Grafica | Solo **peso**; medidas solo en form/lista |
| Unidad canonica | DB/dominio en **kg** y **cm**; UI kg/lb |
| Rango peso | 20–300 kg |
| Rango medidas | 0 exclusivo .. 300 cm si se informan |
| Fecha | Default hoy; **no** futuras |
| Integracion F12 | Override de `WeightReader` / `weightReaderProvider` — **no** inventar `UserProfileService` |
| Offline | 100% local (drift + preferencias app) |
| Salud / medico | No es diagnostico ni app medica; solo registro personal |

## Fuera de alcance (explicito)

- Pedir peso en onboarding o primer launch (F30 no incluye esto en F15).
- Quinto tab o seccion principal nueva en bottom nav.
- Graficas de cintura/brazo/pierna.
- Integracion con basculas Bluetooth, Health Connect, Apple Health, Google Fit.
- Sync cloud / multi-dispositivo (F29 puede exportar datos a futuro; no en F15).
- Calculo de IMC, grasa corporal, recomendaciones nutricionales.
- Multiples pesos el mismo dia en la grafica.
- Cambiar la formula MET de F12 (solo aporta `peso_kg`).
- Cualquier comportamiento no listado en R1–R13.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; empezar sin configurar; datos del usuario.
- `_global/02-architecture-and-structure.md` — modulo `features/body_tracking/`; comunicacion por providers.
- `_global/03-conventions.md` — Riverpod; dominio en ingles; tests.
- `_global/04-design-system.md` — tokens, empty/loading/error, touch ≥ 48 dp.
- `_global/05-data-model.md` — entidad `BodyMeasurement` + preferencia de unidad.
- F04 `requirements.md` / `design.md` — `HistoryScreen`, shell.
- F12 `requirements.md` R5/R12 y `design.md` — `WeightReader`, kcal, caption peso estimado.
