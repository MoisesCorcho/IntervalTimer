/// App theme preference (F27). Pure domain — no Flutter imports.
///
/// Stored in Drift `app_preferences` as string: `light` | `dark` | `system`.
enum AppThemeMode {
  light,
  dark,
  system;

  static const AppThemeMode defaultMode = AppThemeMode.system;

  /// Stable storage value matching [name] (`light` / `dark` / `system`).
  String get storageValue => name;

  /// Parses a stored preference; unknown/null → [defaultMode].
  static AppThemeMode fromStorage(String? raw) {
    return switch (raw) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => defaultMode,
    };
  }
}
