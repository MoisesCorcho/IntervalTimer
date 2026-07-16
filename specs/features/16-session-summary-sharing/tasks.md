# Tasks: Compartir Resumen de Sesion

**ID:** F16 &nbsp;|&nbsp; **Slug:** `16-session-summary-sharing`

## Definition of Done

- [x] Todos los criterios **R1–R20** de `requirements.md` estan implementados y verificados.
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] No se reescribio F01 R18; la pantalla F16 cumple la confirmacion + Listo → idle.
- [x] Nota post-sesion usa `SessionLog.note` / `updateNote` (F04); visible en Historial.
- [x] Kcal y racha reutilizan reglas/`StatsService` de F12 (sin formulas paralelas).
- [x] Codigo en `features/session_summary/`; F01 no importa share/nota de F16.
- [x] Codigo revisado contra `_global/03-conventions.md` (Riverpod, capas, design system).
- [ ] Share verificado en **dispositivo fisico** al menos Android o iOS (sheet nativo + imagen).

## Checklist de implementacion

### Dominio y datos (sin schema nuevo)

- [x] Definir `SessionPhaseBreakdown` + funcion pura work/rest por `Interval.type`. _(cubre R3)_
- [x] Definir `SessionCompleteViewData` / `ShareCardData` (modelos de presentacion). _(cubre R3, R4, R6)_
- [x] Resolver `sessionLogId` tras `SessionCompleted` (latest completed por sourceId o provider del insert F04). _(cubre R10, R15)_
- [x] Documentar en `_global/05-data-model.md` modelos derivados F16 (no persistidos) si aplica. _(cubre R10)_

### Servicios / drivers

- [x] Agregar dependencia `share_plus` (pin compatible con SDK del repo; preferir API v13
      `SharePlus.instance.share` + `ShareParams`). _(cubre R7, R8, R19)_
- [x] Implementar `ShareSheetDriver` + implementacion plugin (files, sharePositionOrigin, mapear
      success/dismissed/unavailable). _(cubre R7, R17, R19)_
- [x] Implementar `ShareImageRenderer` con `RepaintBoundary` → PNG (`dart:ui`) + temp file
      (`path_provider`). _(cubre R6, R8, R16)_
- [x] Integrar `StatsService` (F12) para kcal de la sesion y racha actual post-insert. _(cubre R6)_

### Controller / integracion

- [x] Implementar `SessionSummaryController` (Riverpod): payload de sesion, breakdown, stats,
      logId, draft de nota, estados de share/error. _(cubre R1, R3, R4, R6, R10, R15, R16, R18)_
- [x] Cablear navegacion desde host de ejecucion al detectar `completed` / `SessionCompleted`
      → `SessionCompleteScreen` (sin segunda UI de cierre F01). _(cubre R1, R13, R14, R20)_
- [x] Accion Listo: persistir nota dirty si aplica, `resetToIdle`, pop/replace a editor. _(cubre R12, R18)_
- [x] Garantizar que cancel/abort **no** abre F16. _(cubre R13)_
- [x] Garantizar que F01 domain/controller no importa `session_summary`. _(cubre R20)_

### UI

- [x] `SessionCompleteScreen`: hero + titulo celebratorio + layout scrolleable. _(cubre R1, R2)_
- [x] Tiles metricas Entrenamiento / Descanso total (formateo tiempo, 0s si vacio). _(cubre R3)_
- [x] Bloque Compartir + preview opcional de card. _(cubre R5, R6)_
- [x] `SessionShareCard` plantilla offline (nombre, duracion, kcal est., racha, branding). _(cubre R6)_
- [x] Zona nota: pregunta + campo max 500 + sync a `updateNote`. _(cubre R9, R10, R11)_
- [x] CTA Listo full-width (design system, toque >= 48dp). _(cubre R12)_
- [x] SnackBars / feedback: fallo imagen, fallo nota, share dismissed no-op. _(cubre R16, R17, R18)_
- [x] iPad: anclar `sharePositionOrigin` al boton Compartir. _(cubre R19)_

