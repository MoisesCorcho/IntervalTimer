# Tasks: Capa Pro / Compras In-App

**ID:** F06 &nbsp;|&nbsp; **Slug:** `06-pro-tier-iap`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Configurar productos en Google Play Console / App Store Connect.
- [ ] Integrar `in_app_purchase` y `PurchaseService`.
- [ ] Implementar pantalla de upgrade con listado de beneficios.
- [ ] Implementar `ProGate` widget reutilizable.
- [ ] Implementar restore purchases.
- [ ] Marcar features candidatas (voces premium, estadisticas avanzadas, etc.) con el gate.
- [ ] Tests con productos de sandbox/test.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
