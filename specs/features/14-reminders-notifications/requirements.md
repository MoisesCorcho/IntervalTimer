# Requirements: Recordatorios y Notificaciones

> Estado: No iniciada

**ID:** F14 &nbsp;|&nbsp; **Slug:** `14-reminders-notifications` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Notificaciones **locales** configurables para recordar entrenar. El usuario crea hasta **3**
recordatorios (hora + dias de la semana) desde **Ajustes**. Si ya hay una sesion **completada** ese
dia, el recordatorio de ese dia **no** se envia. Free, offline, sin onboarding forzado de permisos.
Canales e IDs **distintos** de la notificacion de sesion en curso (F20).

**Copy de producto:** todo texto visible al usuario (UI, titulos/cuerpos de notificacion, empty
states, errores de permiso) DEBE usar **espanol neutro sin voseo** (evitar formas tipo "entrená",
"podés", "acordate", "llevás"). Preferir impersonal o formas estandar: p. ej. "Hora de entrenar",
"Recordatorio de entrenamiento", "Sin permiso de notificaciones".

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial (`SessionLog`, `localDate`)

## Postrequisitos / consumidores

- Ninguno bloqueante. F20 ya exige no colisionar canales/IDs con F14 (contrato bilateral).

## User Stories

- **Como** usuario, **quiero** configurar recordatorios en dias y hora que elija, **para que** no se
  me olvide entrenar.
- **Como** usuario, **quiero** no recibir el aviso si ya complete una sesion hoy, **para que** no me
  moleste la app sin necesidad.
- **Como** usuario, **quiero** que me pidan permiso de notificaciones solo cuando active un
  recordatorio, **para que** no me interrumpan al abrir la app por primera vez.
- **Como** usuario, **quiero** entender que hacer si niego el permiso, **para que** pueda activarlo
  despues desde el sistema.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Entrada en Ajustes (sin quinto tab)

DONDE el usuario esta en **Ajustes**, EL SISTEMA DEBE exponer una seccion **Recordatorios** (lista +
crear/editar) para gestionar recordatorios de entrenamiento.

EL SISTEMA NO DEBE agregar un quinto destino en la barra de navegacion inferior ni exigir
recordatorios desde Historial en el MVP.

### R2 — CRUD de recordatorios (maximo 3)

EL SISTEMA DEBE permitir crear, editar, eliminar y activar/desactivar recordatorios con:

| Campo | Regla |
|---|---|
| Hora | Hora local del dispositivo (time picker) |
| Dias | Multi-select L–D; al menos **1** dia |
| enabled | bool; solo los enabled se programan |

EL SISTEMA DEBE limitar a **como maximo 3** recordatorios persistidos. SI ya hay 3, ENTONCES NO DEBE
permitir crear otro hasta eliminar uno (mensaje claro, sin voseo).

No hay recordatorio de fabrica: lista vacia hasta que el usuario cree el primero (empty state con CTA).

### R3 — Programacion recurrente semanal

CUANDO un recordatorio esta `enabled` y el permiso de notificaciones esta concedido, EL SISTEMA DEBE
programar notificaciones locales recurrentes para cada dia de la semana seleccionado a la hora
configurada (zona horaria local del dispositivo).

CUANDO el usuario edita hora/dias/enabled o elimina un recordatorio, EL SISTEMA DEBE
cancelar/reprogramar las notificaciones asociadas de forma coherente (sin husos basura).

### R4 — Supresion si ya completo sesion hoy

SI existe al menos un `SessionLog` con `status = completed` y `localDate` = **hoy** (zona local),
ENTONCES EL SISTEMA NO DEBE mostrar el recordatorio de entrenamiento de ese dia.

Logs `aborted` **no** cuentan como "ya entreno" para suprimir el recordatorio.

**Mecanismo principal (observable):** CUANDO se persiste una sesion `completed` el mismo dia local,
EL SISTEMA DEBE cancelar o invalidar los recordatorios pendientes de **ese dia calendario** y dejar
intacta la programacion de dias futuros.

### R5 — Permiso explicito y rechazo con gracia

EL SISTEMA NO DEBE solicitar permiso de notificaciones en el primer arranque de la app.

CUANDO el usuario intenta **activar** o **guardar en ON** el primer recordatorio (o cualquier
recordatorio si aun no hay permiso), EL SISTEMA DEBE solicitar el permiso de forma explicita.

SI el usuario deniega el permiso, ENTONCES EL SISTEMA DEBE:

1. no crashear;
2. no fingir que los recordatorios funcionan;
3. mostrar estado de gracia en la seccion (mensaje neutro + como abrir ajustes del sistema si la
   plataforma lo permite).

### R6 — Contenido de la notificacion (copy fijo, sin voseo)

