# Design: Voz: Cuenta Regresiva y Anuncios

**ID:** F02 &nbsp;|&nbsp; **Slug:** `02-voice-countdown-announcements`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs listados en la seccion Referencias y los contratos
de eventos de F01 (`SessionCompleted`, `SessionCancelled`, estado del timer).

## Referencias

- `_global/01-vision-and-principles.md` — voz como guia manos-libres; offline-first (TTS local).
- `_global/02-architecture-and-structure.md` — carpeta `features/voice/`; Riverpod; sin acoplar UI entre features.
- `_global/03-conventions.md` — Riverpod unico; tests unitarios del dominio de voz.
- `_global/04-design-system.md` — UI de ajustes (toggles, steppers 48dp).
- `_global/05-data-model.md` — `Interval.announceText` + claves de preferencias de voz.
- `features/01-interval-timer-core/design.md` — `TimerController`, timestamps, streams de sesion.

## Decisiones de diseno

### Paquete TTS (verificado pub.dev)

- **`flutter_tts` ^4.2.5** (publisher verificado eyedeadevelopment.com; activo).
- Abstraccion sobre motores nativos: Android `TextToSpeech`, iOS `AVSpeechSynthesizer`.
- APIs usadas en F02:
  - `FlutterTts()` / `speak(String)` / `stop()`
  - `setLanguage(String)` / `isLanguageAvailable`
  - `awaitSpeakCompletion(true)` opcional para cola interna
  - handlers: `setErrorHandler`, `setCompletionHandler`
- **No** usa `getVoices` / `setVoice` en F02 (eso es F07).
- Android: declarar query `TTS_SERVICE` en el manifest (requerido para apps que usan TTS en API 30+).
- minSdk Android del plugin: 21 (compatible con el proyecto si ya esta >= 21).

### Capas y ubicacion de codigo

Segun `_global/02-architecture-and-structure.md`:

```
features/voice/
  application/   → VoiceAnnouncer (Notifier o servicio Riverpod), VoiceSettingsController
  domain/        → TtsEngine (abstract), AnnouncementQueue, resolucion de texto de anuncio
  presentation/  → VoiceSettingsSection (toggle mute, countdownSeconds, announceIntervalName;
                   campo announceText vive en formulario de intervalo F01/F05 reutilizando form)
data/models/     → Interval (+ announceText)
data/local/      → migracion aditiva intervals.announce_text
data/repositories/ → PreferencesRepository (claves de voz) + RoutineRepository (announceText)
```

### Abstraccion para F07 (hook de extension)

```dart
abstract class TtsEngine {
  Future<void> speak(String text);
  Future<void> stop();
  Future<bool> isAvailable();
}

class SystemTtsEngine implements TtsEngine {
  // envuelve flutter_tts; setLanguage desde locale del sistema
}
```

F07 agregara `PremiumTtsEngine` / seleccion de voz sin reescribir `VoiceAnnouncer`.

### Integracion con F01 (contratos observables)

F01 expone hoy `SessionCompleted` / `SessionCancelled`. F02 **necesita** ademas (extender F01 de
forma minima, documentado aqui; implementar en tasks de datos/integracion):

```dart
class IntervalStartedEvent {
  final String intervalId;
  final String name;
  final String? announceText;
  final int durationSeconds;
  final int index; // 0-based en la sesion
}

// Opcional si se prefiere pull en vez de push para ticks:
// VoiceAnnouncer observa remainingMs / status del TimerController via ref.listen
```

**Responsabilidades:**

| Componente | Hace | No hace |
|---|---|---|
| `TimerController` (F01) | Emite `IntervalStartedEvent`; expone `remainingMs`, `status` | No llama a `flutter_tts` |
| `VoiceAnnouncer` (F02) | Escucha eventos/estado; encola/interrumpe; habla via `TtsEngine` | No muta estado del timer |
| UI ajustes | Lee/escribe prefs de voz | No habla directo |

**Reglas de countdown (R2, R10, R12):**

- Fuente de tiempo: `remainingMs` de F01 (timestamps), no un ticker propio de voz.
- Tick hablado cuando `status == running`, `voiceEnabled`, `countdownSeconds > 0`, y
  `ceil(remainingMs / 1000) == S` con `1 <= S <= countdownSeconds`, y `S` no fue ya anunciado
  en el `intervalId` actual (set `spokenSecondsForInterval`).
- Al `IntervalStartedEvent`: reset del set de segundos hablados; si corresponde R1, `stop()` +
  `speak(resolveAnnounceText)`.
