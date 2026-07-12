# Requirements: Calendario e Historial de Sesiones

> Estado: No iniciada

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Registro persistente de cada sesion ejecutada (completada o cancelada) y pantalla **Historial** con calendario mensual para consultar que se entreno cada dia: seleccionar dia, ver cards de sesiones, anotar notas, re-ejecutar o eliminar del historial.

La UI de referencia (layout y jerarquia visual) se define en este documento y en `design.md`; tokens de marca en `_global/04-design-system.md`.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core (emite `SessionCompletedEvent` y `SessionCancelledEvent`)

## Postrequisitos (features que dependen de esta)

- F09 - Progresion Automatica
- F12 - Estadisticas y Progreso
- F14 - Recordatorios y Notificaciones
- F15 - Registro de Peso y Medidas
- F16 - Compartir Resumen de Sesion
- F29 - Backup y Exportacion de Datos

## User Stories

- **Como** usuario, **quiero** ver un calendario mensual con los dias en que entrene marcados, **para que** reviso mi consistencia de un vistazo.
- **Como** usuario, **quiero** elegir el mes manualmente y volver al dia de hoy en un toque, **para que** navego el historial sin perder el contexto actual.
- **Como** usuario, **quiero** tocar un dia y ver las sesiones de ese dia en cards, **para que** recuerdo que hice y cuanto duro.
- **Como** usuario, **quiero** escribir una nota en cada sesion del historial, **para que** dejo un recuerdo del entrenamiento.
- **Como** usuario, **quiero** desde el menu de una card empezar de nuevo esa rutina o eliminarla del historial, **para que** actuo sin salir de la pantalla.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Persistencia al completar sesion

CUANDO el `TimerController` (F01) emite un `SessionCompletedEvent`, EL SISTEMA DEBE crear y persistir un `SessionLog` con:

- `sourceId` = `routineId` del evento (puede ser id de rutina F01/F05 o `workoutId` F32);
- snapshot de `displayName` (nombre de la rutina/entrenamiento activa al momento del evento);
- `endedAt` = `completedAt`;
- `totalDurationSeconds` = `totalElapsedSeconds`;
- `itemCount` = `intervalCount`;
- `status` = `completed`;
- `localDate` = fecha calendario del dispositivo en zona local al momento de `endedAt`;
- `note` vacio/null.

### R2 — Persistencia al cancelar sesion

CUANDO el `TimerController` emite un `SessionCancelledEvent` y `elapsedSeconds` es mayor que 0, EL SISTEMA DEBE crear y persistir un `SessionLog` con los mismos campos de snapshot que R1, `status` = `aborted`, `endedAt` = `cancelledAt`, `totalDurationSeconds` = `elapsedSeconds`, `itemCount` = `completedIntervalCount`.

SI `elapsedSeconds` es 0, ENTONCES EL SISTEMA NO DEBE crear un `SessionLog` (cancelacion inmediata sin progreso).

### R3 — Persistencia sobrevive reinicio

CUANDO el usuario cierra y reabre la app, EL SISTEMA DEBE mostrar el mismo historial de `SessionLog` que habia antes del cierre (persistencia local drift).

### R4 — Pantalla Historial: chrome superior

DONDE el usuario esta en la seccion **Historial** (tab o ruta dedicada), EL SISTEMA DEBE mostrar en la **barra superior** de la pantalla:

1. **Izquierda:** selector de mes (etiqueta del mes visible en locale de la app, ej. "Julio", con chevron/dropdown) que permite cambiar el mes mostrado del calendario.
2. **Derecha:** boton "hoy" (icono de calendario con el numero del dia actual) con area de toque minima 48x48 dp.

No DEBE haber titulo de seccion que reemplace este chrome; el mes seleccionado es el ancla visual principal.

### R5 — Navegacion de mes

CUANDO el usuario elige un mes distinto en el selector de R4, EL SISTEMA DEBE actualizar el calendario al mes/ano elegidos y conservar el dia seleccionado si existe en el nuevo mes; SI el dia seleccionado no existe en el nuevo mes (ej. 31 en febrero), ENTONCES DEBE seleccionar el ultimo dia valido de ese mes.

### R6 — Boton hoy

CUANDO el usuario activa el boton "hoy" de R4, EL SISTEMA DEBE:

1. cambiar el mes visible al mes/ano del dia actual del dispositivo;
2. seleccionar el dia actual;
3. listar las sesiones de ese dia (R10).

### R7 — Calendario mensual

DONDE el usuario esta en Historial, EL SISTEMA DEBE mostrar un calendario mensual **justo debajo** del chrome de R4 con:

