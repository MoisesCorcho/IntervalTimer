# Tasks: Logros y Badges

**ID:** F13 &nbsp;|&nbsp; **Slug:** `13-achievements-badges`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir catalogo inicial de logros (>=10) con sus condiciones.
- [ ] Implementar modelo y persistencia de `UnlockedAchievement`.
- [ ] Implementar `AchievementEvaluator` conectado al evento de fin de sesion.
- [ ] UI de notificacion de logro desbloqueado (overlay/animacion).
- [ ] UI de pantalla de logros (desbloqueados + progreso de pendientes).
- [ ] Tests de evaluacion de condiciones para cada tipo de logro.

## Notas de secuenciacion

Esta feature depende de: F12.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
