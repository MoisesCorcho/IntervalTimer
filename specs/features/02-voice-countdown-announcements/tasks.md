# Tasks: Voz: Cuenta Regresiva y Anuncios

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Integrar `flutter_tts` y crear `VoiceAnnouncer` service.
- [ ] Conectar `VoiceAnnouncer` a eventos del `TimerController` (start de intervalo, N segundos restantes).
- [ ] UI de configuracion: segundos de cuenta regresiva, activar/desactivar voz.
- [ ] Soportar mensaje custom por intervalo en el modelo `Interval` (`announceText` opcional).
- [ ] Manejar cola/interrupcion de anuncios para evitar solapamientos.
- [ ] Tests: verificar que el anuncio se dispara en el segundo exacto configurado.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
