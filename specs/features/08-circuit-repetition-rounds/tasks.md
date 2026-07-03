# Tasks: Repeticion de Circuitos (Rounds)

**ID:** F08 &nbsp;|&nbsp; **Slug:** `08-circuit-repetition-rounds`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir modelo `Block` y adaptar `Routine` a `List<RoutineItem>`.
- [ ] Implementar 'aplanado' de rutina con bloques en el motor del timer.
- [ ] UI: seleccion multiple + agrupar en bloque en el builder.
- [ ] UI: indicador de ronda actual durante ejecucion.
- [ ] Migracion de datos para rutinas existentes (sin bloques) al nuevo formato.
- [ ] Tests del aplanado con distintos numeros de rondas.

## Notas de secuenciacion

Esta feature depende de: F01, F05.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
