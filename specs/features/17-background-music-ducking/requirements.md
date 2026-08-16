# Requirements: Integracion de Musica / Audio Ducking

> Estado: No iniciada

**ID:** F17 &nbsp;|&nbsp; **Slug:** `17-background-music-ducking` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia

## Resumen

Permite la convivencia armónica entre la música externa del usuario (Spotify, Apple Music, YouTube Music, podcasts) y los audios de la aplicación, aplicando atenuación automática (audio ducking) durante los anuncios hablados de voz (TTS) y restaurando inmediatamente el volumen original al terminar o interrumpir la locución.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F02 - Voz: Cuenta Regresiva y Anuncios
- F35 - Navegacion de Secciones, Preparacion y Ajustes

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** escuchar mi música externa favorita mientras entreno y que el volumen baje automáticamente cuando el timer me habla, **para que** pueda entender las instrucciones con total claridad sin pausar mi música manualmente.
- **Como** usuario, **quiero** que los efectos de sonido breves (pitidos/campanas) suenen por encima de mi música sin provocar subidas y bajadas bruscas de volumen, **para que** mi ritmo de entrenamiento sea continuo y agradable.
- **Como** usuario, **quiero** poder activar o desactivar la opción de atenuación de música desde la pantalla de Ajustes, **para que** pueda personalizar la experiencia según mi preferencia auditiva y entorno.

## Decisiones de producto (registradas en auditoria)

| Tema | Decision | Justificacion |
|---|---|---|
| **Alcance del ducking** | Aplicar ducking activo únicamente a la voz hablada (TTS de F02). Los SFX (F36) se reproducen en mezcla directa (`mixWithOthers`). | Los pitidos de SFX son muy cortos (100–300 ms); forzar ducking en cada beep causa un efecto molesto de "bombeo" de volumen en la música. La voz (1–3 s) requiere inteligibilidad clara. |
| **Ajuste en Configuración** | Preferencia booleana `music_ducking_enabled` en `app_preferences` (default: `true`). | Otorga autonomía al usuario permitiendo desactivar la atenuación si entrena en ambientes con música externa fija o podcasts. |
| **Ciclo de vida del foco** | Solicitud transitoria justo antes de cada `speak()` y liberación inmediata en `onCompletion`, `onError` o `stop()`. | Asegura que la música externa recupere su volumen normal tan pronto el asistente termina de hablar. |
| **Fail-safe con timeout** | Timeout de seguridad de 5 segundos para liberar el foco si el callback nativo de TTS no se emite. | Protege al usuario frente a fallos silenciosos o congelamiento de motores TTS nativos en ciertos fabricantes de Android o ante interrupciones en iOS. |
| **Mezcla con otras apps** | Configurar categoría de audio `.playback` con opciones de mezcla (`duckOthers` / `mixWithOthers`) al inicializar la app o sesión. | Permite que Spotify u otras apps no se pausen cuando nuestra aplicación produce sonido. |

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Configuración global de Audio Session para mezcla

CUANDO la aplicación se inicia o arranca una sesión de temporizador,  
EL SISTEMA DEBE configurar la sesión de audio del dispositivo en modo reproducción (`playback`) permitiendo la mezcla con otras aplicaciones de audio activas.

### R2 — Atenuación de música externa durante voz (TTS)

DONDE existe música o audio reproduciéndose en otra aplicación y la preferencia `music_ducking_enabled` está en `true`,  
CUANDO el motor de voz (F02) va a emitir un anuncio o cuenta regresiva hablada,  
EL SISTEMA DEBE solicitar el foco de audio transitorio con atenuación (`duckOthers` / `AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK`) provocando que la música externa baje su volumen de inmediato.

### R3 — Restauración automática de volumen tras la voz

DONDE la música externa ha sido atenuada por un anuncio de voz,  
CUANDO el motor de voz finaliza la reproducción del texto (`onCompletion`),  
EL SISTEMA DEBE liberar el foco de audio transitorio permitiendo que la música externa recupere su volumen original al 100% de forma suave.

### R4 — Mezcla directa sin ducking para Efectos de Sonido (SFX)

DONDE existe música externa sonando de fondo,  
CUANDO el sistema reproduce un efecto de sonido de catálogo (F36: pitido de prep, inicio de intervalo o fin de sesión),  
EL SISTEMA DEBE reproducir el clip de audio en mezcla directa (`mixWithOthers`) sin disminuir el volumen de la música externa.

### R5 — Preferencia de usuario en pantalla de Ajustes

DONDE el usuario se encuentra en la pantalla de Ajustes de Audio/Voz (F35),  
EL SISTEMA DEBE mostrar un switch "Atenuar música de fondo" asociado a la clave `music_ducking_enabled` (activo por defecto).

### R6 — Comportamiento con atenuación desactivada

DONDE la preferencia `music_ducking_enabled` está establecida en `false`,  
CUANDO el motor de voz emite un anuncio hablado,  
EL SISTEMA DEBE reproducir la voz utilizando mezcla directa (`mixWithOthers`) sin solicitar atenuación de la música externa.

### R7 — Restauración inmediata en pausa, salto o cancelación

DONDE la música externa se encuentra atenuada porque la voz está hablando,  
CUANDO el usuario pausa el temporizador, salta al siguiente intervalo o cancela la sesión,  
EL SISTEMA DEBE detener la locución en curso (`tts.stop()`) y liberar el foco de audio inmediatamente (< 50ms), restaurando el volumen de la música.

## Criterios de Aceptacion — Validacion, casos borde y error (formato EARS)

### R8 — Timeout de seguridad ante fallo de callback de TTS (Fail-safe)

SI transcurren 5 segundos desde que se solicitó el foco de audio con ducking sin que el motor TTS haya notificado la finalización o error,  
ENTONCES EL SISTEMA DEBE forzar la liberación del foco de audio para garantizar que la música externa no quede atenuada de forma permanente.

### R9 — Manejo de interrupciones del sistema (Llamadas / Alarmas)

CUANDO el sistema operativo interrumpe el audio de la app por una llamada telefónica entrante o una alarma del sistema,  
EL SISTEMA DEBE liberar el foco de audio y pausar cualquier locución pendiente sin bloquear el hilo principal.

### R10 — Degradación elegante sin soporte nativo de ducking

SI el sistema operativo o el hardware del dispositivo no soporta la atenuación transitoria (`duckOthers`),  
ENTONCES EL SISTEMA DEBE continuar con la reproducción de la voz en modo mezcla normal sin arrojar excepciones ni alterar la ejecución del temporizador.

### R11 — Concurrencia de locuciones consecutivas

SI se solicitan dos anuncios de voz en rápida sucesión antes de que el primero libere el foco,  
ENTONCES EL SISTEMA DEBE mantener el foco de audio activo durante toda la secuencia y liberarlo únicamente al concluir la última locución.

## Fuera de alcance (explicito)

- Reproductor interno de música o integración de API para controlar reproducción/pausa de Spotify/Apple Music.
- Ajuste fino del porcentaje exacto de atenuación en decibeles (se utiliza el ducking nativo provisto por el SO).
- Ducking de música provocado por apps de terceros sobre nuestra propia app.

## Referencias

- Ver `_global/01-vision-and-principles.md` (Principio 2: Cero fricción durante el entrenamiento).
- Ver `_global/02-architecture-and-structure.md` (Integración de servicios de hardware en `features/`).
- Ver `_global/03-conventions.md` (Principio Anti-Parches y manejo de excepciones).
- Ver `_global/05-data-model.md` (Preferencia `music_ducking_enabled` en `app_preferences`).
