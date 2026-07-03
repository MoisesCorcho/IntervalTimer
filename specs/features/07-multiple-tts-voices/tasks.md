# Tasks: Seleccion de Voces (Sistema y Premium)

**ID:** F07 &nbsp;|&nbsp; **Slug:** `07-multiple-tts-voices`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir interfaz `TtsProvider` y refactorizar `VoiceAnnouncer` para usarla.
- [ ] Implementar `SystemTtsProvider` (listar voces, preview, hablar).
- [ ] Disenar y desplegar Cloud Function proxy para proveedor de voz premium elegido.
- [ ] Implementar `PremiumTtsProvider` consumiendo la Cloud Function.
- [ ] Implementar cache local de audios generados.
- [ ] UI de seleccion de voz con preview y badges 'Pro'.
- [ ] Tests de fallback cuando falla la voz premium.

## Notas de secuenciacion

Esta feature depende de: F02.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
