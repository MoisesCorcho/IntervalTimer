# Design: Efectos de Sonido del Temporizador (SFX)

**ID:** F36 &nbsp;|&nbsp; **Slug:** `36-timer-sound-effects`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F36. El producto necesita beeps/chimes
empaquetados (no TTS) en eventos del timer, configurables por situacion, sin acoplar F01 a
hardware de audio ni mezclar flags con F02/F18.

Antes de implementar: F01 + F35 Done; revisar contratos de estado (`idle` | `preparing` |
`running` | `paused` | `completed`), `IntervalStartedEvent` (o equivalente),
`SessionCompleted` / `SessionCancelled`, `remainingMs`, y tipo de intervalo `IntervalType`.

## Referencias

- `_global/02-architecture-and-structure.md` — `features/<f>/`, shared, data.
- `_global/03-conventions.md` — Riverpod, capas, tests, assets en `pubspec.yaml`.
- `_global/04-design-system.md` — settings UI, steppers 48dp.
- `_global/05-data-model.md` — claves de preferencias SFX (actualizar al implementar).
- `features/01-interval-timer-core/design.md` — timer, `IntervalType`.
- `features/02-voice-countdown-announcements/design.md` — `IntervalStartedEvent`, suscripcion desacoplada.
- `features/18-vibration-feedback/design.md` — espejo de gates, N countdown, idempotencia.
- `features/35-timer-navigation-prep-settings/design.md` — `preparing`, shell settings.
- `assets/sfx/ATTRIBUTION.md` — mapa id ↔ archivo ↔ Freesound.

## Arquitectura / enfoque

### Modulo

```
lib/features/sound_effects/
  application/     # SoundEffectsSettingsNotifier, SoundEffectsController
  domain/          # SfxSlot, SfxCatalog, SoundEffectsSettings (pure)
  data/            # AssetSfxCatalog (paths), opcional
  presentation/    # SoundEffectsSettingsSection (+ picker/preview widgets)
```

Espejo de `features/vibration/` y desacople de `features/voice/`.

Assets (ya en repo; declarar en `pubspec.yaml`):

```
assets/sfx/default/     # factory defaults (*_01)
assets/sfx/catalog/     # variantes seleccionables (*_02+)
assets/sfx/ATTRIBUTION.md
```

Declaracion recomendada:

```yaml
flutter:
  assets:
    - assets/sfx/default/
    - assets/sfx/catalog/
```

(o listado explicito por archivo si se prefiere control fino).

### Capas y responsabilidades

| Componente | Hace | No hace |
|---|---|---|
| `TimerController` (F01/F35) | Emite eventos/estado; expone `remainingMs`, `status`, intervalo actual (`type`, id) | No llama al player de SFX |
| `SfxCatalog` | Lista de `SfxEntry { id, assetPath, suggestedSlots[] }` | No reproduce ni lee prefs |
| `SoundEffectsSettings` / repo prefs | Master, toggles, N, soundId por slot | No conoce el timer |
| `SoundEffectsController` | Escucha timer; aplica gates; pide play one-shot | No muta estado del timer ni prefs de voz/vibe |
| `SfxPlayer` / driver | `play(assetPath)` one-shot; errores → no-op (R12) | No decide *cuándo* tocar |
| UI Settings | Lee/escribe prefs; preview via player | No suscribe al timer para logica de sesion |

### Plugin de audio

- Preferir un player de **one-shots** cortos (evaluar `audioplayers` o `just_audio` al implementar; un solo player reentrante o pool de 1–2 instancias).
- Modo: mezcla con otras apps por defecto (no robar audio focus de forma agresiva en v1); F17 refinara ducking/session.
- Cargar desde `AssetSource` / path de Flutter assets; sin red.

### Eventos y reglas de disparo

Reutilizar el mismo espiritu que F18:

**Inicio de intervalo (R1/R2)**

- Fuente: `IntervalStartedEvent` (o primer frame del nuevo `intervalId` en `running`).
- Resolver slot:
  - `type == rest` → `rest_start`
  - else → `work_start`