### Tests

- [x] **Unit — breakdown:** solo work → rest 0; solo rest → training 0; mixto suma correcta. _(cubre R3)_
- [x] **Unit — share card data:** mapea displayName, total, kcal, streak. _(cubre R4, R6)_
- [x] **Unit — note limit:** rechaza o clamp > 500 coherente con F04. _(cubre R11)_
- [x] **Unit — controller Listo:** llama reset idle y no requiere nota. _(cubre R12)_
- [x] **Unit — controller cancel path:** no construye flujo complete para SessionCancelled. _(cubre R13)_
- [x] **Unit — log resolve:** logId llega tras delay de insert; timeout deja note disabled sin crash. _(cubre R15)_
- [x] **Unit — renderer error:** fallo toImage/IO → estado error sin excepcion sin capturar. _(cubre R16)_
- [x] **Unit — share dismissed:** status dismissed no resetea timer ni cierra pantalla. _(cubre R17)_
- [x] **Unit — note save error:** mantiene draft + flag error. _(cubre R18)_
- [x] **Widget — screen:** muestra hero, dos metricas, Compartir, zona nota, Listo. _(cubre R2, R3, R5, R9, R12)_
- [x] **Widget — share tap:** invoca renderer + driver con origin no null en test iPad-like si se modela. _(cubre R7, R19)_

### QA dispositivo

- [ ] Completar una sesion real: se abre F16, metricas correctas, Listo vuelve a idle/editor. _(cubre R1, R3, R12, R14)_
- [ ] Compartir imagen a al menos una app (Fotos/WhatsApp/Drive); modo avion: generar+sheet sin crash. _(cubre R6, R7, R8)_
- [ ] Guardar nota en F16 y verla en card del Historial (F04). _(cubre R10)_
- [ ] Abortar sesion con progreso: no abre F16; log aborted en historial intacto. _(cubre R13)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Nav completed → screen; QA completo |
| R2 | SessionCompleteScreen layout; widget screen |
| R3 | Breakdown puro; tiles; unit breakdown; QA |
| R4 | ViewData / share card data; unit share card |
| R5 | Bloque Compartir UI; widget screen |
| R6 | ShareCard + renderer + StatsService; unit card data; QA share |
| R7 | ShareSheetDriver; widget share tap; QA |
| R8 | Renderer local + QA modo avion |
| R9 | Zona nota UI; widget screen |
| R10 | updateNote + resolve logId; QA historial |
| R11 | Validacion 500; unit note limit |
| R12 | Listo → idle + nav; unit Listo; QA |
| R13 | No abrir en cancel; unit cancel path; QA abort |
| R14 | Un solo cierre; nav host; QA |
| R15 | Resolve logId; unit log resolve |
| R16 | Renderer error; unit renderer error; SnackBar |
| R17 | Share dismissed; unit dismissed |
| R18 | Note save error; unit note error |
| R19 | sharePositionOrigin; driver + widget |
| R20 | Carpetas session_summary; sin import F01→F16 |

## Notas de secuenciacion

Esta feature depende de: **F01**, **F04**, **F12** (Done como prerequisitos de producto).

Orden recomendado:

1. Domain breakdown + ViewData  
2. Resolve logId + cableado StatsService  
3. ShareImageRenderer + ShareSheetDriver + dep share_plus  
4. SessionSummaryController  
5. SessionCompleteScreen + navegacion desde ejecucion (reemplazar placeholder R18)  
6. Nota → updateNote  
7. Tests unit/widget  
8. QA fisico  

No iniciar hasta que F04 y F12 esten Done.

No implementar F25 (compartir rutinas), F13 (badges en esta pantalla), ni SDKs de redes.

No reescribir `specs/features/01-interval-timer-core/requirements.md` R18; solo cumplirla via esta UI.
