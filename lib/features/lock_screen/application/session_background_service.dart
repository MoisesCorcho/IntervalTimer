import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interval_timer/features/lock_screen/application/plugin_session_surface_driver.dart';
import 'package:interval_timer/features/lock_screen/application/session_notification_builder.dart';
import 'package:interval_timer/features/lock_screen/application/session_surface_constants.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';

/// Configures [FlutterBackgroundService] for Android FGS (F20 R8).
///
/// The service isolate **owns** the ongoing notification content (title, body,
/// action buttons). UI isolate pushes snapshots via `sync_snapshot`.
///
/// Do **not** call [AndroidServiceInstance.setForegroundNotificationInfo] after
/// a custom FLN `show` with actions — it replaces the notification without
/// action buttons.
///
/// **FGS type pin:** `AndroidForegroundType.specialUse` with manifest property
/// `PROPERTY_SPECIAL_USE_FGS_SUBTYPE=workout_interval_session_timer`.
Future<void> configureSessionBackgroundService() async {
  final service = FlutterBackgroundService();

  final plugin = FlutterLocalNotificationsPlugin();
  // defaultImportance: low channels hide actions on many Android skins.
  const channel = AndroidNotificationChannel(
    SessionSurfaceConstants.channelId,
    SessionSurfaceConstants.channelName,
    description: SessionSurfaceConstants.channelDescription,
    importance: Importance.defaultImportance,
  );

  try {
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e, st) {
    debugPrint('createNotificationChannel failed: $e\n$st');
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: sessionBackgroundOnStart,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      notificationChannelId: SessionSurfaceConstants.channelId,
      initialNotificationTitle: SessionSurfaceConstants.channelName,
      initialNotificationContent: '…',
      foregroundServiceNotificationId: SessionSurfaceConstants.notificationId,
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: sessionBackgroundOnStart,
      onBackground: sessionBackgroundOnIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void sessionBackgroundOnStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await plugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (response) {
      _forwardRemoteAction(service, response);
    },
    onDidReceiveBackgroundNotificationResponse:
        sessionNotificationBackgroundHandler,
  );

  try {
    const channel = AndroidNotificationChannel(
      SessionSurfaceConstants.channelId,
      SessionSurfaceConstants.channelName,
      description: SessionSurfaceConstants.channelDescription,
      importance: Importance.defaultImportance,
    );
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (_) {}

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((_) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((_) {
    service.stopSelf();
  });

  // Full notification (actions + public visibility) from FGS isolate.
  // Avoid setForegroundNotificationInfo — it strips action buttons.
  service.on('sync_snapshot').listen((event) async {
    if (event == null) return;
    try {
      final snapshot = SessionNotificationSnapshot.fromMap(event);
      final title = SessionNotificationBuilder.notificationTitle(snapshot);
      final body = SessionNotificationBuilder.notificationBody(snapshot);

      await plugin.show(
        id: SessionSurfaceConstants.notificationId,
        title: title,
        body: body,
        notificationDetails: SessionNotificationBuilder.details(snapshot),
        payload: 'session_open',
      );
    } catch (e, st) {
      debugPrint('sessionBackgroundOnStart sync_snapshot failed: $e\n$st');
    }
  });
}

void _forwardRemoteAction(
  ServiceInstance service,
  NotificationResponse response,
) {
  final id = response.actionId;
  if (id != null && id.isNotEmpty) {
    service.invoke('remote_action', {'action': id});
    return;
  }
  if (response.notificationResponseType ==
      NotificationResponseType.selectedNotification) {
    service.invoke('remote_action', {
      'action': SessionSurfaceConstants.actionOpenApp,
    });
  }
}

@pragma('vm:entry-point')
Future<bool> sessionBackgroundOnIosBackground(ServiceInstance service) async {
  return true;
}
