# Tasks: Pantalla Siempre Encendida

**ID:** F19 &nbsp;|&nbsp; **Slug:** `19-always-on-screen`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Integrar `wakelock_plus`.
- [ ] Activar wakelock al iniciar sesion, desactivar al pausar/terminar/salir.
- [ ] Agregar toggle de configuracion global on/off.
- [ ] Tests manuales de fuga (verificar que el wakelock se libera en todos los flujos de salida, incluyendo cierre forzado de la app).

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
