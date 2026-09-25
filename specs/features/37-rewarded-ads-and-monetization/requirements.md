# Requirements: Publicidad y Anuncios Bonificados (Rewarded Ads & AdMob)

> Estado: Specs redactadas y listas para auditoría SDD

**ID:** F37 &nbsp;|&nbsp; **Slug:** `37-rewarded-ads-and-monetization` &nbsp;|&nbsp; **Fase:** Fase 2 · Monetización y Anuncios

---

## Resumen

Sistema integral de monetización publicitaria ética y de alta retención basado en **Google Mobile Ads (AdMob)**, diseñado como complemento del modelo Pro (F06) bajo el principio innegociable de **Intercambio de Valor (Value Exchange)**.

La feature establece que **el entrenamiento activo es sagrado y libre de toda publicidad**. La monetización se estructura en dos frentes controlados:
1. **Monetización Pasiva:** Anuncio Intersticial a pantalla completa únicamente al finalizar el entrenamiento (al pulsar "Listo" en `SessionCompleteScreen`), protegido por un **cooldown técnico de 10 minutos** entre apariciones.
2. **Monetización Activa (Rewarded Video):** Desbloqueo temporal de capacidades Pro mediante visualización voluntaria de videos bonificados de 15–30 segundos, limitado a un **máximo diario de 2 videos cada 24 horas** por dispositivo.

Todo el desarrollo de la feature se rige bajo **TDD Estricto** (arquitectura de driver desacoplado con `FakeAdService`) y protocolo de verificación **RDD (Receipt-Driven Development)** mediante subagentes adversariales ciegos que auditan la integridad del código previo a la integración.

---

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- **F01 - Interval Timer Core:** Motor del temporizador y pantalla de finalización de sesión (`SessionCompleteScreen`).
- **F06 - Capa Pro / Compras In-App (Freemium):** Entidad `isProUserProvider`, compuertas de valor y `PaywallModalScreen`.
- **F35 - Navegación de Secciones, Preparación y Ajustes:** Repositorio de preferencias y ajustes globales de la aplicación.

## Dependencias blandas e integraciones

- **F32 - Constructor de Entrenamientos por Ejercicios:** Desbloqueo temporal del 4º slot de rutina propia (+1 Slot por 24h).
- **F36 - Efectos de Sonido del Temporizador (SFX):** Desbloqueo temporal del catálogo Pro de sonidos deportivos (Gong, Silbato, Campana) por 12h con fallback elegante al beep estándar.
- **F15 - Registro de Peso y Medidas:** Desbloqueo temporal de la gráfica histórica extendida por 24h.
- **F29 - Backup y Exportación de Datos:** *POSTERGADA A FASE 7*. Queda explícitamente excluida del MVP de F37 para evitar dependencias hacia adelante.

## Postrequisitos (features que dependen de esta)

- Ninguna inmediata; F37 cierra el ecosistema de monetización freemium híbrido de la aplicación.

---

## Decisiones de Producto y Arquitectura

| ID | Tema | Decisión adoptada | Justificación técnica y de negocio |
|---|---|---|---|
| **D1** | Filosofía de UX en Entreno | **Cero publicidad durante la preparación, ejecución o pausa del ejercicio.** | La intrusión publicitaria durante el esfuerzo deportivo genera toques accidentales, destruye el foco y dispara desinstalaciones masivas. |
| **D2** | Frecuencia de Intersticial | **Disparado al tocar "Listo" con Cooldown Técnico de 10 minutos.** | Previene penalizaciones de AdMob por ráfagas de anuncios (*Ad Serving Limits*) y protege al usuario que prueba rutinas cortas consecutivas. |
| **D3** | Pase Sin Publicidad | **Pase "Ad-Free" de 24 Horas exactas al ver 1 video bonificado.** | Cubre el ciclo circadiano del atleta (la sesión actual y la preparación de la siguiente), manteniendo un balance óptimo frente a la suscripción Pro. |
| **D4** | Cap Diario de Rewarded Ads | **Máximo 2 videos bonificados cada 24 horas por dispositivo.** | Evita el *farming* publicitario, preserva el eCPM de AdMob ante los anunciantes e incentiva la conversión a Pro. |
| **D5** | Cero Pérdida de Datos | **La expiración de pases archiva o conmuta en fallback, NUNCA borra.** | La 4ª rutina creada pasa a estado *Archivada / Bloqueada*; los sonidos Pro retornan transparentemente al beep estándar sin alterar la configuración en base de datos. |
| **D6** | Puntos de Entrada UI | **Modal contextual reutilizable (`BenefitUnlockDialog`).** | Consistencia visual universal en los puntos de fricción (Rutina, Audio, Colores, Peso). El `PaywallModalScreen` se mantiene 100% enfocado a conversión Pro sin distracciones publicitarias. |
| **D7** | Resiliencia Offline & No-Fill | **Botón deshabilitado sin red; prohibición de pases de gracia sin anuncio visto.** | Si no hay conexión o no hay inventario publicitario (*no-fill*), se informa transparentemente sin romper el estado ni regalar beneficios vulnerables. |
| **D8** | Prevención de Manipulación de Hora | **Reloj Monotónico del Sistema + Marca de agua UTC en Drift SQLite.** | Evita que usuarios avanzados alteren la hora del sistema operativo para extender artificialmente pases vencidos o resetear el contador diario. |
| **D9** | Disciplina de Desarrollo | **TDD Estricto + Verificación Adversarial RDD (Receipt-Driven Development).** | Implementación primero guiada por tests con `FakeAdService`; verificación de diffs mediante subagentes ciegos sin sesgo de contexto. |

