# Tasks: Registro de Peso y Medidas

**ID:** F15 &nbsp;|&nbsp; **Slug:** `15-body-measurements-tracking`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir modelo y tabla `BodyMeasurement`.
- [ ] UI de registro rapido de peso/medidas.
- [ ] UI de grafica de evolucion.
- [ ] Exponer peso reciente para consumo de F12.
- [ ] Soporte de conversion de unidades kg/lb.
- [ ] Tests de persistencia y de conversion de unidades.

## Notas de secuenciacion

Esta feature depende de: F04.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
