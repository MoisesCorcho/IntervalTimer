# Requirements: Multilenguaje (i18n)

> Estado: No iniciada

**ID:** F28 &nbsp;|&nbsp; **Slug:** `28-multi-language-i18n` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Soporte de multiples idiomas en la UI y en los anuncios de voz (TTS).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** usar la app en mi idioma, **para que** entiendo mejor la interfaz y los anuncios de voz.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE soportar como minimo espanol e ingles al lanzamiento, con arquitectura preparada para agregar mas idiomas.
2. EL SISTEMA DEBE detectar el idioma del sistema operativo por defecto y permitir cambiarlo manualmente.
3. LOS anuncios de voz (F02) DEBEN usar el idioma/locale configurado, no solo la UI de texto.
4. EL CONTENIDO de rutinas preestablecidas (F03) DEBE tener textos traducidos o, como minimo, fallback a ingles si falta traduccion.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
