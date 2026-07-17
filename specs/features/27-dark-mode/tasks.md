# Tasks: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode`

## Definition of Done

- [x] Todos los criterios R1–R8 de `requirements.md` estan implementados y verificados.
- [x] Tests unitarios/widget relevantes pasan.
- [x] No se rompieron features previas (verificar postrequisitos).
- [x] Codigo revisado contra `_global/03-conventions.md` (incl. pureza domain/data).
- [x] Chrome in-app sin colores hardcodeados (R8); excepciones documentadas (interval colors, F16 export).

## Checklist de implementacion

### Datos y persistencia

- [x] Agregar `themeModeKey` y metodos `getThemeMode()` / `setThemeMode(String)` en `PreferencesRepository` (solo string; sin Flutter). _(cubre R3)_
- [x] Agregar enum de dominio `AppThemeMode` + campo en `AppSettings` (sin Flutter) con `copyWith` y equality. _(cubre R3)_
- [x] Agregar `getThemeMode()` / `setThemeMode(AppThemeMode)` en `SettingsRepository` (string ↔ dominio). _(cubre R3)_
- [x] Agregar `setThemeMode(AppThemeMode)` en `SettingsController` (AsyncNotifier). _(cubre R2, R3)_

### Tema

- [x] Crear `AppTheme.dark()` en `app_theme.dart` con `ColorScheme.fromSeed(brightness: Brightness.dark)` y tokens equivalentes. _(cubre R6, R8)_
- [x] Ajustar sombra de botones para dark (`buttonOuterShadowDark` + `buttonShadowFor`). _(cubre R6)_

### App root

- [x] Agregar `darkTheme: AppTheme.dark()` y `themeMode:` (map desde `AppThemeMode` en settings) en `App` widget (`app.dart`). _(cubre R2, R5, R6)_

### UI de configuracion

- [x] Agregar `SegmentedButton<AppThemeMode>` (Claro / Oscuro / Seguir sistema) en `SettingsScreen`, encima del control de `prepSeconds`. _(cubre R1)_
- [x] Default "Seguir sistema" al primer lanzamiento (sin preferencia guardada). _(cubre R4)_
- [x] Copy `UiStrings.themeSystem = 'Seguir sistema'` alineado a R1.

### Auditoria de colores

- [x] Auditar `lib/shared/widgets/` y `lib/features/` en busca de colores ARGB hardcodeados en chrome; reemplazar por `Theme.of(context)` donde aplique. _(cubre R8)_
- [x] Verificar que `timer_execution_screen.dart` usa `contrastTextColor(interval.color)` para texto sobre color de intervalo (no color fijo). _(cubre R7)_
- [x] Documentar excepcion R8 para export share F16 (paleta fija en bitmap) en requirements/design. _(cubre R8 honestidad)_
- [x] Shadow theme-aware en `progress_summary_section.dart` (StatMetricCard). _(cubre R8)_

### Docs globales

- [x] Documentar clave `theme_mode` en `_global/05-data-model.md`.
- [x] Documentar enfoque dark (`AppTheme.dark` / fromSeed) en `_global/04-design-system.md`.

### Tests

- [x] Unit test: `SettingsController.setThemeMode` persiste y actualiza estado. _(cubre R3)_
- [x] Unit test: default `AppThemeMode.system` / storage string `system` cuando no hay valor guardado. _(cubre R4)_
- [x] Widget test: `SettingsScreen` muestra `SegmentedButton` con 3 opciones y responde a seleccion. _(cubre R1)_
- [x] Widget test: `App` aplica `darkTheme` cuando `themeMode` es dark (`test/app/app_theme_mode_test.dart`). _(cubre R2)_

## Mapa de trazabilidad

| Criterio | Tareas |
|---|---|
| R1 | SegmentedButton + copy "Seguir sistema" |
| R2 | setThemeMode en Controller + darkTheme/themeMode en App + widget test App |
| R3 | PreferencesRepository (string) + SettingsRepository + SettingsController + AppThemeMode |
| R4 | Default system sin preferencia guardada |
| R5 | themeMode system en App (Flutter maneja el seguimiento) |
| R6 | AppTheme.dark() + auditoria de chrome |
| R7 | Verificar contrastTextColor en execution screen |
| R8 | Auditar chrome; excepcion F16 export documentada |
