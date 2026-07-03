# Requirements: Interval Timer Core

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Motor central del temporizador: creacion de intervalos (nombre, duracion, color), ejecucion secuencial, pausa/reanudacion, y visualizacion en tiempo real.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- Ninguno (feature fundacional)

## Postrequisitos (features que dependen de esta)

- F02 - Voz: Cuenta Regresiva y Anuncios
- F03 - Sesiones Preestablecidas con Animacion/Video
- F04 - Calendario e Historial de Sesiones
- F05 - Editor de Rutinas Propias
- F06 - Capa Pro / Compras In-App
- F08 - Repeticion de Circuitos (Rounds)
- F10 - Modo por Repeticiones
- F11 - Ajuste Rapido de Intensidad
- F17 - Integracion de Musica / Audio Ducking
- F18 - Vibracion como Feedback
- F19 - Pantalla Siempre Encendida
- F20 - Widget de Pantalla de Bloqueo / Notificacion Persistente
- F21 - Soporte para Smartwatch (Wear OS / Apple Watch)
- F27 - Modo Oscuro
- F28 - Multilenguaje (i18n)
- F30 - Onboarding
- F31 - Accesibilidad

## User Stories

- **Como** usuario, **quiero** crear una lista de intervalos con nombre, duracion y color, **para que** puedo estructurar cualquier tipo de entrenamiento (calentamiento, trabajo, descanso, estiramiento).
- **Como** usuario, **quiero** iniciar, pausar, reanudar y saltar un intervalo durante la ejecucion, **para que** tengo control total mientras entreno.

## Criterios de Aceptacion (formato EARS)

1. CUANDO el usuario agrega un intervalo, EL SISTEMA DEBE requerir nombre, duracion (mm:ss) y color.
2. CUANDO el temporizador esta corriendo, EL SISTEMA DEBE actualizar el contador cada 100ms o menos para fluidez visual.
3. CUANDO un intervalo llega a 0, EL SISTEMA DEBE avanzar automaticamente al siguiente sin input del usuario.
4. CUANDO el usuario pausa, EL SISTEMA DEBE congelar el conteo exacto y permitir reanudar desde ese punto.
5. SI la app pasa a segundo plano, ENTONCES EL SISTEMA DEBE seguir contando con precisión basada en timestamp real, no en ticks de UI.
6. CUANDO todos los intervalos terminan, EL SISTEMA DEBE marcar la sesion como completada y disparar el evento de fin de sesion.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
