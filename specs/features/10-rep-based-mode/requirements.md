# Requirements: Modo por Repeticiones

> Estado: No iniciada

**ID:** F10 &nbsp;|&nbsp; **Slug:** `10-rep-based-mode` &nbsp;|&nbsp; **Fase:** Fase 2 · Profundidad de Entrenamiento

## Resumen

Intervalos que se completan manualmente por conteo de repeticiones (ej. ejercicios de fuerza) en lugar de por tiempo.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** marcar un intervalo como 'por repeticiones' en vez de tiempo, **para que** puedo usar el timer tambien para ejercicios de fuerza con series y reps.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir marcar un intervalo como tipo 'reps' en lugar de 'tiempo', con un numero objetivo de repeticiones opcional (referencia visual, no cuenta automatica).
2. CUANDO el timer llega a un intervalo tipo 'reps', EL SISTEMA DEBE pausar el avance automatico y esperar que el usuario confirme 'Listo' para continuar.
3. EL SISTEMA DEBE seguir contando el tiempo transcurrido en un intervalo de reps para fines de historial, aunque no tenga limite fijo.
4. EL SISTEMA DEBE anunciar por voz el objetivo de repeticiones al iniciar el intervalo (integra con F02).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
