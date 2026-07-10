# Tasks: Navegacion de Secciones, Preparacion y Ajustes

**ID:** F35 &nbsp;|&nbsp; **Slug:** `35-timer-navigation-prep-settings`

## Definition of Done

- [x] Todos los criterios R1–R20 de `requirements.md` estan implementados y verificados. _(cubre R1–R20)_
- [x] Tests unitarios y widget listados abajo pasan en CI/local.
- [x] Preferencia `prep_seconds` documentada en `_global/05-data-model.md`.
- [x] Regresion F01: pause/resume, skip forward, cancel y complete siguen correctos.
- [x] Codigo revisado contra `_global/03-conventions.md` y UI contra `_global/04-design-system.md`.
- [x] Roadmap F35 en estado coherente con `requirements.md` al cerrar la feature.

## Checklist de implementacion

### Datos y preferencias

- [x] Documentar en `_global/05-data-model.md` la preferencia `prep_seconds` (default 10, rango 0–60). _(cubre R15, R16)_
- [x] Implementar `SettingsRepository` (get/set clamp 0–60; default 10 si ausente) sobre `PreferencesRepository` / `app_preferences` (semantica shared_preferences). _(cubre R15, R16, R17)_
- [x] Implementar `SettingsController` / provider Riverpod que expone y actualiza `prepSeconds`. _(cubre R14, R15)_

### Logica del temporizador

- [x] Extender `TimerStatus` / `TimerState` con fase de preparacion (`preparing` y /o `segmentKind`). _(cubre R11, R12, R13)_
- [x] Al `start()`, leer `sessionPrepSeconds` una sola vez; prep > 0 → `preparing`, prep = 0 → intervalo 0 `running`. _(cubre R11, R12, R16, R20)_
- [x] Reutilizar timestamps para restante de prep; al llegar a 0 avanzar a intervalo 0. _(cubre R11, R4)_
- [x] Preservar `pause`/`resume` sin reiniciar sesion ni restante (prep e intervalos). _(cubre R4, R5, R19)_
- [x] Implementar `skipForward` unificado: desde prep salta a intervalo 0; desde intervalo aplica F01 R7; estado post-salto `running`. _(cubre R1, R13)_
- [x] Implementar `skipBack`: prep no-op; index 0 reinicia actual; index > 0 va al anterior full; post-salto `running`. _(cubre R2, R3, R13, R18)_
- [x] Exponer `totalRemainingMs` (y helpers UI: canSkipBack visual, etc.). _(cubre R8)_
- [x] Mantener `cancel` + eventos `SessionCancelled` / complete sin romper contratos F01. _(cubre R7)_
- [x] Priorizar pausa vs fin de segmento tambien en preparacion. _(cubre R19)_

### UI — ejecucion

- [x] Redisenar top bar: salir izq. + RESTANTE total centro. _(cubre R6, R8, R9)_
- [x] Implementar modal de confirmacion al salir; confirmar → `cancel()`; continuar → cierra modal. _(cubre R6, R7)_
- [x] Hero: nombre de fase/intervalo, progreso, tiempo de segmento dominante. _(cubre R9, R11)_
- [x] Control bar inferior: Anterior | Pausar/Reanudar toggle | Siguiente; botones rectangulares radio sutil; touch ≥ 48dp. _(cubre R1, R2, R3, R5, R9)_
- [x] Deshabilitar o no-op visual de Anterior en preparacion. _(cubre R13, R18)_
- [x] Estilizar card/preview de siguiente seccion (premium). _(cubre R10)_
- [x] Strings en `ui_strings.dart`. _(cubre R5, R6, R8, R9, R11, R14)_

### UI — configuracion

- [x] Crear `SettingsScreen` con `NumberStepper` (0–60, step 1) para preparacion y label claro. _(cubre R14, R15, R17)_
- [x] Registrar ruta `/settings` como tab del shell (Rutina | Entrenamientos | Ajustes). _(cubre R14)_
- [x] Persistir al cambiar valor; verificar que no muta sesion activa (R20) si aplica. _(cubre R15, R20)_

