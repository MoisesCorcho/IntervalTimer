# Tasks: Integracion de Musica / Audio Ducking

**ID:** F17 &nbsp;|&nbsp; **Slug:** `17-background-music-ducking`

## Definition of Done

- [x] Todos los criterios de aceptación R1 a R11 de `requirements.md` están implementados y verificados.
- [x] Tests unitarios de `AudioSessionManager` y wrapper de TTS pasando al 100%.
- [x] Tests de widget para el toggle de configuración en la pantalla de Ajustes pasando.
- [x] Cumplimiento estricto del Principio Anti-Parches de `_global/03-conventions.md`.
- [x] Preferencia `music_ducking_enabled` documentada en `_global/05-data-model.md`.
- [x] No se rompió ninguna funcionalidad de las features de audio previas (F01, F02, F36).

## Checklist de implementacion

### 1. Dependencias y Persistencia (Data & Infrastructure)
- [x] Agregar dependencia `audio_session` a `pubspec.yaml` si no está presente. _(cubre R1)_
- [x] Agregar clave `music_ducking_enabled` con valor default `true` en `PreferencesRepository` (tabla Drift `app_preferences`). _(cubre R5, R6)_

### 2. Capa de Dominio y Servicios (Domain & Services)
- [x] Definir interfaz `AudioSessionManager` y su implementación `DefaultAudioSessionManager` con configuración de categoría `playback`, `mixWithOthers` y `duckOthers`. _(cubre R1, R2, R3, R10)_
- [x] Implementar contador de referencias para concurrencia de locuciones (`_activeDuckingCount`) en `AudioSessionManager`. _(cubre R11)_
- [x] Integrar `AudioSessionManager` dentro del flujo de locución de `SystemTtsEngine` (o `DuckingTtsEngineDecorator`). _(cubre R2, R3, R6)_
- [x] Implementar mecanismo Fail-safe con `Timer` de 5 segundos para liberación forzosa del foco si TTS no emite callback. _(cubre R8)_
- [x] Implementar liberación inmediata del foco ante invocación de `tts.stop()` (pausa, salto de intervalo, cancelación de sesión). _(cubre R7, R9)_
- [x] Garantizar que `AudioPlayersSfxPlayer` (F36) opere sin solicitar foco de ducking. _(cubre R4)_

### 3. Capa de Aplicación y Estado (Application & State)
- [x] Crear provider `musicDuckingEnabledProvider` en `lib/features/voice/application/voice_settings_providers.dart` (o `features/settings/`). _(cubre R5, R6)_
- [x] Conectar `musicDuckingEnabledProvider` con el wrapper de TTS para habilitar/deshabilitar la solicitud de ducking reactivamente. _(cubre R2, R6)_

### 4. Presentación y Ajustes (Presentation & UI)
- [x] Agregar switch "Atenuar música de fondo" en la pantalla de Ajustes de Audio/Voz (F35 / `SettingsScreen`). _(cubre R5)_

### 5. Tests y Validación (Testing)
- [x] **Unit Tests (Domain & Services):**
  - [x] Test de activación de ducking antes de `speak()` y liberación en `onCompletion` con mock de `AudioSessionManager`. _(cubre R2, R3)_
  - [x] Test de bypass de ducking cuando `music_ducking_enabled == false`. _(cubre R6)_
  - [x] Test de liberación inmediata del foco al invocar `stop()` por pausa/cancelación. _(cubre R7)_
  - [x] Test del temporizador fail-safe (expiración a los 5s libera el foco si no hay callback). _(cubre R8)_
  - [x] Test de concurrencia: múltiples locuciones consecutivas mantienen el foco hasta la última liberación. _(cubre R11)_
  - [x] Test de captura segura de errores de plataforma sin interrumpir el timer. _(cubre R10)_
- [x] **Widget Tests (UI):**
  - [x] Test de visualización y cambio de estado del toggle "Atenuar música de fondo" en Ajustes. _(cubre R5)_
- [x] **Pruebas en Dispositivo Físico (Manual / Smoke):**
  - [x] Verificar atenuación y recuperación de volumen con Spotify / Apple Music en segundo plano en Android e iOS. _(cubre R2, R3, R4)_

## Mapa de trazabilidad

| Criterio EARS | Tareas que lo cubren |
|---|---|
| **R1** (AudioSession global) | Infra (1.1), Domain (2.1) |
| **R2** (Ducking durante TTS) | Domain (2.1, 2.3), App (3.2), Tests (5.1, 5.3) |
| **R3** (Restauración tras TTS) | Domain (2.1, 2.3), Tests (5.1, 5.3) |
| **R4** (SFX sin ducking) | Domain (2.6), Tests (5.3) |
| **R5** (Preferencia Ajustes) | Data (1.2), App (3.1), UI (4.1), Tests (5.2) |
| **R6** (Bypass sin ducking) | Data (1.2), Domain (2.3), App (3.2), Tests (5.1) |
| **R7** (Liberación en pausa/stop) | Domain (2.5), Tests (5.1) |
| **R8** (Fail-safe 5s) | Domain (2.4), Tests (5.1) |
| **R9** (Interrupción del sistema) | Domain (2.5) |
| **R10** (Degradación elegante) | Domain (2.1), Tests (5.1) |
| **R11** (Concurrencia locuciones) | Domain (2.2), Tests (5.1) |

## Notas de secuenciacion

Esta feature depende de: **F01** (Interval Timer Core), **F02** (Voz: Cuenta Regresiva y Anuncios) y **F35** (Navegacion de Secciones, Preparacion y Ajustes).
No iniciar tareas de implementación en código hasta que dichos prerrequisitos estén en estado "Done".
