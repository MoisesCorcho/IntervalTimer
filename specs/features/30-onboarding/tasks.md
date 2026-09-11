# Tasks: Onboarding

**ID:** F30 &nbsp;|&nbsp; **Slug:** `30-onboarding` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

---

## Definition of Done

- [ ] Todos los criterios de aceptación R1 a R13 de `requirements.md` están implementados y verificados.
- [ ] Suite de pruebas unitarias y de widgets ejecutada en verde (`flutter test`).
- [ ] Integración en `PreferencesRepository` usando Drift SQLite sin dependencias volátiles.
- [ ] Redirección en `GoRouter` sin parpadeos visuales ni bucles infinitos.
- [ ] Soft Paywall integrado con la capa Pro sin bloquear la ruta gratuita ante fallos.
- [ ] Cumplimiento estricto del Design System (`_global/04-design-system.md`) con widgets dinámicos y cero assets rasterizados pesados.
- [ ] No se rompen features existentes ni pruebas del proyecto (429+ tests vigentes en verde).

---

## Checklist de Implementación

### 1. Persistencia y Datos (Preferences & Drift)
- [ ] Agregar constantes de clave `hasSeenOnboardingKey` y métodos `hasSeenOnboarding()` / `setHasSeenOnboarding(bool)` en `PreferencesRepository`. _(cubre R1, R10, R11)_
- [ ] Escribir pruebas unitarias en `preferences_repository_test.dart` para verificar lectura por defecto (`false`) y persistencia a `true`. _(cubre R10, R11)_

### 2. Capa de Aplicación y Estado (Riverpod)
- [ ] Crear modelo de dominio `OnboardingSlide` para representar los datos de cada diapositiva de forma inmutable. _(cubre R2, R4, R5, R6, R7)_
- [ ] Implementar `hasSeenOnboardingProvider` para exponer reactivamente el estado de visualización del onboarding. _(cubre R1, R11)_
- [ ] Implementar `OnboardingController` con métodos `completeOnboarding({required bool isSubscribed})` y `skipOnboarding()`. _(cubre R3, R8, R9, R10)_

### 3. Capa de Presentación (UI & Design System)
- [ ] Crear `OnboardingScreen` con estructura Scaffold, header superior y contenedor `PageView`. _(cubre R2)_
- [ ] Implementar `OnboardingSkipButton` en el header visible exclusivamente en pantallas 1, 2 y 3. _(cubre R3)_
- [ ] Implementar `OnboardingPageIndicator` para representar el progreso visual de 4 pasos según tokens del Design System. _(cubre R2)_
- [ ] Desarrollar `OnboardingHeroGraphic` para Pantalla 1 con miniatura viva del `CountdownRing` y descripción del creador de rutinas. _(cubre R4)_
- [ ] Desarrollar `OnboardingHeroGraphic` para Pantalla 2 con visualizador estilizado de ondas de audio, iconos TTS y Music Ducking. _(cubre R5)_
- [ ] Desarrollar `OnboardingHeroGraphic` para Pantalla 3 con tarjeta interactiva de métricas, chip de racha y medalla dorada. _(cubre R6)_
- [ ] Desarrollar `OnboardingPaywallCard` para Pantalla 4 destacando beneficios Pro, botón de prueba gratuita (7 días) y botón "Continuar con versión gratuita". _(cubre R7, R8, R9, R13)_

### 4. Enrutamiento y Ciclo de Vida (GoRouter)
- [ ] Registrar la ruta `/onboarding` fuera del Shell navegable en `lib/app/router.dart`. _(cubre R1)_
- [ ] Implementar guard condicional en `redirect` de `GoRouter` para interceptar usuarios con `hasSeenOnboarding == false`. _(cubre R1, R11)_
- [ ] Conectar la finalización (éxito Pro, continuación Free o Skip) para redirigir directamente al catálogo `/presets`. _(cubre R3, R8, R9)_
- [ ] Asegurar que salidas intermedias o cierre del proceso no marquen el flag como completado. _(cubre R12)_

### 5. Suite de Pruebas Automatizadas
- [ ] **Unit test:** Verificar que `OnboardingController.completeOnboarding()` persista `true` en el repositorio e invalide el provider. _(cubre R10)_
- [ ] **Widget test:** Verificar renderizado correcto de las 4 pantallas al deslizar o pulsar siguiente. _(cubre R2, R4, R5, R6, R7)_
- [ ] **Widget test:** Verificar que el botón "Saltar" en pantalla 1 llame a la persistencia y navegue a `/presets`. _(cubre R3)_
- [ ] **Widget test:** Verificar que en pantalla 4 el botón "Continuar con versión gratuita" navegue a `/presets` sin requerir compras. _(cubre R9)_
- [ ] **Widget test:** Verificar manejo de degradación cuando el servicio de suscripciones no está disponible o falla. _(cubre R13)_
- [ ] **Integration/Router test:** Validar redirección automática a `/onboarding` cuando el flag es `false` y navegación normal a `/` cuando es `true`. _(cubre R1, R11, R12)_

---

## Mapa de Trazabilidad (Criterios EARS → Tareas)

| Criterio | Descripción Breve | Tareas que lo cubren |
|---|---|---|
| **R1** | Detección primer inicio y redirect a `/onboarding` | 1.1, 2.2, 4.1, 4.2, 5.6 |
| **R2** | Navegación horizontal y paginación (4 pantallas) | 2.1, 3.1, 3.3, 5.2 |
| **R3** | Botón Skip en pantallas 1-3 con redirección a `/presets` | 2.3, 3.2, 4.3, 5.3 |
| **R4** | Contenido y gráficos de Pantalla 1 (Timer & Workouts) | 2.1, 3.4, 5.2 |
| **R5** | Contenido y gráficos de Pantalla 2 (Audio & Ducking) | 2.1, 3.5, 5.2 |
| **R6** | Contenido y gráficos de Pantalla 3 (Métricas & Logros) | 2.1, 3.6, 5.2 |
| **R7** | Contenido de Pantalla 4 (Soft Paywall con Free Trial) | 2.1, 3.7, 5.2 |
| **R8** | Conversión Pro exitosa y navegación a `/presets` | 2.3, 3.7, 4.3 |
| **R9** | Continuar con versión gratuita y navegación a `/presets` | 2.3, 3.7, 4.3, 5.4 |
| **R10** | Persistencia atómica de `has_seen_onboarding = true` | 1.1, 1.2, 2.3, 5.1 |
| **R11** | Idempotencia y no reaparición posterior | 1.1, 1.2, 2.2, 4.2, 5.6 |
| **R12** | Cierre abrupto preserva `has_seen_onboarding = false` | 4.4, 5.6 |
| **R13** | Degradación suave ante fallo de conexión en IAP | 3.7, 5.5 |

---

## Notas de Secuenciación

- Feature clasificada en Fase 7 (Calidad y Pulido), pero lista para adelantarse antes del lanzamiento a Google Play Store según checklist de `06-roadmap-and-dependencies.md`.
- No requiere migraciones destructivas de base de datos (`app_preferences` ya es una tabla clave-valor existente en producción).
- No requiere credenciales externas de RevenueCat ni AdMob para su implementación y testeo gracias al desacoplamiento de `PurchaseService`.

