# Tasks: Capa Pro / Compras In-App (Freemium)

**ID:** F06 &nbsp;|&nbsp; **Slug:** `06-pro-tier-iap` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

---

## Definition of Done

- [x] Todos los criterios de aceptación R1 a R18 de `requirements.md` están implementados y verificados.
- [x] Arquitectura Ports & Adapters completa con `BillingRepository` y `FakeBillingDriver` totalmente funcional en dev.
- [x] Switch de depuración en `SettingsScreen` (debug mode) para alternar Free y Pro instantáneamente en vivo.
- [x] Vista modal de estado de suscripción `ProStatusModalSheet` para usuarios Pro activos sin botones de compra. _(R19)_
- [x] Límite estricto de 3 rutinas en Free aplicado tanto a creación manual como a duplicación de rutinas y clonación de presets.
- [x] Bloqueo de condiciones de carrera mediante mutex/debounce en guardado y duplicación atómica.
- [x] Política de downgrade verificada: rutinas previas preservadas y ejecutables, creación bloqueada mientras count ≥ 3.
- [x] Fallback seguro no destructivo en personalizaciones cosméticas de fases y acentos.
- [x] Componente visual `ProBadge` elegante y uniforme integrado en selectores de colores, audio ducking y notas.
- [x] Modal inmersivo `PaywallModalScreen` con estética del Design System, carrusel de beneficios, planes de precios y restauración.
- [x] Persistencia atómica de `is_pro_user` en Drift SQLite con soporte offline 100% resiliente.
- [x] Suite completa de pruebas unitarias, de aplicación y de widgets ejecutada en verde (`flutter test`).
- [x] Cero regresiones en los 445 tests existentes del proyecto.

---

## Checklist de Implementación

### 1. Persistencia y Datos (Preferences & Drift SQLite)
- [x] Agregar constante `isProUserKey` y métodos `isProUser()`, `setIsProUser(bool)` y `watchIsProUser()` en `PreferencesRepository`. _(cubre R1, R13)_
- [x] Escribir pruebas unitarias en `test/features/pro_tier/data/pro_preferences_test.dart` verificando valor por defecto (`false`), persistencia atómica a `true` y emisión reactiva. _(cubre R1, R13)_

### 2. Dominio y Puerto de Facturación (Ports & Adapters)
- [x] Crear modelos inmutables `ProductPackage`, `PurchaseResult` y enums `BillingPeriod`, `PurchaseStatus`. _(cubre R5, R6, R11)_
- [x] Definir interfaz abstracta `BillingRepository` con métodos `isPro()`, `watchIsPro()`, `getAvailableProducts()`, `purchase()`, `restorePurchases()` y `toggleMockPro()`. _(cubre R1, R5, R6, R7, R14)_
- [x] Implementar `FakeBillingDriver` para desarrollo con catálogo curado (Mensual, Anual con 50% desc. y 7 días trial, Lifetime), simulación de compra exitosa, cancelación y toggle en memoria. _(cubre R5, R6, R11, R12, R14)_
- [x] Escribir pruebas unitarias en `test/features/pro_tier/data/fake_billing_driver_test.dart` validando compras simuladas, cancelaciones y restauración. _(cubre R6, R7, R11, R12, R14)_

### 3. Capa de Aplicación y Estado (Riverpod & Anti-Bypass)
- [x] Implementar `billingRepositoryProvider` inyectando `FakeBillingDriver` por defecto en entornos de desarrollo/test. _(cubre R1, R14)_
- [x] Implementar `isProUserProvider` como `StreamProvider<bool>` consumiendo `watchIsPro()`. _(cubre R1, R6, R7)_
- [x] Implementar `proProductsProvider` para exponer los paquetes disponibles. _(cubre R5, R6)_
- [x] Implementar `canCreateWorkoutProvider` que evalúa `isPro || workoutsCount < 3`. _(cubre R2, R3, R15, R16)_
- [x] Implementar compuerta en `WorkoutsListController.duplicateWorkout()` y `PresetDetailScreen._handleDuplicate()` interceptando si `!canCreate`. _(cubre R15)_
- [x] Implementar mutex `_isMutating` contra double-tap en creación y duplicación. _(cubre R18)_
- [x] Implementar fallback no destructivo en resolución de colores de fase y acento en capa de tema. _(cubre R17)_
- [x] Implementar `PaywallController` para orquestar la selección de plan, compra, feedback de error y persistencia. _(cubre R5, R6, R7, R11, R12)_
- [x] Escribir pruebas unitarias en `test/features/pro_tier/application/paywall_controller_test.dart` validando la máquina de estados del paywall. _(cubre R6, R7, R11, R12)_

### 4. Capa de Presentación Premium (UI & Design System)
- [x] Desarrollar `ProBadge`: chip/insignia reutilizable con estilo ámbar/dorado metálico, ocultable automáticamente para usuarios Pro. _(cubre R4)_
- [x] Desarrollar `PaywallModalScreen`:
  - [x] Encabezado con corona o llama dorada procedural y micro-animación de entrada. _(cubre R5)_
  - [x] Carrusel/lista visual de los 5 beneficios clave con iconos vectoriales. _(cubre R5)_
  - [x] Selector interactivo de tarjetas de planes (Mensual, Anual con etiqueta 'Ahorra 50%', Lifetime). _(cubre R5, R6)_
  - [x] Botón CTA primario prominente con micro-interacción háptica (`mediumImpact`). _(cubre R5, R6)_
  - [x] Enlace accesible a "Restaurar compras" y textos legales de suscripción. _(cubre R5, R7, R12)_
