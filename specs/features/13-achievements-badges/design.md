# Design: Logros y Badges

**ID:** F13 &nbsp;|&nbsp; **Slug:** `13-achievements-badges`

## Contexto

Diseno tecnico para cumplir `requirements.md` de F13: catalogo estatico de logros, evaluacion tras
sesion completada, persistencia inmutable de unlocks, UI de coleccion en Historial, notificacion
multi-unlock compatible con F16.

## Referencias

- `_global/01-vision-and-principles.md` — offline-first; no friccion.
- `_global/02-architecture-and-structure.md` — `features/achievements/`; evento `SessionCompletedEvent`.
- `_global/03-conventions.md` — Riverpod; dominio en ingles; `UiStrings` para copy.
- `_global/04-design-system.md` — tokens; touch >= 48 dp.
- `_global/05-data-model.md` — `UnlockedAchievement`; sin tabla de catalogo.
- F12 `design.md` — `StatsService` racha y agregaciones.
- F04 — `SessionLogRepository`.
- F16 — `session_summary` post-complete UI.

## Decisiones de diseno

### Catalogo estatico (no tabla Drift)

```dart
enum AchievementMetricKind { completedSessionCount, currentStreakDays, completedTotalMinutes }

class AchievementDef {
  final String id;                    // estable: first_session, sessions_10, ...
  final String titleKey;              // o title ES en UiStrings
  final String descriptionKey;
  final IconData icon;                // Material
  final AchievementMetricKind kind;
  final int threshold;
}
```

Lista const en `features/achievements/domain/achievement_catalog.dart` (12 entradas R1).

Progreso UI:

| kind | current | target |
|---|---|---|
| completedSessionCount | count completed logs | threshold |
| currentStreakDays | StatsService streak | threshold |
| completedTotalMinutes | floor(sum duration completed / 60) | threshold |

### Persistencia — solo unlocks

Tabla `unlocked_achievements` (schema **v9** si F15 ya aplico v8; ver nota de migracion):

| Columna | Tipo | Notas |
|---|---|---|
| `achievement_id` | TEXT PK | id del catalogo |
| `unlocked_at` | INTEGER NOT NULL | UTC ms; **inmutable** tras insert |

Sin soft-delete. Insert ignore / unique conflict = no-op (idempotencia R11).

### AchievementEvaluator (dominio puro + repo)

```
evaluate(logs, unlockedIds, {now}) -> List<AchievementDef> newlyUnlocked
```

1. Calcular metricas desde `logs` (conteos/minutos solo `completed`; racha via `StatsService` / shared).
2. Para cada def del catalogo no en `unlockedIds`, si `metric >= threshold` → candidato.
3. Persist layer inserta candidatos; devuelve los que se insertaron OK.

**Trigger:** tras insert exitoso de `SessionLog` `completed` (mismo pipeline que F04 escucha
`SessionCompletedEvent`). Preferir:

- listener en application layer de achievements que reacciona al stream/evento post-persist, **o**
- llamada explicita desde el orquestador que ya guarda el log (F04/F16 path).

No acoplar widgets del timer a achievements; providers/streams.

### Coexistencia F16

Orden sugerido post-complete:

```
SessionCompleted
  -> F04 insert SessionLog
  -> F13 evaluate + persist unlocks (silent)
  -> F16 muestra pantalla fin de sesion
       -> si newlyUnlocked no vacio: chip/seccion "N logros" en sheet F16
       -> al "Listo" o CTA: opcional AchievementsUnlockedSheet si no se mostro detalle
```

Si F16 no monta chip, `AchievementsUnlockedSheet` al dismiss de F16 o en el path sin F16.

Contrato delgado:

```dart
// provider o callback
List<UnlockedAchievementView> pendingCelebrationUnlocks;
void clearPendingCelebrationUnlocks();
```

F16 **opcionalmente** observa ese provider; achievements no importa UI de F16.

### Modulo y capas

```
features/achievements/
  domain/
    achievement_def.dart
    achievement_catalog.dart
    achievement_evaluator.dart
    unlocked_achievement.dart
  application/
    achievements_providers.dart
    achievements_controller.dart   # evaluateAfterCompletedSession, watch progress
  presentation/
    achievements_screen.dart
    achievement_tile.dart
    achievements_entry_tile.dart   # en Historial
    achievements_unlocked_sheet.dart
```

`HistoryScreen` compone `AchievementsEntryTile` (cerca de progreso F12 / debajo de F15 peso si existe).

Orden scroll Historial (con F15 specs en esta rama):

```
1. Chrome mes F04
2. ProgressSummarySection F12
3. BodyWeightSection F15 (si implementado)
4. AchievementsEntryTile F13
5. Calendario F04
6. Lista del dia F04
```

### Riverpod

| Provider | Rol |
|---|---|
| `achievementCatalogProvider` | lista const |
| `unlockedAchievementsProvider` | stream/watch tabla |
| `achievementProgressProvider` | lista UI: def + progress + unlocked? |
| `pendingUnlockCelebrationProvider` | recien desbloqueados para F16/sheet |
| `achievementsControllerProvider` | evaluate + clear celebration |

### Diagrama de flujo

```
[SessionCompletedEvent]
        |
        v
[SessionLogRepository.insert completed]
        |
        v
[AchievementEvaluator.evaluate]
        |
        +--> insert UnlockedAchievement (ignore duplicates)
        +--> set pendingCelebration
        |
        v
[F16 Session complete UI]
        |
        +--> muestra chip si pending no vacio
        |
[Usuario Listo / path sin F16]
        |
        v
[AchievementsUnlockedSheet si hay pending]
        |
        v
[clear pending]

[Historial -> AchievementsScreen]
        |
        v
[progress desde logs + unlocked; nunca revoca]
```

### Migracion Drift

| Version | Feature | Cambio |
|---|---|---|
| 7 | actual codigo | — |
| 8 | F15 | `body_measurements` |
| **9** | **F13** | `unlocked_achievements` |

Si F13 se implementara **antes** que F15 en codigo, la tabla de unlocks puede ser v8 y F15 v9; al
implementar en esta rama, **respetar el schemaVersion real en `database.dart`** y documentar el
bump en `05-data-model.md` en el mismo PR de codigo. Specs asumen **F15 v8 → F13 v9** por orden de
correccion en la rama.

### Riesgos y consideraciones

| Riesgo | Mitigacion |
|---|---|
| Racha distinta a F12 | Reutilizar `StatsService` / funcion compartida; tests compartidos de racha |
| Evaluar antes de insert log | Siempre evaluate **despues** de persist completed |
| Spam UI con F16 | Un sheet; chip opcional; no N dialogs |
| Borrar historial | Unlocks quedan; progreso de pendientes baja; tests R6 |
| Catalogo crece en updates | ids estables; nuevos ids solo se evaluan a futuro |

### Alternativas consideradas

| Alternativa | Por que se descarto |
|---|---|
| Catalogo en JSON remoto | Offline-first; sin red |
| Logros HIIT / preset | F03 no listo; SessionLog sin categoria |
| Contar aborted como sesion | Debilita significado de "sesiones" |
| Tab Logros en bottom nav | Shell 4 tabs; F12/F15 ya rechazaron 5.º |
| Revocar al borrar logs | Viola motivacion y AC de inmutabilidad |
| UserProfileService-style generico | No aplica; dominio achievements acotado |

## Modelos

```dart
class UnlockedAchievement {
  final String achievementId;
  final DateTime unlockedAt;
}

class AchievementProgressView {
  final AchievementDef def;
  final int current;
  final int target;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}
```
