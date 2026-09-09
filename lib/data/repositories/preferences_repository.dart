import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const activeWorkoutIdKey = 'active_workout_id';
  static const prepSecondsKey = 'prep_seconds';
  static const themeModeKey = 'theme_mode';
  static const defaultPrepSeconds = 10;
  static const minPrepSeconds = 0;
  static const maxPrepSeconds = 60;
  /// Storage default for F27 theme preference (`light` | `dark` | `system`).
  static const defaultThemeMode = 'system';

  // F02 voice prefs
  static const voiceEnabledKey = 'voice_enabled';
  static const countdownSecondsKey = 'countdown_seconds';
  static const announceIntervalNameKey = 'announce_interval_name';
  static const musicDuckingEnabledKey = 'music_ducking_enabled';
  static const defaultVoiceEnabled = true;
  static const defaultCountdownSeconds = 3;
  static const minCountdownSeconds = 0;
  static const maxCountdownSeconds = 10;
  static const defaultAnnounceIntervalName = true;
  static const defaultMusicDuckingEnabled = true;

  // F18 vibration prefs (independent of F02 voice keys)
  static const vibrationEnabledKey = 'vibration_enabled';
  static const vibrationOnIntervalStartKey = 'vibration_on_interval_start';
  static const vibrationOnCountdownKey = 'vibration_on_countdown';
  static const vibrationCountdownSecondsKey = 'vibration_countdown_seconds';
  static const defaultVibrationEnabled = true;
  static const defaultVibrationOnIntervalStart = true;
  static const defaultVibrationOnCountdown = true;
  static const defaultVibrationCountdownSeconds = 3;
  static const minVibrationCountdownSeconds = 0;
  static const maxVibrationCountdownSeconds = 10;

  // F36 SFX prefs (independent of F02 voice and F18 vibration)
  static const soundEnabledKey = 'sound_enabled';
  static const soundOnWorkStartKey = 'sound_on_work_start';
  static const soundOnRestStartKey = 'sound_on_rest_start';
  static const soundOnSessionCompleteKey = 'sound_on_session_complete';
  static const soundOnPrepTickKey = 'sound_on_prep_tick';
  static const soundOnPhaseWarningKey = 'sound_on_phase_warning';
  static const soundCountdownSecondsKey = 'sound_countdown_seconds';
  static const soundIdWorkStartKey = 'sound_id_work_start';
  static const soundIdRestStartKey = 'sound_id_rest_start';
  static const soundIdSessionCompleteKey = 'sound_id_session_complete';
  static const soundIdPrepTickKey = 'sound_id_prep_tick';
  static const soundIdPhaseWarningKey = 'sound_id_phase_warning';
  static const defaultSoundEnabled = true;
  static const defaultSoundOnWorkStart = true;
  static const defaultSoundOnRestStart = true;
  static const defaultSoundOnSessionComplete = true;
  static const defaultSoundOnPrepTick = true;
  static const defaultSoundOnPhaseWarning = true;
  static const defaultSoundCountdownSeconds = 3;
  static const minSoundCountdownSeconds = 0;
  static const maxSoundCountdownSeconds = 10;
  static const defaultSoundIdWorkStart = 'sfx_work_start_01';
  static const defaultSoundIdRestStart = 'sfx_rest_start_01';
  static const defaultSoundIdSessionComplete = 'sfx_session_complete_01';
  static const defaultSoundIdPrepTick = 'sfx_tick_01';
  static const defaultSoundIdPhaseWarning = 'sfx_tick_01';

  // F19 always-on screen (independent of F02/F18)
  static const keepScreenOnEnabledKey = 'keep_screen_on_enabled';
  static const defaultKeepScreenOnEnabled = true;

  // F20 session lock screen / notification (independent of F02/F18/F19)
  static const sessionLockScreenEnabledKey = 'session_lock_screen_enabled';
  static const defaultSessionLockScreenEnabled = true;

  // F15 body weight display unit (`kg` | `lb`)
  static const bodyWeightUnitKey = 'body_weight_unit';
  static const defaultBodyWeightUnit = 'kg';

  // F28 multi-language i18n (`system` | `es` | `en`)
  static const appLanguageKey = 'app_language';
  static const defaultAppLanguage = 'system';

  Future<String?> getString(String key) async {
    final row = await (_db.select(_db.appPreferences)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appPreferences)..where((t) => t.key.equals(key)))
          .go();
      return;
    }

    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion(
            key: Value(key),
            value: Value(value),
          ),
        );
  }

  Stream<String?> watchString(String key) {
    return (_db.select(_db.appPreferences)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<int?> getInt(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  Future<String?> getActiveWorkoutId() => getString(activeWorkoutIdKey);

  Future<void> setActiveWorkoutId(String? workoutId) =>
      setString(activeWorkoutIdKey, workoutId);

  /// F35: preparation seconds before first interval (default 10, range 0–60).
  Future<int> getPrepSeconds() async {
    final value = await getInt(prepSecondsKey);
    if (value == null) return defaultPrepSeconds;
    return value.clamp(minPrepSeconds, maxPrepSeconds);
  }

  Future<void> setPrepSeconds(int value) async {
    final clamped = value.clamp(minPrepSeconds, maxPrepSeconds);
    await setInt(prepSecondsKey, clamped);
  }

  Future<bool> getBool(String key, {required bool defaultValue}) async {
    final raw = await getString(key);
    if (raw == null) return defaultValue;
    if (raw == 'true' || raw == '1') return true;
    if (raw == 'false' || raw == '0') return false;
    return defaultValue;
  }

  Future<void> setBool(String key, bool value) =>
      setString(key, value ? 'true' : 'false');

  Future<bool> getVoiceEnabled() =>
      getBool(voiceEnabledKey, defaultValue: defaultVoiceEnabled);

  Future<void> setVoiceEnabled(bool value) =>
      setBool(voiceEnabledKey, value);

  Future<int> getCountdownSeconds() async {
    final value = await getInt(countdownSecondsKey);
    if (value == null) return defaultCountdownSeconds;
    return value.clamp(minCountdownSeconds, maxCountdownSeconds);
  }

  Future<void> setCountdownSeconds(int value) async {
    final clamped = value.clamp(minCountdownSeconds, maxCountdownSeconds);
    await setInt(countdownSecondsKey, clamped);
  }

  Future<bool> getAnnounceIntervalName() => getBool(
        announceIntervalNameKey,
        defaultValue: defaultAnnounceIntervalName,
      );

  Future<void> setAnnounceIntervalName(bool value) =>
      setBool(announceIntervalNameKey, value);

  Future<bool> getMusicDuckingEnabled() => getBool(
        musicDuckingEnabledKey,
        defaultValue: defaultMusicDuckingEnabled,
      );

  Future<void> setMusicDuckingEnabled(bool value) =>
      setBool(musicDuckingEnabledKey, value);

  Future<bool> getVibrationEnabled() => getBool(
        vibrationEnabledKey,
        defaultValue: defaultVibrationEnabled,
      );

  Future<void> setVibrationEnabled(bool value) =>
      setBool(vibrationEnabledKey, value);

  Future<bool> getVibrationOnIntervalStart() => getBool(
        vibrationOnIntervalStartKey,
        defaultValue: defaultVibrationOnIntervalStart,
      );

  Future<void> setVibrationOnIntervalStart(bool value) =>
      setBool(vibrationOnIntervalStartKey, value);

  Future<bool> getVibrationOnCountdown() => getBool(
        vibrationOnCountdownKey,
        defaultValue: defaultVibrationOnCountdown,
      );

  Future<void> setVibrationOnCountdown(bool value) =>
      setBool(vibrationOnCountdownKey, value);

  Future<int> getVibrationCountdownSeconds() async {
    final value = await getInt(vibrationCountdownSecondsKey);
    if (value == null) return defaultVibrationCountdownSeconds;
    return value.clamp(
      minVibrationCountdownSeconds,
      maxVibrationCountdownSeconds,
    );
  }

  Future<void> setVibrationCountdownSeconds(int value) async {
    final clamped = value.clamp(
      minVibrationCountdownSeconds,
      maxVibrationCountdownSeconds,
    );
    await setInt(vibrationCountdownSecondsKey, clamped);
  }

  Future<bool> getSoundEnabled() =>
      getBool(soundEnabledKey, defaultValue: defaultSoundEnabled);

  Future<void> setSoundEnabled(bool value) =>
      setBool(soundEnabledKey, value);

  Future<bool> getSoundOnWorkStart() =>
      getBool(soundOnWorkStartKey, defaultValue: defaultSoundOnWorkStart);

  Future<void> setSoundOnWorkStart(bool value) =>
      setBool(soundOnWorkStartKey, value);

  Future<bool> getSoundOnRestStart() =>
      getBool(soundOnRestStartKey, defaultValue: defaultSoundOnRestStart);

  Future<void> setSoundOnRestStart(bool value) =>
      setBool(soundOnRestStartKey, value);

  Future<bool> getSoundOnSessionComplete() => getBool(
        soundOnSessionCompleteKey,
        defaultValue: defaultSoundOnSessionComplete,
      );

  Future<void> setSoundOnSessionComplete(bool value) =>
      setBool(soundOnSessionCompleteKey, value);

  Future<bool> getSoundOnPrepTick() =>
      getBool(soundOnPrepTickKey, defaultValue: defaultSoundOnPrepTick);

  Future<void> setSoundOnPrepTick(bool value) =>
      setBool(soundOnPrepTickKey, value);

  Future<bool> getSoundOnPhaseWarning() => getBool(
        soundOnPhaseWarningKey,
        defaultValue: defaultSoundOnPhaseWarning,
      );

  Future<void> setSoundOnPhaseWarning(bool value) =>
      setBool(soundOnPhaseWarningKey, value);

  Future<int> getSoundCountdownSeconds() async {
    final value = await getInt(soundCountdownSecondsKey);
    if (value == null) return defaultSoundCountdownSeconds;
    return value.clamp(minSoundCountdownSeconds, maxSoundCountdownSeconds);
  }

  Future<void> setSoundCountdownSeconds(int value) async {
    final clamped =
        value.clamp(minSoundCountdownSeconds, maxSoundCountdownSeconds);
    await setInt(soundCountdownSecondsKey, clamped);
  }

  Future<String> getSoundIdWorkStart() async =>
      (await getString(soundIdWorkStartKey)) ?? defaultSoundIdWorkStart;

  Future<void> setSoundIdWorkStart(String value) =>
      setString(soundIdWorkStartKey, value);

  Future<String> getSoundIdRestStart() async =>
      (await getString(soundIdRestStartKey)) ?? defaultSoundIdRestStart;

  Future<void> setSoundIdRestStart(String value) =>
      setString(soundIdRestStartKey, value);

  Future<String> getSoundIdSessionComplete() async =>
      (await getString(soundIdSessionCompleteKey)) ??
      defaultSoundIdSessionComplete;

  Future<void> setSoundIdSessionComplete(String value) =>
      setString(soundIdSessionCompleteKey, value);

  Future<String> getSoundIdPrepTick() async =>
      (await getString(soundIdPrepTickKey)) ?? defaultSoundIdPrepTick;

  Future<void> setSoundIdPrepTick(String value) =>
      setString(soundIdPrepTickKey, value);

  Future<String> getSoundIdPhaseWarning() async =>
      (await getString(soundIdPhaseWarningKey)) ?? defaultSoundIdPhaseWarning;

  Future<void> setSoundIdPhaseWarning(String value) =>
      setString(soundIdPhaseWarningKey, value);

  Future<bool> getKeepScreenOnEnabled() => getBool(
        keepScreenOnEnabledKey,
        defaultValue: defaultKeepScreenOnEnabled,
      );

  Future<void> setKeepScreenOnEnabled(bool value) =>
      setBool(keepScreenOnEnabledKey, value);

  Future<bool> getSessionLockScreenEnabled() => getBool(
        sessionLockScreenEnabledKey,
        defaultValue: defaultSessionLockScreenEnabled,
      );

  Future<void> setSessionLockScreenEnabled(bool value) =>
      setBool(sessionLockScreenEnabledKey, value);

  /// F27: theme mode preference as storage string (default: `system`).
  ///
  /// Valid values: `light`, `dark`, `system`. Unknown/null → [defaultThemeMode].
  /// Domain mapping lives in settings layer (no Flutter / domain types here).
  Future<String> getThemeMode() async {
    final raw = await getString(themeModeKey);
    return switch (raw) {
      'light' => 'light',
      'dark' => 'dark',
      'system' => 'system',
      _ => defaultThemeMode,
    };
  }

  Future<void> setThemeMode(String mode) async {
    final value =
        (mode == 'light' || mode == 'dark' || mode == 'system')
            ? mode
            : defaultThemeMode;
    await setString(themeModeKey, value);
  }

  /// F15: weight display/edit unit (`kg` | `lb`). Default [defaultBodyWeightUnit].
  Future<String> getBodyWeightUnit() async {
    final raw = await getString(bodyWeightUnitKey);
    return switch (raw) {
      'lb' => 'lb',
      'kg' => 'kg',
      _ => defaultBodyWeightUnit,
    };
  }

  Future<void> setBodyWeightUnit(String unit) async {
    final value = (unit == 'lb' || unit == 'kg') ? unit : defaultBodyWeightUnit;
    await setString(bodyWeightUnitKey, value);
  }

  /// F28: app language preference as storage string (default: `system`).
  ///
  /// Valid values: `system`, `es`, `en`. Unknown/null → [defaultAppLanguage].
  Future<String> getAppLanguage() async {
    final raw = await getString(appLanguageKey);
    return switch (raw) {
      'system' => 'system',
      'es' => 'es',
      'en' => 'en',
      _ => defaultAppLanguage,
    };
  }

  Future<void> setAppLanguage(String lang) async {
    final value =
        (lang == 'system' || lang == 'es' || lang == 'en')
            ? lang
            : defaultAppLanguage;
    await setString(appLanguageKey, value);
  }

  Stream<String> watchAppLanguage() {
    return watchString(appLanguageKey).map((raw) => switch (raw) {
          'system' => 'system',
          'es' => 'es',
          'en' => 'en',
          _ => defaultAppLanguage,
        });
  }
}
