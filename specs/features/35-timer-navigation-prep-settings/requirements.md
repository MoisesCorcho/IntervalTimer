# Requirements: Navegacion de Secciones, Preparacion y Ajustes

> Estado: En progreso

**ID:** F35 &nbsp;|&nbsp; **Slug:** `35-timer-navigation-prep-settings` &nbsp;|&nbsp; **Fase:** Fase 0 · Fundacion (extiende F01)

## Resumen

Extiende la experiencia de ejecucion del timer (F01) con:

1. **Navegacion bidireccional** entre secciones (intervalos): avanzar y retroceder mientras la sesion esta en `running`, `paused` o `preparing`.
2. **Confirmacion al salir** del entrenamiento (modal) para evitar cancelaciones accidentales.
3. **Tiempo restante total** de la sesion visible en la barra superior de la pantalla de ejecucion.
4. **Redisenio de la UI de ejecucion**: layout y forma de controles alineados a referencia premium (botones rectangulares con bordes redondeados sutiles; salir arriba-izquierda; pausa/reanudar centrado abajo; anterior/siguiente a los lados; preview "siguiente" estilizado).
5. **Fase de preparacion** configurable antes de iniciar cualquier sesion de timer.
6. **Pantalla de Configuracion** (shell de ajustes) con, por ahora, solo el control de segundos de preparacion.

La **pausa/reanudacion sin reiniciar la sesion** ya es responsabilidad de F01 (R4, R14). Esta feature **no redefine** ese contrato; debe **preservarlo y verificarlo** al agregar estados y controles nuevos.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core (motor, skip forward, pause/resume, cancel, pantalla de ejecucion)

## Postrequisitos (features que dependen de esta)

- F27 / F28 / F31 pueden reutilizar `features/settings/` y el repositorio de preferencias sin ser prerequisito formal de F35
- F02 puede anunciar la fase de preparacion en el futuro (fuera de alcance de F35)

## User Stories

- **Como** usuario, **quiero** avanzar o retroceder entre secciones mientras entreno, **para que** puedo corregir un salto o repetir una seccion sin cancelar toda la sesion.
- **Como** usuario, **quiero** un boton unico de pausar/reanudar que no reinicie el tiempo, **para que** retomo exactamente donde me detuve.
- **Como** usuario, **quiero** confirmar antes de salir del entrenamiento, **para que** no pierdo la sesion por un toque accidental.
- **Como** usuario, **quiero** ver el tiempo restante total de la sesion ademas del intervalo actual, **para que** se cuanto me falta del entrenamiento completo.
- **Como** usuario, **quiero** una cuenta regresiva de preparacion antes de que empiece el primer intervalo, **para que** puedo colocarme y arrancar sin prisa.
- **Como** usuario, **quiero** configurar la duracion de esa preparacion en Ajustes, **para que** adapto el prep a mi ritmo (o lo desactivo).

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Avanzar seccion (skip forward)

CUANDO el usuario activa "siguiente" durante la ejecucion en estado `running` o `paused` (fuera de preparacion), EL SISTEMA DEBE comportarse segun F01 R7: completar el intervalo actual; si hay posteriores, avanzar al siguiente con duracion completa y dejar el temporizador en estado `running`; si es el ultimo, completar la sesion (`completed` + `SessionCompleted`).

### R2 — Retroceder seccion (skip back) con intervalo previo

CUANDO el usuario activa "anterior" en estado `running` o `paused`, el indice del intervalo actual es **mayor que 0**, y la sesion no esta en preparacion, EL SISTEMA DEBE ir al intervalo **inmediatamente anterior**, reiniciarlo con su **duracion completa**, y mantener el temporizador en estado `running` (si estaba `paused`, reanuda en `running` al confirmar el salto — ver Decisiones).

### R3 — Retroceder en el primer intervalo

CUANDO el usuario activa "anterior" en estado `running` o `paused`, el indice del intervalo actual es **0**, y la sesion no esta en preparacion, EL SISTEMA DEBE **reiniciar el intervalo actual** con su duracion completa (no cancela la sesion ni sale a `idle`).

### R4 — Pausa y reanudacion sin reinicio (contrato F01)

CUANDO el usuario pausa y luego reanuda durante `running`, `paused` o `preparing`, EL SISTEMA DEBE congelar y retomar el **mismo** tiempo restante del segmento actual sin reiniciar la sesion, sin volver al primer intervalo y sin perder segundos (alineado a F01 R4 y R14).

### R5 — Boton unico pausar/reanudar

DONDE el usuario esta en la pantalla de ejecucion, CUANDO la sesion esta en `running` o `preparing`, EL SISTEMA DEBE mostrar un control primario con etiqueta/icono de **Pausar**. CUANDO la sesion esta en `paused` (incluyendo pausa durante preparacion), EL SISTEMA DEBE mostrar el **mismo** control con etiqueta/icono de **Reanudar**. Activar el control alterna entre esos dos estados.

### R6 — Confirmacion al salir del entrenamiento

