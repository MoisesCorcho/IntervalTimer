# Design: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

La app ya cuenta con:
- `AppTheme.light()` en `lib/core/theme/app_theme.dart` (tokens de spacing, radius, button, interval colors).
- `PreferencesRepository` en `lib/data/repositories/preferences_repository.dart` (Drift `app_preferences`, patron get/set generico).
- `SettingsController` (AsyncNotifier) + `SettingsRepository` + `AppSettings` en `features/settings/`.
- `SettingsScreen` con controles de prep / voz / vibracion / always-on / lock screen.
- `App` widget en `lib/app/app.dart` con `MaterialApp.router`.

## Decisiones de diseno

### D1 — Persistencia via Drift `app_preferences` (criterio R3)

Agregar una clave `theme_mode` al store existente en `PreferencesRepository` (mismo patron que `prep_seconds`).
Valores almacenados como string: `"light"`, `"dark"`, `"system"` (default).

No se agrega tabla nueva — se reutiliza `app_preferences` (schema v4 existente, sin migracion).

**Pureza de capas:** `PreferencesRepository` solo lee/escribe **string** (sin import de Flutter). El mapeo a dominio ocurre en settings.

### D2 — Dominio `AppThemeMode` + Riverpod (criterio R2, R5)

- Enum de dominio puro `AppThemeMode { light, dark, system }` en `features/settings/domain/app_theme_mode.dart` (sin Flutter).
- `AppSettings.themeMode` es `AppThemeMode` (domain puro; sin `package:flutter`).
- `SettingsRepository` mapea string ↔ `AppThemeMode` (`fromStorage` / `storageValue`).
- `SettingsController` expone `Future<void> setThemeMode(AppThemeMode)`.
- `App` widget mapea `AppThemeMode` → Flutter `ThemeMode` solo al pasar `themeMode:` a `MaterialApp.router`.
- `SettingsScreen` usa `SegmentedButton<AppThemeMode>` (presentacion puede usar Flutter UI, pero el valor es de dominio).

Flutter maneja automaticamente el seguimiento del tema del sistema cuando `themeMode == ThemeMode.system`, sin necesidad de `WidgetsBindingObserver`.

### D3 — Tema oscuro con ColorScheme de Material 3 (criterio R6, R8)

Agregar `AppTheme.dark()` en `app_theme.dart`:

```
ColorScheme.fromSeed(
  seedColor: Color(0xFF4CAF50),  // mismo seed que light
  brightness: Brightness.dark,
)
```

Los tokens de spacing, radius, button son independientes del tema (no cambian).
Los colores de intervalo (warmup, work, rest, stretch) son fijos por tipo — no cambian entre temas.
Sombra de botones: `buttonOuterShadow` (light) + `buttonOuterShadowDark` (white-tint); helper `buttonShadowFor(context)`.

### D4 — Selector de tema en SettingsScreen (criterio R1)

Agregar un `SegmentedButton<AppThemeMode>` (Material 3) con tres opciones: Claro / Oscuro / Seguir sistema.
Posicion: encima del control de `prepSeconds` existente.
Copy: `UiStrings.themeSystem = 'Seguir sistema'` (alineado a R1).

### D5 — Contraste dinamico en dark mode (criterio R7)

`contrastTextColor` ya recibe el color de fondo del intervalo y calcula blanco/negro.
En dark mode, el fondo de pantalla cambia (surface oscuro), pero el color de intervalo sigue siendo el mismo.
La funcion no necesita cambios — el contraste se recalcula al rebuild del widget cuando cambia el tema.

Verificar en `timer_execution_screen.dart` que el texto/nombre del intervalo use `contrastTextColor(interval.color)` y no un color fijo.

### D6 — Excepcion R8: export share F16 (criterio R8)

El chrome in-app debe usar theme tokens. Las plantillas / arte de export share (F16 — `session_share_studio`, share card templates) pueden conservar paleta de marca fija en el **bitmap exportado**, para que la imagen compartida sea estable y no cambie con el tema del dispositivo. Documentado en requirements R8.

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/core/theme/app_theme.dart` | `static ThemeData dark()`, sombras dark, `buttonShadowFor` |
| `lib/features/settings/domain/app_theme_mode.dart` | Enum puro `AppThemeMode` + fromStorage |
| `lib/data/repositories/preferences_repository.dart` | `themeModeKey`, get/set **string** (sin Flutter) |
| `lib/features/settings/domain/app_settings.dart` | Campo `AppThemeMode themeMode` (sin Flutter) |
| `lib/features/settings/data/settings_repository.dart` | get/set `AppThemeMode` |
| `lib/features/settings/application/settings_controller.dart` | `setThemeMode(AppThemeMode)` |
| `lib/features/settings/presentation/settings_screen.dart` | `SegmentedButton<AppThemeMode>` |
| `lib/app/app.dart` | `darkTheme: AppTheme.dark()`, map `AppThemeMode` → `ThemeMode` |
| `lib/core/constants/ui_strings.dart` | Labels de tema (incl. "Seguir sistema") |

## Diagrama de flujo

```
Usuario abre Ajustes
        |
        v
SegmentedButton (Claro / Oscuro / Seguir sistema)
        |
        v
SettingsController.setThemeMode(AppThemeMode.dark)
        |
        +---> SettingsRepository → PreferencesRepository.setThemeMode("dark")
        |         |
        |         v
        |     Drift app_preferences (key: "theme_mode", value: "dark")
        |
        +---> state = AsyncData(AppSettings(..., themeMode: dark))
                  |
                  v
            App widget rebuild
                  |
                  v
            MaterialApp.router(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.dark,  <-- map desde AppThemeMode
            )
                  |
                  v
            Flutter aplica tema oscuro globalmente
```

## Riesgos y consideraciones

- **Colores hardcodeados en chrome:** auditar widgets in-app; reemplazar hex fijos por `Theme.of(context)` / `colorScheme`. Interval colors y export share F16 son excepciones documentadas (R8).
- **Sombra de botones en dark:** `buttonOuterShadowDark` con tint blanco; consumir via `buttonShadowFor`.
- **CountdownRing y ProgressBar:** verificar que usan el color del intervalo (no hardcoded) y que el anillo de fondo respeta el tema.
- **No requiere migracion Drift** — se reutiliza `app_preferences` existente.
- **Pureza data/domain:** no importar `package:flutter` en `PreferencesRepository` ni en `AppSettings` por ThemeMode.

## Alternativas consideradas

- **shared_preferences:** descartado porque el proyecto unifico preferencias en Drift `app_preferences` desde F32/F35.
- **Package `dynamic_theme`:** descartado; Flutter 3 soporta `themeMode` nativamente en `MaterialApp`.
- **ColorScheme.fromSeed vs ColorScheme.dark():** se elige `fromSeed` con mismo seed que light para mantener coherencia de marca entre temas.
- **ThemeMode en dominio:** descartado; viola pureza de capas. Se usa `AppThemeMode` + map en `App`.
