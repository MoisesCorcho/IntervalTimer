# Design: Widget de Pantalla de Bloqueo / Notificacion Persistente

**ID:** F20 &nbsp;|&nbsp; **Slug:** `20-lock-screen-widget`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar los steering docs en Referencias, los contratos de F01
(`TimerController`, `SessionCompleted`, `SessionCancelled`, skip/pause) y la politica de
lifecycle de F19 (screen wakelock ≠ notificacion de sesion).

**Fases internas de implementacion:**

| Fase | Plataforma | Entregable |
|---|---|---|
| **A (MVP)** | Android | Foreground service + notificacion ongoing con acciones |
| **B** | iOS 16.1+ | Live Activities (ActivityKit) + degradacion iOS < 16.1 |

## Referencias

- `_global/01-vision-and-principles.md` — cero friccion; app killed → sesion descartada.
- `_global/02-architecture-and-structure.md` — `features/lock_screen/`; sin acoplar UI entre features.
- `_global/03-conventions.md` — Riverpod; tests de controllers/mappers.
- `_global/04-design-system.md` — tile de ajustes.
- `_global/05-data-model.md` — `session_lock_screen_enabled`.
- `features/01-interval-timer-core/design.md` — fuente de verdad del timer.
- `features/19-always-on-screen/design.md` — wakelock solo en host de ejecucion.
- `features/14-reminders-notifications/` — canales de recordatorio (no reutilizar IDs).

## Decisiones de diseno

### Paquetes (verificados pub.dev)

#### Android / notificaciones compartidas

| Paquete | Version de referencia | Uso en F20 |
|---|---|---|
| `flutter_local_notifications` | estable actual en pub.dev | Postear/actualizar/cancelar notificacion; actions; MediaStyle opcional; permisos Android 13+ |
| `flutter_background_service` | **5.1.0** (maseka.dev) | Foreground service Android; isolate de servicio; `invoke` / `on` para mensajes UI↔service |

**Notas `flutter_local_notifications`:**

- Soporta actions en Android e iOS 10+; callbacks en main isolate o background isolate segun
  configuracion (`showsUserInterface` / opciones Darwin).
- Estilo **Media**: disponible; **no** soporta `MediaSession.Token` real — sirve para layout
  tipo media (artwork/largeIcon), no para un MediaSession de audio completo.
- Requiere canal Android con `importance` adecuada; para FGS ongoing suele usarse low/default
  con `ongoing: true` y `category: Category.service` / `Category.workout` si aplica.

**Notas `flutter_background_service`:**

- Android 14+ exige `foregroundServiceType` en manifest + permiso `FOREGROUND_SERVICE_*`
  correspondiente. Elegir el tipo **menos privilegiado** aceptable para un timer de
  entrenamiento (candidatos a evaluar en implementacion: `specialUse` con justificacion en
  Play Console, u otro tipo permitido por politicas vigentes de Google Play). Documentar el
  tipo final en este design al pinnear.
- Comunicacion UI isolate ↔ service isolate: `FlutterBackgroundService().invoke` /
  `service.on(...)` — **no** compartir referencias de Riverpod entre isolates.
- `autoStart: false` recomendado: el servicio se inicia al entrar en sesion activa (R1), no en
  cada cold start de la app.
- `@pragma('vm:entry-point')` obligatorio en `onStart` para release.
- iOS de este plugin **no** ofrece un long-running service equivalente a Android (FAQ oficial);
  por eso la fase B usa Live Activities, no `flutter_background_service` como solucion iOS.

#### iOS Live Activities (fase B)

| Paquete | Version de referencia | Uso |
|---|---|---|
| `live_activities` | **2.4.9** (pub.dev) | ActivityKit + Dynamic Island; requiere Widget Extension nativo Swift y App Groups |

Alternativas descartadas o de menor preferencia: `flutter_live_activities`,
`live_activities_flutter` (menos traccion / API distinta). Si el pin de `live_activities`
falla por SDK, re-evaluar en implementacion y actualizar este design.

**Requisitos nativos iOS (fase B):**