---

## User Stories

1. **Como** usuario gratuito que completa su sesión y toca "Listo", **quiero** experimentar una transición limpia con un anuncio intersticial pasivo solo si pasaron más de 10 minutos desde el último, **para que** mi experiencia post-entreno no sea abrumadora.
2. **Como** usuario gratuito que desea usar el sonido de Silbato Pro o crear una 4ª rutina, **quiero** tener la opción clara de ver un video voluntario de 30s, **para que** pueda disfrutar del beneficio durante 12h/24h sin desembolsar dinero.
3. **Como** atleta que no quiere ver anuncios intersticiales post-entreno hoy, **quiero** activar un pase "Ad-Free" de 24 horas viendo 1 video bonificado, **para** entrenar con foco total durante todo el día.
4. **Como** usuario cuyo pase de 4ª rutina ha expirado, **quiero** ver mi rutina intacta pero archivada, **para que** mi trabajo previo no se pierda y pueda reactivarla viendo otro video o comprando Pro.
5. **Como** usuario en el sótano del gimnasio sin conexión a internet, **quiero** que la app me indique amablemente que los videos requieren conexión en lugar de fallar silenciosamente, **para que** comprenda el motivo técnico.
6. **Como** suscriptor Pro, **quiero** que todos los anuncios (intersticiales y bonificados) queden completamente invisibles o desactivados, **para que** disfrute de mi experiencia premium sin fricción publicitaria.

---

## Requisitos Funcionales

- **R01 - Zero Workout Disruption:** Queda terminantemente prohibido solicitar, pre-cargar intrusivamente o renderizar cualquier formato publicitario mientras el temporizador esté en estado de preparación, ejecución, pausa o pantalla bloqueada.
- **R02 - Interstitial Trigger & Cooldown:**
  - El anuncio intersticial solo puede activarse tras pulsar el botón "Listo" en `SessionCompleteScreen`.
  - El servicio de anuncios debe verificar que hayan transcurrido $\ge 10$ minutos desde la última visualización de un intersticial.
  - Si el usuario cuenta con el pase `RewardedBenefit.adFreePass` activo o tiene suscripción Pro activa (`isProUserProvider == true`), el intersticial se omite silenciosamente.
- **R03 - Opt-In Estricto para Rewarded Ads:** La reproducción de un video bonificado debe ser 100% deliberada y precedida por un modal de confirmación (`BenefitUnlockDialog`) que declare: *"Ver video (30s) para desbloquear [Beneficio] por [Duración]"*.
- **R04 - Concesión Atómica de Beneficios:** La recompensa únicamente se acredita en la base de datos local cuando el SDK dispara el callback verificado `onUserEarnedReward`.
- **R05 - Catálogo de Beneficios y Duraciones:**
  - `extraWorkoutSlot`: +1 slot de rutina creada por **24 horas**.
  - `proAudioPass`: Catálogo extendido de SFX deportivos por **12 horas**.
  - `phaseColorsPass`: Selector libre de colores de fase por **24 horas**.
  - `bodyTrackingPass`: Gráfica histórica y medidas corporales por **24 horas**.
  - `adFreePass`: Supresión total de anuncios intersticiales por **24 horas**.
- **R06 - Límite Diario y Cooldown de Recompensas:**
  - Máximo **2 videos bonificados cada 24 horas** por dispositivo.
  - Cooldown mínimo obligatorio de **15 minutos** entre dos visualizaciones de videos bonificados.
  - Si se alcanza el límite diario, los botones de video se muestran deshabilitados indicando *"Límite diario alcanzado. Disponible mañana"*.
- **R07 - Integridad y Preservación de Datos (Zero Data Loss):**
  - La expiración de `extraWorkoutSlot` no elimina la 4ª rutina de la base de datos; la marca como `archived = true` (solo lectura). Al intentar ejecutarla o editarla se solicita renovar el pase o activar Pro.
  - La expiración de `proAudioPass` no muta la rutina; `SoundService` conmuta automáticamente a reproducir el beep estándar si el clip seleccionado es Pro y el pase expiró.
