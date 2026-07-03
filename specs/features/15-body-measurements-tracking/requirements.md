# Requirements: Registro de Peso y Medidas

**ID:** F15 &nbsp;|&nbsp; **Slug:** `15-body-measurements-tracking` &nbsp;|&nbsp; **Fase:** Fase 3 · Seguimiento y Motivacion

## Resumen

Registro opcional y simple de peso corporal y medidas, con grafica de evolucion en el tiempo.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F04 - Calendario e Historial de Sesiones

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** registrar mi peso periodicamente, **para que** puedo ver mi evolucion junto con mi progreso de entrenamiento.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir registrar peso corporal (y opcionalmente medidas: cintura, brazo, pierna) con fecha.
2. EL SISTEMA DEBE mostrar una grafica de evolucion del peso en el tiempo.
3. EL SISTEMA DEBE permitir configurar unidad (kg/lb) segun preferencia del usuario.
4. ESTA feature DEBE ser completamente opcional: no debe bloquear ningun otro flujo si el usuario nunca la usa.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
