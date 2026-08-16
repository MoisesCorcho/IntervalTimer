# Tasks: Efectos de Sonido del Temporizador (SFX)

**ID:** F36 &nbsp;|&nbsp; **Slug:** `36-timer-sound-effects`

## Definition of Done

- [x] Todos los criterios R1–R21 de `requirements.md` estan implementados y verificados. _(cubre R1–R21)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local. _(unit + prefs; widget settings pendiente de ampliar si se requiere CI widget)_
- [x] Preferencias documentadas en `_global/05-data-model.md`.
- [x] Assets SFX declarados en `pubspec.yaml` y reproducibles offline.
- [x] No se rompieron F01/F35 (timer, prep, pause, cancel, completed) ni mutes de F02/F18.
- [x] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, sin acoplar UI F01↔SFX).
- [x] QA manual: defaults en dispositivo real; picker + preview; master off; solape opcional con voz.

## Checklist de implementacion

### Datos, assets y catalogo

- [x] Declarar `assets/sfx/default/` y `assets/sfx/catalog/` (o archivos) en `pubspec.yaml`. _(cubre R21)_
- [x] Implementar `SfxCatalog` estatico alineado a `assets/sfx/ATTRIBUTION.md` (ids + paths `AssetSource` sin prefijo `assets/`; `suggestedFor` solo metadato opcional, picker lista **todo**). _(cubre R9, R14, R21)_
- [x] Persistir preferencias globales SFX (master, 5 toggles, `sound_countdown_seconds`, 5 `sound_id_*`) con defaults y rangos del data model. _(cubre R6–R8, R11, R13, R14)_
- [x] Verificar seccion Preferencias F36 en `_global/05-data-model.md` (ya anadida en el pack SDD; alinear codigo a esas claves si hubo drift). _(cubre R11)_

### Contratos F01 / F35

- [x] Asegurar acceso observable a `IntervalStartedEvent` (o equivalente) con `intervalId` + `type`. _(cubre R1, R2)_
- [x] Asegurar `remainingMs` + `status` estables para `running` y `preparing` (incl. paused). _(cubre R4, R5, R15–R17, R19)_
- [x] Asegurar streams/contratos `SessionCompleted` y `SessionCancelled`. _(cubre R3, R16, R18)_

### Player y logica SFX

- [x] Agregar dependencia `audioplayers` (constraint estable en pubspec) y encapsular `SfxPlayer` con pool/solape (2–3 players o liberar al complete) + `NoOpSfxPlayer` (tests). Paths via `AssetSource('sfx/...')` sin prefijo `assets/`. _(cubre R12, R20, R21)_
- [x] Implementar resolucion slot inicio: `rest` → rest_start; otro type → work_start; incluir skip y fin de prep como inicio de intervalo (no resume). _(cubre R1, R2)_
- [x] Implementar `SoundEffectsController` (Riverpod): gates de prefs, disparos R1–R5, idempotencia, politicas pause/cancel/complete. _(cubre R1–R8, R12, R14–R20)_
- [x] Fallback a default de slot si `soundId` invalido o asset faltante. _(cubre R14)_
- [x] Fallo de `play` → no-op; timer intacto; no bypassear silent switch del SO. _(cubre R12)_
- [x] Independencia de `voiceEnabled` y `vibrationEnabled`; permitir solape TTS + SFX. _(cubre R7, R20)_

### UI Settings

- [x] Seccion “Efectos de sonido” en shell Settings: master, toggles granulares, stepper N 0–10. _(cubre R6–R8, R11, R13)_
- [x] Picker por slot con **catalogo completo** (sin filtrar por slot) + preview usable en Settings. _(cubre R9, R10)_
- [x] Deshabilitar controles granulares / stepper segun master (y warning off para N) — UX. _(cubre R7, R8)_
- [x] Controles con area de toque >= 48dp; reutilizar `NumberStepper` si existe. _(cubre R6)_

### Tests

- [x] **Unit — happy path:** IntervalStarted work → work_start; rest → rest_start; SessionCompleted → complete; skip/fin de prep hacia primer intervalo → R1/R2 (no en resume). _(cubre R1–R3)_
- [x] **Unit — prep ticks:** preparing S=3,2,1 con prep on → 3 plays; no tick extra en transicion a work (solo work_start). _(cubre R4)_
- [x] **Unit — solape:** dos plays seguidos no cancelan el anterior a nivel de API del player mock/pool (o documentar contrato del fake). _(cubre R20)_
- [x] **Unit — phase warning:** N=3, remaining cruza 3,2,1 → 3 plays phase_warning; N=0 → ninguno. _(cubre R5, R6)_
- [x] **Unit — toggles/master:** cada toggle off omite su evento; master off omite todos. _(cubre R7, R8)_
- [x] **Unit — independencia:** voice/vibration off + sound on sigue reproduciendo (mock player). _(cubre R20)_
- [x] **Unit — error/edge:** player lanza / id invalido → fallback o no-op, timer no afectado; intervalo corto N grande solo S alcanzables; idle sin SFX; cancel sin complete SFX; pause no nuevos ticks; idempotencia mismo S. _(cubre R12, R14–R19)_
- [x] **Unit — prefs:** countdown fuera 0–10 se rechaza/clamp; soundIds se restauran. _(cubre R11, R13)_
- [x] **Widget — settings:** toggles, stepper, picker y preview actualizan estado visible. _(cubre R6–R10, R13)_

### QA dispositivo

- [x] Verificar defaults en dispositivo real (work/rest/complete/prep/warning). _(cubre R1–R5, R21)_
- [x] Verificar picker + preview y persistencia tras kill de app. _(cubre R9–R11)_
- [x] Verificar master off y solape opcional con TTS si F02 activo (sin crash). _(cubre R7, R20)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | IntervalStarted + type work, controller, unit happy path, QA |
| R2 | type rest, controller, unit happy path, QA |
| R3 | SessionCompleted, controller, unit happy path, QA |
| R4 | preparing remainingMs, idempotencia prep, unit prep |
| R5 | running remainingMs, N, unit phase warning |
| R6 | prefs N, stepper, unit N=0 |
| R7 | master prefs, UI, unit toggles |
| R8 | toggles granulares, UI, unit toggles |
| R9 | catalogo, prefs sound_id_*, picker UI |
| R10 | preview UI + player |
| R11 | persistencia + data model + unit prefs |
| R12 | SfxPlayer no-op/errors, unit error |
| R13 | validacion stepper/prefs |
| R14 | fallback default id, unit error |
| R15 | logica ticks + unit edge |
| R16 | gate status + complete policy |
| R17 | pause policy + unit edge |
| R18 | SessionCancelled policy |
| R19 | sets de segundos + unit idempotencia |
| R20 | gates independientes + unit independencia |
| R21 | pubspec assets + catalogo + QA offline |

## Notas de secuenciacion

Esta feature depende de: **F01** y **F35** (Done como prerequisitos de producto).

Orden recomendado: pubspec assets + catalogo + prefs/data model → asegurar contratos
timer/prep → `SfxPlayer` → `SoundEffectsController` → UI settings (toggles + N + picker/preview)
→ tests unit/widget → QA dispositivo.

No iniciar tasks de este archivo hasta que F01 y F35 esten en estado Done.

No implementar SFX de pause/resume, volumen relativo, packs remotos, ni ducking F17 en estas tasks.

No acoplar la cola TTS de F02; solo reutilizar contratos de timer y permitir solape.

No sustituir `audioplayers` por `just_audio` en v1 sin actualizar design + requirements.
No filtrar el picker por `suggestedFor` de forma que oculte clips del catalogo.
