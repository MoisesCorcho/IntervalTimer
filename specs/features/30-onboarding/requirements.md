# Requirements: Onboarding

> Estado: No iniciada (specs SDD corregidas)

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

---

## Resumen

Experiencia de bienvenida e inducción premium e interactiva para nuevos usuarios. Diseñada con los más altos estándares visuales y de interacción del Design System (micro-animaciones vectoriales, indicadores fluidos y retroalimentación háptica), comunica en 3 pantallas de alto impacto el valor central de la aplicación (precisión del temporizador, inmersión auditiva sin mirar la pantalla y registro de hábitos), concluyendo con la activación inmediata del atleta en el catálogo de rutinas preestablecidas.

---

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- **F01 - Interval Timer Core:** Motor central y estados de ejecución (`idle`, `running`, `paused`, `completed`).
- **F35 - Navegación de Secciones, Preparación y Ajustes:** Shell de preferencias y `PreferencesRepository`.

## Dependencias blandas e integraciones

- **F03 - Sesiones Preestablecidas con Animación/Video:** Destino post-onboarding (`/presets`) para ejecutar la primera sesión sin fricción ni pantallas vacías.

## Postrequisitos (features que dependen de esta)

- Ninguno registrado formalmente (punto de entrada inicial de la aplicación).

---

## Decisiones de Producto y Arquitectura

| ID | Tema | Decisión adoptada | Justificación técnica y de negocio |
|---|---|---|---|
| **D1** | Alcance y Desacoplamiento | **Onboarding de 3 pantallas enfocado 100% en la activación atlética.** Desacoplado de F06. | Evita el acoplamiento prematuro con una capa de compras que aún no existe en código. Cuando se implemente F06, la monetización se integrará en sus compuertas contextuales correspondientes sin alterar el flujo fundacional. |
| **D2** | Estructura de Pantallas | **Exactamente 3 pantallas** en un `PageView` interactivo. | Pantalla 1: Precisión & Timer Core (CountdownRing interactivo y creador de ejercicios); Pantalla 2: Inmersión Sonora & Enfoque (Voz TTS, SFX deportivos y Music Ducking con Spotify); Pantalla 3: Hábito & Victoria (Calendario, analítica de calorías, peso y medallas de logros). |
| **D3** | Acción de Omisión (Skip) | Botón "Saltar" accesible y sutil en el encabezado superior derecho en **todas las pantallas**. | Brinda control absoluto a atletas avanzados o usuarios recurrentes que reinstalan la app, permitiendo ir a entrenar con un solo toque. |
| **D4** | Destino de Aterrizaje | Redirección directa a `/presets` (Catálogo de Rutinas). | Elimina la parálisis por elección. Guiar al usuario a rutinas listas (Tabata, HIIT, Boxeo) optimiza el Time-to-Value (TTV) a menos de 10 segundos desde la apertura. |
| **D5** | Calidad Visual y Acabado Premium | **Widgets dinámicos vivos del Design System.** Cero imágenes estáticas pesadas (PNG/JPEG). | Garantiza nitidez vectorial 4K en cualquier densidad de pantalla, coherencia visual con temas Claro/Oscuro y rendimiento de 60/120 FPS sin agrandar el peso de descarga de la app. |
| **D6** | Micro-interacciones y Háptica | Transición de página suave (`Curves.easeOutCubic`) y feedback táctil ligero (`selectionClick`). | Provee una sensación táctil moderna, atlética y de calidad artesanal en cada deslizamiento y toque de botón. |
| **D7** | Cierre Inesperado | El flag `has_seen_onboarding` **solo se persiste ante finalización explícita o Skip**. | Si la aplicación es terminada abruptamente en segundo plano a mitad del flujo, el usuario volverá a ver la inducción en la siguiente sesión para no perder contexto. |

---

## User Stories

1. **Como** nuevo usuario, **quiero** experimentar una inducción interactiva y visualmente atractiva de las funciones de la aplicación, **para que** entienda en pocos segundos cómo el temporizador optimiza mis entrenamientos sin tener que mirar la pantalla.
2. **Como** usuario con experiencia previa en la app, **quiero** tener la opción de omitir el recorrido de bienvenida en cualquier momento, **para que** pueda comenzar a entrenar de inmediato sin perder tiempo.
3. **Como** atleta que completa la bienvenida, **quiero** ser dirigido automáticamente a una selección de rutinas listas para usar, **para que** mi primera sesión de entrenamiento ocurra sin fricción.

---

## Criterios de Aceptación (formato EARS)

### Happy Path — Flujo de Bienvenida e Inducción Premium

#### R1 — Detección de primer inicio y redirección
DONDE el usuario inicia la aplicación,  
CUANDO el flag persistente `has_seen_onboarding` es `false`,  
EL SISTEMA DEBE redirigir la navegación inicial a la ruta `/onboarding` antes de renderizar la pantalla principal.

