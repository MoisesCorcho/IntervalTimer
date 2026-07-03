# Requirements: Progresion Automatica

**ID:** F09 &nbsp;|&nbsp; **Slug:** `09-automatic-progression` &nbsp;|&nbsp; **Fase:** Fase 2 · Profundidad de Entrenamiento

## Resumen

Incrementa automaticamente la dificultad de una rutina a lo largo de las semanas (ej. mas tiempo de trabajo, menos descanso) segun un plan configurado.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F05 - Editor de Rutinas Propias
- F04 - Calendario e Historial de Sesiones

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** que la app aumente la dificultad de mi rutina semana a semana, **para que** progreso sin tener que reconfigurar manualmente.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir configurar un plan de progresion sobre una rutina: numero de semanas y regla de incremento por semana (ej. +5s trabajo, -2s descanso).
2. CUANDO el usuario inicia una rutina con plan de progresion activo, EL SISTEMA DEBE calcular automaticamente la semana actual segun la fecha de inicio del plan.
3. EL SISTEMA DEBE aplicar los valores de la semana correspondiente sin modificar la rutina base original.
4. EL SISTEMA DEBE permitir pausar o reiniciar un plan de progresion.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
