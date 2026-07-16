# Tasks: Modo Oscuro

**ID:** F27 &nbsp;|&nbsp; **Slug:** `27-dark-mode`

## Definition of Done

- [x] Todos los criterios R1–R8 de `requirements.md` estan implementados y verificados.
- [x] Tests unitarios/widget relevantes pasan.
- [x] No se rompieron features previas (verificar postrequisitos).
- [x] Codigo revisado contra `_global/03-conventions.md`.
- [x] Sin colores hardcodeados en widgets (R8).

## Checklist de implementacion

### Datos y persistencia

- [x] Agregar `themeModeKey` y metodos `getThemeMode()` / `setThemeMode(ThemeMode)` en `PreferencesRepository`. _(cubre R3)_
- [x] Agregar campo `ThemeMode themeMode` en `AppSettings` con `copyWith` y equality actualizados. _(cubre R3)_
- [x] Agregar `getThemeMode()` / `setThemeMode(ThemeMode)` en `SettingsRepository`. _(cubre R3)_
- [x] Agregar `setThemeMode(ThemeMode)` en `SettingsController` (AsyncNotifier). _(cubre R2, R3)_

### Tema

- [x] Crear `AppTheme.dark()` en `app_theme.dart` con `ColorScheme.fromSeed(brightness: Brightness.dark)` y tokens equivalentes. _(cubre R6, R8)_
- [x] Ajustar `buttonOuterShadow` para dark mode si la opacidad no es visible sobre fondo oscuro. _(cubre R6)_

### App root

- [x] Agregar `darkTheme: AppTheme.dark()` y `themeMode:` (desde `settingsControllerProvider`) en `App` widget (`app.dart`). _(cubre R2, R5, R6)_

### UI de configuracion

- [x] Agregar `SegmentedButton<ThemeMode>` (Claro / Oscuro / Sistema) en `SettingsScreen`, encima del control de `prepSeconds`. _(cubre R1)_
- [x] Default "Seguir sistema" al primer lanzamiento (sin preferencia guardada). _(cubre R4)_

### Auditoria de colores

- [x] Auditar `lib/shared/widgets/` y `lib/features/` en busca de colores ARGB hardcodeados; reemplazar por `Theme.of(context)` donde aplique. _(cubre R8)_
- [x] Verificar que `timer_execution_screen.dart` usa `contrastTextColor(interval.color)` para texto sobre color de intervalo (no color fijo). _(cubre R7)_

### Tests

- [x] Unit test: `SettingsController.setThemeMode` persiste y actualiza estado. _(cubre R3)_
- [x] Unit test: `PreferencesRepository.getThemeMode` retorna `ThemeMode.system` cuando no hay valor guardado. _(cubre R4)_
- [x] Widget test: `SettingsScreen` muestra `SegmentedButton` con 3 opciones y responde a seleccion. _(cubre R1)_
- [x] Widget test: `App` aplica `darkTheme` cuando `themeMode` es `ThemeMode.dark`. _(cubre R2)_

## Mapa de trazabilidad

| Criterio | Tareas |
|---|---|
| R1 | SegmentedButton en SettingsScreen |
| R2 | setThemeMode en Controller + darkTheme/themeMode en App |
| R3 | PreferencesRepository + SettingsRepository + SettingsController |
| R4 | Default en getThemeMode (sin valor guardado) |
| R5 | themeMode: ThemeMode.system en App (Flutter maneja el seguimiento) |
| R6 | AppTheme.dark() + auditoria de colores hardcodeados |
| R7 | Verificar contrastTextColor en execution screen |
| R8 | Auditar widgets y reemplazar hex fijos |