#### R2 — Navegación fluida y paginación
DONDE el usuario se encuentra en `/onboarding`,  
CUANDO desliza horizontalmente o pulsa el botón de avance primario,  
EL SISTEMA DEBE transicionar suavemente entre las 3 pantallas mediante una animación desacelerada (`easeOutCubic`) de máximo 350ms y emitir una micro-vibración háptica de selección.

#### R3 — Indicador de progreso dinámico (Píldora expandible)
DONDE el usuario navega entre las diapositivas de `/onboarding`,  
EL SISTEMA DEBE mostrar un indicador de 3 elementos en la parte inferior, donde la página activa se expanda suavemente en forma de píldora con el color de acento principal (`AppTheme.primaryColor`).

#### R4 — Botón de salto rápido (Skip)
DONDE el usuario se encuentra en cualquiera de las pantallas de `/onboarding`,  
CUANDO pulsa el botón "Saltar" en el encabezado superior,  
EL SISTEMA DEBE persistir `has_seen_onboarding = true` y navegar inmediatamente al catálogo `/presets`.

#### R5 — Contenido y Gráfica de Pantalla 1 (Precisión & Timer Core)
DONDE el usuario visualiza la diapositiva 1 de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Entrená con precisión absoluta", la descripción del temporizador por intervalos y descansos estructurados, y una versión miniatura animada del `CountdownRing` con arcos de fase en alto contraste.

#### R6 — Contenido y Gráfica de Pantalla 2 (Inmersión Sonora & Enfoque)
DONDE el usuario visualiza la diapositiva 2 de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Olvidate de mirar la pantalla", la explicación de locución por voz (TTS), efectos de sonido deportivos y atenuación inteligente de música de fondo (Music Ducking), junto a un ecualizador de ondas de audio animado.

#### R7 — Contenido y Gráfica de Pantalla 3 (Hábito, Progreso & Logros)
DONDE el usuario visualiza la diapositiva 3 de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Constancia que se transforma en logros", la descripción del calendario, cálculo calórico, medallas de logros y registro corporal, acompañado de una tarjeta visual destacando una medalla dorada y chip de racha activa.

#### R8 — Botón de Inicio en Pantalla 3 ("¡Empezar a entrenar!")
DONDE el usuario se encuentra en la diapositiva 3 de `/onboarding`,  
EL SISTEMA DEBE reemplazar el botón de avance genérico por un botón primario prominente con la leyenda "¡Empezar a entrenar!".

#### R9 — Acción de finalización exitosa
DONDE el usuario pulsa "¡Empezar a entrenar!" en la diapositiva 3,  
EL SISTEMA DEBE persistir `has_seen_onboarding = true` en la base de datos local y navegar inmediatamente a `/presets`.

#### R10 — Persistencia atómica en PreferencesRepository
DONDE el usuario completa el onboarding por finalización regular o Skip,  
EL SISTEMA DEBE registrar atómicamente `has_seen_onboarding = 'true'` en la tabla `app_preferences` de Drift SQLite.

---

### Validación, Errores y Casos Borde

#### R11 — No reaparición en aperturas subsiguientes (Idempotencia)
DONDE el usuario inicia la aplicación,  
CUANDO el flag `has_seen_onboarding` es `true`,  
EL SISTEMA NO DEBE mostrar la ruta `/onboarding` y debe presentar directamente la navegación principal de la app (`/`).

#### R12 — Terminación abrupta de la sesión
DONDE el usuario cierra o mata el proceso de la aplicación mientras se encuentra en `/onboarding` sin pulsar Saltar ni "¡Empezar a entrenar!",  
EL SISTEMA DEBE mantener `has_seen_onboarding = false` y presentar nuevamente el flujo de bienvenida en el siguiente arranque.

#### R13 — Adaptabilidad a Modo Claro y Modo Oscuro
DONDE el usuario ejecuta el onboarding en cualquier modo de brillo del sistema o de la app,  
EL SISTEMA DEBE renderizar tipografías, gradientes de fondo y bordes respetando estrictamente los contrastes WCAG AA definidos en `_global/04-design-system.md`.

---

## Fuera de Alcance (Explicito)

- Compras in-app o pantallas de pago dentro del onboarding inicial (pertenece a F06 y compuertas contextuales).
- Pantallas estáticas basadas en imágenes PNG o JPEG pesadas.
- Registro o autenticación obligatoria de usuario en nube (la app es offline-first y privada).

---

## Referencias

- `specs/_global/01-vision-and-principles.md` — Principios de producto: loop central sagrado y sin fricción.
- `specs/_global/02-architecture-and-structure.md` — Arquitectura de capas, proveedores Riverpod y enrutamiento con GoRouter.
- `specs/_global/04-design-system.md` — Tokens de diseño, tipografía atlética, paleta semántica y componentes vivos.
- `specs/_global/05-data-model.md` — Persistencia en Drift SQLite mediante `PreferencesRepository`.