- Al `paused` / cancel / complete: `stop()` y limpiar flags segun R13–R14.

### Resolucion de texto de anuncio (R5)

```dart
String resolveAnnounceText(Interval interval) {
  final custom = interval.announceText?.trim();
  if (custom != null && custom.isNotEmpty) return custom;
  return interval.name;
}
```

### Cola / interrupcion (R12)

- Politica F02: **interrupcion prioritaria** para anuncio de inicio de intervalo
  (`stop()` + `speak` nuevo).
- Countdown: como maximo un speak por `S` por intervalo; si el engine sigue hablando un digito y
  llega el siguiente, `stop()` + speak del nuevo digito (preferir actualidad sobre cola larga).
- No usar `setQueueMode` de Android como unica garantia multiplataforma; la cola vive en dominio.

### Modelo de datos

Alineado con `_global/05-data-model.md` (actualizar antes de migrar):

**`Interval` (extension F02):**

- `announceText: String?` — max 80 chars; null = usar `name`.

**Tabla `intervals` (migracion aditiva):**

- `announce_text` TEXT NULL

**Preferencias globales de voz:**

| Clave | Tipo | Default | Rango | Uso |
|---|---|---|---|---|
| `voice_enabled` | bool | `true` | — | Mute in-app (R4) |
| `countdown_seconds` | int | `3` | `0..10` | N de cuenta regresiva (R2, R3) |
| `announce_interval_name` | bool | `true` | — | Toggle anuncio de inicio (R6) |

Persistir via `PreferencesRepository` / `app_preferences` (mismo patron que F35 `prep_seconds`).
Si al implementar F02 el store unificado aun no existe, usar el repositorio de preferencias vigente
del proyecto y unificar cuando F35 este disponible — **semantica de claves estable**.

### Gestion de estado

- **Riverpod** (`Notifier`): `voiceSettingsProvider` (prefs) + `voiceAnnouncerProvider`
  (suscripcion al timer).
- Sin `setState` para negocio de voz.
- UI de configuracion: seccion en ajustes o sheet accesible desde ejecucion/creacion (ubicacion
  exacta de navegacion: F35 shell si existe; si no, pantalla minima bajo `features/voice/presentation`).

### UI

- Toggle "Voz activada" (`voiceEnabled`).
- Stepper / slider entero `countdownSeconds` 0–10 (reutilizar `NumberStepper` de design system si
  existe; si no, control simple >= 48dp).
- Toggle "Anunciar nombre del intervalo".
- En formulario de intervalo (F01): campo opcional "Texto de anuncio" (`announceText`), max 80.

### Plataforma / audio session

- F02: setup minimo de `flutter_tts` (language + volume default 1.0).
- Configuracion iOS avanzada de categoria de audio / ducking → F17.
- Probar R4/R8/R13 en **dispositivo fisico** Android e iOS.

## Diagrama de flujo — F02

```
[TimerController F01]
   |  IntervalStartedEvent
   |  remainingMs + status (listen)
   |  SessionCompleted / SessionCancelled
   v
[VoiceAnnouncer (Riverpod)]
   |  voiceEnabled / countdownSeconds / announceIntervalName (prefs)
   |  resolveAnnounceText(interval)
   |  spokenSecondsForInterval (idempotencia)
   v
[TtsEngine / SystemTtsEngine]
   v
[flutter_tts → motor TTS del SO]
```

## Riesgos y consideraciones

- Emuladores a menudo no tienen engine TTS o idioma instalado → R8 debe ser robusto; QA en fisico.
- Android 11+: sin query `TTS_SERVICE` en manifest, `getLanguages`/speak pueden fallar silenciosamente.
- Condicion de carrera F01 pause-vs-advance (R16 de F01): VoiceAnnouncer debe reaccionar a `status`
  final, no a ticks intermedios inconsistentes.
- Migracion `announce_text` debe ser aditiva (schemaVersion++).
- No bloquear el isolate UI: `speak` es async; errores van a handler, no a uncaught futures.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Assets MP3 pregrabados ("3","2","1") | No escalan a i18n (F28) ni a nombres custom; contradice decision TTS del roadmap. |
| Llamar `flutter_tts` desde `TimerController` | Acopla F01 a audio; rompe limites de features y dificulta F07. |
| Config por rutina en F02 | Ambiguo en requirements originales; se pospone; prefs globales bastan para Fase 0. |
| `audioplayers` + generacion offline | Complejidad innecesaria; F07 premium usara pipeline propio. |