- Extension WidgetKit + ActivityAttributes en Swift.
- App Group compartido para payload de estado.
- App Intents / deep links para acciones pause/skip si se exponen en la Live Activity.
- Deployment target minimo alineado a iOS 16.1 para ActivityKit; degradacion < 16.1 (R12).

### Capas y ubicacion de codigo

Segun `_global/02-architecture-and-structure.md`:

```
features/lock_screen/
  application/   → SessionLockScreenController, SessionNotificationMapper,
                   LockScreenSettingsController
  domain/        → SessionSurfacePolicy (pure), SessionRemoteAction (enum),
                   SessionNotificationSnapshot
  presentation/  → SessionLockScreenSettingsTile
  # android entrypoints / iOS bridge viven en application o en
  # android/ / ios/ segun el plugin (documentar paths reales en PR)
data/repositories/ → PreferencesRepository (session_lock_screen_enabled)
```

`TimerController` (F01) **no** importa plugins de notificacion ni background service.
F20 se suscribe a estado/eventos F01 y **despacha** comandos (`pause`, `resume`, `skip`)
hacia la API publica del timer (metodos del controller / use-cases), nunca mutando estado
interno del timer desde el isolate de servicio sin pasar por el contrato definido.

### Modelo de dominio (testeable)

```dart
enum SessionRemoteAction { pause, resume, skip, openApp }

class SessionNotificationSnapshot {
  final String status; // preparing | running | paused
  final String title;  // nombre intervalo o "Preparacion"
  final int remainingMs;
  final bool showPause;   // true si running
  final bool showResume;  // true si paused
  final bool showSkip;
}

/// ¿Debe existir superficie externa?
bool shouldShowSessionSurface({
  required String sessionStatus,
  required bool sessionLockScreenEnabled,
  required bool notificationPermissionGranted,
}) {
  if (!sessionLockScreenEnabled) return false;
  if (!notificationPermissionGranted) return false; // iOS Live Activity puede tener gate propio
  return sessionStatus == 'running'
      || sessionStatus == 'paused'
      || sessionStatus == 'preparing';
}
```

Mapper puro: `TimerState → SessionNotificationSnapshot` (titulo, remaining formateado mm:ss,
flags de botones). Unit-testable sin plugins.

### Contratos con F01

| Direccion | Mecanismo | Payload |
|---|---|---|
| F01 → F20 | `ref.listen` / stream de status + remainingMs + eventos completed/cancelled | estado actual |
| F20 → F01 | Llamadas a API de `TimerController` (`pause`, `resume`, `skip`) en el isolate UI | `SessionRemoteAction` |
| Service isolate → UI (Android) | `invoke('remote_action', {action})` | action string |
| UI → Service isolate | `invoke('sync_snapshot', snapshotMap)` o update via `flutter_local_notifications.show` desde UI si el FGS solo mantiene el proceso vivo | snapshot |

**Estrategia recomendada (Android fase A):**

1. UI isolate es **owner** del estado F01 (Riverpod).
2. Al iniciar sesion activa con pref on: pedir permiso si falta → `startService` FGS → postear
   notificacion ongoing (id fijo, ej. `888` o constante `kSessionNotificationId`).
3. Cada tick de presentacion (~1s) o cambio de estado: `show()` con mismo id (update in-place).
4. Actions de notificacion: callback → mapear a `SessionRemoteAction` → invocar F01 en UI
   isolate (o via bridge del background service hacia el main isolate).
5. Al complete/cancel/idle/pref off: cancel notification + `stopService`.

Evitar duplicar un segundo reloj en el service isolate. Si el UI isolate es suspendido, el FGS
mantiene el proceso; el remaining se recalcula desde timestamps F01 al reanudar (F01 R5).

### Permisos y manifest (Android)

```xml
<!-- Esquema orientativo; ajustar al FGS type final -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<!-- o el FOREGROUND_SERVICE_* que corresponda al type elegido -->

<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:foregroundServiceType="specialUse"
    android:exported="false" />
```

Solicitar `POST_NOTIFICATIONS` en runtime (API 33+) la primera vez que R1 lo necesita.

