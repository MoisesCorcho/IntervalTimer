# Tasks: Ajuste Rapido de Intensidad

**ID:** F11 &nbsp;|&nbsp; **Slug:** `11-quick-intensity-scaling`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Implementar funcion pura de escalado de rutina.
- [ ] UI de modal de ajuste con preview de la nueva duracion total.
- [ ] Logica de exclusion de intervalos tipo 'reps'.
- [ ] Flujo de guardar cambios permanentes (solo rutinas propias).
- [ ] Tests de la funcion de escalado (limites, redondeo, minimos).

## Notas de secuenciacion

Esta feature depende de: F01, F05.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
