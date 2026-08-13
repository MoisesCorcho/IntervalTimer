# Requirements: Logros y Badges

> Estado: Completado

**ID:** F13 &nbsp;|&nbsp; **Slug:** `13-achievements-badges` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Sistema simple de gamificacion **local y free**: catalogo de logros desbloqueables por hitos de
entrenamiento (sesiones completadas, racha, minutos totales). Los desbloqueos son **inmutables**.
Entrada desde **Historial** (junto al progreso F12); sin tab nuevo. Evaluacion principal al
**completar** una sesion. Sin logros de categoria HIIT/preset (F03 no es prerequisito). Offline-first.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial (`SessionLog`, `HistoryScreen`)
- F12 - Estadisticas y Progreso (`StatsService` racha/metricas; mismos datos base)

## Postrequisitos / consumidores

- Ninguno bloqueante. F26 (retos) puede inspirarse en hitos a futuro; fuera de alcance de F13.

## User Stories

- **Como** usuario, **quiero** desbloquear logros al cumplir hitos reales de entrenamiento,
  **para que** me siento motivado a seguir.
- **Como** usuario, **quiero** ver mis logros desbloqueados y el progreso de los pendientes,
  **para que** se hacia donde voy (ej. 5/10 sesiones).
- **Como** usuario, **quiero** enterarme cuando desbloqueo uno o varios logros al terminar una sesion,
  **para que** el momento se siente celebratorio sin perder el cierre de sesion (F16).
- **Como** usuario, **quiero** que un logro ya ganado no se me quite si borro historial,
  **para que** el reconocimiento se conserva.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Catalogo inicial (>= 10) solo con datos F04/F12

EL SISTEMA DEBE incluir un catalogo estatico de **al menos 10** logros, cada uno con:

- `id` estable (string),
- titulo y descripcion en espanol (UI),
- condicion verificable solo con `SessionLog` y/o reglas de `StatsService` (F12),
- icono (Material / icon data; sin pack de arte obligatorio).

EL SISTEMA NO DEBE incluir en el MVP logros que dependan de categoria HIIT, presets F03, ni metadata
de rutina no presente en `SessionLog`.

**Catalogo minimo obligatorio (12 logros):**

| id | Condicion (resumen) |
|---|---|
| `first_session` | 1 sesion `completed` |
| `sessions_10` | 10 sesiones `completed` |
| `sessions_25` | 25 sesiones `completed` |
| `sessions_50` | 50 sesiones `completed` |
| `sessions_100` | 100 sesiones `completed` |
| `streak_3` | racha actual >= 3 (regla F12 R6) |
| `streak_7` | racha actual >= 7 |
| `streak_14` | racha actual >= 14 |
| `streak_30` | racha actual >= 30 |
| `minutes_60` | floor(suma `totalDurationSeconds` de `completed` / 60) >= 60 |
| `minutes_300` | idem >= 300 |
| `minutes_1000` | idem >= 1000 |

### R2 — Entrada desde Historial (sin quinto tab)

DONDE el usuario esta en **Historial**, EL SISTEMA DEBE ofrecer un acceso claro a la **pantalla de
logros** (tile, boton o seccion "Logros" cerca del bloque de progreso F12 / peso F15 si existe).

EL SISTEMA NO DEBE agregar un quinto destino en la barra de navegacion inferior.

### R3 — Pantalla de logros (desbloqueados + pendientes con progreso)

DONDE el usuario abre la pantalla de logros, EL SISTEMA DEBE listar **todos** los del catalogo y,
para cada uno:

| Estado | UI minima |
|---|---|
| Desbloqueado | Indicador visual unlocked + fecha de desbloqueo (o al menos estado ganado) |
| Pendiente | Indicador locked/atenuado + **progreso** legible (ej. `5/10 sesiones`, `3/7 dias`) |

EL SISTEMA NO DEBE ocultar logros "secretos" en el MVP: el catalogo completo es visible.

### R4 — Evaluacion al completar sesion

CUANDO se persiste una sesion **completada** (`SessionLog` con `status = completed`, tipicamente tras
`SessionCompletedEvent` F01 y escritura F04), EL SISTEMA DEBE ejecutar el evaluador de logros
comparando el estado actual de metricas con el catalogo y los ya desbloqueados.

EL SISTEMA NO DEBE desbloquear logros de conteo/minutos/primera sesion basandose solo en logs
`aborted`.

### R5 — Reglas de metricas por tipo de logro

EL SISTEMA DEBE calcular asi:

| Tipo | Fuente |
|---|---|
| Conteos de sesiones / primera sesion / minutos | Solo `SessionLog` con `status = completed` |
| Racha | **Misma definicion que F12 R6** (dias con al menos un log `completed` o `aborted` con progreso; ancla hoy/ayer) |

