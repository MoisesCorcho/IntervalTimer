# Tasks: Widget de Pantalla de Bloqueo / Notificacion Persistente

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget`

## Definition of Done

- [ ] Todos los criterios R1–R18 de `requirements.md` estan implementados y verificados
      (fase A Android completa; fase B iOS Live Activities o degradacion documentada y testeada). _(cubre R1–R18)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] Preferencia documentada en `_global/05-data-model.md`.
- [ ] No se rompieron F01 (pause/resume/skip/complete/cancel) ni F19 (wakelock).
- [ ] Canales/IDs de notificacion no colisionan con F14 si esta presente.
- [ ] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, sin acoplar plugins a F01).
- [ ] QA en **dispositivo fisico** Android (fase A) e iOS (fase B o degradacion).

## Checklist de implementacion

### Datos y persistencia

- [ ] Persistir `session_lock_screen_enabled` (bool, default `true`) via `PreferencesRepository`. _(cubre R9, R10)_
- [ ] Actualizar `_global/05-data-model.md` con Preferencias F20. _(cubre R10)_

### Dominio (puro)

- [ ] Implementar `SessionSurfacePolicy.shouldShowSessionSurface(...)`. _(cubre R1, R14, R17)_
- [ ] Implementar `SessionNotificationMapper` (estado F01 → snapshot de notificacion/Live Activity). _(cubre R1, R2, R3)_
- [ ] Definir `SessionRemoteAction` { pause, resume, skip, openApp } y routing hacia API F01. _(cubre R4, R5, R11)_

### Fase A — Android (MVP)

- [ ] Agregar `flutter_local_notifications` y `flutter_background_service` (versiones compatibles con el SDK del proyecto). _(cubre R1, R8)_
- [ ] Configurar canal `session_timer_ongoing` (distinto de F14), icono FGS, id fijo de notificacion de sesion. _(cubre R1, R13)_
- [ ] Declarar permisos y `foregroundServiceType` en AndroidManifest; documentar tipo elegido en design si difiere del draft. _(cubre R8, R14)_
- [ ] Implementar start/stop FGS al entrar/salir de estados R1; notificacion `ongoing`. _(cubre R1, R7, R8, R17)_
- [ ] Actualizar notificacion >= 1 Hz en `running`; metadata al pausar. _(cubre R2, R3)_
- [ ] Actions Pausar / Reanudar / Siguiente cableadas a F01. _(cubre R4, R5, R6)_
- [ ] Tap en cuerpo de notificacion → open app / ruta de ejecucion. _(cubre R11)_
- [ ] Solicitud de permiso de notificaciones contextual (no spam en cold start). _(cubre R14)_
- [ ] Limpieza en SessionCompleted / SessionCancelled / idle / pref off. _(cubre R7, R9, R17)_

### Controller y settings

- [ ] Implementar `SessionLockScreenController` (Riverpod): policy + show/update/hide + errores no fatales. _(cubre R1, R6, R7, R15, R18)_
- [ ] Tile de ajustes con toggle y estado de permiso denegado. _(cubre R9, R10, R14)_
- [ ] Controles de ajustes >= 48dp. _(cubre R9)_
- [ ] Garantizar independencia de prefs F19/F02/F18. _(cubre R18)_

### Fase B — iOS Live Activities

- [ ] Integrar `live_activities` (o pin documentado) + Widget Extension Swift + App Group. _(cubre R12)_
- [ ] Mapear snapshot → Activity attributes; update en running/paused; end en complete/cancel. _(cubre R1, R2, R3, R7, R12)_
- [ ] Acciones pause/skip via App Intents / URL scheme hacia F01. _(cubre R4, R5, R6)_
- [ ] Degradacion iOS < 16.1 o fallo de ActivityKit sin romper timer (R12, R15). _(cubre R12, R15)_

### Tests

- [ ] **Unit — policy:** running/paused/preparing + pref on + permission → show; idle/completed/pref off/permission denied → hide. _(cubre R1, R14, R17)_
- [ ] **Unit — mapper:** snapshot refleja nombre, remaining, flags pause vs resume. _(cubre R1, R3)_
- [ ] **Unit — remote actions:** pause/resume/skip despachan a mock de TimerController API. _(cubre R4, R5)_
- [ ] **Unit — cleanup:** completed/cancelled/pref false → hide invocado. _(cubre R7, R9)_
- [ ] **Unit — error:** fallos de driver/notificacion no cambian estado del timer mock. _(cubre R15)_
- [ ] **Unit — prefs:** default true; persistencia round-trip. _(cubre R10)_
- [ ] **Unit — independencia:** togglear F20 no muta keep_screen_on / voice / vibration en mock de prefs. _(cubre R18)_
- [ ] **Widget — settings:** toggle y estado sin permiso visibles. _(cubre R9, R14)_

### QA dispositivo

- [ ] **Android fisico:** notificacion visible en lock screen/shade con sesion running; pause/resume/skip; update de tiempo; cleanup al complete/cancel; FGS no muere al background breve; permiso denegado no crashea. _(cubre R1–R8, R11, R14, R15)_
- [ ] **iOS fisico (fase B):** Live Activity / Dynamic Island o degradacion documentada; acciones; end al complete. _(cubre R12, R4, R5, R7)_
- [ ] **Kill app:** al reabrir, idle y sin notificacion huerfana indefinida (politica vision). _(cubre R16)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Policy, mapper, FGS/notif, controller, unit policy, QA Android |
| R2 | Update 1 Hz, mapper remaining, QA Android |
| R3 | Mapper paused flags, update metadata, unit mapper |
| R4 | Remote actions pause/resume, QA |
| R5 | Remote action skip, QA |
| R6 | Controller sync + actions, QA |
| R7 | Cleanup completed/cancelled, unit cleanup, QA |
| R8 | FGS + manifest, QA Android |
| R9 | Settings toggle, controller pref off, unit cleanup |
| R10 | Prefs persist, data model, unit prefs |
| R11 | Tap open app, QA Android |
| R12 | Fase B Live Activities + degradacion, QA iOS |
| R13 | Canal session_timer_ongoing vs F14 |
| R14 | Permission flow, policy gate, widget settings, QA |
| R15 | Error handling controller/driver, unit error |
| R16 | QA kill app; sin resume v1 |
| R17 | Policy idle/completed, cleanup |
| R18 | Independencia prefs, unit independencia |

## Notas de secuenciacion

Esta feature depende de: **F01** y **F19** (roadmap).

Orden recomendado:

1. Prefs + dominio puro (policy/mapper/actions)
2. Fase A Android (plugins, FGS, notificacion, controller, settings)
3. Tests unit/widget
4. QA Android fisico
5. Fase B iOS Live Activities + QA iOS
6. Verificacion R16 (kill) y R13 (canales)

No iniciar hasta F01 Done. F19 Done preferible por fase; F20 no llama a `wakelock_plus`.

No implementar home widgets, cancel-from-notification, ni resume tras kill en estas tasks.
