# Plan de Cierre F06 (Pro Tier IAP) y Propuestas Estratégicas de Naming

> **Proyecto:** Interval Timer (Flutter)  
> **Fecha:** 14 de Septiembre, 2026  
> **Estado:** Documento de Trabajo y Arquitectura de Producto  
> **Propósito:** Consolidar el plan para llevar F06 al 100% de completitud y definir las propuestas de identidad de marca (Naming) para publicación en Google Play y App Store.

---

# PARTE 1: Plan de Cierre de Feature F06 al 100%

## 1. Estado Actual de la Feature
- **Arquitectura:** Patrón *Ports & Adapters* implementado limpiamente (`BillingRepository` + `FakeBillingDriver`).
- **Estado de Dominio:** Exposición reactiva con `isProUserProvider`, compuerta de creación `canCreateWorkoutProvider` (límite de 3 rutinas en Free), compuerta en duplicación/clonación y mutex anti-carreras (`_isMutating`).
- **Presentación:** `PaywallModalScreen` inmersivo con selección de planes, `ProStatusModalSheet` defensivo para usuarios Pro activos, `ProBadge` metálico en chips bloqueados y switch de desarrollo en `SettingsScreen`.
- **Suite de Pruebas:** 506/506 tests pasando en verde en todo el proyecto.

---

## 2. Requerimientos de Producción: Adaptador Real e Inyección Condicional [Implementado ✅]

| Componente | Estado | Descripción Técnica |
|---|---|---|
| **Adaptador de Producción Real** | **Implementado ✅** | `RevenueCatBillingDriver` (respaldado en `PurchasesDelegate` y `purchases_flutter`) implementa el puerto `BillingRepository`. Soporta validación de recibos server-side, compras de suscripciones/lifetime, restauración y resiliencia offline respaldada en Drift SQLite. |
| **Inyección Condicional de Driver** | **Implementado ✅** | `billingRepositoryProvider` en `pro_providers.dart` inyecta automáticamente `FakeBillingDriver` en modo dev/test/profile o cuando las variables de entorno están vacías; e inyecta `RevenueCatBillingDriver` en builds `--release` (o con `FORCE_REVENUECAT=true`) cuando las API Keys están presentes. |

---

### 2.1 Guía Explícita de Configuración al Crear las Cuentas de Tienda

Cuando crees las cuentas en Google Play Console, Apple Developer y RevenueCat, seguí estos pasos exactos para conectar la facturación con el código:

#### 1. Google Play Console (Android)
1. **Crear la aplicación** con el ID de paquete del proyecto.
2. Ir a **Monetizar con Play > Productos > Suscripciones**:
   - Crear suscripción con ID de producto: `repulse_pro_monthly` (Plan base mensual recurrente).
   - Crear suscripción con ID de producto: `repulse_pro_annual` (Plan base anual con fase de prueba gratuita / *Free Trial* de 7 días y oferta equivalente a ~50% de ahorro).
3. Ir a **Monetizar con Play > Productos > Productos integrados**:
   - Crear producto con ID: `repulse_pro_lifetime` (Compra única administrada / Lifetime).
4. Ir a **Configuración para desarrolladores > Acceso a la API > Cuentas de servicio**:
   - Crear una cuenta de servicio en Google Cloud Console vinculada con roles de visualización financiera y administración de pedidos.
   - Generar y descargar la clave privada en formato **JSON**.

#### 2. App Store Connect (iOS / Apple)
1. **Crear la aplicación** con el Bundle ID correspondiente (`interval_timer` / `com.repulse.app`).
2. Ir a **Monetización > Suscripciones**:
   - Crear grupo de suscripción: `"Repulse Pro"`.
   - Suscripción 1: ID de referencia `repulse_pro_monthly`, duración 1 mes.
   - Suscripción 2: ID de referencia `repulse_pro_annual`, duración 1 año con 1 semana de prueba gratuita (*Introductory Offer: Free Trial 7 days*).
3. Ir a **Monetización > Compras dentro de la app**:
   - Crear producto **No consumible (*Non-Consumable*)**: ID `repulse_pro_lifetime`.