EL SISTEMA DEBE reutilizar la logica de racha de `StatsService` (o extraer funcion compartida) para no
divergir de F12.

### R6 — Desbloqueo inmutable

CUANDO la condicion de un logro se cumple y aun no esta desbloqueado, EL SISTEMA DEBE persistir un
registro de desbloqueo (`achievementId` + `unlockedAt`) que **no se borra ni se revierte** si el
usuario elimina o altera `SessionLog` despues.

SI el historial ya no sustenta la condicion, ENTONCES el logro **permanece** desbloqueado y el
progreso de pendientes se recalcula solo para logros **no** desbloqueados.

### R7 — Notificacion de desbloqueo (uno o varios)

CUANDO la evaluacion post-sesion desbloquea **uno o mas** logros nuevos, EL SISTEMA DEBE informar al
usuario con un **unico** dialogo / bottom sheet que liste los recien desbloqueados (titulo + icono),
sin una cola de overlays independientes por cada logro.

**Coexistencia con F16:** SI la pantalla de fin de sesion F16 esta activa en el flujo, ENTONCES la
notificacion de logros DEBE integrarse de forma no destructiva (ej. seccion/chip "Logros nuevos" en
F16, o sheet de logros **al cerrar** F16 con "Listo", sin tapar de forma permanente el hero de F16).
SI F16 no forma parte del build, ENTONCES basta el sheet/dialog de logros tras completar.

### R8 — Free, local, offline

Esta feature DEBE estar disponible sin suscripcion Pro (F06). Todos los datos DEBEN vivir en local
(drift + catalogo en codigo). No requiere red.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R9 — Re-evaluacion y progreso al abrir la lista

CUANDO el usuario abre la pantalla de logros, EL SISTEMA DEBE refrescar el progreso de pendientes
con el historial actual. EL SISTEMA NO DEBE usar esa apertura para **revocar** desbloqueos.

EL SISTEMA NO DEBE desbloquear logros nuevos **solo** como efecto de borrar un `SessionLog`
(el desbloqueo de nuevos ocurre en R4; la apertura solo actualiza progreso UI / estado derivado).

### R10 — Fallo de persistencia / lectura

SI falla la lectura de `SessionLog` o de desbloqueos al evaluar o al mostrar la lista, ENTONCES EL
SISTEMA DEBE:

1. no crashear la app;
2. mostrar estado de error no bloqueante en la UI de logros (mensaje + reintentar si aplica);
3. no marcar logros como desbloqueados si la escritura del unlock fallo (transaccion/resultado
   explicito).

### R11 — Idempotencia

CUANDO se re-evalua un logro ya desbloqueado, EL SISTEMA DEBE no crear filas duplicadas de unlock ni
cambiar `unlockedAt` original.

### R12 — Design system y shell

La UI DEBE usar tokens de `_global/04-design-system.md`, touch targets >= 48 dp, y estados
vacio/carga/error coherentes. Sin quinto tab (R2).

## Decisiones de producto

| Tema | Decision |
|---|---|
| Entrada UI | Historial → pantalla de logros |
| Bottom nav | Sin tab nuevo |
| Momento de desbloqueo nuevo | Tras sesion **completada** (post persist F04) |
| Multi-unlock | Un solo sheet/dialog con la lista |
| F16 | Integracion no destructiva (chip en F16 o sheet al cerrar F16) |
| Catalogo | 12 fijos en codigo; solo sesiones/racha/minutos |
| HIIT / presets | Fuera de MVP |
| Conteos y minutos | Solo `completed` |
| Racha | Igual F12 R6 (incluye aborted con log) |
| Secretos | No |
| Iconos | Material / theme; locked atenuado |
| Revocar al borrar historial | Nunca |
| Pro / IAP | Free |
| Onboarding de logros | No obligatorio |

## Fuera de alcance (explicito)

- Logros por categoria HIIT, ejercicio, o preset (F03/F05/F32 metadata rica).
- Leaderboards, retos sociales (F26), sync cloud.
- Notificaciones push/locales de logros (eso es dominio F14 si aplica; F13 es in-app).
- Logros secretos, rareza, XP, niveles de jugador.
- Gate Pro (F06).
- Arte custom obligatorio / Lottie de badge (opcional futuro).
- Quinto tab.
- Cualquier comportamiento no listado en R1–R12.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; motivacion sin friccion.
- `_global/02-architecture-and-structure.md` — `features/achievements/`; `SessionCompletedEvent` → F13.
- `_global/03-conventions.md` — Riverpod; dominio en ingles; UI en espanol.
- `_global/04-design-system.md` — tokens, estados, touch >= 48 dp.
- `_global/05-data-model.md` — `UnlockedAchievement`; catalogo no tabla.
- F04 — `SessionLog`.
- F12 — `StatsService` racha R6; metricas.
- F16 — pantalla post-sesion (coexistencia R7).
