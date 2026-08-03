# Tasks: Registro de Peso y Medidas

**ID:** F15 &nbsp;|&nbsp; **Slug:** `15-body-measurements-tracking`

## Definition of Done

- [x] Todos los criterios R1–R13 de `requirements.md` estan implementados y verificados. _(cubre R1–R13)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Entidad y tabla documentadas en `_global/05-data-model.md`; migracion Drift schema **v8**.
- [x] `weightReaderProvider` expone peso real o default F12; kcal de F12 se actualizan al mutar peso.
- [x] No se agrego un quinto tab en el shell. _(cubre R2, R13)_
- [x] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Dominio y datos

- [x] Documentar `BodyMeasurement` + tabla `body_measurements` + clave `body_weight_unit` en `_global/05-data-model.md`. _(cubre R3, R4, R8)_
- [x] Migracion Drift schema **v8**: crear `body_measurements` con UNIQUE(`local_date`). _(cubre R3, R4)_
- [x] Modelo de dominio + validacion pura (peso 20–300 kg, medidas, fecha no futura). _(cubre R10, R11)_
- [x] `BodyWeightUnit` + funciones de conversion kg ↔ lb. _(cubre R8)_
- [x] `BodyMeasurementRepository`: watchAll, upsertByLocalDate, update, delete, latestByDate. _(cubre R3, R4, R6, R7, R12)_

### Application (Riverpod)

- [x] Providers de repo, lista, latest weight, unidad de preferencia. _(cubre R5, R7, R8)_
- [x] Implementar `BodyMeasurementWeightReader` e **override** de `weightReaderProvider`. _(cubre R1, R7)_
- [x] Controller/notifier de form: save (upsert), edit, delete + invalidacion de stats. _(cubre R3, R4, R6, R7)_
- [x] Manejo `AsyncValue` loading/error en seccion de peso. _(cubre R12)_
- [x] Preferencia `body_weight_unit` via `PreferencesRepository`. _(cubre R8)_

### UI

- [x] `BodyWeightSection` en `HistoryScreen` (orden: chrome → F12 stats → F15 peso → calendario → lista). _(cubre R2, R5, R13)_
- [x] Caption/CTA: "Peso estimado 70 kg · Registrar" vs "X kg · Actualizar" alineado a F12. _(cubre R1, R2, R7)_
- [x] Formulario bottom sheet/pantalla: peso, fecha, medidas opcionales. _(cubre R3, R9)_
- [x] `BodyWeightLineChart` con `fl_chart` LineChart; empty state amable. _(cubre R5, R12)_
- [x] Lista compacta + editar + borrar con confirmacion. _(cubre R6)_
- [x] UI de unidad kg/lb en Ajustes (y labels del form/chart). _(cubre R8)_
- [x] Validacion visible en form (peso/medidas/fecha). _(cubre R10, R11)_
- [x] Verificar shell: 4 tabs, tokens design system, touch ≥ 48 dp. _(cubre R13)_

### Tests

Cobertura **selectiva** (MVP fiable, sin suite enorme). Priorizar dominio/repo + 2–3 widgets criticos.

- [x] **Unit — validacion:** peso fuera de rango, ≤0, medidas invalidas, fecha futura rechazados. _(cubre R10, R11)_
- [x] **Unit — conversion:** kg ↔ lb round-trip con tolerancia (ej. 0.01 kg). _(cubre R8)_
- [x] **Unit — upsert:** dos saves mismo `localDate` dejan una sola fila con ultimo peso. _(cubre R4)_
- [x] **Unit — WeightReader:** sin filas → 70 estimado; con filas → latest kg no estimado. _(cubre R1, R7)_
- [x] **Unit — delete ultimo:** vuelve a estimado. _(cubre R6, R7)_
- [x] **Unit — edge fechas:** (1) `localDate` = hoy OK; (2) mover/editar registro a un dia que ya tiene fila → queda **una** fila en destino (upsert), sin duplicar. _(cubre R4, R11)_
- [x] **Unit — edge limites:** peso en frontera 20 y 300 kg aceptados; 19.9 y 300.1 rechazados. _(cubre R10)_
- [x] **Unit — latest weight:** con varios dias, el reader usa el de `localDate` maximo (no el de mayor `weightKg`). _(cubre R7)_
- [x] **Widget — seccion Historial:** CTA registrar / chart o empty; sin quinto tab. _(cubre R2, R5, R12, R13)_
- [x] **Widget — form validacion:** no guarda peso invalido; muestra error. _(cubre R10)_
- [x] **Widget/integration — preferencia unidad:** cambiar kg/lb actualiza labels mostrados. _(cubre R8)_

**Explicitamente fuera de esta ronda de tests** (no inflar suite): Health APIs, multi-device, isolate/concurrency stress, golden screenshots, matrix completa de timezones. Migracion v7→v8 se valida al implementar (smoke de upgrade o test de migracion **uno** si el proyecto ya testea schema; no una bateria).

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | WeightReader default sin filas; no onboarding; caption estimado |
| R2 | BodyWeightSection en HistoryScreen; sin 5.º tab |
| R3 | Form + repo upsert; modelo documentado |
| R4 | UNIQUE local_date + unit upsert; test upsert |
| R5 | LineChart + empty state; widget seccion |
| R6 | Lista edit/delete; test delete ultimo |
| R7 | BodyMeasurementWeightReader + override provider; refresh stats |
| R8 | Preferencia + conversion + UI Ajustes; tests conversion/unidad |
| R9 | Campos opcionales en form; sin chart de medidas |
| R10 | Validacion dominio + widget form |
| R11 | Validacion medidas/fecha + unit tests |
| R12 | Empty/error AsyncValue; widget empty |
| R13 | Shell 4 tabs; design system |

## Notas de secuenciacion

Dependencias: **F04** (Completado), **F12** (Completada — contrato `WeightReader` en codigo).

Orden recomendado:

1. data-model + migracion v8 + repo  
2. validacion + conversion + tests unitarios  
3. WeightReader override + providers  
4. UI seccion + form + chart  
5. Ajustes unidad  
6. widget tests + smoke en dispositivo (grafica + form)

No bloquear por F13/F14. No pedir peso en F30.
