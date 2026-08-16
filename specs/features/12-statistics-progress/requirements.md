# Requirements: Estadisticas y Progreso

> Estado: Completado

**ID:** F12 &nbsp;|&nbsp; **Slug:** `12-statistics-progress` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Agrega, dentro de la seccion **Historial** (F04), un bloque de progreso derivado de `SessionLog`: minutos entrenados, sesiones, racha, calorias estimadas y graficas de actividad semanal/mensual. No introduce un tab nuevo en la barra de navegacion.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones

## Postrequisitos (features que dependen de esta)

- F13 - Logros y Badges
- F16 - Compartir Resumen de Sesion (consume metricas derivadas: racha, calorias; no la UI de graficas)
- F26 - Retos Grupales
- F29 - Backup y Exportacion de Datos

## User Stories

- **Como** usuario, **quiero** ver en Historial cuantos minutos entreno esta semana y mi racha actual, **para que** me mantengo motivado sin buscar otra seccion.
- **Como** usuario, **quiero** ver una grafica de actividad semanal o mensual, **para que** entiendo de un vistazo si estoy siendo constante.
- **Como** usuario, **quiero** ver una estimacion de calorias quemadas marcada como tal, **para que** tengo una referencia sin creer que es medicion medica.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Ubicacion en Historial (sin tab nuevo)

DONDE el usuario esta en la seccion **Historial** (tab F04 / R22), EL SISTEMA DEBE mostrar el bloque de progreso de esta feature **en la misma pantalla scrolleable**, **encima** del calendario mensual y **debajo** del chrome de mes (selector de mes + boton hoy de F04 R4).

EL SISTEMA NO DEBE agregar un quinto destino en la barra de navegacion inferior para estadisticas o progreso.

### R2 — Resumen de metricas

DONDE el usuario ve el bloque de progreso en Historial, EL SISTEMA DEBE mostrar al menos estas metricas, calculadas a partir de `SessionLog` (F04):

| Metrica | Definicion |
|---|---|
| Racha actual | Dias consecutivos con actividad (ver R6) |
| Minutos esta semana | Suma de `totalDurationSeconds` de logs cuya `localDate` cae en la semana ISO actual (lunes–domingo, zona local), convertida a minutos enteros (floor) |
| Sesiones este mes | Cantidad de `SessionLog` cuya `localDate` cae en el **mes visible** del chrome de Historial (F04 `focusedMonth`) |
| Calorias estimadas (total) | Suma de calorias estimadas de todos los `SessionLog` (ver R5), redondeada a entero |

Cada metrica DEBE mostrar valor numerico + etiqueta legible. La metrica de calorias DEBE indicar de forma visible que es una **estimacion** (ej. "kcal (est.)").

### R3 — Linea opcional de totales historicos

DONDE hay al menos un `SessionLog` en el historial, EL SISTEMA DEBE mostrar una linea secundaria (texto atenuado) con:

- minutos totales historicos (floor de suma de `totalDurationSeconds` / 60), y
- numero total de sesiones historicas.

SI no hay ningun `SessionLog`, ENTONCES esa linea DEBE omitirse o mostrar ceros de forma coherente con R10.

### R4 — Grafica de actividad (semana / mes)

DONDE el usuario ve el bloque de progreso, EL SISTEMA DEBE mostrar una grafica de barras de **minutos por dia** con control de periodo **Semana | Mes**:

- **Semana (default):** 7 barras, lunes–domingo de la semana ISO actual en zona local; valor = minutos (floor) de logs ese `localDate`.
- **Mes:** una barra por cada dia del **mes visible** del chrome de Historial; valor = minutos (floor) ese `localDate`.

CUANDO el usuario cambia el control Semana/Mes, EL SISTEMA DEBE actualizar la grafica sin salir de Historial.

CUANDO el usuario cambia el mes visible del chrome (F04 R5), y el control esta en **Mes**, EL SISTEMA DEBE recalcular la grafica y la metrica "sesiones este mes" (R2) para ese mes.

### R5 — Estimacion de calorias

CUANDO el sistema calcula calorias de un `SessionLog`, EL SISTEMA DEBE aplicar:

`kcal = MET * peso_kg * (totalDurationSeconds / 3600)`

con:

- `MET` = valor por defecto de entrenamiento por intervalos documentado en Decisiones (**8.0**), mientras no exista categoria de rutina en el log (F03 fuera de alcance de F12);
- `peso_kg` = peso del usuario si F15 ya expone un valor legible; SI no hay peso registrado, ENTONCES `peso_kg` = **70** (default).

EL SISTEMA DEBE marcar el resultado agregado en UI como estimacion (R2). No DEBE presentarlo como medicion real de gasto energetico.

### R6 — Racha de dias consecutivos

EL SISTEMA DEBE calcular la **racha actual** asi:

1. Considerar un dia con actividad si existe al menos un `SessionLog` con ese `localDate` (incluye `completed` y `aborted`; F04 solo persiste abortados con progreso).
2. Si **hoy** (fecha local del dispositivo) tiene actividad, el ancla es hoy.
3. SI hoy **no** tiene actividad, ENTONCES el ancla es **ayer** solo si ayer tiene actividad (el dia actual aun no cerro; no se rompe la racha hasta que un dia calendario termine sin sesion).
4. SI no hay ancla (ni hoy ni ayer con actividad), ENTONCES la racha es **0**.
5. Desde el ancla, contar hacia atras dias consecutivos con actividad hasta el primer hueco.

