# Requirements: Compartir Resumen de Sesion

> Estado: Completado

**ID:** F16 &nbsp;|&nbsp; **Slug:** `16-session-summary-sharing` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Pantalla de **fin de sesion completada** (celebracion + metricas de la sesion + compartir imagen
offline + nota opcional) que aparece de inmediato al terminar cualquier timer/sesion con exito.
Cumple el contrato de confirmacion de F01 R18 con UI rica; la nota escribe el mismo campo
`SessionLog.note` del historial (F04). Offline-first: generar y compartir la tarjeta sin red.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core (`SessionCompleted` + estado `completed` + R18)
- F04 - Calendario e Historial de Sesiones (`SessionLog`, `updateNote`)
- F12 - Estadisticas y Progreso (`StatsService`: racha, kcal estimadas)

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** ver una pantalla celebratoria al terminar mi entrenamiento,
  **para que** siento cierre y motivacion sin volver en seco al editor de rutina.
- **Como** usuario, **quiero** ver metricas claras de lo que acabo de entrenar (trabajo vs descanso),
  **para que** entiendo de un vistazo como fue la sesion.
- **Como** usuario, **quiero** compartir una imagen resumen de la sesion en redes o mensajeria,
  **para que** puedo motivar a otros y llevar un registro visual fuera de la app.
- **Como** usuario, **quiero** anadir una nota opcional al terminar, **para que** dejo el mismo
  recuerdo que despues veo en el calendario/historial.
- **Como** usuario, **quiero** cerrar con "Listo" y volver al flujo de rutina en estado idle,
  **para que** no quedo atrapado en la pantalla de fin.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Apertura de pantalla post-completado

CUANDO el `TimerController` (F01) emite `SessionCompleted` / la sesion transiciona a estado
`completed`, EL SISTEMA DEBE mostrar de inmediato la **pantalla de fin de sesion** de esta
feature (no solo un SnackBar) y **no** debe regresar automaticamente al editor sin accion del
usuario.

### R2 — Layout celebratorio (hero + sheet)

DONDE el usuario esta en la pantalla de fin de sesion,
EL SISTEMA DEBE seguir esta secuencia de presentacion:

1. **Fase intro (~1–1.5 s):** fondo de marca; icono de llama **centrado** en pantalla con
   **ondas/anillos blancos animados** expandiendose desde la llama.
2. **Fase sheet:** al terminar la intro, un **bottom sheet** sube desde abajo hasta cubrir
   aproximadamente el **50%** inferior de la pantalla (mitad superior llama, mitad inferior
   contenido). El sheet DEBE ser **arrastrable hacia arriba** (hasta ~90%) para ver mas detalle.
3. Contenido del sheet (cuando esta visible): titulo de refuerzo (ej. "¡Gran trabajo!"),
   metricas (R3), CTA de compartir (R5), zona de nota (R9–R11), CTA **Listo** (R12).

Tokens de color/radio/spacing desde `_global/04-design-system.md`.

### R3 — Metricas de la sesion en pantalla

DONDE el usuario ve la pantalla de fin de sesion, EL SISTEMA DEBE mostrar al menos dos metricas
de la sesion recien completada:

| Metrica | Definicion |
|---|---|
| Entrenamiento | Suma de segundos de intervalos con `type` ∈ {`work`, `warmup`, `stretch`, `custom`} del plan ejecutado de la sesion |
| Descanso total | Suma de segundos de intervalos con `type` = `rest` del plan ejecutado de la sesion |

Cada metrica DEBE mostrar valor formateado (segundos cortos como `3s` / `mm:ss` / `h:mm:ss`
coherente con F04) + etiqueta legible.

SI el plan no tiene intervalos de un tipo, ENTONCES esa metrica DEBE mostrar `0` (o `0s`), no
ocultar el tile de forma ambigua.

### R4 — Datos de contexto (nombre y total)

DONDE el usuario ve la pantalla de fin de sesion, EL SISTEMA DEBE disponer de:

- `displayName` de la sesion (snapshot / nombre de rutina o workout; fallback coherente con F04
  si vacio);
- `totalDurationSeconds` alineado al `SessionLog` / evento (`totalElapsedSeconds` del
  `SessionCompletedEvent`).

Estos datos alimentan la tarjeta de share (R6) aunque no todos deban verse como tiles en R3.

### R5 — Estudio de compartir (plantillas)

DONDE el usuario esta en la pantalla de fin de sesion,
CUANDO activa **Compartir**, EL SISTEMA DEBE abrir un **estudio de compartir** a pantalla
completa (no solo el share sheet del SO de inmediato) con:

1. carrusel de **plantillas** de tarjeta (al menos: transparente/checkerboard, solida oscura,
   solida de marca);
2. previsualizacion grande de la plantilla seleccionada;
3. acciones **Compartir** y **Guardar en la galeria** (area de toque >= 48dp).

