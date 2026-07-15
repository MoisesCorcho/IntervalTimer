import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interval_timer/features/lock_screen/application/session_notification_builder.dart';
import 'package:interval_timer/features/lock_screen/application/session_surface_constants.dart';
import 'package:interval_timer/features/lock_screen/domain/session_notification_snapshot.dart';
import 'package:interval_timer/features/lock_screen/domain/session_remote_action.dart';
import 'package:interval_timer/features/lock_screen/domain/session_surface_driver.dart';
import 'package:live_activities/live_activities.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform driver: Android FGS + ongoing notification; iOS Live Activities
/// with degradation when ActivityKit is unavailable (F20 R12, R15).
class PluginSessionSurfaceDriver implements SessionSurfaceDriver {
  PluginSessionSurfaceDriver({
    FlutterLocalNotificationsPlugin? notifications,
    LiveActivities? liveActivities,
  })  : _notifications =
            notifications ?? FlutterLocalNotificationsPlugin(),
        _liveActivities = liveActivities ?? LiveActivities();

  final FlutterLocalNotificationsPlugin _notifications;
  final LiveActivities _liveActivities;
  final _actions = StreamController<SessionRemoteAction>.broadcast();

  bool _initialized = false;
  bool _liveActivitiesReady = false;
  String? _liveActivityId;
  bool _serviceRunning = false;
  ReceivePort? _actionPort;
  StreamSubscription<Map<String, dynamic>?>? _serviceActionSub;

  @override
  Stream<SessionRemoteAction> get remoteActions => _actions.stream;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    _registerActionPort();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          sessionNotificationBackgroundHandler,
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        SessionSurfaceConstants.channelId,
        SessionSurfaceConstants.channelName,
        description: SessionSurfaceConstants.channelDescription,
        importance: Importance.defaultImportance,
      );
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Actions posted from FGS isolate → UI via service events.
      _serviceActionSub = FlutterBackgroundService()
          .on('remote_action')
          .listen(_onServiceRemoteAction);
    }

    if (Platform.isIOS) {
      try {
        await _liveActivities.init(
          appGroupId: SessionSurfaceConstants.liveActivitiesAppGroupId,
        );
        _liveActivitiesReady = true;
      } catch (e, st) {
        debugPrint('LiveActivities.init failed (degrade): $e\n$st');
        _liveActivitiesReady = false;
      }
    }

    _initialized = true;
  }

  void _registerActionPort() {
    if (_actionPort != null) return;
    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(
      SessionSurfaceConstants.actionPortName,
    );
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      SessionSurfaceConstants.actionPortName,
    );
    port.listen((message) {
      if (message is String) {
        final action = mapActionId(message);
        if (action != null) _actions.add(action);
      }
    });
    _actionPort = port;
  }

  void _onServiceRemoteAction(Map<String, dynamic>? event) {
    if (event == null) return;
    final raw = event['action'] as String?;
    if (raw == null) return;
    final action = mapActionId(raw);
    if (action != null) _actions.add(action);
  }

  @override
  Future<bool> isPermissionGranted() async {
    try {
      await ensureInitialized();
      if (Platform.isAndroid) {
        final android = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.areNotificationsEnabled();
        return granted ?? true;
      }
      if (Platform.isIOS) {
        final status = await Permission.notification.status;
        return status.isGranted || status.isLimited;
      }
      return true;
    } catch (e, st) {
      debugPrint('isPermissionGranted failed: $e\n$st');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await ensureInitialized();
      if (Platform.isAndroid) {
        final android = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final result = await android?.requestNotificationsPermission();
        return result ?? await isPermissionGranted();
      }
      if (Platform.isIOS) {
        final status = await Permission.notification.request();
        return status.isGranted || status.isLimited;
      }
      return true;
    } catch (e, st) {
      debugPrint('requestPermission failed: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> showOrUpdate(SessionNotificationSnapshot snapshot) async {
    await ensureInitialized();

    if (Platform.isAndroid) {
      await _ensureAndroidService();
      await _showAndroidNotification(snapshot);
      return;
    }

    if (Platform.isIOS) {
      await _showOrUpdateLiveActivity(snapshot);
      if (_liveActivityId == null) {
        await _showIosNotification(snapshot);
      }
    }
  }

  @override
  Future<void> hide() async {
    try {
      await ensureInitialized();
      await _notifications.cancel(id: SessionSurfaceConstants.notificationId);

      if (Platform.isAndroid && _serviceRunning) {
        final service = FlutterBackgroundService();
        final isRunning = await service.isRunning();
        if (isRunning) {
          service.invoke('stopService');
        }
        _serviceRunning = false;
      }

      if (Platform.isIOS) {
        await _endLiveActivity();
      }
    } catch (e, st) {
      debugPrint('PluginSessionSurfaceDriver.hide failed: $e\n$st');
    }
  }

  @override
  Future<void> openSystemSettings() async {
    try {
      await openAppSettings();
    } catch (e, st) {
      debugPrint('openSystemSettings failed: $e\n$st');
    }
  }

  Future<void> _ensureAndroidService() async {
    if (!Platform.isAndroid) return;
    try {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
        // Give the FGS isolate a moment to register sync_snapshot listeners.
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      _serviceRunning = true;
    } catch (e, st) {
      debugPrint('_ensureAndroidService failed: $e\n$st');
    }
  }

  Future<void> _showAndroidNotification(
    SessionNotificationSnapshot snapshot,
  ) async {
    final title = SessionNotificationBuilder.notificationTitle(snapshot);
    final body = SessionNotificationBuilder.notificationBody(snapshot);

    // Post from UI isolate (works if FGS not ready yet).
    await _notifications.show(
      id: SessionSurfaceConstants.notificationId,
      title: title,
      body: body,
      notificationDetails: SessionNotificationBuilder.details(snapshot),
      payload: 'session_open',
    );

    // Authoritative update from FGS isolate (keeps actions on ongoing FGS notif).
    try {
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke('sync_snapshot', snapshot.toMap());
      }
    } catch (e, st) {
      debugPrint('sync_snapshot invoke failed: $e\n$st');
    }
  }

  Future<void> _showIosNotification(
    SessionNotificationSnapshot snapshot,
  ) async {
    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      threadIdentifier: SessionSurfaceConstants.channelId,
      categoryIdentifier: SessionSurfaceConstants.channelId,
    );
    const details = NotificationDetails(iOS: darwin);
    await _notifications.show(
      id: SessionSurfaceConstants.notificationId,
      title: SessionNotificationBuilder.notificationTitle(snapshot),
      body: SessionNotificationBuilder.notificationBody(snapshot),
      notificationDetails: details,
      payload: 'session_open',
    );
  }

  Future<void> _showOrUpdateLiveActivity(
    SessionNotificationSnapshot snapshot,
  ) async {
    if (!_liveActivitiesReady) return;
    try {
      final data = <String, dynamic>{
        'title': snapshot.title,
        'status': snapshot.status,
        'remaining': snapshot.remainingFormatted,
        'remainingMs': '${snapshot.remainingMs}',
        'showPause': '${snapshot.showPause}',
        'showResume': '${snapshot.showResume}',
        'showSkip': '${snapshot.showSkip}',
      };

      if (_liveActivityId == null) {
        final id = await _liveActivities.createActivity(
          SessionSurfaceConstants.liveActivityId,
          data,
          removeWhenAppIsKilled: true,
        );
        _liveActivityId = id ?? SessionSurfaceConstants.liveActivityId;
      } else {
        await _liveActivities.updateActivity(_liveActivityId!, data);
      }
    } catch (e, st) {
      debugPrint('Live Activity show/update failed (degrade): $e\n$st');
      _liveActivityId = null;
    }
  }

  Future<void> _endLiveActivity() async {
    if (!_liveActivitiesReady) return;
    try {
      if (_liveActivityId != null) {
        await _liveActivities.endActivity(_liveActivityId!);
      }
      await _liveActivities.endAllActivities();
    } catch (e, st) {
      debugPrint('Live Activity end failed: $e\n$st');
    } finally {
      _liveActivityId = null;
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final action = mapNotificationResponse(response);
    if (action != null) {
      _actions.add(action);
    }
  }

  void dispose() {
    unawaited(_serviceActionSub?.cancel());
    _actionPort?.close();
    IsolateNameServer.removePortNameMapping(
      SessionSurfaceConstants.actionPortName,
    );
    unawaited(_actions.close());
  }
}

