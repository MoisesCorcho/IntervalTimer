# Requirements: Repeticion de Circuitos (Rounds)

**ID:** F08 &nbsp;|&nbsp; **Slug:** `08-circuit-repetition-rounds` &nbsp;|&nbsp; **Fase:** Fase 2 · Profundidad de Entrenamiento

## Resumen

Permite agrupar un bloque de intervalos y repetirlo N veces (ej. 4 ejercicios x 3 rondas) sin duplicar manualmente los intervalos.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F05 - Editor de Rutinas Propias

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** definir un bloque de ejercicios y repetirlo varias veces, **para que** no tengo que armar el mismo circuito manualmente varias veces.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir agrupar un subconjunto de intervalos en un 'bloque' con un numero de repeticiones configurable.
2. CUANDO el timer ejecuta un bloque, EL SISTEMA DEBE repetir la secuencia completa las veces indicadas antes de avanzar al siguiente elemento de la rutina.
3. EL SISTEMA DEBE mostrar visualmente en que ronda va el usuario (ej. 'Ronda 2 de 3').
4. EL SISTEMA DEBE permitir anidar como maximo un nivel de bloque (sin bloques dentro de bloques) en el MVP.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