- Gate: `soundEnabled` && toggle del slot && status coherente con inicio en `running`.
- No re-disparar al resume del mismo intervalo (R17).

**Session complete (R3)**

- Fuente: `SessionCompleted` una vez.
- Gate: master + `soundOnSessionComplete`.
- No en `SessionCancelled` (R18).

**Prep ticks (R4)**

- Fuente: `remainingMs` de preparacion + `status == preparing` (no paused).
- Condicion: `ceil(remainingMs/1000) == S` con `S >= 1`, no emitido antes en esta prep.
- Set de idempotencia: `prepTickedSeconds` (se limpia al salir de preparing / cancel / nuevo start).

**Phase warning (R5)**

- Fuente: `remainingMs` del intervalo + `status == running`.
- Condicion: `ceil(remainingMs/1000) == S` con `1 <= S <= soundCountdownSeconds`, no emitido en este `intervalId`.
- Set: `warnedSecondsForInterval` (reset en `IntervalStartedEvent`).

**Pausa / cancel / complete**

- `paused`: no nuevos SFX de sesion (R17).
- `SessionCancelled`: limpiar sets; no R3 (R18).
- `SessionCompleted`: permitir R3; luego no mas R1/R2/R4/R5 (R16).

### Catalogo y slots

```dart
enum SfxSlot {
  workStart,
  restStart,
  sessionComplete,
  prepTick,
  phaseWarning,
}

class SfxEntry {
  final String id;        // p.ej. sfx_work_start_01
  final String assetPath; // assets/sfx/default/sfx_work_start_01.mp3
  final Set<SfxSlot> suggestedFor; // filtro UX opcional en picker
}
```

**Defaults de fabrica (IDs):**

| Slot | soundId default | Archivo |
|---|---|---|
| `work_start` | `sfx_work_start_01` | `assets/sfx/default/sfx_work_start_01.mp3` |
| `rest_start` | `sfx_rest_start_01` | `assets/sfx/default/sfx_rest_start_01.wav` |
| `session_complete` | `sfx_session_complete_01` | `assets/sfx/default/sfx_session_complete_01.wav` |
| `prep_tick` | `sfx_tick_01` | `assets/sfx/default/sfx_tick_01.wav` |
| `phase_warning` | `sfx_tick_01` | mismo archivo (path unico; dos prefs de id) |

El picker puede mostrar **todo** el catalogo unificado (default + catalog) o filtrar por
`suggestedFor`; en ambos casos el usuario puede asignar cualquier id a cualquier slot (R9).
Si id invalido → fallback al default del slot (R14).

### Modelo de datos / preferencias

Sin tablas drift nuevas. Preferencias globales (actualizar `_global/05-data-model.md`):

| Clave | Tipo | Default | Rango / valores | Uso |
|---|---|---|---|---|
| `sound_enabled` | bool | `true` | — | Master SFX (R7) |
| `sound_on_work_start` | bool | `true` | — | Toggle R1 |
| `sound_on_rest_start` | bool | `true` | — | Toggle R2 |
| `sound_on_session_complete` | bool | `true` | — | Toggle R3 |
| `sound_on_prep_tick` | bool | `true` | — | Toggle R4 |
| `sound_on_phase_warning` | bool | `true` | — | Toggle R5 |
| `sound_countdown_seconds` | int | `3` | `0..10` | Ventana N de R5/R6 |
| `sound_id_work_start` | string | `sfx_work_start_01` | id de catalogo | Clip R1 |
| `sound_id_rest_start` | string | `sfx_rest_start_01` | id de catalogo | Clip R2 |
| `sound_id_session_complete` | string | `sfx_session_complete_01` | id de catalogo | Clip R3 |
| `sound_id_prep_tick` | string | `sfx_tick_01` | id de catalogo | Clip R4 |
| `sound_id_phase_warning` | string | `sfx_tick_01` | id de catalogo | Clip R5 |

**Independencia:** no reutilizar `voice_*`, `vibration_*`, ni `countdown_seconds` de F02.

### Gestion de estado

