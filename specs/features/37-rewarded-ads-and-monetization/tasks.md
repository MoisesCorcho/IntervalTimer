# Tasks: Publicidad y Anuncios Bonificados (Rewarded Ads & AdMob)

**ID:** F37 &nbsp;|&nbsp; **Slug:** `37-rewarded-ads-and-monetization` &nbsp;|&nbsp; **Fase:** Fase 2 · Monetización y Anuncios

---

## Definition of Done

- [ ] Todos los criterios de aceptación R01 a R10 de `requirements.md` están implementados y verificados.
- [ ] Arquitectura Ports & Adapters completa con `AdService` y `FakeAdService` totalmente funcional en dev y test suite.
- [ ] Implementación guiada por **TDD Estricto**: pruebas unitarias y de aplicación escritas y aprobadas en verde antes de implementar código de infraestructura nativo.
- [ ] Cooldown técnico de 10 minutos para anuncios intersticiales post-entreno en `SessionCompleteScreen` verificado con tests.
- [ ] Supresión absoluta de anuncios durante el entrenamiento activo, pausas o pantallas de bloqueo.
- [ ] Límite diario estricto de 2 videos bonificados cada 24 horas por dispositivo y cooldown de 15 minutos entre anuncios.
- [ ] Política de Cero Pérdida de Datos (Zero Data Loss) verificada:
  - La expiración del pase de rutina preserva la 4ª rutina en base de datos en modo archivada/bloqueada.
  - La expiración del pase de audio conmuta elegantemente al beep estándar sin mutar la rutina ni la DB.
- [ ] Modal contextual reutilizable `BenefitUnlockDialog` integrado de forma consistente en:
  - Creador de rutinas / límite de 3 rutinas (`WorkoutBuilder`).
  - Selector de sonidos deportivos Pro (`SoundService` / F36).
  - Selector de colores de fase (`PhaseColorPickerScreen`).
  - Seguimiento corporal / historial de peso extendido (F15).
- [ ] Opción secundaria de ver video bonificado integrada en el pie de `PaywallModalScreen`.
- [ ] Persistencia atómica de pases temporales en Drift SQLite (`TemporaryPassesTable`) con protección contra manipulación de reloj del dispositivo.
- [ ] Verificación adversarial **RDD (Receipt-Driven Development)** completada mediante subagente ciego sin contexto previo al merge.
- [ ] Cero regresiones en la suite completa de tests automatizados del proyecto (`flutter test`).

---

## Checklist de Implementación

### 1. Persistencia y Datos (Drift SQLite & Anti-Tampering)
- [ ] Crear tabla `TemporaryPassesTable` en `lib/core/database/tables/temporary_passes_table.dart` con columnas `id`, `benefitType`, `grantedAtUtc`, `expiresAtUtc`, `source`. _(cubre R04, R05)_
- [ ] Crear tabla `AdMetadataTable` en `lib/core/database/tables/ad_metadata_table.dart` para registrar marcas de agua UTC (`max_verified_utc`) y timestamp del último intersticial. _(cubre R02, R09)_
- [ ] Incorporar tablas en `AppDatabase` (`lib/core/database/database.dart`) y generar migración incremental no destructiva con Drift. _(cubre R04, R09)_
- [ ] Implementar `TemporaryPassRepository` con métodos atómicos:
  - [ ] `grantPass(RewardedBenefit benefit, Duration duration)`.
  - [ ] `watchActivePasses()`.
  - [ ] `hasActivePass(RewardedBenefit benefit)`.
  - [ ] `purgeExpiredPasses()`.
  - [ ] `recordMaxTimestamp(DateTime utc)` y detección de inconsistencias de reloj. _(cubre R04, R05, R09)_
- [ ] **TDD:** Escribir pruebas unitarias en `test/features/monetization/data/temporary_pass_repository_test.dart` verificando inserción, filtrado de pases expirados y detección de salto hacia el pasado en el reloj. _(cubre R04, R05, R09, R10)_

### 2. Dominio y Puerto de Anuncios (Ports & Adapters)
- [ ] Crear enum inmutable `RewardedBenefit` con sus duraciones por defecto (rutina 24h, audio 12h, colores 24h, peso 24h, ad-free 24h). _(cubre R05)_
- [ ] Crear entidad inmutable `TemporaryPass` con métodos de evaluación `isExpired()` y `remainingTime()`. _(cubre R05, R07)_
- [ ] Definir Value Objects `AdRewardResult` y `AdRewardStatus`. _(cubre R04, R08)_
- [ ] Definir interfaz abstracta `AdService` en `lib/features/monetization/domain/ad_service.dart`. _(cubre R01, R02, R03, R10)_
- [ ] Implementar adaptador `FakeAdService` en `lib/features/monetization/infrastructure/fake_ad_service.dart` soportando simulación de visualización completa, cierre prematuro, no-fill y latencia artificial. _(cubre R08, R10)_
- [ ] **TDD:** Escribir pruebas unitarias en `test/features/monetization/domain/temporary_pass_test.dart` y `test/features/monetization/infrastructure/fake_ad_service_test.dart`. _(cubre R05, R08, R10)_