DONDE el usuario esta en la pantalla de ejecucion en estado `running`, `paused` o `preparing`, CUANDO activa el control de salir/cancelar, EL SISTEMA DEBE mostrar un **modal de confirmacion** con:

- titulo que pregunte si desea salir (ej. "¿Salir del entrenamiento?");
- cuerpo breve que indique que se perdera el progreso de la sesion;
- accion de confirmar salida;
- accion de cancelar/continuar (cierra el modal sin cancelar la sesion).

### R7 — Confirmar salida cancela la sesion

CUANDO el usuario confirma la salida en el modal de R6, EL SISTEMA DEBE aplicar el contrato de F01 R8: detener el conteo, descartar progreso parcial, volver a `idle`, emitir `SessionCancelled` y salir de la pantalla de ejecucion.

### R8 — Tiempo restante total de sesion

DONDE el usuario esta en la pantalla de ejecucion en estado `running`, `paused` o `preparing`, CUANDO el contador se actualiza, EL SISTEMA DEBE mostrar en la **zona superior central** un indicador de **tiempo restante total** de la sesion (etiqueta tipo "RESTANTE" + `mm:ss` o `h:mm:ss` si supera 59:59), calculado como:

- en `preparing`: restante de preparacion + suma de duraciones de **todos** los intervalos de la sesion;
- en intervalo `i`: restante del intervalo actual + suma de duraciones completas de los intervalos con indice `> i`.

El valor DEBE actualizarse al menos con la misma cadencia que el contador del intervalo (F01 R2: cada 100ms o menos) y DEBE congelarse en `paused` junto con el resto del tiempo.

### R9 — Layout de controles de ejecucion

DONDE el usuario esta en la pantalla de ejecucion, CUANDO la sesion esta en `running`, `paused` o `preparing`, EL SISTEMA DEBE presentar:

1. **Arriba izquierda:** control de salir (icono cerrar o equivalente) que dispara R6.
2. **Arriba centro:** tiempo restante total (R8).
3. **Centro:** nombre/fase del segmento actual (preparacion o intervalo) y, si aplica, progreso de intervalo (ej. "3/8"), con el **tiempo del segmento actual** como elemento visual dominante.
4. **Abajo, zona de pulgar:** fila de tres controles:
   - izquierda: **Anterior** (R2/R3);
   - centro: **Pausar/Reanudar** (R5), con mayor peso visual;
   - derecha: **Siguiente** (R1).
5. Forma de botones: **rectangulos con bordes redondeados sutiles** (no circulos ni cuadrados de esquina viva); radio alineado a tokens `radius.sm`/`radius.md` de `_global/04-design-system.md`.
6. Area de toque minima **48×48 dp** en cada control interactivo.

### R10 — Preview siguiente estilizado

DONDE el usuario esta en la pantalla de ejecucion en un intervalo de trabajo/descanso (no en preparacion, o en preparacion mostrando el primer intervalo como siguiente), CUANDO hay un intervalo posterior, EL SISTEMA DEBE mostrar un bloque de **proxima seccion** con estilo premium (superficie elevada o card con radio y padding del design system, jerarquia tipografica clara: etiqueta secundaria "Siguiente" + nombre + duracion opcional). SI no hay posterior, EL SISTEMA DEBE indicar explicitamente que es el ultimo intervalo (F01 R9).

### R11 — Inicio con preparacion > 0

CUANDO el usuario inicia una sesion con al menos un intervalo y el valor de preparacion configurado es **N > 0** segundos, EL SISTEMA DEBE:

1. entrar en estado `preparing` (no `running` de intervalos aun);
2. mostrar cuenta regresiva de preparacion de N segundos;
3. al llegar a 0 en preparacion, avanzar automaticamente al **primer intervalo** con su duracion completa y estado `running` (equivalente al inicio post-prep de F01 R10).

### R12 — Inicio con preparacion = 0

CUANDO el usuario inicia una sesion con al menos un intervalo y la preparacion configurada es **0**, EL SISTEMA DEBE omitir la fase de preparacion e iniciar el primer intervalo de inmediato (comportamiento F01 R10).

### R13 — Controles durante preparacion

MIENTRAS la sesion esta en `preparing` (o `paused` originado desde preparacion), EL SISTEMA DEBE:

- permitir **Pausar/Reanudar** (R4, R5);
- permitir **Siguiente**: omite el resto de la preparacion e inicia el primer intervalo con duracion completa en `running`;
- tratar **Anterior** como no-op seguro (sin error bloqueante; el control puede mostrarse deshabilitado);
- permitir **Salir** con modal (R6–R7).

### R14 — Pantalla de Configuracion: acceso y shell

DONDE el usuario esta fuera de una sesion activa de timer (estados distintos de `running`/`paused`/`preparing` en pantalla de ejecucion), CUANDO navega a **Configuracion/Ajustes** desde el punto de entrada de la app definido en `design.md`, EL SISTEMA DEBE mostrar una pantalla de ajustes con al menos el control de R15.

