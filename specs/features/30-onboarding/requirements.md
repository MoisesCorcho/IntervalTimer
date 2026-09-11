# Requirements: Onboarding

> Estado: No iniciada (specs SDD corregidas)

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

---

## Resumen

Flujo interactivo de bienvenida y activación para nuevos usuarios. Introduce la propuesta de valor del temporizador (precisión visual, asistencia por voz, atenuación musical y registro de hábitos), ofrece una conversión temprana al nivel Pro mediante un Soft Paywall con prueba gratuita (Free Trial), y concluye dirigiendo al atleta directamente al catálogo de rutinas preestablecidas para lograr un Time-to-Value inmediato.

---

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- **F01 - Interval Timer Core:** Motor central y estados de ejecución (`idle`, `running`, `paused`, `completed`).
- **F35 - Navegación de Secciones, Preparación y Ajustes:** Shell de preferencias y `PreferencesRepository`.

## Dependencias blandas e integraciones

- **F03 - Sesiones Preestablecidas con Animación/Video:** Destino post-onboarding (`/presets`) para ejecutar la primera sesión sin fricción.
- **F06 - Capa Pro / Compras In-App:** Integración de la pantalla de Soft Paywall en la última diapositiva (`PaywallCard` / `PurchaseService`).

## Postrequisitos (features que dependen de esta)

- Ninguno registrado formalmente (punto de entrada inicial de la aplicación).

---

## Decisiones de Producto y Arquitectura

| ID | Tema | Decisión adoptada | Justificación técnica y de negocio |
|---|---|---|---|
| **D1** | Modelo Freemium en Onboarding | **Soft Paywall en Pantalla 4.** Nunca Hard Paywall. | Conforme a `ANALISIS_MONETIZACION_FREEMIUM_F06.md`, el bucle central de entrenamiento es sagrado y gratuito. Un paywall bloqueante destruye la retención; un soft paywall educa y ofrece 7 días de prueba gratis permitiendo continuar sin pagar. |
| **D2** | Estructura de Pantallas | **Exactamente 4 pantallas** en un `PageView` interactivo. | Pantalla 1: Core Timer & Workout Builder; Pantalla 2: Experiencia Sensorial (Voz, SFX, Music Ducking); Pantalla 3: Consistencia, Métricas y Logros; Pantalla 4: Desbloqueo Pro (Soft Paywall con Free Trial). |
| **D3** | Acción de Omisión (Skip) | Botón "Saltar" visible en el encabezado de las **pantallas 1, 2 y 3**. | Atletas experimentados o usuarios reinstalando deben poder omitir la introducción sin fricción. En la pantalla 4, el salto se convierte en el botón secundario "Continuar con versión gratuita". |
| **D4** | Destino de Aterrizaje | Redirección a `/presets` (Catálogo de Rutinas). | Aterrizar en una pantalla vacía genera parálisis por elección. Guiar al usuario a rutinas listas (Tabata, HIIT) optimiza la tasa de activación del primer entrenamiento. |
| **D5** | Cierre Inesperado | El flag `has_seen_onboarding` **solo se persiste al completar o pulsar Saltar/Continuar**. | Si la app es terminada abruptamente por el SO en la diapositiva 1 o 2, el usuario aún no completó la inducción y el flujo se presenta nuevamente en el siguiente arranque. |
| **D6** | Recursos Visuales | **Widgets vectoriales dinámicos del Design System.** Cero imágenes PNG/JPEG pesadas. | Garantiza soporte impecable para Modo Claro/Oscuro, nitidez vectorial en cualquier densidad de pantalla y reducción drástica del tamaño del instalador (`.apk` / `.aab`). |

---

## User Stories

1. **Como** nuevo usuario, **quiero** recorrer una inducción rápida y visual de las principales capacidades de la app, **para que** comprenda cómo el temporizador optimiza mi entrenamiento sin necesidad de mirar la pantalla.
2. **Como** usuario que ya conoce la aplicación, **quiero** tener la opción de saltar el recorrido inicial en cualquier momento, **para que** pueda comenzar a entrenar de inmediato sin perder tiempo.
3. **Como** atleta evaluando la aplicación, **quiero** conocer las ventajas del nivel Pro y tener la posibilidad de activar una prueba gratuita de 7 días o continuar con la versión gratuita, **para que** decida cómo utilizar la app de forma transparente y sin presiones.
4. **Como** usuario que completó o saltó la bienvenida, **quiero** ser dirigido a un catálogo de entrenamientos listos para usar, **para que** mi primer contacto operativo con el temporizador sea inmediato.

---

## Criterios de Aceptación (formato EARS)

### Happy Path — Flujo de Bienvenida y Activación

#### R1 — Detección de primer inicio y redirección
DONDE el usuario inicia la aplicación,  
CUANDO el flag persistente `has_seen_onboarding` es `false`,  
EL SISTEMA DEBE redirigir la navegación inicial a la ruta `/onboarding` antes de mostrar la pantalla principal.

