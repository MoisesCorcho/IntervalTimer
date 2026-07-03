# Requirements: Accesibilidad

**ID:** F31 &nbsp;|&nbsp; **Slug:** `31-accessibility` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Soporte de tamanos de texto ajustables, buen contraste, y compatibilidad con lectores de pantalla (TalkBack/VoiceOver).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario con baja vision, **quiero** poder ajustar el tamano de texto y tener buen contraste, **para que** puedo usar la app comodamente.
- **Como** usuario con lector de pantalla, **quiero** que la app sea navegable con TalkBack/VoiceOver, **para que** puedo usar todas las funciones principales de forma independiente.

## Criterios de Aceptacion (formato EARS)

1. LA UI DEBE respetar el factor de escala de texto del sistema operativo (`textScaleFactor`) sin romper layouts.
2. TODOS los elementos interactivos DEBEN tener un `Semantics label` descriptivo para lectores de pantalla.
3. EL CONTRASTE de texto sobre fondo DEBE cumplir como minimo WCAG AA (4.5:1 para texto normal) en ambos temas (F27).
4. LOS controles criticos del timer (play/pause/skip) DEBEN ser operables enteramente con TalkBack/VoiceOver activo.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