CUANDO pasa un dia calendario completo (00:00 local del dia siguiente) sin ningun `SessionLog` en ese dia, y ese dia ya no es "hoy", EL SISTEMA DEBE tratar la racha como rota respecto de ese hueco (equivalente al punto 4 si el hueco es ayer o anterior).

### R7 — Solo sesiones del historial

EL SISTEMA DEBE basar todas las metricas y graficas exclusivamente en `SessionLog` persistidos (F04). No DEBE inventar sesiones ni leer el estado efimero del timer en ejecucion.

### R8 — Actualizacion al cambiar el historial

CUANDO se inserta, elimina o modifica la duracion relevante de un `SessionLog` (completar sesion, borrar del historial, etc.), EL SISTEMA DEBE recalcular y reflejar metricas y grafica al volver a mostrar o al invalidar providers de Historial, sin reiniciar la app.

### R9 — Integracion visual con F04

DONDE el usuario scrollea Historial, EL SISTEMA DEBE mantener el orden vertical:

1. Chrome mes + hoy (F04 R4)
2. Bloque progreso: titulo de seccion, metricas (R2–R3), grafica (R4)
3. Calendario mensual (F04 R7)
4. Lista "Entrenamientos" del dia (F04 R10–R16)

El bloque de progreso DEBE usar tokens de `_global/04-design-system.md` (radius, superficies, tipografia); no inventar colores hardcodeados fuera del theme.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R10 — Historial vacio

DONDE no existe ningun `SessionLog`, EL SISTEMA DEBE mostrar el bloque de progreso con valores en **0** (racha 0, minutos 0, sesiones 0, kcal 0) y grafica con barras en 0, **sin** error bloqueante. El calendario y el estado vacio del dia (F04 R16) siguen aplicando debajo.

### R11 — Fallo al leer historial

SI falla la lectura de `SessionLog` al calcular stats (error de repositorio/DB), ENTONCES EL SISTEMA DEBE:

1. no crashear la app;
2. mostrar un estado de error no bloqueante en el bloque de progreso (mensaje breve + opcion de reintentar si aplica el patron AsyncNotifier);
3. permitir que el resto de Historial (calendario/lista) siga el manejo de error/carga de F04 si es independiente, o el mismo fallo de carga de F04 R17 si comparten la misma fuente.

### R12 — Peso por defecto visible

SI se usa el peso por defecto de R5 (no hay peso de F15), ENTONCES EL SISTEMA DEBE mostrarlo de forma no intrusiva al menos una vez en el bloque de progreso (ej. caption bajo calorias: "Peso estimado 70 kg" o copy i18n equivalente), sin forzar al usuario a registrar peso.

## Decisiones de producto

| Tema | Decision |
|---|---|
| Ubicacion UI | **Dentro de Historial**, scroll unico; **no** tab "Progreso" ni quinto destino en bottom nav |
| Orden en pantalla | Chrome mes → stats + grafica → calendario → lista del dia |
| Fuente de datos | Solo `SessionLog` (F04); sin tabla nueva de stats |
| Sesiones que cuentan | Todos los `SessionLog` persistidos (`completed` y `aborted`) |
| Semana | ISO (lunes–domingo), zona local del dispositivo |
| Mes de metricas/grafica | Mes **visible** del chrome F04 (`focusedMonth`) |
| Minutos | `floor(sum(totalDurationSeconds) / 60)` por el rango |
| MET default | **8.0** (intervalo/HIIT generico) hasta que exista categoria en log (futuro F03) |
| Peso default | **70 kg** si F15 no aporta peso |
| Racha con dia en curso | Si hoy no hay sesion aun, se ancla en ayer si ayer tuvo sesion; se rompe al cerrar un dia sin sesion |
| Dependencia F15 | Opcional; F12 no espera F15 |
| Dependencia F03 | No es prerequisito; sin categorias MET por rutina en MVP |
| F16 | Puede reutilizar el **servicio de metricas** (racha, kcal); no requiere la grafica ni el layout de Historial |
| Logros / retos | Fuera de alcance (F13, F26) |
| Share / imagen | Fuera de alcance (F16) |

## Fuera de alcance (explicito)

- Tab o seccion principal nueva en la barra de navegacion.
- Logros, badges, retos grupales, export de stats.
- Compartir imagen de resumen (F16).
- Registro de peso/medidas (F15) mas alla de leer un peso si ya existe.
- Tabla MET por categoria de preset (requiere F03 + metadata en log).
- Graficas de peso corporal (F15).
- Cualquier comportamiento no listado en R1–R12.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; motivacion sin friccion.
- `_global/02-architecture-and-structure.md` — modulo `features/stats/`; contratos via providers.
- `_global/03-conventions.md` — Riverpod; nombres en ingles en codigo.
- `_global/04-design-system.md` — tokens, estados vacio/carga/error, touch >= 48 dp.
- `_global/05-data-model.md` — `SessionLog`; stats derivadas (sin tabla).
- F04 `requirements.md` / `design.md` — chrome, calendario, lista, shell.
