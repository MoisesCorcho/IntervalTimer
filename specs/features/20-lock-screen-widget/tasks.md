# Tasks: Widget de Pantalla de Bloqueo / Notificacion Persistente

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Implementar foreground service en Android con notificacion con controles.
- [ ] Conectar acciones de la notificacion al `TimerController`.
- [ ] Investigar e implementar Live Activities en iOS (fase separada, requiere Swift).
- [ ] Sincronizar estado entre notificacion/Live Activity y UI de la app.
- [ ] Manejar limpieza de notificacion al finalizar/cancelar sesion.
- [ ] Tests manuales en ambas plataformas.

## Notas de secuenciacion

Esta feature depende de: F01, F19.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