- cabecera de dias de la semana empezando en **lunes** (LUN … DOM en es);
- celdas de dia del mes visible (incluyendo dias de mes adyacente si el grid lo requiere, visualmente atenuados);
- dia **hoy** con borde/outline de acento (sin relleno solido obligatorio);
- dia **seleccionado** con relleno de color de acento (primario/exito) y contraste de texto legible (WCAG AA);
- dias con al menos un `SessionLog` en `localDate` marcados con un **indicador visual** consistente (ej. icono de pesa/brazo o badge bajo el numero) distinto del relleno de seleccion.

### R8 — Seleccion de dia en calendario

CUANDO el usuario toca una celda de dia del mes visible, EL SISTEMA DEBE marcar ese dia como seleccionado (estilo R7) y actualizar la lista de sesiones debajo al contenido de ese `localDate` (R10).

### R9 — Marcadores de dias con actividad

CUANDO existe al menos un `SessionLog` con `localDate` igual a un dia del mes visible, EL SISTEMA DEBE mostrar el indicador de actividad de R7 en esa celda, con independencia de si el dia esta seleccionado o es hoy.

### R10 — Lista de sesiones del dia (cards)

DONDE hay un dia seleccionado, CUANDO ese dia tiene uno o mas `SessionLog`, EL SISTEMA DEBE mostrar debajo del calendario (y de cualquier banner no bloqueante opcional):

1. un encabezado de seccion **Entrenamientos**;
2. una **card por sesion**, ordenadas por `endedAt` **descendente** (mas reciente arriba).

Cada card DEBE incluir:

| Zona | Contenido |
|---|---|
| Superior izquierda | Titulo: `displayName` si no esta vacio; si vacio, fallback `"Entrenamiento a las HH:mm"` usando hora local de `endedAt` |
| Superior derecha | Boton overflow (tres puntos verticales), toque >= 48 dp |
| Meta (bajo titulo) | Chip/texto de duracion (`totalDurationSeconds` formateado, ej. `15s` o `mm:ss` / `h:mm:ss`) + texto `Ejercicios: {itemCount}` |
| Inferior | Zona de nota (R11) |

Las cards usan `radius` y superficie del design system (`_global/04-design-system.md`); no inventar tokens hardcodeados fuera del tema.

### R11 — Nota en card

DONDE se muestra una card de sesion, EL SISTEMA DEBE mostrar en la parte inferior de la card:

- SI `note` es null o vacio: placeholder accionable **"Anadir una nota..."** (o copy i18n equivalente);
- SI `note` tiene texto: el texto de la nota (truncado a 3 lineas max en la card con ellipsis si excede).

CUANDO el usuario activa la zona de nota, EL SISTEMA DEBE permitir editar y guardar el texto (inline expandido, bottom sheet o dialog de edicion — ver Decisiones). Al guardar, EL SISTEMA DEBE persistir `note` en el `SessionLog` y reflejarlo en la card sin recargar toda la app.

### R12 — Limite de nota

CUANDO el usuario intenta guardar una nota de mas de **500** caracteres, EL SISTEMA DEBE rechazar el guardado (o impedir exceder el limite en el campo) y mostrar feedback visible sin truncar en silencio de forma confusa.

### R13 — Menu overflow (bottom sheet)

CUANDO el usuario activa los tres puntos de una card, EL SISTEMA DEBE abrir un **menu modal desde abajo** (bottom sheet) con:

1. **Cabecera informativa** (no accion): `displayName` o fallback de hora (como en R10) y duracion destacada (`totalDurationSeconds` formateada, tipografia dominante);
2. accion **Empezar** (icono play);
3. accion **Eliminar del historial** (icono papelera, estilo destructivo o neutro con confirmacion posterior).

En esta version de F04 el sheet **NO** DEBE incluir "Guardar en Mis entrenamientos" ni "Compartir entrenamiento" (alcance de F05/F32 y F16 respectivamente).

### R14 — Empezar desde historial

CUANDO el usuario activa **Empezar** en el bottom sheet de R13, EL SISTEMA DEBE:

1. cerrar el sheet;
2. intentar cargar la fuente original (`sourceId`) en el timer (rutina o entrenamiento segun exista en repositorios F01/F05/F32);
3. navegar a la pantalla de ejecucion / preparacion del timer segun contratos F01/F35.

SI la fuente ya no existe, ENTONCES EL SISTEMA DEBE mostrar un mensaje de error no bloqueante (SnackBar) y **no** iniciar sesion vacia.

### R15 — Eliminar con confirmacion

CUANDO el usuario activa **Eliminar del historial** en el sheet de R13, EL SISTEMA DEBE pedir **confirmacion** (dialog) con accion destructiva separada de cancelar (patron `_global/04-design-system.md`).

CUANDO el usuario confirma, EL SISTEMA DEBE borrar el `SessionLog`, cerrar sheet/dialog, quitar la card de la lista y actualizar los marcadores del calendario si el dia queda sin sesiones.

