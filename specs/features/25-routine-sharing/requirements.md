# Requirements: Compartir Rutinas con Otros Usuarios

**ID:** F25 &nbsp;|&nbsp; **Slug:** `25-routine-sharing` &nbsp;|&nbsp; **Fase:** Fase 6 · Social (Futuro)

## Resumen

Permite exportar/publicar una rutina propia para que otros usuarios la importen. Requiere backend real (a diferencia de la mayoria de features anteriores.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F05 - Editor de Rutinas Propias
- F06 - Capa Pro / Compras In-App

## Postrequisitos (features que dependen de esta)

- F26 - Retos Grupales

## User Stories

- **Como** usuario, **quiero** compartir una rutina que arme con un amigo, **para que** puede usarla sin tener que recrearla manualmente.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir exportar una rutina propia a un formato compartible (link o codigo).
2. EL SISTEMA DEBE permitir importar una rutina desde un link/codigo compartido por otro usuario.
3. SI se implementa como catalogo publico (no solo link 1 a 1), ENTONCES EL SISTEMA DEBE incluir moderacion basica de contenido antes de hacerlo visible a otros.
4. ESTA feature REQUIERE backend (no es viable solo local): almacenamiento remoto de rutinas + identificacion de usuario.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
