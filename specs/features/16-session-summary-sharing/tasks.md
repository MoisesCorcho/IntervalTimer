# Tasks: Compartir Resumen de Sesion

**ID:** F16 &nbsp;|&nbsp; **Slug:** `16-session-summary-sharing`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Disenar plantilla visual de la tarjeta resumen.
- [ ] Implementar renderizado a imagen con `RepaintBoundary`.
- [ ] Integrar `share_plus` para compartir.
- [ ] Conectar boton 'Compartir' a la pantalla de fin de sesion.
- [ ] Tests de generacion de imagen (snapshot testing).

## Notas de secuenciacion

Esta feature depende de: F04, F12.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