### R16 — Dia sin sesiones

DONDE el dia seleccionado no tiene ningun `SessionLog`, EL SISTEMA DEBE mostrar la seccion **Entrenamientos** con estado vacio: mensaje breve (ej. "No hay entrenamientos este dia") sin cards fantasma.

### R17 — Carga de historial

DONDE el usuario entra a Historial, CUANDO los logs aun no estan disponibles, EL SISTEMA DEBE mostrar estado de carga centrado (`CircularProgressIndicator` / patron AsyncNotifier de `_global/04-design-system.md`) y, al resolver, el calendario + lista.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R18 — Fallo al persistir sesion

SI falla la escritura de un `SessionLog` tras un evento de sesion (error de DB), ENTONCES EL SISTEMA DEBE registrar el error en debug/log y **no** crashear la app; el timer y la UI de ejecucion DEBEN poder completarse con normalidad. Un reintento opcional en background queda a criterio de implementacion documentado en `design.md`.

### R19 — Fallo al guardar nota

SI falla la persistencia al guardar una nota (R11), ENTONCES EL SISTEMA DEBE mostrar SnackBar con opcion de reintentar y **mantener** el texto que el usuario intento guardar en el editor hasta confirmar o descartar.

### R20 — Fallo al eliminar

SI falla el borrado de un `SessionLog`, ENTONCES EL SISTEMA DEBE mostrar SnackBar de error, mantener el registro en UI y no cerrar el historial.

### R21 — Mes sin datos

DONDE el mes visible no tiene ningun `SessionLog`, EL SISTEMA DEBE renderizar el calendario sin marcadores de actividad y, si el dia seleccionado esta vacio, el estado vacio de R16. No DEBE mostrarse error.

## Decisiones de producto

| Tema | Decision |
|---|---|
| Eventos F01 | Consumir **solo** `SessionCompletedEvent` y `SessionCancelledEvent` (no `onSessionEnd`). Ver `_global/02-architecture-and-structure.md`. |
| Cancelacion sin progreso | `elapsedSeconds == 0` → no crear log (R2). |
| Cancelacion con progreso | Se registra como `aborted` y **cuenta** para marcador de dia (R9). |
| Zona horaria | `localDate` siempre en **zona local del dispositivo** al momento de `endedAt`. |
| Inicio de semana | Lunes (alineado a locale es y referencia UI). |
| Titulo de card | Preferir snapshot `displayName`; fallback `"Entrenamiento a las HH:mm"`. |
| Label de cantidad | UI muestra `Ejercicios: {itemCount}` usando `intervalCount` / `completedIntervalCount` del evento (MVP; no requiere conteo de entidades Exercise). |
| Edicion de nota | Editor via bottom sheet o dialog simple con campo multilinea, Guardar y Cancelar; max **500** chars. |
| Menu overflow v1 | Solo **Empezar** + **Eliminar del historial** (+ cabecera info). |
| Empezar | Requiere que `sourceId` siga existiendo; no reconstruye rutina solo desde snapshot. |
| Banners PRO | Fuera de alcance F04 (F06). Pueden existir en shell sin ser requisito de esta feature. |
| Shell de tabs | F04 provee la **pantalla** Historial; el `BottomNavigationBar`/`NavigationBar` del shell de app (Temporizador / Entrenamientos / Historial / Ajustes) se integra en capa app sin bloquear F04. |
| Paquete calendario | `table_calendar` (ver `design.md`); API validada en pub.dev. |

## Fuera de alcance (explicito)

- Estadisticas agregadas, rachas y graficas (F12).
- Compartir sesion o rutina (F16, F25).
- Guardar sesion del historial como plantilla en Mis entrenamientos/rutinas (F05/F32).
- Gate PRO / IAP en esta pantalla (F06).
- Backup/export del historial (F29) — solo consume los mismos datos.
- Edicion manual de sesiones inventadas (no se crean logs sin evento de timer).
- Seleccion multi-dia, vista semanal/anual, o heatmap avanzado.
- Multilenguaje completo (F28); strings en espanol via `ui_strings` / constantes hasta F28.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; historial local.
- `_global/02-architecture-and-structure.md` — `features/calendar_history/`, contratos de eventos F01.
- `_global/03-conventions.md` — Riverpod; modelos en ingles (`SessionLog`).
- `_global/04-design-system.md` — tokens, estados vacio/carga/error, confirmacion destructiva, touch 48 dp.
- `_global/05-data-model.md` — entidad `SessionLog` y tabla `session_logs` (actualizar al implementar).
- `_global/06-roadmap-and-dependencies.md` — prerequisito F01; consumidores F09/F12/…
- Referencia visual de producto: capturas de pantalla Historial (selector de mes, boton hoy, calendario con marcadores, cards con nota, bottom sheet de acciones).