### 3. Capa de Aplicación y Estado (Riverpod & Políticas de Negocio)
- [ ] Crear proveedor `adServiceProvider` inyectando `FakeAdService` por defecto para tests y desarrollo. _(cubre R10)_
- [ ] Implementar `activeTemporaryPassesProvider` consumiendo `TemporaryPassRepository.watchActivePasses()`. _(cubre R04, R05)_
- [ ] Implementar `isBenefitUnlockedProvider.family<bool, RewardedBenefit>` evaluando jerarquía: `isProUserProvider == true` OR pase activo no vencido. _(cubre R02, R05, R07)_
- [ ] Implementar controlador `DailyRewardedAdTracker`:
  - [ ] Registro de visualizaciones en las últimas 24 horas.
  - [ ] Validación de límite máximo de 2 videos por ciclo de 24h (`canWatchRewardedAdProvider`).
  - [ ] Enfriamiento mínimo obligatorio de 15 minutos entre videos. _(cubre R06)_
- [ ] Integrar con `canCreateWorkoutProvider` (F32/F06) para admitir 4ª rutina si `isBenefitUnlocked(extraWorkoutSlot)`. _(cubre R05, R07)_
- [ ] Integrar con `SoundService` (F36) para fallback transparente al beep estándar cuando `isBenefitUnlocked(proAudioPass) == false`. _(cubre R05, R07)_
- [ ] Implementar `MonetizationController` para orquestar la visualización de videos bonificados, acreditación del pase y manejo de errores. _(cubre R03, R04, R08)_
- [ ] **TDD:** Escribir pruebas en `test/features/monetization/application/is_benefit_unlocked_provider_test.dart` y `test/features/monetization/application/daily_rewarded_ad_tracker_test.dart`. _(cubre R02, R05, R06, R07)_

### 4. Capa de Presentación (UI Reutilizable & Flujos de Usuario)
- [ ] Crear widget modal reutilizable `BenefitUnlockDialog` en `lib/features/monetization/presentation/widgets/benefit_unlock_dialog.dart`:
  - [ ] Cabecera con título del beneficio y duración del desbloqueo.
  - [ ] Botón primario de compra Pro (navega a `PaywallModalScreen`).
  - [ ] Botón secundario con icono de play *"Ver video (30s) para desbloquear"*.
  - [ ] Estado deshabilitado reactivo cuando no hay internet o se alcanzó el límite diario (2/2). _(cubre R03, R06, R08)_
- [ ] Actualizar `PaywallModalScreen` (F06) para incluir en el pie una sección secundaria discreta: *"¿Sin tarjeta? Mirá un video bonificado para probar por 24h"*. _(cubre R03)_
- [ ] Integrar compuerta en `SessionCompleteScreen`:
  - [ ] Al presionar "Listo", evaluar si corresponde mostrar intersticial con cooldown de 10 min.
  - [ ] Omitir si `adFreePass` está activo o el usuario es Pro. _(cubre R01, R02)_
- [ ] Integrar compuertas de visualización en selectores:
  - [ ] Al pulsar 4ª rutina bloqueada en lista de rutinas. _(cubre R05, R07)_
  - [ ] Al seleccionar clips de audio Pro en `SoundPicker`. _(cubre R05, R07)_
  - [ ] Al seleccionar colores de fase personalizados. _(cubre R05)_
  - [ ] Al consultar histórico de peso extendido en F15. _(cubre R05)_
- [ ] **TDD:** Escribir pruebas de widget en `test/features/monetization/presentation/benefit_unlock_dialog_test.dart` validando renderizado, interacción y accesibilidad. _(cubre R03, R06, R08)_

### 5. Adaptador de Producción AdMob (`google_mobile_ads`)
- [ ] Añadir dependencia `google_mobile_ads` en `pubspec.yaml`. _(cubre NFR02)_
- [ ] Configurar identificadores de aplicación de prueba en `android/app/src/main/AndroidManifest.xml` y `ios/Runner/Info.plist`. _(cubre NFR03)_
- [ ] Implementar `AdMobAdService` en `lib/features/monetization/infrastructure/admob_ad_service.dart`:
  - [ ] Carga asíncrona de `RewardedAd` y `InterstitialAd` con Ad Unit IDs oficiales de test de Google.
  - [ ] Gestión estricta de callbacks nativos (`onUserEarnedReward`, `onAdFailedToLoad`, `onAdDismissedFullScreenContent`).
  - [ ] Precarga automática en segundo plano (ad preloading) post-consumo. _(cubre R01, R04, R08, NFR01, NFR02)_
- [ ] Inyección condicional de `AdMobAdService` para entornos release / flavors de producción. _(cubre NFR02, R10)_

### 6. Protocolo RDD y Verificación de Calidad
- [ ] Ejecutar la suite completa de tests de la aplicación (`flutter test`) asegurando cero regresiones y 100% de tests en verde. _(cubre NFR04)_
- [ ] Orquestar subagente ciego RDD adversarial (`invoke_subagent`) pasando el diff congelado de la rama `feature/37-rewarded-ads-and-monetization`. _(cubre D9, NFR04)_
- [ ] Validar que el veredicto RDD confirme ausencia de parches, cumplimiento estricto de Clean Architecture y respeto de la política de Cero Pérdida de Datos.
- [ ] Marcar checkboxes en este archivo al completar cada fase.
