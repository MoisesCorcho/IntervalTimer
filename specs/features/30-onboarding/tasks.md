# Tasks: Onboarding

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

---

## Definition of Done

- [x] Todos los criterios de aceptación R1 a R13 de `requirements.md` están implementados y verificados.
- [x] Experiencia visual premium: micro-interacciones fluidas (`Curves.easeOutCubic`), indicador de píldora expandible y feedback háptico.
- [x] Cero imágenes rasterizadas pesadas (PNG/JPEG); 100% componentes vectoriales vivos del Design System.
- [x] Integración en `PreferencesRepository` usando Drift SQLite con persistencia atómica.
- [x] Redirección en `GoRouter` sin parpadeos visuales ni bucles de redirección.
- [x] Totalmente desacoplado de pasarelas de pago y servicios externos de compras (F06).
- [x] Suite de pruebas unitarias, de widgets y de enrutamiento ejecutada en verde (`flutter test`).
- [x] No se rompen features existentes ni pruebas del proyecto (429+ tests vigentes en verde).

---

## Checklist de Implementación

### 1. Persistencia y Datos (Preferences & Drift)
- [x] Agregar constante `hasSeenOnboardingKey` y métodos `hasSeenOnboarding()` / `setHasSeenOnboarding(bool)` en `PreferencesRepository`. _(cubre R1, R10, R11)_
- [x] Escribir pruebas unitarias en `preferences_repository_test.dart` validando lectura por defecto (`false`) y persistencia a `true`. _(cubre R10, R11)_

### 2. Capa de Aplicación y Estado (Riverpod)
- [x] Crear modelo inmutable `OnboardingSlideData` con título, descripción, etiquetas y tipo de diapositiva. _(cubre R2, R5, R6, R7)_
- [x] Implementar `hasSeenOnboardingProvider` para exponer reactivamente el estado de visualización. _(cubre R1, R11)_
- [x] Implementar `onboardingPageProvider` para rastrear la diapositiva activa en el `PageView`. _(cubre R2, R3)_
- [x] Implementar `OnboardingController` con métodos `completeOnboarding()` y `skipOnboarding()`. _(cubre R4, R9, R10)_

### 3. Capa de Presentación Premium (UI & Micro-interacciones)
- [x] Crear `OnboardingScreen` con fondo de gradiente sutil y seguro para contrastes WCAG AA en Modo Claro y Oscuro. _(cubre R13)_
- [x] Implementar `OnboardingSkipButton` sutil en el header superior, visible en todas las diapositivas. _(cubre R4)_
- [x] Implementar `OnboardingPageIndicator` con efecto de píldora activa expandible (28dp con `AppTheme.primaryColor`) y círculos secundarios inactivos. _(cubre R3)_
- [x] Desarrollar `TimerShowcaseSlide` (Slide 1): miniatura viva animada de `CountdownRing` con arcos de trabajo/descanso y pulso rítmico. _(cubre R5)_
- [x] Desarrollar `AudioShowcaseSlide` (Slide 2): visualizador estilizado de ondas de audio senoidales y badges flotantes translúcidos. _(cubre R6)_
- [x] Desarrollar `ProgressShowcaseSlide` (Slide 3): tarjeta de logros con medalla dorada, chip de racha activa y gráfico calórico. _(cubre R7)_
- [x] Implementar botón de acción inferior: botón "Siguiente" en slides 1 y 2, y botón primario prominente "¡Empezar a entrenar!" en slide 3. _(cubre R2, R8, R9)_
- [x] Integrar micro-vibración háptica (`selectionClick` en cambios de página y `mediumImpact` en inicio de entrenamiento). _(cubre R2, R9)_

### 4. Enrutamiento y Ciclo de Vida (GoRouter)
- [x] Registrar la ruta modal `/onboarding` fuera del Shell navegable en `lib/app/router.dart`. _(cubre R1)_
- [x] Implementar guard en `redirect` de `GoRouter` para interceptar usuarios con `hasSeenOnboarding == false`. _(cubre R1, R11)_
- [x] Conectar la finalización (Skip o botón de inicio) para navegar inmediatamente al catálogo `/presets`. _(cubre R4, R9)_
- [x] Verificar que cierres forzados del proceso durante la navegación mantengan `has_seen_onboarding = false`. _(cubre R12)_

### 5. Suite de Pruebas Automatizadas
- [x] **Unit test:** Verificar que `OnboardingController.completeOnboarding()` persista `true` en SQLite e invalide reactivamente el provider. _(cubre R10)_
- [x] **Widget test:** Verificar renderizado, swipe horizontal y actualización del indicador de píldora entre las 3 diapositivas. _(cubre R2, R3, R5, R6, R7)_
- [x] **Widget test:** Verificar que el botón "Saltar" en cualquier diapositiva persista el flag y redirija a `/presets`. _(cubre R4)_
- [x] **Widget test:** Verificar que el botón "¡Empezar a entrenar!" aparezca exclusivamente en la diapositiva 3 y complete el flujo hacia `/presets`. _(cubre R8, R9)_
- [x] **Widget test:** Validar legibilidad tipográfica y contrastes semánticos en Modo Claro y Modo Oscuro. _(cubre R13)_
- [x] **Integration/Router test:** Validar redirección automática a `/onboarding` en primer inicio y navegación normal a `/` en aperturas subsiguientes. _(cubre R1, R11, R12)_

---

## Mapa de Trazabilidad (Criterios EARS → Tareas)

| Criterio | Descripción Breve | Tareas que lo cubren |
|---|---|---|
| **R1** | Detección primer inicio y redirect a `/onboarding` | 1.1, 2.2, 4.1, 4.2, 5.6 |
| **R2** | Navegación horizontal fluida y háptica (3 diapositivas) | 2.1, 2.3, 3.7, 3.8, 5.2 |
| **R3** | Indicador de píldora dinámica expandible | 2.3, 3.3, 5.2 |
| **R4** | Botón Skip en todas las pantallas hacia `/presets` | 2.4, 3.2, 4.3, 5.3 |
| **R5** | Contenido y gráfica de Slide 1 (Timer & Workouts) | 2.1, 3.4, 5.2 |
| **R6** | Contenido y gráfica de Slide 2 (Audio & Ducking) | 2.1, 3.5, 5.2 |
| **R7** | Contenido y gráfica de Slide 3 (Métricas & Logros) | 2.1, 3.6, 5.2 |
| **R8** | Botón prominente "¡Empezar a entrenar!" en Slide 3 | 3.7, 5.4 |
| **R9** | Finalización exitosa y navegación a `/presets` | 2.4, 3.7, 3.8, 4.3, 5.4 |
| **R10** | Persistencia atómica de `has_seen_onboarding = true` | 1.1, 1.2, 2.4, 5.1 |
| **R11** | Idempotencia y no reaparición en arranques posteriores | 1.1, 1.2, 2.2, 4.2, 5.6 |
| **R12** | Cierre abrupto preserva `has_seen_onboarding = false` | 4.4, 5.6 |
| **R13** | Adaptabilidad y accesibilidad en Modo Claro y Oscuro | 3.1, 5.5 |

---

## Notas de Secuenciación

- Feature clasificada en Fase 7 (Calidad y Pulido), pero lista para adelantarse antes del lanzamiento oficial en tiendas según el checklist de `06-roadmap-and-dependencies.md`.
- No introduce tablas nuevas ni migraciones destructivas en Drift SQLite (`app_preferences` ya existe y está probada en producción).
- No tiene dependencias bloqueantes con F06 ni requiere librerías externas de pago.


