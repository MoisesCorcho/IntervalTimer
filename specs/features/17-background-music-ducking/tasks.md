# Tasks: Integracion de Musica / Audio Ducking

**ID:** F17 &nbsp;|&nbsp; **Slug:** `17-background-music-ducking`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Integrar paquete `audio_session` y configurar categoria de audio de la app.
- [ ] Solicitar audio focus transitorio con ducking antes de cada anuncio de voz.
- [ ] Liberar audio focus al terminar el anuncio.
- [ ] Probar en dispositivo real con Spotify/Youtube Music de fondo (Android e iOS).
- [ ] Manejar caso sin soporte de ducking (fallback).

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
