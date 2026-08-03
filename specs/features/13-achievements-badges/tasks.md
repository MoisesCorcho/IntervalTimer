# Tasks: Logros y Badges

**ID:** F13 &nbsp;|&nbsp; **Slug:** `13-achievements-badges`

## Definition of Done

- [ ] Todos los criterios R1–R12 de `requirements.md` estan implementados y verificados. _(cubre R1–R12)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] `UnlockedAchievement` documentado en `_global/05-data-model.md`; migracion Drift aplicada.
- [ ] Racha de logros alineada a F12 (misma logica / tests de ancla).
- [ ] No se agrego un quinto tab. _(cubre R2, R12)_
- [ ] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Dominio y datos

- [ ] Documentar `UnlockedAchievement` + tabla + nota schema (v9 tras F15 v8) en `_global/05-data-model.md`. _(cubre R6, R11)_
- [ ] Migracion Drift: crear `unlocked_achievements` (PK `achievement_id`, `unlocked_at`). _(cubre R6, R11)_
- [ ] Catalogo estatico 12 logros (`achievement_catalog.dart`) con thresholds R1. _(cubre R1)_
- [ ] `AchievementEvaluator` puro: conteos/minutos solo `completed`; racha via StatsService/shared. _(cubre R4, R5)_
- [ ] Repositorio: watch unlocks, insertIgnore, getUnlockedIds. _(cubre R6, R10, R11)_

### Application (Riverpod)

- [ ] Providers: catalogo, unlocks, progress list, pending celebration. _(cubre R3, R7, R9)_
- [ ] Hook post-insert sesion `completed` → evaluate → set pending. _(cubre R4, R7)_
- [ ] No revocar unlocks al borrar logs; refrescar solo progreso. _(cubre R6, R9)_
- [ ] Manejo error AsyncValue en pantalla de logros. _(cubre R10)_

### UI

- [ ] `AchievementsEntryTile` en `HistoryScreen` (orden: … F12 → F15 si hay → **F13 entry** → calendario). _(cubre R2, R12)_
- [ ] `AchievementsScreen`: lista completa locked/unlocked + progreso. _(cubre R3, R9)_
- [ ] `AchievementsUnlockedSheet` (lista N logros nuevos). _(cubre R7)_
- [ ] Integracion no destructiva con F16 (chip/seccion o sheet al cerrar Listo). _(cubre R7)_
- [ ] Iconos Material; estados atenuados locked; touch >= 48 dp. _(cubre R12)_
- [ ] Verificar 4 tabs en shell. _(cubre R2, R12)_

### Tests (selectivos — fiable sin suite enorme)

- [ ] **Unit — catalogo:** size >= 10 y ids unicos de R1. _(cubre R1)_
- [ ] **Unit — evaluator conteos:** 0/1/10 completed; aborted no cuentan para sessions_*. _(cubre R4, R5)_
- [ ] **Unit — evaluator minutos:** umbrales 60/300 con logs de duracion controlada. _(cubre R5)_
- [ ] **Unit — evaluator racha:** alineado a F12 (hoy/ayer ancla; aborted cuenta dia). _(cubre R5)_
- [ ] **Unit — inmutabilidad:** unlock persiste aunque se vacien logs en el calculo de progreso. _(cubre R6)_
- [ ] **Unit — idempotencia:** segunda evaluate no duplica ni cambia `unlockedAt`. _(cubre R11)_
- [ ] **Unit — multi unlock:** una sesion puede devolver N nuevos en un evaluate. _(cubre R7)_
- [ ] **Widget — entry Historial + screen:** progreso visible; sin quinto tab. _(cubre R2, R3, R12)_
- [ ] **Widget — sheet desbloqueo:** muestra lista de recien desbloqueados. _(cubre R7)_

**Fuera de esta ronda:** golden de animaciones, stress de 10k logs, logros secretos, push F14, matrix i18n completa.

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Catalogo 12; unit catalogo |
| R2 | Entry tile Historial; sin 5.º tab; widget entry |
| R3 | AchievementsScreen; widget screen |
| R4 | Hook post completed; unit conteos |
| R5 | Evaluator + StatsService racha; unit racha/minutos |
| R6 | Repo insert; unit inmutabilidad |
| R7 | Sheet + F16 hook; unit multi; widget sheet |
| R8 | Sin gate Pro (verificacion DoD / code review) |
| R9 | Refresh al abrir; no unlock por delete |
| R10 | AsyncValue error; no unlock si insert falla |
| R11 | insertIgnore; unit idempotencia |
| R12 | Design system; shell 4 tabs |

## Notas de secuenciacion

Dependencias: **F04** + **F12** completados.

Orden recomendado:

1. data-model + migracion + repo  
2. catalogo + evaluator + tests unitarios  
3. providers + hook post-sesion  
4. UI lista + entry Historial  
5. celebration sheet + enganche F16  
6. widget tests  

En esta rama conviven specs F15 y F13: al implementar codigo, aplicar migraciones en orden
**v8 body_measurements (F15) → v9 unlocked_achievements (F13)** salvo que se invierta el orden de
features en codigo (entonces renumerar en el PR de implementacion).