- Riverpod: `soundEffectsSettingsProvider` (prefs) + `soundEffectsControllerProvider`
  (suscripcion al timer; dependiente de settings).
- Catalogo: provider sync/const o `FutureProvider` si se carga de asset manifest; preferible
  catalogo estatico generado/hardcodeado alineado a `ATTRIBUTION.md` para tests deterministas.
- Preview: metodo `preview(SfxEntry)` / `previewSlot(SfxSlot)` en player o controller de
  settings (sin pasar por gates de sesion, salvo master opcional: **recomendar** que preview
  funcione aunque master este off solo en pantalla de settings, o respete master — elegir al
  implementar y documentar en UI; default de producto: **preview siempre disponible en
  Settings** para poder elegir clips con master off).

### UI (Settings)

Seccion “Efectos de sonido” en shell `features/settings/` (F35):

1. Toggle master “Efectos de sonido”.
2. Toggles granulares (deshabilitados visualmente si master off).
3. `NumberStepper` 0–10 para `soundCountdownSeconds` (reutilizar shared; deshabilitar si master
   off o toggle phase warning off).
4. Por cada slot: fila con nombre del evento + clip actual + accion “Cambiar” / “Probar”.
5. Picker: lista de clips (nombre amigable o id) + preview al seleccionar o boton play.
6. Areas de toque >= 48dp; textos via convenciones i18n si F28 aplica; si no, strings locales
   consistentes con el resto de Settings.

### Diagrama de flujo

```
[TimerController F01/F35]
   |  IntervalStartedEvent (intervalId, type, ...)
   |  remainingMs + status (running | preparing | paused | ...)
   |  SessionCompleted / SessionCancelled
   v
[SoundEffectsController]
   |  sound_enabled + toggles + countdown_seconds + sound_id_* (prefs)
   |  SfxCatalog.resolve(id) → assetPath
   |  prepTickedSeconds / warnedSecondsForInterval (idempotencia)
   v
[SfxPlayer]
   |  play one-shot asset  --error--> no-op (R12)
   v
[OS audio / speakers]
```

## Riesgos y consideraciones

- **Tamano del binario:** ~25–30 clips cortos; aceptable. Evitar WAV enormes; MP3 preferible a
  futuro si se reexporta.
- **Latencia:** one-shots cortos; precargar defaults al inicio de sesion es opcional (nice-to-have).
- **Solape TTS + SFX:** intencional en v1 (R20); no silenciar SFX cuando habla F02.
- **Solape work_start + phase_warning del intervalo anterior:** no aplica; warning es del
  intervalo actual; al advance se resetea set y suena start del nuevo.
- **Doble sensacion prep “1” + work_start:** esperado; no anadir tercer “go”.
- **Audio focus / ducking:** v1 simple; documentar follow-up F17 para bajar musica externa tambien
  ante SFX.
- **Tests:** mock `SfxPlayer`; no depender de audio real en CI.
- **pubspec:** olvidar declarar assets → R12 en runtime; task explicita de registro.

## Alternativas consideradas

| Alternativa | Motivo de descarte |
|---|---|
| Meter SFX en F02 | F02 es TTS-only y excluye assets pregrabados. |
| Meter SFX en F18 | F18 es haptics; patrones no son audio ni catalogo de clips. |
| Un solo toggle sin granulares | No permite apagar solo ticks molestos. |
| Compartir N con F02 o F18 | Acopla producto; el usuario puede querer N distintos. |
| Un solo slot tick+warning | Impide elegir clips distintos despues; defaults iguales bastan. |
| Volumen SFX en v1 | Scope; el volumen del sistema alcanza. |
| SFX en pause/resume | Feedback ya cubierto por vibracion/UI; ruido extra. |
| Packs remotos / Pro | Fuera de v1; catalogo empaquetado suficiente. |
| Llamar player desde `TimerController` | Acopla F01 a audio; rompe limites de features. |

## Nota F17 (ducking)

Cuando se implemente F17, el session/category de audio y el ducking ante “app speech/SFX”
deben contemplar reproducciones de `SfxPlayer`, no solo TTS. F36 no implementa ducking.
