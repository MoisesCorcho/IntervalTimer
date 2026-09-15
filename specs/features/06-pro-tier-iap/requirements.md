# Requirements: Capa Pro / Compras In-App (Freemium)

> Estado: Specs auditadas y corregidas

**ID:** F06 &nbsp;|&nbsp; **Slug:** `06-pro-tier-iap` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

---

## Resumen

Capa de monetización freemium ética y de alto valor percibido para la aplicación, diseñada bajo la premisa innegociable de que **el loop básico de entrenamiento es sagrado y 100% gratuito**, mientras que se monetiza la conveniencia operativa (rutinas creadas ilimitadas más allá de 3), el seguimiento biométrico avanzado (historial ilimitado y registro de medidas corporales en F15), el catálogo extendido de efectos de sonido deportivos (SFX de alta fidelidad en F36) y la personalización estética profunda (selector de colores de fase con mockup interactivo).

La arquitectura implementa el patrón **Ports & Adapters**, desacoplando el dominio y la presentación de los servicios de facturación mediante una interfaz abstracta (`BillingRepository`), respaldada inicialmente por un adaptador simulado (`FakeBillingDriver`) con switch de depuración para validar inmediatamente la experiencia visual Free vs. Pro y simplificar los tests automatizados sin requerir cuentas de Google Play Console en desarrollo.

---

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- **F01 - Interval Timer Core:** Motor del temporizador y ciclo de vida de ejecución.
- **F35 - Navegación de Secciones, Preparación y Ajustes:** Repositorio de preferencias (`PreferencesRepository`) y pantalla de ajustes.

## Dependencias blandas e integraciones

- **F32 - Constructor de Entrenamientos por Ejercicios:** Compuerta de límite de 3 rutinas propias para usuarios Free.
- **F15 - Registro de Peso y Medidas Corporales:** Límite de 5 registros históricos y bloqueo de medidas corporales avanzadas (cintura, brazo, pierna) para Free.
- **F36 - Efectos de Sonido del Temporizador (SFX):** Desbloqueo del catálogo ampliado de clips deportivos (Gong, Campana, Silbato).
- **F17 - Integración de Música / Audio Ducking:** Funcionalidad de confort auditivo esencial 100% libre para todos los usuarios.
- **F04 - Calendario e Historial de Sesiones:** Creación y edición de notas post-entreno 100% libres para preservar la retención del atleta.

## Postrequisitos (features que dependen de esta)

- **F25 - Compartir Rutinas con Otros Usuarios:** Límite de importación/exportación según plan.

---

## Decisiones de Producto y Arquitectura

| ID | Tema | Decisión adoptada | Justificación técnica y de negocio |
|---|---|---|---|
| **D1** | Filosofía Freemium | **El loop de entrenamiento es 100% libre y sin publicidad intrusiva.** | Cobrar por funciones core genera abandono y malas reseñas. Se monetiza la conveniencia, la escala y la personalización estética. |
| **D2** | Límite de Creación Free | **Máximo 3 rutinas propias creadas.** | Modelo probado en apps líderes (*Hevy*, *Seconds*). Quien crea más de 3 rutinas entrena con disciplina y es el cliente con mayor propensión a pagar. |
| **D3** | Arquitectura Ports & Adapters | **Abstracción `BillingRepository` + `FakeBillingDriver` en dev.** | Evita bloqueos por configuración de Play Console / StoreKit; permite testing visual instantáneo y pruebas automatizadas determinísticas. |
| **D4** | Señalización Visual | **Componente `ProBadge` sutil y uniforme en esquinas/chips.** | Informa claramente al usuario qué elementos son Pro sin entorpecer el uso ni degradar la armonía del Design System. |
| **D5** | Experiencia de Paywall | **Pantalla modal inmersiva (`PaywallModalScreen`) tipo onboarding.** | Presenta los beneficios con animaciones vectoriales de alto impacto, desglose transparente de precios y botón de restauración de compras. |
| **D6** | Estructura de Precios | **Suscripción Mensual, Anual con 7 días de prueba, y Lifetime.** | La suscripción anual con descuento (50%) optimiza el LTV; la opción de por vida captura a usuarios que rechazan pagos recurrentes. |
| **D7** | Tolerancia Offline | **Persistencia local atómica en Drift SQLite del derecho adquirido.** | El atleta Pro debe poder entrenar en sótanos, pistas al aire libre o en modo avión sin perder sus funciones premium. |
| **D8** | Switch de Depuración | **Toggle Free/Pro accesible en Ajustes para entornos de desarrollo.** | Permite alternar en tiempo real entre ambos estados para validar diseño, textos y accesibilidad en un toque. |