CUANDO se muestra un recordatorio, EL SISTEMA DEBE usar copy **fijo** de producto en espanol neutro
**sin voseo**, por ejemplo:

| Parte | Ejemplo permitido |
|---|---|
| Titulo | `Recordatorio de entrenamiento` |
| Cuerpo | `Hora de entrenar` |

EL SISTEMA NO DEBE usar voseo rioplatense en titulos, cuerpos, ni en la UI de la seccion
Recordatorios. Personalizacion libre del texto por el usuario: **fuera de alcance** MVP.

### R7 — Accion al tocar la notificacion

CUANDO el usuario toca la notificacion de recordatorio, EL SISTEMA DEBE abrir la app en el destino
principal de entrenamiento (shell del **Temporizador** / home de sesion), no en Ajustes.

### R8 — Separacion de F20 (sesion en curso)

EL SISTEMA DEBE usar **canal(es) de notificacion e IDs** distintos a los de la superficie de sesion
F20 (`session_timer_ongoing_*`, notification id de sesion, etc.). Un recordatorio F14 NO DEBE
reemplazar ni cancelar la notificacion ongoing de un timer activo por colision de IDs.

### R9 — Free y offline

Esta feature DEBE estar disponible sin Pro (F06). Programacion y config 100% locales; sin backend.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R10 — Validacion de formulario

SI el usuario intenta guardar sin hora valida, sin ningun dia seleccionado, o superando el maximo de
3, ENTONCES EL SISTEMA DEBE rechazar el guardado con mensaje de validacion (sin voseo) y no
persistir.

### R11 — Fallo de programacion / plugin

SI falla la programacion o cancelacion de notificaciones (plugin/OS), ENTONCES EL SISTEMA DEBE:

1. no crashear la app;
2. informar error no bloqueante en la seccion Recordatorios;
3. dejar la config persistida coherente o marcar el reminder como problemático de forma visible
   (no silencioso total).

### R12 — Exactitud de hora (best effort de plataforma)

EL SISTEMA DEBE intentar alarmas **exactas** cuando el SO y los permisos lo permitan (p. ej. Android
exact alarms).

SI el SO solo permite inexactas o el usuario niega permisos de alarma exacta, ENTONCES EL SISTEMA
DEBE degradar a scheduling inexacto y, si aplica, mostrar nota honesta en UI (sin voseo): el aviso
puede retrasarse unos minutos. No DEBE prometer "segundo exacto" en marketing de la pantalla.

### R13 — Design system y shell

UI de Ajustes/recordatorios DEBE usar tokens de `_global/04-design-system.md`, touch >= 48 dp, y
estados vacio/carga/error coherentes. Sin quinto tab (R1).

## Decisiones de producto

| Tema | Decision |
|---|---|
| Entrada UI | Solo **Ajustes** → Recordatorios |
| Max reminders | **3** |
| Default de fabrica | **Ninguno** (lista vacia) |
| Dias / hora | Recurrente semanal L–D + hora local |
| "Ya entreno hoy" | Solo `SessionLog` **completed** |
| Supresion | Cancel/reprogram al completar sesion ese dia |
| Permiso | Al activar/guardar ON; no en cold start |
| Copy notificacion | Fijo, **espanol neutro sin voseo** |
| Copy UI | Mismo criterio anti-voseo |
| Deep link tap | Temporizador / home entrenamiento |
| F20 | Canales e IDs separados (obligatorio) |
| Pro | Free |
| Texto editable por usuario | No en MVP |
| Variantes con racha F12 | Fuera de MVP (opcional futuro) |
| Recordatorio one-shot por fecha | Fuera de MVP |

## Fuera de alcance (explicito)

- Push remoto / FCM / marketing campaigns.
- Recordatorios one-shot por fecha del calendario.
- Texto de notificacion editable por el usuario.
- Variantes de copy con racha (F12) en MVP.
- Quiet hours / modo no molestar custom (ademas del del SO).
- Snooze configurable.
- Integracion Health / calendario externo.
- Colision o reutilizacion del canal F20.
- Voseo en cualquier string de usuario.
- Quinto tab.
- Gate Pro.
- Cualquier comportamiento no listado en R1–R13.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; empezar sin configurar.
- `_global/02-architecture-and-structure.md` — `features/reminders/`; F20 lock_screen separado.
- `_global/03-conventions.md` — Riverpod; dominio en ingles; UI espanol.
- `_global/04-design-system.md` — tokens, estados, touch >= 48 dp.
- `_global/05-data-model.md` — entidad `Reminder`.
- F04 — `SessionLog` completed / localDate.
- F20 — `SessionSurfaceConstants` (no colisionar channelId / notificationId).
