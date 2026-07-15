import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/features/lock_screen/application/session_surface_constants.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';

/// Shared Android notification layout for F20 (UI isolate + FGS isolate).
abstract final class SessionNotificationBuilder {
  static String statusLabel(String status) {
    return switch (status) {
      'paused' => UiStrings.sessionSurfaceStatusPaused,
      'preparing' => UiStrings.preparation,
      _ => UiStrings.sessionSurfaceStatusRunning,
    };
  }

  /// Title: countdown. Body: interval + status (clear on lock screen).
  static String notificationTitle(SessionNotificationSnapshot snapshot) =>
      snapshot.remainingFormatted;

  static String notificationBody(SessionNotificationSnapshot snapshot) {
    final status = statusLabel(snapshot.status);
    return '${snapshot.title} · $status';
  }

  static List<AndroidNotificationAction> actionsFor(
    SessionNotificationSnapshot snapshot,
  ) {
    return [
      if (snapshot.showPause)
        AndroidNotificationAction(
          SessionSurfaceConstants.actionPause,
          UiStrings.pause,
          // Keep process in place; main isolate receives via IsolateNameServer.
          showsUserInterface: false,
          cancelNotification: false,
        ),
      if (snapshot.showResume)
        AndroidNotificationAction(
          SessionSurfaceConstants.actionResume,
          UiStrings.resume,
          showsUserInterface: false,
          cancelNotification: false,
        ),
      if (snapshot.showSkip)
        AndroidNotificationAction(
          SessionSurfaceConstants.actionSkip,
          UiStrings.skip,
          showsUserInterface: false,
          cancelNotification: false,
        ),
    ];
  }

  static AndroidNotificationDetails androidDetails(
    SessionNotificationSnapshot snapshot,
  ) {
    final body = notificationBody(snapshot);
    return AndroidNotificationDetails(
      SessionSurfaceConstants.channelId,
      SessionSurfaceConstants.channelName,
      channelDescription: SessionSurfaceConstants.channelDescription,
      // Default (not low): low channels hide actions on many OEMs / lock screen.
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      // Public: full content + actions on lock screen.
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.workout,
      actions: actionsFor(snapshot),
      // BigText keeps interval+status readable; MediaStyle hid action buttons.
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: notificationTitle(snapshot),
        summaryText: statusLabel(snapshot.status),
      ),
    );
  }

  static NotificationDetails details(SessionNotificationSnapshot snapshot) {
    return NotificationDetails(android: androidDetails(snapshot));
  }
}
