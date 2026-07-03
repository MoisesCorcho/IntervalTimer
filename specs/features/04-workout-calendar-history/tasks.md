# Tasks: Calendario e Historial de Sesiones

**ID:** F04 &nbsp;|&nbsp; **Slug:** `04-workout-calendar-history`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Elegir y configurar motor de base de datos local (drift/isar).
- [ ] Definir tabla/modelo `SessionLog` y migraciones iniciales.
- [ ] Implementar `SessionLogRepository` (CRUD).
- [ ] Conectar el fin de sesion del timer al guardado automatico del log.
- [ ] Construir UI de calendario con marcadores.
- [ ] Construir UI de detalle de dia (lista de sesiones).
- [ ] Implementar eliminacion de registro con confirmacion.
- [ ] Tests de persistencia y de la logica de marcado de dias.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
