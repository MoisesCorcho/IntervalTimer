import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
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
  static const defaultThemeMode = ThemeMode.system;

  // F02 voice prefs
  static const voiceEnabledKey = 'voice_enabled';
  static const countdownSecondsKey = 'countdown_seconds';
  static const announceIntervalNameKey = 'announce_interval_name';
  static const defaultVoiceEnabled = true;
  static const defaultCountdownSeconds = 3;
  static const minCountdownSeconds = 0;
  static const maxCountdownSeconds = 10;
  static const defaultAnnounceIntervalName = true;

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

  // F19 always-on screen (independent of F02/F18)
  static const keepScreenOnEnabledKey = 'keep_screen_on_enabled';
  static const defaultKeepScreenOnEnabled = true;

  // F20 session lock screen / notification (independent of F02/F18/F19)
  static const sessionLockScreenEnabledKey = 'session_lock_screen_enabled';
  static const defaultSessionLockScreenEnabled = true;

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

  /// F27: theme mode preference (default: follow system).
  Future<ThemeMode> getThemeMode() async {
    final raw = await getString(themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => defaultThemeMode,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await setString(themeModeKey, mode.name);
  }
}