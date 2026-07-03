# Tasks: Favoritos

**ID:** F24 &nbsp;|&nbsp; **Slug:** `24-favorites`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir tabla/modelo `FavoriteRoutine`.
- [ ] Implementar `FavoriteToggleButton` reutilizable.
- [ ] Integrar el boton en catalogo (F03) y en 'Mis rutinas' (F05).
- [ ] Implementar pantalla/seccion de Favoritos.
- [ ] Tests de persistencia de favoritos.

## Notas de secuenciacion

Esta feature depende de: F03, F05.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
