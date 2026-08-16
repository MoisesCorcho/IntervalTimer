# Requirements: Multilenguaje (i18n)

> Estado: No iniciada

**ID:** F28 &nbsp;|&nbsp; **Slug:** `28-multi-language-i18n` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Soporte oficial y completo de internacionalización para Español e Inglés, abarcando la totalidad de los textos de la interfaz de usuario, las locuciones del motor de voz (TTS), las fases del temporizador y el catálogo de rutinas preestablecidas empaquetadas, con detección automática del sistema operativo y selector manual en Ajustes.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F02 - Voz: Cuenta Regresiva y Anuncios
- F03 - Sesiones Preestablecidas con Animacion/Video
- F35 - Navegacion de Secciones, Preparacion y Ajustes

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** usar la aplicación en mi idioma preferido (Español o Inglés), **para que** entienda claramente todas las opciones, botones y pantallas.
- **Como** usuario, **quiero** que la voz del temporizador me hable en el mismo idioma configurado en la app, **para que** los anuncios de voz ("Trabajo", "Descanso", cuenta regresiva) coincidan con lo que veo en pantalla.
- **Como** usuario, **quiero** explorar el catálogo de rutinas preestablecidas y ejercicios con títulos y descripciones en mi idioma, **para que** pueda comprender las instrucciones de cada entrenamiento.
- **Como** usuario, **quiero** poder elegir entre seguir el idioma de mi teléfono o fijar manualmente Español o Inglés desde Ajustes, **para que** tenga control total sobre mi experiencia.

## Decisiones de producto (registradas en auditoria)

| Tema | Decision | Justificacion |
|---|---|---|
| **Idiomas soportados** | **Español (`es`)** e **Inglés (`en`)** al lanzamiento, con arquitectura escalable para agregar más idiomas en el futuro. | Cubre el 100% de la audiencia objetivo inicial con paridad completa de contenido. |
| **Preferencia de idioma** | Clave `app_language` en `app_preferences` con valores `system` (default), `es`, `en`. | Respeta la configuración del teléfono por defecto pero permite anulación manual para usuarios bilingües. |
| **Sincronización de Voz (TTS)** | El motor TTS de F02 se reconfigura dinámicamente con el locale activo de la app (`es-ES` / `en-US`). | Evita la disonancia cognitiva de ver la interfaz en un idioma y escuchar la voz en otro. |
| **Catálogo de Presets (F03)** | Archivos JSON independientes por idioma en `assets/routines/` (`presets_es.json`, `presets_en.json`, `exercises_es.json`, `exercises_en.json`). | Mantiene el código de los parsers simple y limpio, sin inflar los archivos `.arb` con contenido estático extenso. |
| **Contenido de usuario** | Entrenamientos, nombres de intervalos y notas creadas por el usuario **no** se traducen (permanecen en su texto original). | Los datos del usuario son sagrados y no deben ser alterados por heurísticas de traducción. |
| **Fallback predeterminado** | Si el dispositivo tiene un idioma no soportado (ej. Francés o Alemán) y la preferencia es `system`, se usa **Inglés (`en`)**. | Estándar global de accesibilidad y localización móvil. |

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Idiomas oficiales disponibles

EL SISTEMA DEBE proveer traducciones completas y profesionales para todos los textos de la interfaz en Español (`es`) e Inglés (`en`).

### R2 — Detección automática del idioma del sistema (`system`)

DONDE la preferencia de idioma está configurada en `system` (valor por defecto),  
CUANDO la aplicación se inicia o el usuario cambia el idioma del sistema operativo,  
EL SISTEMA DEBE adoptar automáticamente el idioma del dispositivo si es Español o Inglés.

### R3 — Selector manual de idioma en Ajustes

DONDE el usuario navega a la sección de Ajustes (F35),  
EL SISTEMA DEBE mostrar una opción "Idioma" con las opciones: "Automático (Sistema)", "Español" e "English", persistiendo la selección inmediatamente.

