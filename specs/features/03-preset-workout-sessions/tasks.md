# Tasks: Sesiones Preestablecidas con Animacion/Video

**ID:** F03 &nbsp;|&nbsp; **Slug:** `03-preset-workout-sessions`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Definir modelos `Exercise` y `PresetRoutine`.
- [ ] Curar/producir contenido inicial: min. 4-5 categorias con 3-5 ejercicios cada una.
- [ ] Implementar pantalla de catalogo de rutinas por categoria.
- [ ] Implementar pantalla de detalle de rutina (lista de ejercicios + boton iniciar).
- [ ] Implementar visor de ejercicio individual con Lottie/video y fallback a imagen.
- [ ] Cargar `PresetRoutine` seleccionada dentro del `TimerController` (F01).
- [ ] Tests de carga de JSON de rutinas y manejo de assets faltantes.

## Notas de secuenciacion

Esta feature depende de: F01.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