### Tests

- [x] **Unit — prep start:** prep=10 inicia `preparing` y no corre intervalo 0 hasta fin de prep; prep=0 inicia intervalo 0. _(cubre R11, R12, R16)_
- [x] **Unit — prep fin y skip:** prep llega a 0 → intervalo 0 full; skipForward en prep → intervalo 0; skipBack en prep no-op. _(cubre R11, R13, R18)_
- [x] **Unit — skipBack:** index>0 va a anterior full en `running`; index=0 reinicia actual full. _(cubre R2, R3)_
- [x] **Unit — skipForward:** ultimo intervalo completa sesion; intermedio avanza (regresion F01 R7 / R1). _(cubre R1)_
- [x] **Unit — pause/resume:** pause en intervalo y en prep congela restante; resume continua sin reset de indice. _(cubre R4, R5, R19)_
- [x] **Unit — totalRemainingMs:** coherente en prep, en intervalo medio y en ultimo; estable en pause. _(cubre R8)_
- [x] **Unit — settings repo:** default 10; set 0 y 60 ok; fuera de rango clamp; valor sobrevive mock prefs. _(cubre R15, R16, R17)_
- [x] **Unit — R20:** cambiar prep en repo tras start no altera `sessionPrepSeconds` de la sesion en curso. _(cubre R20)_
- [x] **Widget — ejecucion layout:** top restante + controles prev/pause/next + keys de botones; pause muestra Reanudar. _(cubre R5, R8, R9)_
- [x] **Widget — modal salir:** tap salir abre dialog; continuar no cancela; confirmar invoca cancel/sale. _(cubre R6, R7)_
- [x] **Widget — settings:** stepper visible; cambiar valor actualiza provider/repo (mock). _(cubre R14, R15)_
- [x] **Widget — next card:** muestra siguiente o estado ultimo intervalo. _(cubre R10)_

## Mapa de trazabilidad (resumen)

| Criterio | Tareas que lo cubren |
|---|---|
| R1 | skipForward, control Siguiente, unit skipForward |
| R2 | skipBack index>0, control Anterior, unit skipBack |
| R3 | skipBack index=0, unit skipBack |
| R4 | pause/resume controller, unit pause/resume |
| R5 | control toggle UI, widget ejecucion |
| R6 | top bar salir, modal, widget modal |
| R7 | modal confirmar → cancel, widget modal |
| R8 | totalRemainingMs, top bar, unit total, widget layout |
| R9 | redesenio layout, control bar, widget layout |
| R10 | next card premium, widget next card |
| R11 | start con prep, UI fase prep, unit prep start/fin |
| R12 | start prep=0, unit prep start |
| R13 | controles en prep, unit prep skip |
| R14 | SettingsScreen, ruta, widget settings |
| R15 | repo + stepper + persistencia, unit settings |
| R16 | default repo, unit settings, start |
| R17 | clamp UI/repo, unit settings |
| R18 | no-ops, unit prep skipBack |
| R19 | pause vs fin segmento, unit pause/resume |
| R20 | sessionPrepSeconds snapshot, unit R20 |

## Notas de secuenciacion

Depende de: **F01** completa/estable en motor y pantalla de ejecucion.

Orden recomendado:

1. Documentar prefs + `SettingsRepository` + controller  
2. Extender `TimerController` (prep, skipBack, totalRemaining) + tests unit  
3. UI ejecucion (layout, modal, card) + widget tests  
4. Settings screen + navegacion + widget tests  
5. Barrido de regresion F01 y DoD  

No iniciar implementacion hasta que este archivo y `requirements.md` / `design.md` esten aceptados por el equipo (ideal: auditoria `07` sin hallazgos bloqueantes).
