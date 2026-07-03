# Tasks: Progresion Automatica

**ID:** F09 &nbsp;|&nbsp; **Slug:** `09-automatic-progression`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir modelos `ProgressionPlan` y `WeekAdjustment`.
- [ ] Implementar calculo de semana activa y generacion de rutina derivada.
- [ ] UI de configuracion del plan (numero de semanas, incrementos).
- [ ] UI de estado del plan en la pantalla de la rutina ('Semana 3 de 8').
- [ ] Implementar pausar/reiniciar plan.
- [ ] Tests del calculo de semana y de la generacion de rutina derivada en distintos escenarios de fecha.

## Notas de secuenciacion

Esta feature depende de: F05, F04.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
