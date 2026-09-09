import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';

/// Feature-facing settings store (F35 / F02 / F27).
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
  static const defaultMusicDuckingEnabled =
      PreferencesRepository.defaultMusicDuckingEnabled;

  // F18 vibration
  static const defaultVibrationEnabled =
      PreferencesRepository.defaultVibrationEnabled;
  static const defaultVibrationOnIntervalStart =
      PreferencesRepository.defaultVibrationOnIntervalStart;
  static const defaultVibrationOnCountdown =
      PreferencesRepository.defaultVibrationOnCountdown;
  static const defaultVibrationCountdownSeconds =
      PreferencesRepository.defaultVibrationCountdownSeconds;
  static const minVibrationCountdownSeconds =
      PreferencesRepository.minVibrationCountdownSeconds;
  static const maxVibrationCountdownSeconds =
      PreferencesRepository.maxVibrationCountdownSeconds;

  // F36 SFX
  static const defaultSoundEnabled = PreferencesRepository.defaultSoundEnabled;
  static const defaultSoundCountdownSeconds =
      PreferencesRepository.defaultSoundCountdownSeconds;
  static const minSoundCountdownSeconds =
      PreferencesRepository.minSoundCountdownSeconds;
  static const maxSoundCountdownSeconds =
      PreferencesRepository.maxSoundCountdownSeconds;

  // F19 always-on
  static const defaultKeepScreenOnEnabled =
      PreferencesRepository.defaultKeepScreenOnEnabled;

  // F20 session lock screen
  static const defaultSessionLockScreenEnabled =
      PreferencesRepository.defaultSessionLockScreenEnabled;

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

  Future<bool> getMusicDuckingEnabled() => _prefs.getMusicDuckingEnabled();

  Future<void> setMusicDuckingEnabled(bool value) =>
      _prefs.setMusicDuckingEnabled(value);

  Future<bool> getVibrationEnabled() => _prefs.getVibrationEnabled();

  Future<void> setVibrationEnabled(bool value) =>
      _prefs.setVibrationEnabled(value);

  Future<bool> getVibrationOnIntervalStart() =>
      _prefs.getVibrationOnIntervalStart();

  Future<void> setVibrationOnIntervalStart(bool value) =>
      _prefs.setVibrationOnIntervalStart(value);

  Future<bool> getVibrationOnCountdown() => _prefs.getVibrationOnCountdown();

  Future<void> setVibrationOnCountdown(bool value) =>
      _prefs.setVibrationOnCountdown(value);

  Future<int> getVibrationCountdownSeconds() =>
      _prefs.getVibrationCountdownSeconds();

  Future<void> setVibrationCountdownSeconds(int value) =>
      _prefs.setVibrationCountdownSeconds(value);

  Future<bool> getSoundEnabled() => _prefs.getSoundEnabled();

  Future<void> setSoundEnabled(bool value) => _prefs.setSoundEnabled(value);

  Future<bool> getSoundOnWorkStart() => _prefs.getSoundOnWorkStart();

  Future<void> setSoundOnWorkStart(bool value) =>
      _prefs.setSoundOnWorkStart(value);

  Future<bool> getSoundOnRestStart() => _prefs.getSoundOnRestStart();

  Future<void> setSoundOnRestStart(bool value) =>
      _prefs.setSoundOnRestStart(value);

  Future<bool> getSoundOnSessionComplete() =>
      _prefs.getSoundOnSessionComplete();

  Future<void> setSoundOnSessionComplete(bool value) =>
      _prefs.setSoundOnSessionComplete(value);

  Future<bool> getSoundOnPrepTick() => _prefs.getSoundOnPrepTick();

  Future<void> setSoundOnPrepTick(bool value) =>
      _prefs.setSoundOnPrepTick(value);

  Future<bool> getSoundOnPhaseWarning() => _prefs.getSoundOnPhaseWarning();

  Future<void> setSoundOnPhaseWarning(bool value) =>
      _prefs.setSoundOnPhaseWarning(value);

  Future<int> getSoundCountdownSeconds() => _prefs.getSoundCountdownSeconds();

  Future<void> setSoundCountdownSeconds(int value) =>
      _prefs.setSoundCountdownSeconds(value);

  Future<String> getSoundIdWorkStart() => _prefs.getSoundIdWorkStart();

  Future<void> setSoundIdWorkStart(String value) =>
      _prefs.setSoundIdWorkStart(value);

  Future<String> getSoundIdRestStart() => _prefs.getSoundIdRestStart();

  Future<void> setSoundIdRestStart(String value) =>
      _prefs.setSoundIdRestStart(value);

  Future<String> getSoundIdSessionComplete() =>
      _prefs.getSoundIdSessionComplete();

  Future<void> setSoundIdSessionComplete(String value) =>
      _prefs.setSoundIdSessionComplete(value);

  Future<String> getSoundIdPrepTick() => _prefs.getSoundIdPrepTick();

  Future<void> setSoundIdPrepTick(String value) =>
      _prefs.setSoundIdPrepTick(value);

  Future<String> getSoundIdPhaseWarning() => _prefs.getSoundIdPhaseWarning();

  Future<void> setSoundIdPhaseWarning(String value) =>
      _prefs.setSoundIdPhaseWarning(value);

  Future<bool> getKeepScreenOnEnabled() => _prefs.getKeepScreenOnEnabled();

  Future<void> setKeepScreenOnEnabled(bool value) =>
      _prefs.setKeepScreenOnEnabled(value);

  Future<bool> getSessionLockScreenEnabled() =>
      _prefs.getSessionLockScreenEnabled();

  Future<void> setSessionLockScreenEnabled(bool value) =>
      _prefs.setSessionLockScreenEnabled(value);

  /// F27: maps storage string ↔ domain [AppThemeMode] (no Flutter ThemeMode).
  Future<AppThemeMode> getThemeMode() async {
    final raw = await _prefs.getThemeMode();
    return AppThemeMode.fromStorage(raw);
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _prefs.setThemeMode(mode.storageValue);

  /// F15: maps storage string ↔ domain [BodyWeightUnit].
  Future<BodyWeightUnit> getBodyWeightUnit() async {
    final raw = await _prefs.getBodyWeightUnit();
    return BodyWeightUnit.fromStorage(raw);
  }

  Future<void> setBodyWeightUnit(BodyWeightUnit unit) =>
      _prefs.setBodyWeightUnit(unit.storageValue);
}