### R15 — Configurar segundos de preparacion

DONDE el usuario esta en la pantalla de Configuracion, CUANDO ajusta los segundos de preparacion dentro del rango **0–60** inclusive, EL SISTEMA DEBE persistir el valor de forma durable (sobrevive reinicio de app) y usarlo en el **siguiente** inicio de sesion (R11/R12). El control DEBE usar el patron de steppers del proyecto (`NumberStepper` de F33) cuando este disponible, sin teclado libre.

### R16 — Default de preparacion

CUANDO la app no tiene un valor de preparacion persistido aun (primera instalacion o preferencia ausente), EL SISTEMA DEBE usar **10 segundos** como default efectivo hasta que el usuario guarde otro valor.

## Criterios de Aceptacion — Validacion y error (formato EARS)

### R17 — Rango invalido de preparacion en UI

DONDE el usuario esta en Configuracion, CUANDO el valor de preparacion esta en el minimo (0) o maximo (60), EL SISTEMA DEBE deshabilitar el boton que intentaria salir del rango (patron F33) y no persistir valores fuera de 0–60.

### R18 — Acciones invalidas ignoradas

CUANDO el usuario intenta avanzar/retroceder/pausar en estados donde la accion no aplica (ej. `idle`, `completed`, o anterior durante preparacion), EL SISTEMA DEBE ignorar la accion sin cambiar de estado de forma incorrecta ni mostrar error bloqueante (extension del espiritu de F01 R15).

### R19 — Pausa prioritaria vs fin de segmento

CUANDO el usuario pausa en el mismo instante en que el segmento actual (preparacion o intervalo) llega a 0, EL SISTEMA DEBE priorizar la pausa: congelar el restante del segmento actual sin avanzar al siguiente (alineado a F01 R16, extensible a preparacion).

### R20 — No editar preparacion a mitad de sesion activa

MIENTRAS existe una sesion en `preparing`, `running` o `paused`, CUANDO el valor de preparacion en preferencias cambia (si la UI de ajustes no esta accesible, este caso es defensivo), EL SISTEMA DEBE **no** alterar la duracion del segmento de preparacion ya iniciado ni reiniciar la sesion en curso; el nuevo valor aplica solo al **proximo** `start`.

## Decisiones de producto (resuelven ambiguedades)

| Tema | Decision |
|---|---|
| Estado de maquina | Se agrega `preparing` entre `idle` e intervalos: `idle` → `preparing` (si prep > 0) → `running` ↔ `paused` → `completed`. Pausa desde prep: `preparing` → `paused` con flag/contexto de segmento prep. |
| Skip (anterior/siguiente) deja `paused` | Tras skip back/forward, el timer queda en **`running`** (reanuda) para no dejar al usuario en pausa silenciosa tras un salto intencional. |
| Anterior en indice 0 | Reinicia el intervalo actual a duracion completa (R3), no cancela. |
| Anterior en preparacion | No-op / control deshabilitado (R13). |
| Siguiente en preparacion | Salta prep e inicia intervalo 0 (R13). |
| Default prep | 10 s (R16). |
| Rango prep | 0–60 s inclusive; 0 desactiva prep (R12). |
| Persistencia prep | `shared_preferences` (clave documentada en design / `05-data-model.md`); no requiere tabla drift para un solo entero global. |
| Shell Settings | Introduce `features/settings/` como base reutilizable; F35 solo agrega el item de preparacion. |
| Mute / audio en referencia visual | Fuera de alcance (F02/F17). |
| Pausa sin reinicio | Contrato F01; F35 lo verifica en tests de regresion al tocar `TimerController`. |
| Labels UI (es) | "Pausar", "Reanudar", "Anterior"/"Siguiente" o iconos equivalentes, "RESTANTE", "Preparacion", modal salir — centralizados en `ui_strings.dart` hasta F28. |

## Fuera de alcance (explicito)

- Voces/anuncios de preparacion (F02).
- Otras preferencias de ajustes (tema F27, idioma F28, accesibilidad F31).
- Historial de sesiones (F04).
- Edicion de intervalos durante ejecucion.
- Widget de lock screen / smartwatch.
- Cambiar el default de prep por rutina (solo global en F35).
- Cualquier comportamiento no listado se considera fuera de alcance.

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion durante el entrenamiento; offline-first.
- `_global/02-architecture-and-structure.md` — `features/timer/`, `features/settings/`, capas.
- `_global/03-conventions.md` — EARS, Riverpod, testing con timestamps/`fake_async`, `ui_strings.dart`.
- `_global/04-design-system.md` — jerarquia del timer, touch 48dp, radius, steppers F33.
- `_global/05-data-model.md` — preferencias globales; sin entidad drift nueva obligatoria.
- `features/01-interval-timer-core/` — contratos R4, R7, R8, R9, R10, R14, R16 a preservar.
- `features/33-premium-numeric-steppers/` — `NumberStepper` para el control de prep.
