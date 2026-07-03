# Tasks: Filtros de Rutinas

**ID:** F22 &nbsp;|&nbsp; **Slug:** `22-routine-filters`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Extender modelo `PresetRoutine` con `level` y `equipment`.
- [ ] Etiquetar el contenido existente con los nuevos metadatos.
- [ ] Implementar UI de filtros (bottom sheet + chips).
- [ ] Implementar logica de filtrado combinado en memoria.
- [ ] Implementar estado vacio de 'sin resultados'.
- [ ] Tests de combinaciones de filtros.

## Notas de secuenciacion

Esta feature depende de: F03.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
