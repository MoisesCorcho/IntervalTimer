# Design: Integracion de Musica / Audio Ducking

**ID:** F17 &nbsp;|&nbsp; **Slug:** `17-background-music-ducking`

## Contexto

Este documento describe la arquitectura técnica para la convivencia armónica entre la música externa de fondo y los audios de la aplicación (F17), implementando atenuación automática (audio ducking) durante los anuncios de voz (F02) y manteniendo mezcla directa en efectos de sonido (F36).
Alineado con `_global/02-architecture-and-structure.md`, `_global/03-conventions.md` (Principio Anti-Parches) y `_global/05-data-model.md`.

## Decisiones Técnicas y de Arquitectura

1. **Gestor Central de Sesión de Audio (`AudioSessionManager`):**
   - Abstracción multiplataforma construida sobre el paquete `audio_session` (o APIs de plataforma encapsuladas).
   - Configura la sesión de audio global en `AVAudioSessionCategory.playback` (iOS) y `AudioAttributes` para asistencia de entrenamiento (Android), permitiendo mezcla (`mixWithOthers`).
2. **Patrón Decorador / Coordinador para TTS (`DuckingTtsEngine` / `AudioSessionCoordinator`):**
   - En lugar de ensuciar `TimerController` o la UI con llamadas a foco de audio, se encapsula la lógica de foco dentro de un `AudioSessionCoordinator` o envolviendo la llamada en `SystemTtsEngine`.
   - Antes de llamar a `_tts.speak(text)`:
     - Consulta la preferencia `music_ducking_enabled` vía `PreferencesRepository`.
     - Si está activa, invoca `AudioSessionManager.activateDucking()`.
     - Inicia un timer de seguridad (`safetyTimer`) de 5 segundos.
   - En los callbacks nativos `setProgressHandler` / `setCompletionHandler` / `setErrorHandler` o al invocar `stop()`:
     - Cancela el timer de seguridad.
     - Invoca `AudioSessionManager.deactivateDucking()` para liberar el foco.
3. **Desacoplamiento con Efectos de Sonido (SFX F36):**
   - `AudioPlayersSfxPlayer` (F36) continúa operando con `PlayerMode.lowLatency` y audio attributes que no solicitan ducking transitorio, garantizando que los pitidos breves no provoquen saltos bruscos en el volumen de la música externa.
4. **Persistencia de Ajustes (`app_preferences`):**
   - Clave `music_ducking_enabled` (`bool`, default `true`) leída reactivamente mediante Riverpod y almacenada en la tabla `app_preferences` de Drift vía `PreferencesRepository`.

## Contratos e Interfaces

### AudioSessionManager
```dart
abstract class AudioSessionManager {
  /// Configura la categoría global de la app para permitir mezcla.
  Future<void> initialize();

  /// Solicita foco transitorio con atenuación de música externa.
  Future<void> activateDucking();

  /// Libera el foco transitorio restaurando el volumen normal.
  Future<void> deactivateDucking();
}
```

### Implementación con audio_session
```dart
class DefaultAudioSessionManager implements AudioSessionManager {
  AudioSession? _session;
  int _activeDuckingCount = 0;

  @override
  Future<void> initialize() async {
    _session = await AudioSession.instance;
    await _session?.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers |
          AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.assistanceNavigationGuidance,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    ));
  }

  @override
  Future<void> activateDucking() async {
    _activeDuckingCount++;
    if (_activeDuckingCount == 1) {
      await _session?.setActive(true);
    }
  }

  @override
  Future<void> deactivateDucking() async {
    if (_activeDuckingCount > 0) {
      _activeDuckingCount--;
    }
    if (_activeDuckingCount == 0) {
      await _session?.setActive(false);
    }
  }
}
```

## Arquitectura de Providers (Riverpod)

```
[PreferencesRepository]
       |
       v
[musicDuckingEnabledProvider] -> StateNotifier/Notifier<bool> (clave: 'music_ducking_enabled')
       |
       +---> [AudioSessionManager]
                   |
                   v
       [SystemTtsEngine (Ducking Wrapper)]
                   |
                   v
         [VoiceAnnouncer / Timer]
```

## Diagrama de Flujo: Anuncio con Ducking y Liberación Segura

```
[Evento de Temporizador: VoiceAnnouncer.announce(text)]
                     |
                     v
       ¿music_ducking_enabled == true?
              /             \
       (Sí)  /               \ (No)
            v                 v
[AudioSessionManager]    [tts.speak(text) directo]
  - Solicita foco ducking      (Mezcla normal)
  - Inicia Fail-safe 5s               |
            |                         |
            v                         |
    [tts.speak(text)]                 |
            |                         |
     +------+------+                  |
     |             |                  |
     v (Fin)       v (Error/Stop/5s)  |
[onCompletion]   [Timer expira / Stop] |
     |             |                  |
     +------+------+                  |
            |                         |
            v                         |
[AudioSessionManager]                 |
  - Libera foco audio                 |
  - Cancela Timer                     |
  - Música externa restaura volumen   v
                     |                |
                     +--------+-------+
                              |
                              v
                        [Fin de flujo]
```

## Riesgos, Mitigaciones y Causa Raíz

1. **Riesgo: El motor nativo de TTS no dispara `onCompletion` (congelamiento de volumen externo):**
   - **Solución Causa Raíz:** Se implementa un contador de seguridad (`safetyTimer` de 5s) por cada solicitud de ducking. Si el motor se cuelga o no emite el evento de fin, el timer expira y libera forzosamente la sesión de audio.
2. **Riesgo: Múltiples anuncios hablados consecutivos (concurrencia):**
   - **Solución Causa Raíz:** `AudioSessionManager` utiliza un contador de referencias (`_activeDuckingCount`). La sesión permanece activa durante toda la secuencia de locuciones y solo se desactiva cuando el contador vuelve a cero.
3. **Riesgo: Excepciones de plataforma en dispositivos sin soporte de ducking:**
   - **Solución Causa Raíz:** Todos los métodos de `AudioSessionManager` capturan errores de plataforma (`PlatformException`) de forma segura, degradando a reproducción directa sin interrumpir la máquina de estados del temporizador.

## Alternativas Descartadas

- **Controlar el volumen de la música externa mediante APIs nativas de reproductor:**
  - *Descartada:* Viola los permisos del sistema operativo y las políticas de privacidad de Android/iOS. El mecanismo oficial y seguro es gestionar el Audio Focus con categoría `duckOthers`.
- **Hacer ducking en cada pitido de SFX (F36):**
  - *Descartada:* La constante fluctuación de volumen en clips de 200 ms arruina la fidelidad de la música de Spotify del usuario.
