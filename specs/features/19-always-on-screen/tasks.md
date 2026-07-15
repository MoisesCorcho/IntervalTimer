# Tasks: Pantalla Siempre Encendida

**ID:** F19 &nbsp;|&nbsp; **Slug:** `19-always-on-screen`

## Definition of Done

- [ ] Todos los criterios R1–R14 de `requirements.md` estan implementados y verificados. _(cubre R1–R14)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] Preferencia documentada en `_global/05-data-model.md`.
- [ ] No se rompieron F01 (timer, pause, resume, cancel, completed) ni preferencias F02/F18 si estan presentes.
- [ ] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, sin acoplar UI F01↔always_on).
- [ ] Liberacion de wakelock verificada en **dispositivo fisico** en todos los flujos de salida (pause, complete, cancel, pop, force-stop de app si aplica).

## Checklist de implementacion

### Datos y persistencia

- [ ] Persistir preferencia global `keep_screen_on_enabled` (bool, default `true`) via `PreferencesRepository` / `app_preferences`. _(cubre R5, R6, R8, R12)_
- [ ] Actualizar `_global/05-data-model.md` con la seccion Preferencias F19 (si aun no esta). _(cubre R6)_

### Driver y politica

- [ ] Agregar dependencia `wakelock_plus` (version compatible con el SDK del proyecto; preferir ^1.6.x si aplica). _(cubre R1, R11)_
- [ ] Implementar `WakelockDriver` + `PluginWakelockDriver` + `NoOpWakelockDriver` (enable/disable/isEnabled; excepciones → no-op). _(cubre R1, R2, R11)_
- [ ] Implementar `KeepScreenOnPolicy.shouldKeepScreenOn(...)` puro (status + pref + hostMounted). _(cubre R1, R2, R12, R13, R14)_

### Controller / integracion F01

- [ ] Implementar `AlwaysOnController` (Riverpod): escucha status F01, prefs, host montado; aplica enable/disable de forma idempotente. _(cubre R1, R2, R3, R7, R10, R12, R13, R14)_
- [ ] Enlazar `executionHostMounted` al ciclo de vida de la pantalla/flujo de ejecucion (dispose → false + disable). _(cubre R4)_
- [ ] Manejar `SessionCompleted` / `SessionCancelled` → disable. _(cubre R3)_
- [ ] Reafirmar enable en `AppLifecycleState.resumed` si la politica sigue true. _(cubre R9)_
- [ ] Garantizar que F01 no importa `wakelock_plus` ni widgets de always_on. _(cubre R10)_

### UI

- [ ] Seccion/tile de configuracion "Pantalla siempre encendida" (toggle) en shell settings o `features/always_on/presentation`. _(cubre R5, R6, R7)_
- [ ] Control con area de toque >= 48dp segun design system. _(cubre R5)_
- [ ] Toggle aplica de inmediato durante sesion running (pref true↔false). _(cubre R7)_

### Tests

- [ ] **Unit — policy happy path:** status running + pref true + host mounted → true; preparing + pref true + mounted → true. _(cubre R1, R14)_
- [ ] **Unit — policy off paths:** paused / idle / completed / pref false / host not mounted → false. _(cubre R2, R12, R13)_
- [ ] **Unit — controller:** transicion a running llama enable una vez; a paused llama disable; completed/cancelled disable. _(cubre R1, R2, R3)_
- [ ] **Unit — toggle en vivo:** running + pref false→true enable; true→false disable. _(cubre R7)_
- [ ] **Unit — error/edge:** driver.enable/disable lanza → no propaga; timer status no cambia. _(cubre R11)_
- [ ] **Unit — prefs:** default true sin valor persistido; guardar restaura tras "reinicio" mock del repo. _(cubre R6, R8)_
- [ ] **Unit — lifecycle:** on resumed con politica true → enable (reafirmar). _(cubre R9)_
- [ ] **Unit — dispose host:** executionHostMounted false → disable. _(cubre R4)_
- [ ] **Widget — settings:** toggle actualiza estado visible y no rompe layout 48dp. _(cubre R5)_

### QA dispositivo

- [ ] Verificar en dispositivo fisico Android y/o iOS: pantalla no se apaga en running con pref on; se apaga (timeout SO) tras pause/complete/cancel/salir; pref off no mantiene pantalla; no hay fuga tras cerrar la app de la sesion. _(cubre R1, R2, R3, R4, R12)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Policy, controller, driver, unit happy path, QA fisico |
| R2 | Policy off, controller paused, QA fisico |
| R3 | Controller completed/cancelled, unit controller |
| R4 | Host dispose, unit dispose, QA fisico |
| R5 | UI settings, prefs, widget settings |
| R6 | Persistencia prefs, unit prefs, data model |
| R7 | Controller toggle en vivo, unit toggle, UI |
| R8 | Default true, unit prefs |
| R9 | Lifecycle resumed, unit lifecycle |
| R10 | Sin acoplar F01, independencia de otras prefs |
| R11 | Driver no-op/errors, unit error/edge |
| R12 | Policy pref false, unit policy off, QA fisico |
| R13 | Policy idle/completed, unit policy off |
| R14 | Policy preparing, unit happy path |

## Notas de secuenciacion

Esta feature depende de: **F01** (Done como prerequisito de producto).

Orden recomendado: prefs + data model → `WakelockDriver` + `KeepScreenOnPolicy` →
`AlwaysOnController` + host de ejecucion → UI settings → tests unit/widget → QA fisico.

No iniciar tasks de este archivo hasta que F01 este en estado Done.

No implementar notificacion de lock screen (F20), smartwatch (F21), ni CPU/partial wakelock.

No llamar `WakelockPlus.enable()` de forma global en `main()`.
