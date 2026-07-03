# Tasks: Estadisticas y Progreso

**ID:** F12 &nbsp;|&nbsp; **Slug:** `12-statistics-progress`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Implementar `StatsService` con calculo de minutos, sesiones y racha.
- [ ] Implementar estimacion de calorias con tabla MET por categoria.
- [ ] Integrar `fl_chart` para graficas semanal/mensual.
- [ ] UI de pantalla 'Progreso' con resumen + graficas.
- [ ] Tests de calculo de racha con distintos escenarios de gaps.
- [ ] Tests de estimacion de calorias.

## Notas de secuenciacion

Esta feature depende de: F04.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
