import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/features/lock_screen/application/session_surface_constants.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:session_compact_notification/session_compact_notification.dart';

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

  /// Action maps for the compact MediaStyle path (id + title).
  static List<Map<String, String>> compactActionMaps(
    SessionNotificationSnapshot snapshot,
  ) {
    return [
      if (snapshot.showPause)
        {
          'id': SessionSurfaceConstants.actionPause,
          'title': UiStrings.pause,
        },
      if (snapshot.showResume)
        {
          'id': SessionSurfaceConstants.actionResume,
          'title': UiStrings.resume,
        },
      if (snapshot.showSkip)
        {
          'id': SessionSurfaceConstants.actionSkip,
          'title': UiStrings.skip,
        },
    ];
  }

  /// Prefer MediaStyle + compact actions (Pause/Skip visible without expand).
  ///
  /// Falls back to [flutter_local_notifications] BigText details if the
  /// compact plugin channel is unavailable (e.g. tests / non-Android).
  static Future<void> showAndroid({
    required FlutterLocalNotificationsPlugin plugin,
    required SessionNotificationSnapshot snapshot,
  }) async {
    final title = notificationTitle(snapshot);
    final body = notificationBody(snapshot);

    try {
      await SessionCompactNotification.show(
        id: SessionSurfaceConstants.notificationId,
        channelId: SessionSurfaceConstants.channelId,
        title: title,
        body: body,
        actions: compactActionMaps(snapshot),
        payload: 'session_open',
      );
      return;
    } catch (e, st) {
      debugPrint(
        'SessionCompactNotification.show failed, FLN fallback: $e\n$st',
      );
    }

    await plugin.show(
      id: SessionSurfaceConstants.notificationId,
      title: title,
      body: body,
      notificationDetails: details(snapshot),
      payload: 'session_open',
    );
  }

  /// FLN fallback details (expanded actions only on most OEMs).
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
      // BigText fallback only — MediaStyle compact needs setShowActionsInCompactView
      // which flutter_local_notifications 22.0.1 does not expose.
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
