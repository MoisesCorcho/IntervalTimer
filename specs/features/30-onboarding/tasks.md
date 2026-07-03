# Tasks: Onboarding

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Disenar contenido y copy de las 3-4 pantallas de onboarding.
- [ ] Implementar `PageView` de onboarding con skip.
- [ ] Implementar flag de persistencia `hasSeenOnboarding`.
- [ ] Conectar el final del onboarding a una rutina preestablecida sugerida (F03).
- [ ] Tests de que el onboarding no reaparece tras la primera vez.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