4. Ir a **Usuarios y acceso > Integraciones > Claves de compra en la app (StoreKit 2)**:
   - Generar clave de API de compra dentro de la app.
   - Descargar el archivo `.p8` y copiar el **Key ID** y el **Issuer ID**.

#### 3. Panel de RevenueCat (Dashboard)
1. Crear un nuevo proyecto llamado **"Repulse"**.
2. **Conectar las tiendas**:
   - En **Android app**: Subir el archivo JSON de la cuenta de servicio de Google Cloud y el Package Name.
   - En **iOS app**: Subir el archivo `.p8`, Key ID, Issuer ID y Bundle ID.
3. Ir a **Entitlements**:
   - Crear un único Entitlement con identificador exacto: `pro` *(Importante: debe ser exactamente `pro`, ya que está referenciado como `RevenueCatConfig.entitlementId`)*.
4. Ir a **Offerings**:
   - En el Offering predeterminado (`default`):
     - Asociar al package `$rc_monthly` ➔ Producto: `repulse_pro_monthly`.
     - Asociar al package `$rc_annual` ➔ Producto: `repulse_pro_annual`.
     - Asociar al package `$rc_lifetime` ➔ Producto: `repulse_pro_lifetime`.
   - Vincular todos estos productos al Entitlement `pro`.
5. Ir a **Project Settings > API Keys**:
   - Copiar la **Public Android API Key** (empieza con `goog_...`).
   - Copiar la **Public iOS API Key** (empieza con `appl_...`).

#### 4. Variables de Compilación en el Proyecto (`--dart-define`)
El código en [`revenue_cat_config.dart`](lib/features/pro_tier/data/revenue_cat_config.dart) y [`pro_providers.dart`](lib/features/pro_tier/application/pro_providers.dart) lee automáticamente estas claves:

* **Para compilar APK/Bundle de producción (Release con pagos reales):**
  ```bash
  flutter build appbundle --release \
    --dart-define=REVENUECAT_API_KEY_ANDROID=goog_tu_clave_publica_android \
    --dart-define=REVENUECAT_API_KEY_IOS=appl_tu_clave_publica_ios
  ```

* **Para depurar pagos reales en dispositivos físicos (Sandbox / Test Tracks):**
  ```bash
  flutter run \
    --dart-define=FORCE_REVENUECAT=true \
    --dart-define=REVENUECAT_API_KEY_ANDROID=goog_tu_clave_publica_android \
    --dart-define=REVENUECAT_API_KEY_IOS=appl_tu_clave_publica_ios
  ```

* **Para desarrollo diario local y tests automáticos:**
  No se pasa ninguna variable. La aplicación resuelve limpiamente `FakeBillingDriver`, protegiendo la velocidad de desarrollo y los tests locales sin internet ni cuentas.

---

## 3. Requerimientos por Sincronizar y Pulir (Specs SDD vs. Código) [Sincronizado ✅]

Durante la implementación tomamos decisiones de producto correctas que beneficiaron al usuario, y las 3 discrepancias en `specs/features/06-pro-tier-iap/` han sido sincronizadas formalmente con el código fuente:

### 3.1 R9 — Desincronización en Audio Ducking
- **Problema en `requirements.md`:** R9 exige bloquear el switch de *Music Ducking* para usuarios Free.
- **Realidad en Código y Producto:** Se determinó que *Music Ducking* es una funcionalidad de confort auditivo esencial y debe ser **100% gratuita** para todos.
- **Acción requerida:** Corregir R9 en `requirements.md` para que aplique **exclusivamente al catálogo de clips SFX deportivos** (Gong de boxeo, silbato de árbitro, campana de gimnasio), liberando formalmente a Music Ducking.

### 3.2 R10 — Desincronización en Notas de Calendario
- **Problema en `requirements.md`:** R10 exige que las notas de sesión requieran Pro para ser creadas o editadas.
- **Realidad en Código y Producto:** En el commit `95f9e88` y en el análisis estratégico se acordó que las notas post-entreno son **100% libres** para proteger el core loop y la fidelización del atleta.
- **Acción requerida:** Depurar o retirar R10 de `requirements.md` para reflejar la realidad del código fuente.

