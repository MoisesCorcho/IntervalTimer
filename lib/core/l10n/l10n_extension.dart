import 'package:flutter/widgets.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/core/l10n/app_localizations_es.dart';

export 'package:interval_timer/core/l10n/app_localizations.dart';

final AppLocalizations _fallbackLocalizations = AppLocalizationsEs();

/// Extension for fast, null-safe access to localized strings via `context.l10n`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? _fallbackLocalizations;
}

/// Dynamic resolution for achievements by ID.
extension AchievementL10n on AppLocalizations {
  String achievementTitle(String id) {
    return switch (id) {
      'first_session' => achievementFirstSessionTitle,
      'sessions_10' => achievementSessions10Title,
      'sessions_25' => achievementSessions25Title,
      'sessions_50' => achievementSessions50Title,
      'sessions_100' => achievementSessions100Title,
      'streak_3' => achievementStreak3Title,
      'streak_7' => achievementStreak7Title,
      'streak_14' => achievementStreak14Title,
      'streak_30' => achievementStreak30Title,
      'minutes_60' => achievementMinutes60Title,
      'minutes_300' => achievementMinutes300Title,
      'minutes_1000' => achievementMinutes1000Title,
      _ => id,
    };
  }

  String achievementDescription(String id) {
    return switch (id) {
      'first_session' => achievementFirstSessionDesc,
      'sessions_10' => achievementSessions10Desc,
      'sessions_25' => achievementSessions25Desc,
      'sessions_50' => achievementSessions50Desc,
      'sessions_100' => achievementSessions100Desc,
      'streak_3' => achievementStreak3Desc,
      'streak_7' => achievementStreak7Desc,
      'streak_14' => achievementStreak14Desc,
      'streak_30' => achievementStreak30Desc,
      'minutes_60' => achievementMinutes60Desc,
      'minutes_300' => achievementMinutes300Desc,
      'minutes_1000' => achievementMinutes1000Desc,
      _ => '',
    };
  }
}