Sin requerir red para habilitar el estudio.

### R5b — Foto en plantilla transparente

DONDE la plantilla activa es la de tipo **transparente**,
EL SISTEMA DEBE permitir **anadir una foto** de fondo mediante:

- **Hacer foto** (camara), o
- **Seleccionar imagen** (galeria),

presentados en un bottom sheet de origen. Con foto cargada, DEBE ofrecer editar (reemplazar)
y eliminar la foto. La foto es **opcional**; se puede compartir sin ella.

### R6 — Contenido de la imagen resumen

CUANDO el usuario confirma Compartir o Guardar en el estudio, EL SISTEMA DEBE generar una
**imagen** local (PNG) de la plantilla visible que incluya al menos:

| Campo | Fuente |
|---|---|
| Duracion total | `totalDurationSeconds` (formato mm:ss) |
| Etiqueta sesion | "Entrenamiento" (o i18n) |
| Sets | cantidad de intervalos `work` del plan |
| Trabajo | `trainingSeconds` (R3) |
| Descanso | `restSeconds` (R3) |
| Branding app | nombre + tagline sutil |
| Foto de fondo | si el usuario la anadio (R5b), solo en plantilla transparente |

Calorias/racha pueden mostrarse en plantillas secundarias o en el sheet de fin de sesion;
la plantilla principal de referencia prioriza sets/trabajo/descanso.

### R7 — Share sheet nativo y galeria

CUANDO el usuario activa **Compartir** en el estudio y la imagen se genero con exito,
EL SISTEMA DEBE invocar el share sheet nativo con esa imagen.

CUANDO activa **Guardar en la galeria**, EL SISTEMA DEBE persistir la PNG en la galeria del
dispositivo (pidiendo permisos si hace falta) y mostrar feedback de exito o error.

### R8 — Offline total del share

CUANDO el dispositivo no tiene conectividad, EL SISTEMA DEBE permitir abrir el estudio,
elegir plantilla, tomar/seleccionar foto (camara/galeria local), generar la imagen y
compartir o guardar **sin** error bloqueante por red.

### R9 — Nota opcional post-sesion

DONDE el usuario esta en la pantalla de fin de sesion,
EL SISTEMA DEBE ofrecer una zona de nota opcional con:

- pregunta o label de contexto (ej. "¿Cómo fue tu entrenamiento?");
- campo o accion para escribir texto;
- la nota **no** es obligatoria para pulsar Listo (R12).

### R10 — Persistencia de nota = `SessionLog.note` (F04)

CUANDO el usuario guarda o confirma una nota en la pantalla de fin de sesion, EL SISTEMA DEBE
persistir el texto en el campo `note` del `SessionLog` creado por F04 al recibir
`SessionCompleted` (mismo registro del historial/calendario).

CUANDO el usuario abre el Historial (F04) y ve la card de esa sesion, EL SISTEMA DEBE mostrar
esa misma nota (F04 R11).

EL SISTEMA DEBE reutilizar `SessionLogRepository.updateNote` (o API equivalente de F04); **no**
crear una tabla o campo paralelo de notas.

### R11 — Limite de nota

CUANDO el usuario intenta guardar una nota de mas de **500** caracteres, EL SISTEMA DEBE
rechazar el guardado o impedir exceder el limite en el campo (misma regla F04 R12) y mostrar
feedback visible sin truncar en silencio de forma confusa.

### R12 — Listo → idle + retorno (cumple F01 R18)

CUANDO el usuario activa **Listo** (o equivalente de cierre primario) en la pantalla de fin de
sesion, EL SISTEMA DEBE:

1. transicionar el `TimerController` a estado `idle` (si aun esta en `completed`);
2. cerrar la pantalla de fin de sesion;
3. regresar a la pantalla de creacion/edicion de rutina (o destino de retorno del flujo de
   ejecucion documentado en F01 R18).

SI el usuario no escribio nota, ENTONCES Listo DEBE funcionar igual (`note` permanece null/vacio).

### R13 — Solo sesiones completadas

CUANDO la sesion emite `SessionCancelled` (abortada), EL SISTEMA NO DEBE abrir la pantalla de
fin de sesion de F16. El historial de abortados con progreso sigue siendo responsabilidad de F04.

### R14 — Sin pantalla duplicada de F01

DONDE F16 esta implementada, EL SISTEMA DEBE usar esta pantalla como la **confirmacion visible**
exigida por F01 R18. EL SISTEMA NO DEBE mostrar una segunda pantalla/dialog generico de
"sesion finalizada" en paralelo (evitar doble cierre).

### R15 — Resolucion del `SessionLog` recien creado

CUANDO se abre la pantalla de fin de sesion, EL SISTEMA DEBE asociar el flujo a un
`SessionLog` con `status = completed` correspondiente a la sesion (via id devuelto al insertar,
o consulta del log mas reciente para el `sourceId` / `endedAt` del evento — ver `design.md`).

