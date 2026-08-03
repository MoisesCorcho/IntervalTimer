# Tasks: Recordatorios y Notificaciones

**ID:** F14 &nbsp;|&nbsp; **Slug:** `14-reminders-notifications`

## Definition of Done

- [ ] Todos los criterios R1–R13 de `requirements.md` estan implementados y verificados. _(cubre R1–R13)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] `Reminder` documentado en `_global/05-data-model.md`; migracion Drift aplicada.
- [ ] Canales/IDs F14 **no** colisionan con F20 (`SessionSurfaceConstants`). _(cubre R8)_
- [ ] Ningun string de usuario usa voseo (UiStrings review). _(cubre R6)_
- [ ] No se agrego un quinto tab. _(cubre R1, R13)_
- [ ] Smoke en **dispositivo fisico** de permiso + al menos un schedule (emulador no basta solo).
- [ ] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Dominio y datos

- [ ] Documentar `Reminder` + tabla `reminders` + constantes de canal en `_global/05-data-model.md`. _(cubre R2, R8)_
- [ ] Migracion Drift schema **v10** (tras F15 v8 / F13 v9 en esta rama): tabla `reminders`. _(cubre R2)_
- [ ] Modelo + validador: max 3, >=1 weekday, hour/minute ranges. _(cubre R2, R10)_
- [ ] `ReminderRepository` CRUD + count. _(cubre R2, R10)_

### Scheduling y permisos

- [ ] `ReminderNotificationConstants` (channel/ids/payload) distintos de F20. _(cubre R8)_
- [ ] `ReminderScheduler`: syncAll, cancelAll, cancelToday, schedule weekly/zoned. _(cubre R3, R4, R12)_
- [ ] Request permiso solo al activar/guardar ON; gracia si niega. _(cubre R5)_
- [ ] Exact alarm best-effort + nota UI si inexact. _(cubre R12)_
- [ ] Hook post `SessionLog` completed → cancel reminders de hoy. _(cubre R4)_
- [ ] Tap payload → navegar a tab Temporizador. _(cubre R7)_

### UI

- [ ] Seccion Recordatorios en Ajustes (lista, empty, max 3). _(cubre R1, R2, R13)_
- [ ] Sheet crear/editar: hora, dias L–D, enable. _(cubre R2, R10)_
- [ ] UiStrings: notif + UI **sin voseo** (titulo/cuerpo fijos R6). _(cubre R6)_
- [ ] Estados permiso denegado / error programacion. _(cubre R5, R11)_
- [ ] Verificar shell 4 tabs. _(cubre R1, R13)_

### Tests (selectivos)

- [ ] **Unit — validador:** 0 dias rechaza; 4.º reminder rechaza; hour/minute invalidos. _(cubre R10, R2)_
- [ ] **Unit — supresion rule:** completed hoy → must suppress; solo aborted → no suppress. _(cubre R4)_
- [ ] **Unit — weekdays encoding:** round-trip set ↔ storage. _(cubre R2, R3)_
- [ ] **Unit — notification ids:** ningun id F14 == 888 F20; channelId != session channel. _(cubre R8)_
- [ ] **Unit — copy guard (opcional simple):** lista de strings de reminder no contiene patrones de voseo basicos (`á` en imperativos de riesgo o lista negra: "entrená","podés","acordate","llevás","tenés"). _(cubre R6)_
- [ ] **Widget — settings section:** empty CTA; crear hasta 3; bloquear 4.º. _(cubre R1, R2, R10)_
- [ ] **Widget — permission denied UI:** mensaje de gracia visible. _(cubre R5)_

**Fuera de esta ronda:** matrix completa de OEM battery killers, golden notificaciones, push remoto, variantes de racha, tests de timezone de todo el mundo (1–2 casos locales bastan).

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Seccion Ajustes; sin 5.º tab |
| R2 | CRUD max 3; repo; widget lista |
| R3 | ReminderScheduler sync |
| R4 | Hook completed; unit supresion |
| R5 | Permission flow; widget gracia |
| R6 | UiStrings fijos; copy guard test |
| R7 | Payload → timer tab |
| R8 | Constants + unit ids |
| R9 | Free/local (DoD / review) |
| R10 | Validador + widget form |
| R11 | Error UI programacion |
| R12 | Exact/inexact + nota UI |
| R13 | Design system; shell |

## Notas de secuenciacion

Dependencia: **F04** (Completado). F20 ya en codigo con `flutter_local_notifications` — reutilizar plugin, no duplicar init ciego.

Orden recomendado:

1. data-model + migracion + repo  
2. constants + scheduler (mockeable) + tests unitarios  
3. permisos + controller  
4. UI Ajustes  
5. hook post-sesion completed  
6. widget tests + smoke fisico  

Migraciones en esta rama (docs): **v8 F15 → v9 F13 → v10 F14**.
