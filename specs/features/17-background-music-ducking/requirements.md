# Requirements: Integracion de Musica / Audio Ducking

**ID:** F17 &nbsp;|&nbsp; **Slug:** `17-background-music-ducking` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Permite que la musica del usuario (Spotify u otra app) siga sonando durante el entrenamiento, bajando de volumen automaticamente cuando la voz del timer habla.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** escuchar mi musica mientras entreno y que la voz del timer se escuche clara, **para que** tengo una mejor experiencia sin tener que pausar mi musica manualmente.

## Criterios de Aceptacion (formato EARS)

1. CUANDO el usuario tiene musica sonando de otra app Y la voz del timer necesita hablar, EL SISTEMA DEBE bajar el volumen de la musica externa temporalmente (ducking).
2. AL terminar el anuncio de voz, EL SISTEMA DEBE restaurar el volumen original de la musica automaticamente.
3. EL SISTEMA DEBE configurar la categoria de audio de la app para permitir mezcla con otras apps de audio por defecto.
4. SI el sistema operativo no soporta ducking automatico, ENTONCES EL SISTEMA DEBE degradar con gracia (la voz simplemente suena encima sin bajar la musica).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
