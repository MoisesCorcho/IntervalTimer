# Requirements: Ajuste Rapido de Intensidad

> Estado: No iniciada

**ID:** F11 &nbsp;|&nbsp; **Slug:** `11-quick-intensity-scaling` &nbsp;|&nbsp; **Fase:** Fase 2 · Profundidad de Entrenamiento

## Resumen

Boton para escalar toda la rutina (+/- tiempo global) sin tener que editar cada intervalo manualmente.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F05 - Editor de Rutinas Propias

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** escalar toda mi rutina +20% o -20% de tiempo con un boton, **para que** adapto rapido la dificultad sin editar intervalo por intervalo.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE ofrecer un control (slider o botones +/-) para escalar la duracion de todos los intervalos de trabajo de una rutina por un porcentaje.
2. EL SISTEMA DEBE aplicar el escalado solo a la sesion en curso por defecto, preguntando si se desea guardar como cambio permanente.
3. EL SISTEMA DEBE excluir del escalado los intervalos marcados como 'reps' (F10), ya que no tienen duracion fija.
4. EL SISTEMA DEBE respetar un minimo de duracion (ej. 5s) para evitar intervalos de 0 o negativos al escalar hacia abajo.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
