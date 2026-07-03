# Tasks: Interval Timer Core

**ID:** F01 &nbsp;|&nbsp; **Slug:** `01-interval-timer-core`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir modelos `Interval` y `Routine` (con serializacion a JSON para persistencia).
- [ ] Implementar `TimerController` con la maquina de estados (idle/running/paused/completed).
- [ ] Implementar logica de avance automatico entre intervalos.
- [ ] Construir UI de creacion/edicion de intervalos con selector de color.
- [ ] Construir pantalla de ejecucion: circulo/barra de progreso, nombre del intervalo actual, siguiente intervalo en preview.
- [ ] Implementar controles: play, pause, resume, skip, cancelar sesion.
- [ ] Manejar ciclo de vida de la app (background/foreground) sin perder precision del tiempo.
- [ ] Tests unitarios de la maquina de estados y del calculo de tiempo restante.

## Notas de secuenciacion

Esta feature depende de: ninguna (fundacional).
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