---

## User Stories

1. **Como** usuario gratuito, **quiero** usar el cronómetro y rutinas de fábrica sin restricciones ni anuncios invasivos, **para que** mi entrenamiento nunca sea interrumpido.
2. **Como** usuario gratuito que crea su cuarta rutina, **quiero** ver un aviso claro y la opción de pasar a Pro, **para que** comprenda el valor de la suscripción.
3. **Como** atleta que adquiere Pro, **quiero** que todas las restricciones visuales, auditivas y de rutinas se desbloqueen al instante sin reiniciar la app, **para que** disfrute inmediatamente de mi compra.
4. **Como** usuario que reinstala la app o cambia de teléfono, **quiero** restaurar mi suscripción previa con un solo toque, **para que** no tenga que volver a pagar.
5. **Como** desarrollador/tester, **quiero** alternar entre modo Free y Pro mediante un switch de depuración, **para que** verifique el comportamiento de la UI sin emular la pasarela de pagos.

---

## Criterios de Aceptación (formato EARS)

### Happy Path — Estado de Entitlement y Desbloqueo Pro

#### R1 — Detección y persistencia de suscripción
DONDE el usuario inicia la aplicación o navega entre secciones,  
CUANDO se consulta el estado de suscripción,  
EL SISTEMA DEBE exponer reactivamente el flag booleano `isPro` a través de `isProUserProvider`, leyéndolo de forma segura y atómica desde `PreferencesRepository`.

#### R2 — Límite de rutinas propias en capa Free
DONDE el usuario tiene el estado `isPro == false`,  
CUANDO navega a la sección de rutinas propias (`/workouts`),  
EL SISTEMA DEBE permitir crear y guardar hasta un máximo de 3 entrenamientos propios, mostrando un contador de uso visible (ej. "2 / 3 rutinas gratuitas").

#### R3 — Compuerta de bloqueo al superar el límite
DONDE el usuario gratuito ya tiene 3 entrenamientos guardados,  
CUANDO presiona el botón para agregar una nueva rutina o duplicar una existente,  
EL SISTEMA DEBE bloquear la creación y abrir inmediatamente la pantalla modal de suscripción (`PaywallModalScreen`).

#### R4 — Señalización visual con `ProBadge`
DONDE cualquier componente de interfaz incluye características exclusivas de Pro (ej. colores de fase personalizados, clips de audio deportivo no predeterminados, campos de medidas corporales avanzadas),  
CUANDO el usuario tiene el estado `isPro == false`,  
EL SISTEMA DEBE renderizar un badge visual `ProBadge` sutil en color ámbar/dorado con icono de candado o corona.

#### R5 — Paywall Modal Inmersivo
DONDE el usuario pulsa un componente Pro o el botón de upgrade en Ajustes,  
CUANDO se despliega `PaywallModalScreen`,  
EL SISTEMA DEBE mostrar:
1. Encabezado premium con medalla o corona animada y título de valor aspiracional.
2. Lista estructurada de los 6 beneficios clave reales:
   - Rutinas ilimitadas (más allá del límite de 3 rutinas propias).
   - Seguimiento corporal completo (historial de peso y registro de medidas de cintura, brazo y pierna).
   - Cero publicidad intersticial.
   - Efectos de sonido deportivos de alta fidelidad (catálogo de clips SFX: campana, gong, silbato).
   - Colores de fase personalizables con mockup interactivo en tiempo real.
   - Apoyo directo al desarrollo independiente.
3. Selector de planes de compra: Mensual, Anual con 7 días de prueba (destacada como 'Mejor valor') y Pago Único de por vida (Lifetime).
4. Botón de acción primario ("Probar 7 días gratis" o "Comenzar Pro").
5. Enlace visible para "Restaurar compras".
6. Enlaces obligatorios de conformidad con las tiendas (Términos de Servicio / EULA y Política de Privacidad) accesibles en el pie del modal.
7. Botón de cierre para volver a la pantalla previa sin fricción.

#### R6 — Desbloqueo reactivo inmediato tras compra
DONDE el usuario completa exitosamente el flujo de compra desde el paywall,  
CUANDO la transacción es confirmada por el `BillingRepository`,  
EL SISTEMA DEBE persistir `is_pro = true`, cerrar el modal y actualizar reactivamente todos los badges y compuertas de la aplicación sin reiniciar.

#### R7 — Restauración de compras previas
DONDE un usuario Pro reinstala la app o activa un nuevo dispositivo,  
CUANDO presiona la opción "Restaurar compras" en el paywall o en Ajustes,  
EL SISTEMA DEBE consultar el historial en el servicio de facturación, restablecer `is_pro = true` si existe una compra válida y notificar al usuario con un mensaje de éxito.