- [x] Integrar compuerta en `MyWorkoutsScreen`: mostrar contador `"X / 3 rutinas gratuitas"` y gatillar `PaywallModalScreen` al intentar crear una 4ta rutina en Free. _(cubre R2, R3)_
- [x] Integrar compuerta en `PresetDetailScreen`: botón duplicar gatilla Paywall si se alcanzó el límite. _(cubre R15)_
- [x] Integrar `ProBadge` en `PhaseColorPickerSheet`/`Screen`, `TimerAudioControlsSheet` (ducking) y notas de `HistoryScreen`. _(cubre R4, R8, R9, R10)_
- [x] Agregar tarjeta de depuración en `SettingsScreen` (solo en debug/profile) con `SwitchListTile` para alternar usuario Free/Pro en vivo. _(cubre R14)_
- [x] Implementar `ProStatusModalSheet` con resumen de beneficios desbloqueados, enlace de gestión en tiendas y blindar `PaywallModalScreen` ante `isPro == true`. _(cubre R19)_

### 5. Suite de Pruebas Automatizadas (TDD, Edge Cases & Regresión)
- [x] **Unit test:** Validar que `canCreateWorkoutProvider` retorne `true` con ≤ 2 rutinas en Free, `false` con 3 rutinas en Free, y siempre `true` si `isPro == true`. _(cubre R2, R3)_
- [x] **Unit test:** Validar que duplicar una rutina existente o un preset falle con compuerta si el usuario Free ya tiene 3 rutinas. _(cubre R15)_
- [x] **Unit test:** Validar preservación de datos en downgrade (usuario con 5 rutinas puede ejecutarlas y editarlas, pero no crear la 6ta). _(cubre R16)_
- [x] **Unit test:** Validar fallback no destructivo de colores Pro cuando el usuario es Free. _(cubre R17)_
- [x] **Unit test:** Validar prevención de double-tap / mutex en duplicación concurrente. _(cubre R18)_
- [x] **Widget test:** Validar que `ProBadge` se renderice cuando `isPro == false` y desaparezca cuando `isPro == true`. _(cubre R4)_
- [x] **Widget test:** Validar renderizado de `PaywallModalScreen`, selección de plan anual por defecto y pulsación de compra con feedback háptico. _(cubre R5, R6)_
- [x] **Widget test:** Validar que un fallo o cancelación de compra en el paywall muestre un snackbar informativo sin alterar el estado del usuario. _(cubre R11)_
- [x] **Widget test:** Validar que el switch de depuración en `SettingsScreen` alterne inmediatamente el estado `isPro` y reactive los componentes de la interfaz. _(cubre R14)_
- [x] **Widget test:** Validar que pulsar la tarjeta Pro en `SettingsScreen` cuando `isPro == true` abra `ProStatusModalSheet` y no ofrezca opciones ni botones de pago. _(cubre R19)_
- [x] **Regression test:** Ejecutar suite completa (`flutter test`) asegurando 0 fallos en los 445 tests previos.

---

## Mapa de Trazabilidad (Criterios EARS → Tareas)

| Criterio | Descripción Breve | Tareas que lo cubren |
|---|---|---|
| **R1** | Persistencia atómica y detección de `isPro` | 1.1, 1.2, 2.2, 3.1, 3.2 |
| **R2** | Límite de 3 rutinas en capa Free y contador visible | 3.4, 4.3, 5.1 |
| **R3** | Bloqueo y apertura de paywall al crear 4ta rutina | 3.4, 4.3, 5.1 |
| **R4** | Señalización visual con `ProBadge` | 4.1, 4.5, 5.6 |
| **R5** | Despliegue de `PaywallModalScreen` con beneficios y planes | 2.1, 3.3, 4.2, 5.7 |
| **R6** | Desbloqueo reactivo inmediato tras compra | 2.1, 2.2, 3.2, 3.8, 4.2, 5.7 |
| **R7** | Restauración de compras previas con éxito | 2.2, 3.2, 3.8, 4.2 |
| **R8** | Bloqueo de personalización estética Pro | 4.5 |
| **R9** | Bloqueo de audio avanzado (ducking y clips SFX) | 4.5 |
| **R10** | Bloqueo de notas en calendario en Free | 4.5 |
| **R11** | Manejo de compra cancelada o fallida con mensaje | 2.1, 2.3, 3.8, 5.8 |
| **R12** | Restauración sin compras activas | 2.3, 3.8, 4.2 |
| **R13** | Funcionamiento y resiliencia offline | 1.1, 1.2 |
| **R14** | Switch de depuración (Fake Driver) en Ajustes | 2.2, 2.3, 3.1, 4.6, 5.9 |
| **R15** | Compuerta en Duplicación de Rutinas y Presets | 3.5, 4.4, 5.2 |
| **R16** | Política de Downgrade y Preservación de Datos | 3.4, 5.3 |
| **R17** | Fallback Seguro de Personalizaciones Cosméticas | 3.7, 5.4 |
| **R18** | Prevención de Condiciones de Carrera (Double-Tap) | 3.6, 5.5 |
| **R19** | Estado Pro Activo y Gestión de Suscripción | 4.7, 5.10 |

---

## Notas de Secuenciación

- No introduce dependencias de librerías nativas invasivas en esta etapa (`FakeBillingDriver` funciona 100% en Dart puro sobre `PreferencesRepository`).
- La integración con `in_app_purchase` o RevenueCat se agregará en una fase posterior como un adaptador alternativo al `FakeBillingDriver` sin alterar la UI ni el dominio.
- Listo para comenzar inmediatamente con la Fase 1 bajo TDD.

