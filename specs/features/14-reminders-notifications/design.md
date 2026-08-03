# Design: Recordatorios y Notificaciones

**ID:** F14 &nbsp;|&nbsp; **Slug:** `14-reminders-notifications`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F14: hasta 3 recordatorios semanales locales,
permisos al activar, supresion si hay sesion `completed` hoy, copy sin voseo, sin colision con F20.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; no friccion en cold start.
- `_global/02-architecture-and-structure.md` — `features/reminders/`; `lock_screen/` es F20.
- `_global/03-conventions.md` — Riverpod; dominio en ingles; strings UI centralizados.
- `_global/04-design-system.md` — tokens Ajustes; touch >= 48 dp.
- `_global/05-data-model.md` — tabla `reminders` + constantes de canal.
- F04 — `SessionLogRepository` post-complete.
- F20 — `SessionSurfaceConstants` (`channelId`, `notificationId = 888`); **no reutilizar**.

## Decisiones de diseno

### Paquete

- **`flutter_local_notifications`** ya en el proyecto (`^22.0.1` via F20).
- Reutilizar el plugin singleton / inicializacion compartida si existe; **no** second `initialize`
  conflictivo. F14 registra su propio canal y handlers de tap con payload tipo `reminder`.
- Scheduling: zoned schedule / weekly con `timezone` package si el proyecto ya lo usa; si no,
  anadir `timezone` + `flutter_timezone` (o API actual del paquete) en el PR de implementacion y
  verificar pub.dev al codear (no asumir API de memoria en el PR).

### Constantes de superficie F14 (no colisionar F20)

```dart
abstract final class ReminderNotificationConstants {
  static const channelId = 'workout_reminders';
  static const channelName = 'Recordatorios de entrenamiento'; // sin voseo
  static const channelDescription =
      'Avisos para recordar entrenar en los dias configurados.';
  /// Rango de IDs reservado; F20 usa 888 — no usar 888 aqui.
  static const notificationIdBase = 1400; // id = base + stableHash(reminderId) % 100
  static const payloadPrefix = 'reminder:';
}
```

### Persistencia

Tabla drift `reminders` (schema **v10** si F15=v8 y F13=v9 ya aplicados; al implementar respetar
`schemaVersion` real en `database.dart`):

| Columna | Tipo | Notas |
|---|---|---|
| `id` | TEXT PK | UUID v4 |
| `hour` | INTEGER | 0–23 local |
| `minute` | INTEGER | 0–59 |
| `weekdays` | TEXT | encoding estable, ej. JSON `[1,2,3,4,5]` ISO (1=lun … 7=dom) |
| `enabled` | INTEGER | 0/1 |
| `created_at` / `updated_at` | INTEGER | UTC ms |

Max **3** filas enforced en dominio/repositorio (no solo UI).

### Supresion "ya complete hoy"

```
onSessionLogCompleted(localDate):
  if localDate == todayLocal:
    cancelTodaysPendingReminderNotifications()
    // reprogram future occurrences only (plugin-specific)
```

Al **programar** o al **medianoche/reopen** (best effort): si hoy ya tiene completed, no encolar el
slot de hoy.

No contar `aborted`. Query: `SessionLogRepository` hasCompletedOn(localDate).

### Permisos

- Flujo: usuario pone `enabled=true` → request notification permission → si OK schedule; si no,
  dejar enabled=false o enabled=true con flag UI "sin permiso" (preferir **no dejar enabled=true
  enganoso**: si niega, persistir enabled=false + mensaje).
- Android 13+ POST_NOTIFICATIONS; iOS UNUserNotificationCenter.
- Exact alarms (Android 12+): intentar; si falta permiso, inexact + nota UI (R12).

### Copy (UiStrings) — anti-voseo

Todas las cadenas de usuario en `UiStrings` (o equivalente del proyecto), **sin voseo**:

| Key conceptual | Valor ejemplo |
|---|---|
| notif title | `Recordatorio de entrenamiento` |
| notif body | `Hora de entrenar` |
| settings section | `Recordatorios` |
| empty | `No hay recordatorios. Crea uno para recibir avisos.` |
| permission denied | `Sin permiso de notificaciones. Activalo en los ajustes del sistema.` |
| max reached | `Maximo 3 recordatorios.` |
| exact alarm note | `El aviso puede retrasarse unos minutos en este dispositivo.` |

Evitar: "entrená", "creá", "activá", "podés", "tenés", "acordate", "llevás".  
Usar: "Crea", "Activalo", "Hora de entrenar", formas impersonales.

### Deep link / tap

Payload `reminder:<id>` → `go_router` al tab **Temporizador** (ruta home del timer shell).

### Modulo y capas

```
features/reminders/
  domain/
    reminder.dart
    reminder_validator.dart      # max 3, weekdays non-empty, hour/minute
  application/
    reminder_scheduler.dart      # wrap plugin
    reminders_providers.dart
    reminders_controller.dart
  presentation/
    reminders_settings_section.dart
    reminder_edit_sheet.dart
```

Enganche post-sesion: mismo pipeline que F04/F13 (listener tras insert `completed`) llama
`ReminderScheduler.cancelTodayIfNeeded()`.

Settings: componer `RemindersSettingsSection` en la pantalla de Ajustes existente (F35/settings).

### Riverpod

| Provider | Rol |
|---|---|
| `reminderRepositoryProvider` | CRUD drift |
| `remindersListProvider` | watch list |
| `remindersControllerProvider` | create/update/delete/toggle + schedule |
| `notificationPermissionProvider` | estado permiso (refresh on resume) |

### Diagrama de flujo

```
[Ajustes > Recordatorios]
    |
    +--> empty / list (max 3)
    +--> create/edit sheet (hora, L-D, enabled)
    |
    v
[permission if needed]
    |
    +-- denied --> gracia UI; no schedule
    +-- granted --> ReminderScheduler.syncAll(reminders)
                        |
                        v
              [flutter_local_notifications weekly/zoned]
                        |
[Session completed today]
    |
    v
[cancel today's reminder firings; keep future]

[User taps reminder notif]
    |
    v
[Open app -> Timer tab]
```

### Migracion Drift

| Version | Feature | Cambio |
|---|---|---|
| 8 | F15 | body_measurements |
| 9 | F13 | unlocked_achievements |
| **10** | **F14** | reminders |

Si el orden de implementacion en codigo cambia, renumerar en el PR y actualizar `05-data-model.md`.

### Riesgos y consideraciones

| Riesgo | Mitigacion |
|---|---|
| Colision ID con F20 (888) | Rango 1400+; tests de constantes |
| Doble init del plugin | Un solo bootstrap app-level |
| iOS background limits | Best effort; no prometer segundo exacto |
| Usuario completa sesion en otro TZ | `localDate` F04 ya es local device |
| Voseo accidental en copy | Checklist en code review + R6; strings solo en UiStrings |

### Alternativas consideradas

| Alternativa | Por que se descarto |
|---|---|
| WorkManager check en cada fire | Fragil; A (cancel al complete) mas simple |
| Default reminder 18:00 | Spam sin consentimiento |
| Contar aborted como "entreno" | Abort corto no debe silenciar el aviso |
| Entry en Historial | Config pertenece a Ajustes |
| Copy con racha | Scope; F12 acoplamiento UI copy |
| Canal compartido con F20 | Mezcla sesion activa vs habito |

## Modelos

```dart
class Reminder {
  final String id;
  final int hour;          // 0-23
  final int minute;        // 0-59
  final Set<int> weekdays; // 1=Mon .. 7=Sun (ISO)
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```