- **R08 - Resiliencia Offline y No-Fill:**
  - Si no se detecta conexión a internet o el SDK reporta `onAdFailedToLoad` / no-fill, el botón de ver video se deshabilita o despliega un aviso descriptivo: *"No hay videos disponibles en este momento. Verificá tu conexión o pasate a Pro"*.
  - En ningún caso se otorgará un pase temporal ante un fallo de red o cierre prematuro del video.
- **R09 - Blindaje contra Manipulación de Hora:**
  - El repositorio de pases debe cotejar la marca de agua del mayor timestamp UTC registrado localmente (`max_verified_timestamp`).
  - Si se detecta un timestamp menor al registrado previamente, se invalida el pase preventivamente hasta la siguiente sincronización válida.
- **R10 - Driver Simulado para Tests (TDD):** Existencia mandatoria de una implementación `FakeAdService` que permita simular estados de éxito, cierre prematuro, no-fill, cooldown y límites diarios de forma determinista en tests sin inicializar el SDK nativo.

---

## Requisitos No Funcionales

- **NFR01 - Rendimiento y Memoria:** La precarga de anuncios (`loadRewardedAd`, `loadInterstitialAd`) debe realizarse en segundo plano sin causar caídas de frames (jank) en las animaciones de la UI.
- **NFR02 - Aislamiento Arquitectónico:** El SDK de terceros (`google_mobile_ads`) debe residir estrictamente encapsulado en la capa de infraestructura (`lib/features/monetization/infrastructure/`). Ningún widget de presentación ni entidad de dominio debe importar directamente el paquete de Google Mobile Ads.
- **NFR03 - Privacidad y Compliance:** Soporte de los Ad Unit IDs oficiales de prueba de Google durante el desarrollo y ejecución de pruebas automatizadas.
- **NFR04 - TDD y RDD Cobertura:** 100% de cobertura en tests unitarios para las reglas de negocio de `TemporaryPassRepository`, `DailyCapTracker` y evaluadores de autorización en Riverpod. Toda PR debe superar la revisión RDD de subagente ciego.

---

## Criterios de Aceptación (Gherkin)

### Escenario 1: Salto de anuncio intersticial con cooldown activo
```gherkin
Given un usuario Free que finalizó un entrenamiento y visualizó un intersticial hace 4 minutos
When finaliza un segundo entrenamiento y pulsa "Listo" en SessionCompleteScreen
Then la aplicación NO solicita ni muestra ningún anuncio intersticial
And navega directamente a la pantalla de Inicio/Historial
```

### Escenario 2: Desbloqueo de 4º slot mediante Rewarded Ad
```gherkin
Given un usuario Free que ya posee 3 rutinas creadas (límite alcanzado)
When intenta crear una 4ª rutina y pulsa "Ver video (30s) para desbloquear por 24h"
And completa la visualización total del video bonificado
Then se crea un pase activo para "extraWorkoutSlot" con expiración en DateTime.now() + 24 horas
And la UI abre inmediatamente el editor para crear la 4ª rutina
```

### Escenario 3: Expiración de pase de rutina sin pérdida de datos
```gherkin
Given un usuario que creó una 4ª rutina bajo un pase temporal ya expirado (> 24h)
When ingresa a la lista de sus entrenamientos
Then la 4ª rutina aparece listada con un icono de candado y estado "Archivada"
And al pulsar sobre ella se despliega el diálogo BenefitUnlockDialog ofreciendo renovar el pase o adquirir Pro
And los ejercicios y tiempos internos de la rutina permanecen 100% inalterados
```

### Escenario 4: Límite diario de videos alcanzado
```gherkin
Given un usuario que ya completó la visualización de 2 videos bonificados en las últimas 24 horas
When intenta desbloquear los colores de fase en PhaseColorPickerScreen
Then el botón de ver video se encuentra deshabilitado con el texto "Límite diario alcanzado (2/2)"
And el botón principal "Obtener Pro" permanece activo como alternativa
```

---

## Casos Borde y Pruebas de Estrés

| Caso Borde | Comportamiento Esperado | Mitigación Arquitectónica |
|---|---|---|
| **Cierre prematuro del video a los 10 segundos** | No se otorga ninguna recompensa; se informa al usuario que debe completar el anuncio. | La mutación a SQLite solo escucha el callback `onUserEarnedReward`. |
| **Usuario desconecta internet a mitad del video** | Si el SDK no emite el evento de completado con éxito, la transacción se aborta. | Transaccionalidad estricta en el repositorio de pases. |
| **El usuario adelanta el reloj del sistema 3 días** | El pase se evalúa como expirado inmediatamente. Si intenta atrasarlo al pasado, salta la alarma de manipulación temporal y se revoca. | Verificación de monotonía contra marca de agua en Drift. |
| **Usuario compra Pro mientras tiene un pase temporal activo** | Pro toma precedencia jerárquica total; los pases temporales quedan redundantes y se ignoran. | `isBenefitUnlockedProvider` chequea primero `isProUserProvider`. |
