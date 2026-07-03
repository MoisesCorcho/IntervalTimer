# Tasks: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir `ThemeData` light y dark en design-system.md y codigo.
- [ ] Auditar y reemplazar colores hardcodeados en toda la app existente.
- [ ] Implementar seleccion de tema (claro/oscuro/sistema) en configuracion.
- [ ] Verificar contraste de colores de intervalos custom sobre ambos temas.
- [ ] Tests visuales/snapshot en ambos temas.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
