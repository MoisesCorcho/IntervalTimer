import 'package:flutter/services.dart';

/// Posts Android MediaStyle notifications with actions visible in the
/// **collapsed / compact** view via `setShowActionsInCompactView`.
///
/// Action taps are routed through `flutter_local_notifications`'
/// `ActionBroadcastReceiver` so existing F20 handlers keep working.
class SessionCompactNotification {
  SessionCompactNotification._();

  static const MethodChannel _channel = MethodChannel(
    'interval_timer/session_compact_notification',
  );

  /// Shows or replaces notification [id] with MediaStyle compact actions.
  ///
  /// [actions] entries: `{ 'id': String, 'title': String }`, max 3 recommended.
  /// Compact view shows up to the first 3 action indices.
  static Future<void> show({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required List<Map<String, String>> actions,
    String payload = 'session_open',
  }) async {
    await _channel.invokeMethod<void>('show', <String, Object?>{
      'id': id,
      'channelId': channelId,
      'title': title,
      'body': body,
      'payload': payload,
      'actions': actions,
    });
  }
}
