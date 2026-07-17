# Requirements: Interval Timer Core

> Estado: Completa

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion

## Resumen

Motor central del temporizador: creacion de intervalos (nombre, duracion, color), ejecucion secuencial, pausa/reanudacion, salto y cancelacion de sesion, y visualizacion en tiempo real.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- Ninguno (feature fundacional)

## Postrequisitos (features que dependen de esta)

- F02 - Voz: Cuenta Regresiva y Anuncios
- F03 - Sesiones Preestablecidas con Animacion/Video
- F04 - Calendario e Historial de Sesiones
- F05 - Editor de Rutinas Propias
- F32 - Constructor de Entrenamientos por Ejercicios
- F33 - Controles Numericos y de Duracion (Steppers Premium)
- F35 - Navegacion de Secciones, Preparacion y Ajustes
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
- **Como** usuario, **quiero** cancelar una sesion en curso, **para que** puedo abandonar un entrenamiento sin esperar a que terminen todos los intervalos.

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Creacion de intervalo

CUANDO el usuario agrega un intervalo con nombre no vacio, duracion valida (mm:ss entre 00:01 y 99:59) y color (explicito o default de marca), EL SISTEMA DEBE persistir el intervalo en la rutina activa.

### R2 — Actualizacion del contador visible

CUANDO el temporizador esta en estado `running`, EL SISTEMA DEBE actualizar el contador visible cada 100ms o menos.

### R3 — Avance automatico entre intervalos

CUANDO el tiempo restante del intervalo actual llega a 0 y existen intervalos posteriores, EL SISTEMA DEBE avanzar automaticamente al siguiente intervalo con su duracion completa, sin input del usuario.

### R4 — Pausa y reanudacion

CUANDO el usuario pausa durante la ejecucion, EL SISTEMA DEBE congelar el tiempo restante exacto y permitir reanudar desde ese punto sin perdida de segundos.

### R5 — Continuidad en segundo plano

SI la app pasa a segundo plano durante una sesion en estado `running` y el usuario vuelve a primer plano tras hasta 60 minutos, ENTONCES EL SISTEMA DEBE mostrar un tiempo restante con error maximo de ±1 segundo respecto al tiempo teorico transcurrido.

### R6 — Fin de sesion completada

CUANDO el ultimo intervalo de la rutina llega a 0, EL SISTEMA DEBE transicionar a estado `completed` y emitir un evento `SessionCompleted` observable (ver contrato en `design.md`).

### R7 — Saltar intervalo

CUANDO el usuario activa "saltar" durante la ejecucion en estado `running` o `paused`, EL SISTEMA DEBE marcar el intervalo actual como completado.

SI existen intervalos posteriores, ENTONCES EL SISTEMA DEBE avanzar al siguiente con duracion completa y mantener el temporizador en estado `running`.

SI el intervalo actual es el ultimo (incluido el caso de rutina con un solo intervalo), ENTONCES EL SISTEMA DEBE transicionar a estado `completed` y emitir `SessionCompleted` (equivalente a R6).

### R8 — Cancelar sesion

CUANDO el usuario cancela la sesion durante la ejecucion, EL SISTEMA DEBE detener el conteo, descartar el progreso parcial, volver a estado `idle` y emitir un evento `SessionCancelled` observable (ver contrato en `design.md`).

### R9 — Vista de ejecucion: intervalo actual y siguiente

DONDE el usuario esta en la pantalla de ejecucion del temporizador, CUANDO la sesion esta en estado `running` o `paused`, EL SISTEMA DEBE mostrar el nombre y color del intervalo actual, el tiempo restante como elemento visual dominante, y un preview del siguiente intervalo (o indicar "ultimo intervalo" si no hay mas).

### R10 — Inicio de sesion

CUANDO el usuario inicia la sesion con al menos un intervalo en la rutina, EL SISTEMA DEBE comenzar el primer intervalo con su duracion completa y transicionar a estado `running`.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R11 — Nombre invalido

CUANDO el usuario intenta guardar un intervalo con nombre vacio, solo espacios en blanco, o longitud superior a 50 caracteres, EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir el intervalo.

### R12 — Duracion invalida

CUANDO el usuario ingresa una duracion fuera del rango 00:01–99:59 o en formato no parseable (ej. `abc`, `00:00`), EL SISTEMA DEBE rechazar la operacion y mostrar un mensaje de validacion visible sin persistir el intervalo.

### R13 — Rutina vacia

CUANDO el usuario intenta iniciar la sesion sin intervalos en la rutina, EL SISTEMA DEBE impedir el inicio y mostrar un mensaje indicando que se requiere al menos un intervalo.

### R14 — Congelamiento en pausa

MIENTRAS el temporizador esta en estado `paused`, EL SISTEMA DEBE mantener el tiempo restante sin decrementar.

### R15 — Transicion invalida ignorada

CUANDO el usuario intenta pausar estando en estado `idle` o `completed`, EL SISTEMA DEBE ignorar la accion sin cambiar de estado ni mostrar error bloqueante.

### R16 — Condicion de carrera pausa vs avance

CUANDO el usuario pausa en el mismo instante en que un intervalo llega a 0, EL SISTEMA DEBE priorizar la pausa: congelar el tiempo restante del intervalo actual sin avanzar al siguiente.

### R17 — Contraste de color en ejecucion

DONDE el usuario esta en la pantalla de ejecucion, CUANDO se muestra un intervalo con color de fondo o acento asignado por el usuario, EL SISTEMA DEBE calcular automaticamente texto blanco o negro para cumplir contraste WCAG AA (ratio >= 4.5:1) segun `_global/04-design-system.md`.

### R18 — Retorno tras sesion completada

CUANDO la sesion transiciona a estado `completed`, EL SISTEMA DEBE mostrar una confirmacion visible de que la sesion finalizo (ej. mensaje o pantalla de resumen) y ofrecer una accion explicita (ej. boton "Volver" o "Listo") que transiciona a estado `idle` y regresa a la pantalla de creacion/edicion de la rutina.

## Decisiones de producto (resuelven ambiguedades de la auditoria)

| Tema | Decision |
|---|---|
| Edicion durante ejecucion | No permitida. La edicion de intervalos solo esta disponible en estado `idle` (pantalla de creacion/edicion). |
| Color por defecto | Si el usuario no elige color explicitamente, se asigna el color de trabajo por defecto definido en `ThemeData` / `_global/04-design-system.md`. |
| Longitud maxima de nombre | 50 caracteres (criterio R11). |
| Skip sin intervalos posteriores | Cubierto por R7: ultimo intervalo o rutina de un solo intervalo → `completed` + `SessionCompleted`. |
| Cancel vs completada | `SessionCancelled` es distinto de `SessionCompleted`; F04 consumira ambos para `SessionLog` abortado vs completo. |

## Fuera de alcance (explicito)

- Edicion de intervalos mientras la sesion esta `running` o `paused`.
- Persistencia de historial de sesiones (responsabilidad de F04).
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first, cero friccion durante el entrenamiento.
- `_global/02-architecture-and-structure.md` — capas, carpetas, persistencia con drift.
- `_global/03-conventions.md` — formato EARS, Riverpod, testing.
- `_global/04-design-system.md` — jerarquia visual, contraste, componentes (`CountdownRing`, controles 48dp).
- `_global/05-data-model.md` — entidades `Interval`, `Routine`, `RoutineItem`.