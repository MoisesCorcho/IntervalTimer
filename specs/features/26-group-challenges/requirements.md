# Requirements: Retos Grupales

**ID:** F26 &nbsp;|&nbsp; **Slug:** `26-group-challenges` &nbsp;|&nbsp; **Fase:** Fase 6 · Social (Futuro)

## Resumen

Retos entre amigos (ej. 'quien entrena mas esta semana') con ranking simple.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F25 - Compartir Rutinas con Otros Usuarios
- F12 - Estadisticas y Progreso

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** competir amistosamente con mis amigos en minutos entrenados, **para que** me motivo mas a traves de la competencia social.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE permitir crear un reto con un grupo de usuarios, una metrica (minutos/sesiones) y una duracion.
2. EL SISTEMA DEBE mostrar un ranking actualizado de los participantes durante el reto.
3. AL finalizar el reto, EL SISTEMA DEBE mostrar el resultado final y notificar al ganador.
4. ESTA feature REQUIERE backend real (sincronizacion entre multiples usuarios en tiempo casi real).

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