#### R8 — Restricción y desbloqueo de personalización estética
DONDE el usuario navega a la selección de acento o colores de fase (`PhaseColorPickerScreen`),  
CUANDO `isPro == false`,  
EL SISTEMA DEBE permitir visualizar la vista previa interactiva en el mockup de teléfono, pero bloquear la persistencia con un llamado a `PaywallModalScreen` si selecciona un color Pro.

#### R9 — Restricción y desbloqueo de clips SFX deportivos
DONDE el usuario navega a Ajustes de efectos de sonido (`SoundEffectsSettingsSection`) y abre el selector de clips de audio (`_openPicker`),  
CUANDO el clip seleccionado es un sonido deportivo Pro (no predeterminado) y el usuario tiene el estado `isPro == false`,  
EL SISTEMA DEBE mostrar el distintivo `ProBadge` junto al clip y desplegar `PaywallModalScreen` al intentar seleccionarlo, manteniendo el clip por defecto y la función de Music Ducking 100% gratuitos y accesibles para todos los usuarios.

#### R10 — Restricción y desbloqueo de seguimiento corporal (Body Tracking)
DONDE el usuario interactúa con el módulo de registro corporal (F15),  
CUANDO el usuario tiene el estado `isPro == false`,  
EL SISTEMA DEBE permitir registrar y consultar el peso corporal libremente con hasta 5 registros históricos visibles (`kFreeBodyMeasurementsLimit = 5`), pero requerir Pro (abriendo `PaywallModalScreen`) para registrar medidas avanzadas (cintura, brazo, pierna) y visualizar el historial completo previo, manteniendo las notas de sesión en calendario 100% libres.

---

### Casos de Error, Validación y Modo de Depuración

#### R11 — Cancelación o fallo de compra
DONDE el usuario cancela la pasarela de compra o se produce un error de red/pago,  
CUANDO el proveedor de facturación retorna un estado fallido o cancelado,  
EL SISTEMA DEBE mantener el estado `isPro == false`, mostrar un snackbar informativo no bloqueante y permitir reintentar sin cerrar abruptamente el paywall.

#### R12 — Restauración sin compras activas
DONDE el usuario pulsa "Restaurar compras",  
CUANDO el servicio de facturación confirma que no existen transacciones activas asociadas a la cuenta del usuario,  
EL SISTEMA DEBE informar amablemente al usuario que no se encontraron suscripciones previas sin alterar su estado actual.

#### R13 — Resiliencia y funcionamiento offline
DONDE la aplicación se ejecuta sin conectividad a internet,  
CUANDO un usuario previamente autenticado como Pro abre la app,  
EL SISTEMA DEBE leer el estado persistido en SQLite local y mantener todas las funciones Pro desbloqueadas indefinidamente en modo offline.

#### R14 — Switch de depuración (Developer Mock Driver)
DONDE la aplicación se ejecuta en modo debug o perfil,  
CUANDO se accede a la sección de Ajustes,  
EL SISTEMA DEBE proporcionar una tarjeta de desarrollo con un switch ("Simular usuario Pro") que alterne instantáneamente entre `isPro = true` e `isPro = false` en memoria para fines de prueba visual.

---

### Casos Borde y Cruce Transversal de Funcionalidades (Edge Cases)

#### R15 — Compuerta en Duplicación de Rutinas y Presets
DONDE el usuario gratuito tiene 3 o más entrenamientos propios guardados,  
CUANDO intenta duplicar una rutina existente desde el menú de acciones (`WorkoutAction.duplicate`) o clonar un preset del catálogo hacia sus rutinas (`PresetDetailScreen`),  
EL SISTEMA DEBE interceptar la acción a nivel de controlador/repositorio, rechazar la creación y desplegar `PaywallModalScreen`.

#### R16 — Política de Downgrade y Preservación de Datos
DONDE un usuario Pro que creó más de 3 entrenamientos propios pasa al estado Free (por vencimiento, cancelación o toggle debug),  
CUANDO inicia la app o consulta su catálogo de rutinas,  
EL SISTEMA DEBE:
1. Preservar intactos el 100% de los entrenamientos existentes sin eliminar ni alterar datos.
2. Permitir ejecutar, entrenar y editar cualquiera de las rutinas existentes.
3. Bloquear estrictamente la creación o duplicación de nuevas rutinas hasta que el usuario vuelva a ser Pro o reduzca su biblioteca a menos de 3 rutinas.

