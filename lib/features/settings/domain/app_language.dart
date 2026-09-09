/// Supported application language choices (F28).
enum AppLanguage {
  system,
  es,
  en;

  /// User-facing display name in Settings selector.
  String get displayName => switch (this) {
        system => 'Automático (Sistema)',
        es => 'Español',
        en => 'English',
      };

  /// Serialized key stored in preferences.
  String get code => name;

  /// Parses a string representation from storage into [AppLanguage].
  static AppLanguage fromString(String? value) {
    return switch (value) {
      'es' => AppLanguage.es,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };
  }
}
