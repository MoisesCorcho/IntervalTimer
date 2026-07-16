# Design: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

La app ya cuenta con:
- `AppTheme.light()` en `lib/core/theme/app_theme.dart` (tokens de spacing, radius, button, interval colors).
- `PreferencesRepository` en `lib/data/repositories/preferences_repository.dart` (Drift `app_preferences`, patron get/set generico).
- `SettingsController` (AsyncNotifier) + `SettingsRepository` + `AppSettings` en `features/settings/`.
- `SettingsScreen` con un unico control (`prepSeconds`).
- `App` widget en `lib/app/app.dart` con `MaterialApp.router(theme: AppTheme.light())`.

## Decisiones de diseno

### D1 — Persistencia via Drift `app_preferences` (criterio R3)

Agregar una clave `theme_mode` al store existente en `PreferencesRepository` (mismo patron que `prep_seconds`).
Valores almacenados como string: `"light"`, `"dark"`, `"system"` (default).

No se agrega tabla nueva — se reutiliza `app_preferences` (schema v4 existente, sin migracion).

### D2 — ThemeMode en Riverpod (criterio R2, R5)

- `AppSettings` se extiende con un campo `ThemeMode themeMode`.
- `SettingsController` expone `Future<void> setThemeMode(ThemeMode)`.
- `App` widget lee `settingsControllerProvider` y pasa `themeMode:` a `MaterialApp.router`.

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
La sombra de botones (`buttonOuterShadow`) puede necesitar ajuste de opacidad en dark.

### D4 — Selector de tema en SettingsScreen (criterio R1)

Agregar un `SegmentedButton<ThemeMode>` (Material 3) con tres opciones: Claro / Oscuro / Sistema.
Posicion: encima del control de `prepSeconds` existente.

### D5 — Contraste dinamico en dark mode (criterio R7)

`contrastTextColor` ya recibe el color de fondo del intervalo y calcula blanco/negro.
En dark mode, el fondo de pantalla cambia (surface oscuro), pero el color de intervalo sigue siendo el mismo.
La funcion no necesita cambios — el contraste se recalcula al rebuild del widget cuando cambia el tema.

Verificar en `timer_execution_screen.dart` que el texto/nombre del intervalo use `contrastTextColor(interval.color)` y no un color fijo.

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `lib/core/theme/app_theme.dart` | Agregar `static ThemeData dark()` con `Brightness.dark` |
| `lib/data/repositories/preferences_repository.dart` | Agregar `themeModeKey`, `getThemeMode()`, `setThemeMode(ThemeMode)` |
| `lib/features/settings/domain/app_settings.dart` | Agregar campo `ThemeMode themeMode` |
| `lib/features/settings/data/settings_repository.dart` | Agregar `getThemeMode()`, `setThemeMode(ThemeMode)` |
| `lib/features/settings/application/settings_controller.dart` | Agregar `setThemeMode(ThemeMode)` |
| `lib/features/settings/presentation/settings_screen.dart` | Agregar `SegmentedButton<ThemeMode>` |
| `lib/app/app.dart` | Agregar `darkTheme: AppTheme.dark()`, `themeMode:` desde settings |

## Diagrama de flujo

```
Usuario abre Ajustes
        |
        v
SegmentedButton (Claro / Oscuro / Sistema)
        |
        v
SettingsController.setThemeMode(mode)
        |
        +---> PreferencesRepository.setThemeMode("dark")
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
              themeMode: ThemeMode.dark,  <-- desde settings
            )
                  |
                  v
            Flutter aplica tema oscuro globalmente
```

## Riesgos y consideraciones

- **Colores hardcodeados existentes:** auditar todos los widgets en `lib/` y `lib/shared/widgets/` para reemplazar hex fijos por `Theme.of(context)`. Los colores de intervalo (`warmupColor`, `workColor`, etc.) son correctos como constantes porque se usan como fondo y el texto se calcula con `contrastTextColor`.
- **Sombra de botones en dark:** `buttonOuterShadow` usa `Color(0x1A000000)` (negro 10%). En fondo oscuro puede no ser visible. Considerar `Color(0x33FFFFFF)` (blanco 20%) para dark.
- **CountdownRing y ProgressBar:** verificar que usan el color del intervalo (no hardcoded) y que el anillo de fondo respeta el tema.
- **No requiere migracion Drift** — se reutiliza `app_preferences` existente.

## Alternativas consideradas

- **shared_preferences:** descartado porque el proyecto unifico preferencias en Drift `app_preferences` desde F32/F35.
- **Package `dynamic_theme`:** descartado; Flutter 3 soporta `themeMode` nativamente en `MaterialApp`.
- **ColorScheme.fromSeed vs ColorScheme.dark():** se elige `fromSeed` con mismo seed que light para mantener coherencia de marca entre temas.