#### R2 — Navegación secuencial y paginación
DONDE el usuario se encuentra en `/onboarding`,  
CUANDO desliza horizontalmente o pulsa el botón de avance primario,  
EL SISTEMA DEBE transicionar entre las 4 diapositivas actualizando el indicador visual de página correspondiente.

#### R3 — Botón de salto rápido (Skip)
DONDE el usuario se encuentra en las pantallas 1, 2 o 3 de `/onboarding`,  
CUANDO pulsa el botón "Saltar" del encabezado superior,  
EL SISTEMA DEBE persistir `has_seen_onboarding = true` y redirigir inmediatamente a `/presets`.

#### R4 — Contenido de Pantalla 1 (Core Timer & Builder)
DONDE el usuario visualiza la primera diapositiva de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Entrená con precisión absoluta", el resumen de entrenamientos estructurados y descansos exactos, y una representación gráfica animada del `CountdownRing`.

#### R5 — Contenido de Pantalla 2 (Audio & Cero Distracciones)
DONDE el usuario visualiza la segunda diapositiva de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Olvidate de mirar la pantalla", explicando la locución por voz (TTS), efectos de sonido deportivos (gong/campana) y la atenuación inteligente de música externa (Music Ducking).

#### R6 — Contenido de Pantalla 3 (Constancia y Métricas)
DONDE el usuario visualiza la tercera diapositiva de `/onboarding`,  
EL SISTEMA DEBE presentar el título "Constancia que se transforma en logros", detallando el calendario de sesiones, rachas, cálculo de calorías, medallas desbloqueables y registro de peso corporal.

#### R7 — Contenido de Pantalla 4 (Soft Paywall Pro)
DONDE el usuario visualiza la cuarta diapositiva de `/onboarding`,  
EL SISTEMA DEBE presentar la propuesta de valor Pro (rutinas ilimitadas, cero anuncios, pantalla de bloqueo y personalización total), el botón de acción principal para iniciar la prueba gratuita de 7 días y el botón secundario "Continuar con versión gratuita".

#### R8 — Conversión Pro desde Onboarding
DONDE el usuario se encuentra en la pantalla 4 de `/onboarding`,  
CUANDO pulsa el botón para iniciar la prueba gratuita y la transacción resulta exitosa,  
EL SISTEMA DEBE activar el estado Pro, persistir `has_seen_onboarding = true` y navegar a `/presets`.

#### R9 — Continuar en modo gratuito
DONDE el usuario se encuentra en la pantalla 4 de `/onboarding`,  
CUANDO pulsa "Continuar con versión gratuita",  
EL SISTEMA DEBE persistir `has_seen_onboarding = true` manteniendo el estado Free y navegar a `/presets`.

#### R10 — Persistencia atómica de finalización
DONDE el usuario completa el onboarding mediante Skip, suscripción o continuación gratuita,  
EL SISTEMA DEBE almacenar atómicamente `has_seen_onboarding = true` en `PreferencesRepository` mediante la base de datos local SQLite (Drift).

---

### Validación, Errores y Casos Borde

#### R11 — No reaparición en aperturas subsiguientes
DONDE el usuario inicia la aplicación,  
CUANDO el flag `has_seen_onboarding` es `true`,  
EL SISTEMA NO DEBE mostrar la ruta `/onboarding` y debe presentar directamente el flujo normal de navegación (`/`).

#### R12 — Terminación abrupta de la sesión
DONDE el usuario cierra o mata el proceso de la aplicación mientras se encuentra en `/onboarding` sin haber pulsado Saltar, Continuar ni Comprar,  
EL SISTEMA DEBE mantener `has_seen_onboarding = false` y presentar nuevamente el flujo de onboarding en la siguiente apertura.

#### R13 — Degradación ante indisponibilidad de compras
DONDE el usuario se encuentra en la pantalla 4 de `/onboarding`,  
CUANDO el servicio de compras integradas (IAP / RevenueCat) experimenta un fallo de conexión o no devuelve ofertas,  
EL SISTEMA DEBE permitir pulsar "Continuar con versión gratuita" sin bloquear al usuario ni generar un estado inestable.

---

## Fuera de Alcance (Explicito)

- Creación o registro obligatorio de cuentas de usuario en servidores externos (la app es offline-first y privada por diseño).
- Hard Paywall obligatorio que bloquee el temporizador si no se introduce un método de pago.
- Descarga de paquetes de imágenes o animaciones pesadas desde internet durante el primer arranque.

---

## Referencias

- `specs/_global/01-vision-and-principles.md` — Principios de producto: loop central sagrado y sin fricción.
- `specs/_global/02-architecture-and-structure.md` — Arquitectura de capas, proveedores Riverpod y enrutamiento con GoRouter.
- `specs/_global/04-design-system.md` — Tokens de diseño, tipografía, paleta de colores y componentes interactivos.
- `specs/_global/05-data-model.md` — Persistencia de preferencias en Drift SQLite.
- `ANALISIS_MONETIZACION_FREEMIUM_F06.md` — Estrategia de monetización, tiers Pro y soft paywall.
