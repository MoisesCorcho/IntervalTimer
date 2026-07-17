# Requirements: Modo Oscuro

> Estado: Completa

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Tema oscuro completo de la app, con seguimiento opcional del tema del sistema operativo. La preferencia se persiste via Drift `app_preferences` (mismo patron que F35 `prep_seconds`).

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core (Completado)

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** usar la app en modo oscuro, **para que** es mas comodo de usar en ambientes con poca luz, como un gimnasio de noche.
- **Como** usuario, **quiero** que la app siga automaticamente el tema de mi telefono, **para que** no tenga que cambiarlo manualmente.

## Criterios de Aceptacion (formato EARS)

### Happy Path

#### R1 — Opciones de tema en configuracion

EL SISTEMA DEBE ofrecer tres opciones de tema en la pantalla de Ajustes: Claro, Oscuro y Seguir sistema.

#### R2 — Aplicacion inmediata del tema

CUANDO el usuario selecciona una opcion de tema diferente, EL SISTEMA DEBE aplicar el cambio inmediatamente en toda la app sin necesidad de reiniciar.

#### R3 — Persistencia de preferencia

EL SISTEMA DEBE persistir la opcion de tema seleccionada entre sesiones de la app, utilizando Drift `app_preferences` (mismo patron que `prep_seconds`).

#### R4 — Default al primer lanzamiento

CUANDO la app se ejecuta por primera vez sin preferencia guardada, EL SISTEMA DEBE usar "Seguir sistema" como tema por defecto.

#### R5 — Seguimiento automatico del tema del sistema

SI la opcion seleccionada es "Seguir sistema", ENTONCES EL SISTEMA DEBE cambiar automaticamente entre tema claro y oscuro cuando el sistema operativo cambia de tema.

#### R6 — Todos los componentes respetan el tema

DONDE el usuario esta en cualquier pantalla de la app, EL SISTEMA DEBE mostrar todos los componentes de la UI respetando el tema seleccionado, sin colores hardcodeados que rompan el contraste.

### Validacion y error

#### R7 — Contraste de colores de intervalo sobre ambos temas

DONDE el usuario esta en la pantalla de ejecucion del timer, EL SISTEMA DEBE calcular el contraste del texto sobre el color de intervalo actual dinamicamente, usando `contrastTextColor` contra el fondo de la pantalla (claro u oscuro), garantizando ratio WCAG AA >= 4.5:1.

#### R8 — Sin colores hardcodeados en widgets

EL SISTEMA DEBE prohibir colores ARGB hardcodeados en **chrome in-app** (pantallas, cards, botones, listas, chrome de navegacion); todo color DEBE consumirse via `Theme.of(context)` o desde constantes del design system que dependan del tema (`AppTheme`, `ColorScheme`).

**Excepciones explicitas (no violan R8):**
- **Colores de intervalo por tipo** (`warmupColor`, `workColor`, `restColor`, `stretchColor`): constantes de marca usadas como fondo de segmento; el texto se resuelve con `contrastTextColor`.
- **Assets exportados de share (F16):** plantillas / arte de `session_share_studio` y tarjetas de share pueden usar paleta de marca fija para el **bitmap exportado**, de modo que la imagen compartida no dependa del tema del dispositivo. El chrome de la app que rodea el flujo de share sigue R8 (theme tokens).

## Fuera de alcance (explicito)

- Cambios de animaciones, motion o transiciones no especificados aqui.
- Cambios de layout o posicionamiento de widgets.
- Temas personalizados o seleccion de color primario por el usuario.
- Rebranding de export share (F16) para seguir el tema del SO — fuera de alcance; se mantiene paleta fija de marca en el asset exportado.
- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.

## Referencias

- Ver `_global/04-design-system.md` seccion "Theme tokens" para los tokens base (light) y la nota "F27 agrega variantes dark".
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura (Riverpod, Drift).
- Ver `_global/05-data-model.md` para el modelo de datos (`app_preferences`).