### Canales (aislamiento F14)

| Uso | Channel id sugerido | Importancia |
|---|---|---|
| Sesion F20 | `session_timer_ongoing` | low/default + ongoing |
| Recordatorios F14 | `workout_reminders` (u otro; lo define F14) | default/high |

IDs de notificacion numericos **no** deben colisionar entre F14 y F20.

### Preferencias

Sin tablas drift nuevas:

| Clave | Tipo | Default | Uso |
|---|---|---|---|
| `session_lock_screen_enabled` | bool | `true` | Master on/off superficie de sesion (R9, R10) |

Store: `PreferencesRepository` / `app_preferences` (mismo patron F02/F18/F19).

### Gestion de estado

- **Riverpod** `Notifier`s:
  - `sessionLockScreenSettingsProvider`
  - `sessionLockScreenControllerProvider` (orquesta show/update/hide + permisos)
- Sin `setState` para la politica de superficie.
- Settings tile en shell `features/settings/` si existe.

### UI de ajustes

- Toggle "Controles en pantalla de bloqueo" / "Notificacion de sesion" (`sessionLockScreenEnabled`).
- Si permiso denegado: texto de ayuda + boton "Abrir ajustes del sistema" (R14).
- Area de toque >= 48dp.

## Diagrama de flujo — F20 (fase A Android)

```
[TimerController F01]
   |  status, remainingMs
   |  SessionCompleted / SessionCancelled
   v
[SessionLockScreenController]
   |  session_lock_screen_enabled + permission
   |  SessionSurfacePolicy.shouldShow...
   |  SessionNotificationMapper → snapshot
   +-- start/stop FlutterBackgroundService (FGS)
   +-- flutter_local_notifications.show/cancel (id fijo)
   |
   |  user action (pause|resume|skip|open)
   v
[TimerController API]  ←── no mutar estado interno desde plugins
```

## Diagrama de flujo — F20 (fase B iOS)

```
[SessionLockScreenController]
   |  snapshot
   v
[live_activities / ActivityKit bridge]
   |  App Group payload
   v
[Lock screen + Dynamic Island UI (Swift extension)]
   |  App Intent / URL action
   v
[SessionRemoteAction → TimerController]
```

## Riesgos y consideraciones

- **Politicas Google Play FGS:** el tipo de foreground service incorrecto puede causar rechazo
  en Play Console. Validar tipo y declaracion `property` specialUse si aplica **antes** de
  release.
- **Aislamiento de isolates:** no usar providers Riverpod dentro de `onStart` del background
  service sin bootstrap; preferir mensajes y owner de estado en UI isolate.
- **Bateria / OEMs agresivos:** algunos OEMs matan FGS; R15 + documentar en QA.
- **iOS:** sin Live Activity, no hay paridad real de lock screen; comunicar degradacion.
- **App killed:** no prometer resume; limpiar lo que el SO permita (R16).
- **Colision F14:** canales e IDs distintos desde el dia 1.
- **No reimplementar tiempo:** cualquier drift de notificacion vs app se corrige releyendo
  timestamps F01, no "adelantando" un tick local del service.
- **F19:** al background, wakelock off; F20 no debe llamar `WakelockPlus.enable` global.

## Alternativas consideradas

| Alternativa | Motivo de descarte / aplazamiento |
|---|---|
| Solo `flutter_local_notifications` sin FGS en Android | El SO puede matar el proceso en background; AC R8 exige FGS. |
| `awesome_notifications` | Incompatible con otros plugins de notificacion; mas peso; F14 puede usar FLN. |
| MediaSession real + audio silencioso | Hack frágil; no necesario si actions de notificacion bastan. |
| `flutter_background_service` como solucion iOS | El propio paquete documenta que iOS no mantiene long-running service como Android. |
| Home screen widget | Fuera de alcance del slug; otro producto. |
| Cancelar desde notificacion | Riesgo de taps accidentales; solo in-app en v1. |
| Resume de sesion tras kill | Contradice politica global v1 de vision; futuro opcional. |
