# Requirements: Onboarding

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Flujo de bienvenida para nuevos usuarios: explica el valor de la app y guia hacia la primera sesion completada.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario nuevo, **quiero** entender rapido que hace la app y como empezar, **para que** decido quedarme y uso la app en vez de desinstalarla.

## Criterios de Aceptacion (formato EARS)

1. AL abrir la app por primera vez, EL SISTEMA DEBE mostrar un flujo de onboarding de maximo 3-4 pantallas explicando el valor principal.
2. EL ONBOARDING DEBE terminar dirigiendo al usuario a iniciar su primera rutina preestablecida (F03), no solo a la pantalla principal vacia.
3. EL SISTEMA DEBE permitir saltar el onboarding en cualquier momento.
4. EL ONBOARDING NO DEBE volver a mostrarse en aperturas posteriores de la app.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
