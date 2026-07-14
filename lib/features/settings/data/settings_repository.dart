import 'package:interval_timer/data/repositories/preferences_repository.dart';

/// Feature-facing settings store (F35 / F02).
///
/// Uses the project-wide [PreferencesRepository] (Drift `app_preferences`)
/// with the same semantics as shared_preferences keys from the data model.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final PreferencesRepository _prefs;

  static const defaultPrepSeconds = PreferencesRepository.defaultPrepSeconds;
  static const minPrepSeconds = PreferencesRepository.minPrepSeconds;
  static const maxPrepSeconds = PreferencesRepository.maxPrepSeconds;

  static const defaultVoiceEnabled = PreferencesRepository.defaultVoiceEnabled;
  static const defaultCountdownSeconds =
      PreferencesRepository.defaultCountdownSeconds;
  static const minCountdownSeconds =
      PreferencesRepository.minCountdownSeconds;
  static const maxCountdownSeconds =
      PreferencesRepository.maxCountdownSeconds;
  static const defaultAnnounceIntervalName =
      PreferencesRepository.defaultAnnounceIntervalName;

  Future<int> getPrepSeconds() => _prefs.getPrepSeconds();

  Future<void> setPrepSeconds(int value) => _prefs.setPrepSeconds(value);

  Future<bool> getVoiceEnabled() => _prefs.getVoiceEnabled();

  Future<void> setVoiceEnabled(bool value) => _prefs.setVoiceEnabled(value);

  Future<int> getCountdownSeconds() => _prefs.getCountdownSeconds();

  Future<void> setCountdownSeconds(int value) =>
      _prefs.setCountdownSeconds(value);

  Future<bool> getAnnounceIntervalName() => _prefs.getAnnounceIntervalName();

  Future<void> setAnnounceIntervalName(bool value) =>
      _prefs.setAnnounceIntervalName(value);
}