### 3.3 R5 — Catálogo Real de Beneficios en Paywall
- **Problema en `requirements.md`:** R5 menciona 5 beneficios antiguos (incluyendo notas y ducking).
- **Realidad en Código:** [`PaywallModalScreen`] exhibe los **6 beneficios reales**:
  1. Rutinas ilimitadas (más allá de 3).
  2. Seguimiento corporal completo (historial de peso y medidas).
  3. Cero publicidad intersticial.
  4. Efectos de sonido deportivos de alta fidelidad.
  5. Colores de fase personalizables con mockup interactivo.
  6. Apoyo directo al desarrollo independiente.
- **Acción requerida:** Actualizar la lista en R5 para que coincida exactamente con lo implementado.

---

## 4. Mejoras de UI/UX e i18n por Pulir [Completado ✅]

1. **Localización de Título de Marca:**
   - Archivo: `lib/features/settings/presentation/settings_screen.dart` (línea 319).
   - Tarea: Reemplazar el literal hardcodeado `'Interval Timer Pro'` por `l10n.proTierSectionTitle` (`"Repulse Pro"`) en los archivos ARB (`app_en.arb` y `app_es.arb`). [Completado ✅]
2. **Empatía UX al Bloquear Clonación de Presets:**
   - Archivo: `lib/features/preset_routines/presentation/screens/preset_detail_screen.dart`.
   - Tarea: Agregar feedback háptico (`HapticFeedback.lightImpact()`) al intentar duplicar un preset con el límite alcanzado, antes o al abrir el modal de Paywall.
3. **Micro-interacciones en Selector de Planes:**
   - Archivo: `lib/features/pro_tier/presentation/screens/paywall_modal_screen.dart`.
   - Tarea: Convertir `_PackageCard` en `AnimatedContainer` para suavizar las transiciones de borde y escala al alternar entre Mensual, Anual y Lifetime.

---

# PARTE 2: Propuestas Estratégicas de Naming (Identidad de Marca)

## 1. El Diagnóstico del Mercado: Por qué huir de "Interval Timer"
En Google Play y App Store existen más de 200 aplicaciones con el nombre genérico *"Interval Timer"*, *"Tabata Timer"* o *"HIIT Timer"*.
- **Desventaja del nombre genérico:** Se pierde en los resultados de búsqueda, carece de protección legal/marcaria, no genera retención ni sentido de pertenencia y se percibe como una utilidad básica desechable.
- **La fórmula ASO ganadora en 2026:**
  $$\textbf{Nombre de Marca Único} \quad+\quad \textbf{Palabras Clave de Búsqueda (ASO)}$$
  Ejemplo en tiendas: **Repulse — Interval & HIIT Timer** o **Phasor — Workout Timer**.

---

## 2. Criterios de Selección de Nombre
1. **Brevedad y Sonoridad:** 1 o 2 sílabas, fácil de pronunciar en español e inglés.
2. **Semántica Deportiva:** Debe evocar ritmo, fases, precisión, pulso o rendimiento.
3. **Escalabilidad:** Que permita a futuro expandirse a smartwatches, planes de nutrición o comunidad sin que el nombre quede chico.
4. **Disponibilidad:** No copiado de los competidores directos (*Seconds*, *Hevy*, *Tabata Timer*, *SmartWOD*).

---

## 3. Cuadrante de Propuestas de Naming

### Categoría A: Enfoque "Fases y Precisión" (Estructural y Técnico)
Ideal si querés proyectar seriedad atlética, enfoque en CrossFit, deportes de combate y circuitos estructurados.

1. **PHASOR (o Phasor Timer)**
   - *Etimología:* De *Phase* (Fase). Toda la app gira alrededor del cambio de fases (Preparación, Trabajo, Descanso).
   - *Sensación:* Científico, quirúrgico, moderno.
   - *Fórmula ASO:* `Phasor: HIIT & Interval Timer` / `Phasor: Cronómetro de Intervalos`
