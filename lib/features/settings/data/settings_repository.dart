import 'package:interval_timer/data/repositories/preferences_repository.dart';

/// Feature-facing settings store (F35).
///
/// Uses the project-wide [PreferencesRepository] (Drift `app_preferences`)
/// with the same semantics as shared_preferences keys from the data model.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final PreferencesRepository _prefs;

  static const defaultPrepSeconds = PreferencesRepository.defaultPrepSeconds;
  static const minPrepSeconds = PreferencesRepository.minPrepSeconds;
  static const maxPrepSeconds = PreferencesRepository.maxPrepSeconds;

  Future<int> getPrepSeconds() => _prefs.getPrepSeconds();

  Future<void> setPrepSeconds(int value) => _prefs.setPrepSeconds(value);
}