/// Maps action id / payload to [SessionRemoteAction].
SessionRemoteAction? mapActionId(String? id) {
  if (id == null || id.isEmpty) return SessionRemoteAction.openApp;
  if (id == SessionSurfaceConstants.actionPause) {
    return SessionRemoteAction.pause;
  }
  if (id == SessionSurfaceConstants.actionResume) {
    return SessionRemoteAction.resume;
  }
  if (id == SessionSurfaceConstants.actionSkip) {
    return SessionRemoteAction.skip;
  }
  if (id == SessionSurfaceConstants.actionOpenApp || id == 'session_open') {
    return SessionRemoteAction.openApp;
  }
  return SessionRemoteAction.openApp;
}

SessionRemoteAction? mapNotificationResponse(NotificationResponse response) {
  final id = response.actionId;
  if (id != null && id.isNotEmpty) {
    return mapActionId(id);
  }
  if (response.notificationResponseType ==
      NotificationResponseType.selectedNotification) {
    return SessionRemoteAction.openApp;
  }
  return null;
}

/// Background isolate entry for notification actions (must be top-level).
@pragma('vm:entry-point')
void sessionNotificationBackgroundHandler(NotificationResponse response) {
  final send = IsolateNameServer.lookupPortByName(
    SessionSurfaceConstants.actionPortName,
  );
  final id = response.actionId;
  if (id != null && id.isNotEmpty) {
    send?.send(id);
  } else if (response.notificationResponseType ==
      NotificationResponseType.selectedNotification) {
    send?.send(SessionSurfaceConstants.actionOpenApp);
  }
}
