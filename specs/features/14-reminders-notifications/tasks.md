# Tasks: Recordatorios y Notificaciones

**ID:** F14 &nbsp;|&nbsp; **Slug:** `14-reminders-notifications`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Integrar `flutter_local_notifications` y manejar permisos.
- [ ] Implementar modelo y persistencia de `Reminder`.
- [ ] Implementar programacion de notificaciones recurrentes por dia de semana.
- [ ] Implementar logica de supresion si ya hubo sesion ese dia.
- [ ] UI de gestion de recordatorios (crear, editar, eliminar).
- [ ] Tests de programacion y de la logica de supresion.

## Notas de secuenciacion

Esta feature depende de: F04.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
