# Tasks: Compartir Rutinas con Otros Usuarios

**ID:** F25 &nbsp;|&nbsp; **Slug:** `25-routine-sharing`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Decidir proveedor BaaS (Firebase vs Supabase) — ver architecture.md.
- [ ] Implementar exportacion de rutina a JSON + deep link.
- [ ] Implementar importacion desde deep link.
- [ ] (Fase 2 de esta feature) Disenar backend de catalogo publico con moderacion — spec separado.
- [ ] Tests de exportacion/importacion end-to-end.

## Notas de secuenciacion

Esta feature depende de: F05, F06.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