### R4 — Localización de la interfaz vía `AppLocalizations`

CUANDO cualquier pantalla o componente renderiza texto visible,  
EL SISTEMA DEBE obtener las cadenas desde `AppLocalizations` (o `context.l10n`), eliminando cadenas de texto hardcodeadas en código de producción.

### R5 — Sincronización del motor de voz (TTS)

CUANDO el idioma de la aplicación cambia (automática o manualmente),  
EL SISTEMA DEBE actualizar el locale del motor de voz (`SystemTtsEngine` de F02) para que las locuciones, nombres de intervalos estándar y cuenta regresiva hablada se emitan en dicho idioma.

### R6 — Textos y anuncios fijos de fase del temporizador

CUANDO el temporizador ejecuta una sesión,  
EL SISTEMA DEBE presentar y anunciar las fases del timer según el idioma activo:
- En Español: *"Preparación"*, *"Trabajo"*, *"Descanso"*, *"Sesión completada"*.
- En Inglés: *"Get Ready"*, *"Work"*, *"Rest"*, *"Session Complete"*.

### R7 — Carga dinámica del catálogo de Presets localizado

CUANDO el usuario accede al catálogo de rutinas preestablecidas (F03),  
EL SISTEMA DEBE cargar el archivo de presets y ejercicios correspondiente al idioma activo (`presets_es.json` o `presets_en.json`).

### R8 — Cambio en caliente (Hot switch sin reiniciar)

CUANDO el usuario selecciona un nuevo idioma en Ajustes,  
EL SISTEMA DEBE actualizar toda la interfaz visual y la configuración de servicios en tiempo real (< 100ms) sin requerir reiniciar la aplicación.

### R9 — Formato de fechas, números y duraciones

CUANDO se muestran fechas en el calendario (F04) o estadísticas (F12),  
EL SISTEMA DEBE formatear los meses, días de la semana y separadores numéricos según las convenciones del locale seleccionado.

## Criterios de Aceptacion — Validacion, casos borde y error (formato EARS)

### R10 — Fallback ante idioma del sistema no soportado

SI el idioma del sistema operativo es distinto de Español o Inglés y la preferencia es `system`,  
ENTONCES EL SISTEMA DEBE aplicar Inglés (`en`) como idioma de fallback seguro.

### R11 — Fallback del motor TTS ante voz no instalada

SI el motor de TTS del dispositivo no tiene instalado el paquete de voz del idioma seleccionado,  
ENTONCES EL SISTEMA DEBE intentar el locale base (ej. `es` si falla `es-ES`, `en` si falla `en-US`) y degradar silenciosamente a texto en pantalla sin bloquear el temporizador.

### R12 — Inmutabilidad del texto libre creado por el usuario

CUANDO el usuario cambia de idioma,  
EL SISTEMA DEBE preservar intactos los nombres de entrenamientos personalizados, ejercicios y notas creadas por el usuario en `Workouts` (F32) y `SessionLogs` (F04).

### R13 — Fallback en catálogo de Presets

SI por alguna inconsistencia falta un archivo JSON localizado específico,  
ENTONCES EL SISTEMA DEBE cargar el catálogo en inglés (`presets_en.json`) como respaldo sin arrojar excepciones en pantalla.

## Fuera de alcance (explicito)

- Traducción automática de texto libre escrito por el usuario mediante servicios de machine learning.
- Soporte de idiomas RTL (árabe, hebreo) en la versión v1.
- Descarga de paquetes de voz TTS desde la nube (se usan las voces nativas disponibles en el dispositivo).

## Referencias

- Ver `_global/01-vision-and-principles.md` (Principio 1: Offline-first; Principio 3: Empezar sin configurar).
- Ver `_global/02-architecture-and-structure.md` (Estructura en `lib/core/l10n/`).
- Ver `_global/03-conventions.md` (Convenciones de internacionalización y Principio Anti-Parches).
- Ver `_global/05-data-model.md` (Preferencia `app_language` en `app_preferences`).
