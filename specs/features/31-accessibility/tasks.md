# Tasks: Accesibilidad

**ID:** F31 &nbsp;|&nbsp; **Slug:** `31-accessibility`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Auditar toda la app existente con Accessibility Scanner / VoiceOver.
- [ ] Agregar labels `Semantics` a componentes custom (timer, color picker, calendario).
- [ ] Verificar y corregir contraste en ambos temas.
- [ ] Verificar que la app sea usable de principio a fin solo con lector de pantalla.
- [ ] Agregar checklist de accesibilidad a conventions.md para features futuras.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
