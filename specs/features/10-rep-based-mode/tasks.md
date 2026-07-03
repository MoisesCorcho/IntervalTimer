# Tasks: Modo por Repeticiones

**ID:** F10 &nbsp;|&nbsp; **Slug:** `10-rep-based-mode`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Extender modelo `Interval` con `mode` y `targetReps`.
- [ ] Adaptar `TimerController` para manejar intervalos de duracion indefinida.
- [ ] UI de creacion: toggle tiempo/reps en el formulario de intervalo.
- [ ] UI de ejecucion: vista especial para intervalos de reps con boton 'Listo'.
- [ ] Integrar anuncio de voz del objetivo de reps.
- [ ] Tests del flujo reps (esperar confirmacion antes de avanzar).

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