#### R17 — Fallback Seguro de Personalizaciones Cosméticas
DONDE un usuario Free posee configurados en SQLite colores de fase o acentos Pro (debido a un downgrade previo o importación de backup),  
CUANDO el motor de temas y ejecución renderiza la interfaz,  
EL SISTEMA DEBE aplicar los colores estándar ergonómicos en pantalla sin sobrescribir ni borrar la preferencia guardada en base de datos.

#### R18 — Prevención de Condiciones de Carrera (Double-Tap Lock)
DONDE el usuario tiene 2 rutinas creadas y pulsa repetidamente en milisegundos el botón "Guardar" o "Duplicar",  
CUANDO se procesan las peticiones concurrentes,  
EL SISTEMA DEBE ejecutar la verificación y guardado de forma atómica y bloqueante (mutex/debounce), impidiendo que se sobrepase el límite de 3 rutinas por ejecuciones paralelas.

#### R19 — Estado Pro Activo y Gestión de Suscripción
DONDE el usuario posee el estado `isPro == true`,  
CUANDO interactúa con la tarjeta Pro en la pantalla de Ajustes o accede a la vista de suscripción,  
EL SISTEMA DEBE:
1. Ocultar estrictamente opciones de compra, precios de suscripción y botones de pago redundantes.
2. Presentar una vista modal informativa (`ProStatusModalSheet`) confirmando el estado activo de la membresía con el distintivo visual Pro.
3. Mostrar el catálogo de beneficios actualmente desbloqueados (rutinas ilimitadas, métricas corporales, SFX deportivos, personalización de colores, cero publicidad).
4. Proveer un botón de cierre y una acción accesible para gestionar la suscripción directamente en la tienda de aplicaciones correspondiente (Google Play / App Store).

---

## Matriz de Cruce Funcional y Casos Borde (A x B x C)

| Escenario de Cruce | Flujo de Usuario | Comportamiento Esperado (Protección Robusta) |
|---|---|---|
| **Presets (F03) ✕ Límite Free (F32) ✕ Paywall (F06)** | Usuario Free con 3 rutinas abre un preset en `/presets` y pulsa "Duplicar a Mis Rutinas". | Bloqueo preventivo a nivel de controlador; abre `PaywallModalScreen` antes de invocar la copia en Drift. |
| **Acciones de Rutina ✕ Límite Free ✕ Quick Tap** | Usuario Free con 2 rutinas pulsa rápidamente 2 veces "Duplicar" en el menú de tarjeta. | Mutex en repositorio: la 1ra copia pasa (total: 3); la 2da falla con compuerta de límite y abre Paywall. |
| **Downgrade Pro→Free ✕ Ejecución (F01) ✕ Workouts (F32)** | Usuario Pro con 8 rutinas cancela suscripción. Abre una rutina creada cuando era Pro. | Ejecución perfecta del timer sin bloqueos; el límite solo prohíbe crear la 9na rutina. |
| **Clips SFX (F36) ✕ Ajustes de Sonido ✕ Selector** | Usuario Free selecciona un sonido deportivo Pro (Gong, Silbato) en Ajustes de SFX. | Muestra `ProBadge`, abre `PaywallModalScreen` preventivamente y no persiste la selección bloqueada. |
| **Body Tracking (F15) ✕ Límite Free ✕ SQLite** | Usuario Free registra peso y medidas. Posee más de 5 registros previos en base de datos. | Permite registrar peso corporal libremente; oculta medidas avanzadas e historial > 5 con opción a desbloquear Pro. |
| **Backup Import (F29) ✕ Límite Free (F06) ✕ SQLite** | Usuario Free restaura un backup JSON que contiene 6 rutinas creadas en otro equipo. | Se restauran las 6 rutinas (datos sagrados), pero la UI bloquea nuevas creaciones ("6 / 3 rutinas"). |
| **Offline Mode ✕ Compra previa ✕ Reinicio de App** | Usuario Pro viaja en avión sin internet durante 15 días y reinicia la app repetidamente. | El flag `is_pro_user` en SQLite persiste intacto y la app mantiene todas las funciones Pro activas. |

---

## Fuera de alcance (explicito)

- Integración de SDK de publicidad (AdMob); la política de cero anuncios se modela mediante el flag `showAds = !isPro`.
- Conexión con servidores de backend para verificación de recibos criptográficos (MVP local respaldado en Google Play / App Store).
- Sistema de cupones de descuento o códigos promocionales de terceros.

---

## Referencias

- Ver `ANALISIS_MONETIZACION_FREEMIUM_F06.md` para el análisis de mercado, eCPM y matriz detallada.
- Ver `_global/02-architecture-and-structure.md` para la convención de Ports & Adapters.
- Ver `_global/04-design-system.md` para la paleta de colores y componentes visuales.

