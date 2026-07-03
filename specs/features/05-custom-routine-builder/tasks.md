# Tasks: Editor de Rutinas Propias

**ID:** F05 &nbsp;|&nbsp; **Slug:** `05-custom-routine-builder`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Extender modelo `Routine` con `source` y `originId`.
- [ ] Implementar pantalla de listado 'Mis rutinas'.
- [ ] Implementar builder: agregar/editar/eliminar/reordenar intervalos.
- [ ] Implementar duplicar rutina (preset -> custom, custom -> custom).
- [ ] Implementar eliminar rutina con confirmacion.
- [ ] Validaciones de formulario (min. 1 intervalo, duracion > 0).
- [ ] Tests de reordenamiento y de duplicacion.

## Notas de secuenciacion

Esta feature depende de: F01, F03.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