SI el log aun no esta disponible (carrera con el insert de F04), ENTONCES EL SISTEMA DEBE
reintentar de forma acotada o esperar al provider/repositorio sin crashear; la UI de
celebracion y metricas DEBE poder mostrarse con datos del evento aunque la nota quede
deshabilitada temporalmente hasta resolver el id.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R16 — Fallo al generar imagen

SI falla la captura/export de la imagen de share (error de render, IO, memoria), ENTONCES EL
SISTEMA DEBE mostrar feedback visible (SnackBar o equivalente), **no** crashear, y dejar al
usuario en la pantalla de fin de sesion con Compartir y Listo disponibles para reintentar o
salir.

### R17 — Fallo o cancelacion del share sheet

SI el share sheet no puede abrirse o el usuario lo descarta sin compartir, ENTONCES EL SISTEMA
DEBE permanecer en la pantalla de fin de sesion sin borrar metricas ni nota en edicion. Descartar
el sheet **no** equivale a Listo (R12).

### R18 — Fallo al guardar nota

SI falla la persistencia al guardar la nota (R10), ENTONCES EL SISTEMA DEBE mostrar SnackBar
con opcion de reintentar (o feedback equivalente) y **mantener** el texto en el editor hasta
confirmar o descartar (alineado a F04 R19). Listo DEBE seguir disponible; no bloquear el
cierre por un fallo de nota.

### R19 — iPad / ancla del popover de share

DONDE la plataforma es iPad (o requiere origen del popover),
CUANDO el usuario activa Compartir, EL SISTEMA DEBE pasar un origen de anclaje valido
(`sharePositionOrigin` o equivalente del paquete) para no crashear ni dejar la UI colgada.

### R20 — Independencia del motor del timer

EL SISTEMA DEBE implementar F16 en `features/session_summary/` (o slug de carpeta acordado en
`design.md`) sin que `TimerController` (F01) importe widgets ni servicios de share/nota de F16.
La integracion es por navegacion/host al detectar `completed` + consumo de repositorios F04/F12.

## Decisiones de producto

| Tema | Decision |
|---|---|
| Alcance de F16 | Pantalla post-completado **completa** (hero + metricas + share + nota + Listo), no solo un boton "Compartir" suelto |
| Relacion F01 R18 | F01 R18 **no se reescribe**; F16 **es** la implementacion de la confirmacion + Listo → idle |
| Canceladas / abortadas | Sin pantalla F16 (R13) |
| Work vs rest | Por `Interval.type` del plan de la sesion completada (R3); no se inventan tipos nuevos |
| Nota | Mismo `SessionLog.note` (max 500); opcional; editable tambien despues en Historial (F04) |
| Share | Imagen local + share sheet nativo; sin SDKs de redes; sin backend |
| Kcal / racha | Reutilizar reglas y `StatsService` de F12; no recalcular con formulas distintas |
| Marca de agua / branding en card | Permitido texto o logo de app en la plantilla de imagen (design system) |
| Bookmark / favoritos en chrome de referencia | Fuera de alcance F16 (F24 si aplica) |
| Compartir rutina a otros usuarios | F25, no F16 |
| Idioma de copy | Strings en capa UI; i18n formal es F28 |

## Fuera de alcance (explicito)

- Compartir rutinas entre usuarios o deep links de rutina (F25).
- Logros/badges desbloqueados en esta pantalla (F13 puede reaccionar aparte).
- Edicion del entrenamiento desde la pantalla de fin.
- Publicacion automatica a redes sin share sheet.
- Calculo medico de calorias o integracion con HealthKit/Google Fit.
- Mostrar graficas de F12 en esta pantalla.
- Cambiar el schema de `session_logs` (salvo que una task de implementacion demuestre
  necesidad; default: reutilizar columnas existentes).
- Reescribir F01 R18 u otros criterios de F01.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; compartir como plus, no requisito basico.
- `_global/02-architecture-and-structure.md` — features aisladas; contratos `SessionCompletedEvent`.
- `_global/03-conventions.md` — Riverpod; tests; reutilizar `shared/widgets/`.
- `_global/04-design-system.md` — tokens, botones, contraste, tipos de intervalo.
- `_global/05-data-model.md` — `SessionLog.note`, `StatsSummary`.
- `_global/06-roadmap-and-dependencies.md` — F16 prereqs F04, F12.
- `features/01-interval-timer-core/` — R6, R18; eventos de sesion.
- `features/04-workout-calendar-history/` — insert log, R11–R12 nota, `updateNote`.
- `features/12-statistics-progress/` — R5 kcal, R6 racha, `StatsService`.
- Referencia visual de producto: capturas post-timer (hero fuego, "¡Gran trabajo!", tiles
  entrenamiento/descanso, Compartir, nota, Listo).
