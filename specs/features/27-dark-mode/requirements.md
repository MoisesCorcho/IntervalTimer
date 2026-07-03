# Requirements: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Tema oscuro completo de la app, con seguimiento opcional del tema del sistema.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** usar la app en modo oscuro, **para que** es mas comodo de usar en ambientes con poca luz, como un gimnasio de noche.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE ofrecer tema claro, oscuro y 'seguir sistema' en configuracion.
2. TODOS los componentes de la UI DEBEN respetar el tema seleccionado sin colores hardcodeados que rompan el contraste.
3. EL CAMBIO de tema DEBE aplicarse sin reiniciar la app.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