2. **SHIFT (o ShiftFit)**
   - *Etimología:* El cambio de marcha o transición de fase ("shift from work to rest").
   - *Sensación:* Ágil, dinámico, minimalista.
   - *Fórmula ASO:* `Shift: Workout Interval Timer`
3. **CIRCA (o Circa Timer)**
   - *Etimología:* De *Circuit* (Circuito) y *Ciclo*.
   - *Sensación:* Elegante, limpio, muy afín al diseño nórdico/oscuro de nuestra interfaz.
   - *Fórmula ASO:* `Circa: Circuit & Tabata Timer`

---

### Categoría B: Enfoque "Ritmo, Pulso y Corazón" (Energético y Biométrico)
Alineado perfectamente con el diseño de nuestro logo (el dial con el pulso cardíaco central) y el módulo de *Body Tracking*.

4. **REPULSE (Re-Pulse)** ⭐ *(Recomendado por Arquitectura de Marca)*
   - *Etimología:* *Re* (Repetición) + *Pulse* (Pulso / Ritmo cardíaco).
   - *Sensación:* Poderoso, memorable, suena a impacto atlético y resiliencia.
   - *Fórmula ASO:* `Repulse: HIIT & Interval Timer`
5. **PULSEFORGE**
   - *Etimología:* Forjar el ritmo cardíaco y la resistencia.
   - *Sensación:* Robusto, enfocado en fuerza, calistenia y acondicionamiento.
   - *Fórmula ASO:* `PulseForge: Workout Timer & WODs`
6. **TEMPOX**
   - *Etimología:* *Tempo* (el compás exacto de cada repetición y descanso) + *X* (entrenamiento extremo).
   - *Sensación:* Tecnológico, directo, muy sonoro.
   - *Fórmula ASO:* `TempoX: Interval Training Timer`

---

### Categoría C: Enfoque "Fuego y Combate" (Intensidad y Resistencia)
Inspirado en la llama procedural del cierre de sesión (`AnimatedFlameHero`) y los clips de campana/gong.

7. **ROUNDSMITHS (o Roundly)**
   - *Etimología:* Los artesanos del round. Enfocado en boxeo, artes marciales y HIIT.
   - *Sensación:* Artesanal, enfocado en atletas dedicados.
   - *Fórmula ASO:* `Roundly: Boxing & HIIT Timer`
8. **IGNITE INTERVALS**
   - *Etimología:* Encender el esfuerzo metabólico y calórico.
   - *Sensación:* Motivacional, visualmente coherente con la paleta Solar Orange y Crimson.
   - *Fórmula ASO:* `Ignite: Interval & Tabata Timer`

---

## 4. Tabla Comparativa y Recomendación Final

| Nombre Propuesto | Sonoridad Global | Coherencia con UI y Logo | Fuerza de Marca | Facilidad de Registro |
|---|:---:|:---:|:---:|:---:|
| **Repulse** ⭐ | Alta | ⭐⭐⭐⭐⭐ (Une el dial y el pulso cardíaco) | Muy Alta | Excelente |
| **Phasor** | Media-Alta | ⭐⭐⭐⭐⭐ (Refleja el motor de fases Trabajo/Descanso) | Alta | Excelente |
| **Circa** | Muy Alta | ⭐⭐⭐⭐ (Refleja los circuitos circulares) | Alta | Buena |
| **TempoX** | Alta | ⭐⭐⭐⭐ (Refleja la precisión de los descansos) | Media-Alta | Buena |
| **Shift** | Alta | ⭐⭐⭐ (Minimalista, pero palabra muy común) | Media | Regular |

### Recomendación del Senior Architect:
1. **Opción #1 (Favorita absoluta): `Repulse`**  
   Encaja al 100% con el nuevo icono que acabamos de optimizar (el anillo de fases + el pulso cardíaco en el triángulo de reproducción). Además, se asocia directamente a la repetición de series y a la respuesta cardiovascular.
2. **Opción #2 (Enfoque funcional): `Phasor`**  
   Si querés priorizar el concepto de precisión matemática en las fases de entrenamiento.
