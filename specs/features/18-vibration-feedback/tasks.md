# Tasks: Vibracion como Feedback

**ID:** F18 &nbsp;|&nbsp; **Slug:** `18-vibration-feedback`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Integrar paquete de vibracion y verificar soporte de hardware.
- [ ] Implementar `HapticsService` con patrones para inicio de intervalo y cuenta regresiva.
- [ ] Conectar a los eventos del `TimerController`.
- [ ] UI de configuracion on/off independiente del audio.
- [ ] Tests en dispositivo real (Android/iOS).

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
