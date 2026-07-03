# Tasks: Multilenguaje (i18n)

**ID:** F28 &nbsp;|&nbsp; **Slug:** `28-multi-language-i18n`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Configurar `flutter_localizations` e infraestructura de archivos `.arb`.
- [ ] Extraer todos los strings hardcodeados de la UI existente a claves de traduccion.
- [ ] Traducir contenido de rutinas preestablecidas (F03).
- [ ] Propagar locale seleccionado al `TtsProvider`.
- [ ] UI de seleccion de idioma en configuracion.
- [ ] Tests de que no queden strings sin traducir (lint/CI check).

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
