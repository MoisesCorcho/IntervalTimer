# Tasks: Retos Grupales

**ID:** F26 &nbsp;|&nbsp; **Slug:** `26-group-challenges`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Disenar modelo remoto de `Challenge` y reglas de sincronizacion selectiva de sesiones.
- [ ] Implementar creacion e invitacion a retos.
- [ ] Implementar ranking en tiempo real.
- [ ] Implementar cierre de reto y notificacion de resultado.
- [ ] Tests de sincronizacion con multiples usuarios simulados.

## Notas de secuenciacion

Esta feature depende de: F25, F12.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
