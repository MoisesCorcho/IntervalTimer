# Tasks: Modo Sin Video

**ID:** F23 &nbsp;|&nbsp; **Slug:** `23-no-video-mode`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Agregar flag `lowMediaMode` a configuracion de usuario.
- [ ] Adaptar el widget de renderizado de ejercicio para respetar el flag.
- [ ] UI de configuracion (toggle).
- [ ] Verificar que todas las pantallas con media respeten el flag.
- [ ] Tests del render condicional.

## Notas de secuenciacion

Esta feature depende de: F03.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
