# Tasks: Estadisticas y Progreso

**ID:** F12 &nbsp;|&nbsp; **Slug:** `12-statistics-progress`

## Definition of Done

- [ ] Todos los criterios R1–R12 de `requirements.md` estan implementados y verificados. _(cubre R1–R12)_
- [ ] Tests unitarios y widget listados abajo pasan en CI/local.
- [ ] Tipos derivados documentados en `_global/05-data-model.md` (sin tabla nueva).
- [ ] No se agrego un quinto tab en el shell; stats viven en Historial.
- [ ] No se rompieron F04 ni el shell (R22).
- [ ] Codigo revisado contra `_global/03-conventions.md`.

## Checklist de implementacion

### Dominio y datos

- [ ] Definir modelos `StatsSummary`, `DayMinutes`, `ChartPeriod` en `features/stats/domain/`. _(cubre R2, R3, R4, R6)_
- [ ] Implementar `StatsService` (minutos, sesiones, racha R6, kcal R5, series semana/mes). _(cubre R2, R3, R4, R5, R6, R7)_
- [ ] Implementar `WeightReader` / provider con default 70 kg y flag `isWeightEstimated`. _(cubre R5, R12)_
- [ ] Documentar derivados F12 en `_global/05-data-model.md` (sin migracion drift). _(cubre R7)_

### Application (Riverpod)

- [ ] Providers que leen `SessionLogRepository` (F04) y exponen summary + chart series. _(cubre R2, R4, R7, R8)_
- [ ] Estado `chartPeriodProvider` (default week) y reaccion a `focusedMonth` de Historial. _(cubre R4)_
- [ ] Invalidacion/refresh al insertar o borrar `SessionLog`. _(cubre R8)_
- [ ] Manejo `AsyncValue` error/loading en providers de stats. _(cubre R10, R11)_

### UI

- [ ] Anadir dependencia `fl_chart` en pubspec (BarChart). _(cubre R4)_
- [ ] Widgets `ProgressSummarySection`, `StatMetricCard`, caption peso estimado. _(cubre R2, R3, R9, R12)_
- [ ] `ChartPeriodToggle` + `ActivityBarChart` (semana/mes). _(cubre R4)_
- [ ] Integrar bloque de progreso en `HistoryScreen` (orden R9: chrome → stats → calendario → lista). _(cubre R1, R9)_
- [ ] Estado vacio: metricas en 0 y barras en 0 sin error. _(cubre R10)_
- [ ] Estado error no bloqueante del bloque stats + reintento. _(cubre R11)_
- [ ] Verificar que bottom nav sigue con 4 destinos (sin tab Progreso). _(cubre R1)_

### Tests

- [ ] **Unit — happy path:** minutos semana/mes/total y conteo de sesiones con logs de ejemplo. _(cubre R2, R3, R7)_
- [ ] **Unit — racha:** hoy con actividad; hoy vacio + ayer con actividad; hueco rompe racha; racha 0 sin logs. _(cubre R6, R10)_
- [ ] **Unit — kcal:** formula MET×peso×horas; default 70 kg y flag estimado. _(cubre R5, R12)_
- [ ] **Unit — series:** weekSeries 7 barras lun–dom; monthSeries dias del mes focused. _(cubre R4)_
- [ ] **Widget — Historial integrado:** bloque progreso visible encima del calendario; sin quinto tab. _(cubre R1, R9)_
- [ ] **Widget — toggle grafica:** cambiar Semana/Mes actualiza chart. _(cubre R4)_
- [ ] **Widget — vacio/error:** 0s sin crash; error de repo muestra mensaje no bloqueante. _(cubre R10, R11)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | Integracion HistoryScreen; verificar 4 tabs; widget Historial integrado |
| R2 | StatsService summary; ProgressSummarySection; unit happy path |
| R3 | StatsService totales; linea secundaria UI |
| R4 | Series semana/mes; toggle + chart; providers focusedMonth; unit series; widget toggle |
| R5 | StatsService kcal; WeightReader; unit kcal |
| R6 | StatsService racha; unit racha |
| R7 | Solo SessionLog; unit happy path |
| R8 | Invalidacion providers al mutar logs |
| R9 | Orden en HistoryScreen; tokens design system; widget integrado |
| R10 | Estado vacio UI; unit racha 0; widget vacio |
| R11 | AsyncValue error; widget error |
| R12 | Caption peso estimado; unit kcal default |

## Notas de secuenciacion

Esta feature depende de: **F04** (Completado).

Orden recomendado: dominio `StatsService` + tests unitarios → providers → widgets stats → integracion `HistoryScreen` → widget tests.

No bloquear por F03 ni F15. F16 debe reutilizar `StatsService` cuando se implemente (no recalcular racha/kcal con otras reglas).
