package com.example.session_compact_notification

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.media.app.NotificationCompat.MediaStyle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Posts MediaStyle notifications with [MediaStyle.setShowActionsInCompactView]
 * so Pause/Skip stay visible without expanding.
 *
 * Action taps target flutter_local_notifications' ActionBroadcastReceiver
 * (same extras) so F20 Dart handlers keep working.
 */
class SessionCompactNotificationPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var appContext: Context

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel =
      MethodChannel(
        binding.binaryMessenger,
        "interval_timer/session_compact_notification",
      )
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "show" -> {
        try {
          show(call)
          result.success(null)
        } catch (e: Exception) {
          result.error("show_failed", e.message, null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun show(call: MethodCall) {
    val id = call.argument<Int>("id") ?: error("id required")
    val channelId = call.argument<String>("channelId") ?: error("channelId required")
    val title = call.argument<String>("title") ?: ""
    val body = call.argument<String>("body") ?: ""
    val payload = call.argument<String>("payload") ?: "session_open"
    @Suppress("UNCHECKED_CAST")
    val actions =
      (call.argument<List<Map<String, Any?>>>("actions") ?: emptyList())

    val smallIcon =
      appContext.resources.getIdentifier(
        "ic_launcher",
        "mipmap",
        appContext.packageName,
      ).takeIf { it != 0 } ?: android.R.drawable.ic_media_play

    val builder =
      NotificationCompat.Builder(appContext, channelId)
        .setContentTitle(title)
        .setContentText(body)
        .setSmallIcon(smallIcon)
        .setOngoing(true)
        .setAutoCancel(false)
        .setOnlyAlertOnce(true)
        .setShowWhen(false)
        .setSilent(true)
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        .setCategory(NotificationCompat.CATEGORY_WORKOUT)
        .setContentIntent(contentPendingIntent(id, payload))

    val compactIndices = ArrayList<Int>(3)
    actions.forEachIndexed { index, raw ->
      if (index >= 3) return@forEachIndexed
      val actionId = raw["id"] as? String ?: return@forEachIndexed
      val actionTitle = raw["title"] as? String ?: actionId
      builder.addAction(
        NotificationCompat.Action.Builder(
          iconForAction(actionId),
          actionTitle,
          actionPendingIntent(id, index, actionId, payload),
        )
          .setShowsUserInterface(false)
          .build(),
      )
      compactIndices.add(index)
    }

    if (compactIndices.isNotEmpty()) {
      val mediaStyle =
        MediaStyle().setShowActionsInCompactView(*compactIndices.toIntArray())
      builder.setStyle(mediaStyle)
    }

    NotificationManagerCompat.from(appContext).notify(id, builder.build())
  }

  private fun contentPendingIntent(notificationId: Int, payload: String): PendingIntent {
    val launch =
      appContext.packageManager.getLaunchIntentForPackage(appContext.packageName)
        ?: Intent()
    launch.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
    launch.putExtra("payload", payload)
    return PendingIntent.getActivity(
      appContext,
      notificationId,
      launch,
      pendingFlags(),
    )
  }

  private fun actionPendingIntent(
    notificationId: Int,
    actionIndex: Int,
    actionId: String,
    payload: String,
  ): PendingIntent {
    // Mirror flutter_local_notifications ActionBroadcastReceiver contract.
    val intent =
      Intent().apply {
        setClassName(
          appContext,
          "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver",
        )
        action =
          "com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver.ACTION_TAPPED"
        putExtra("notificationId", notificationId)
        putExtra("actionId", actionId)
        putExtra("cancelNotification", false)
        putExtra("payload", payload)
      }
    // FLN spaces request codes by 16: id * 16 + index
    val requestCode = notificationId * 16 + actionIndex
    return PendingIntent.getBroadcast(appContext, requestCode, intent, pendingFlags())
  }

  private fun pendingFlags(): Int {
    var flags = PendingIntent.FLAG_UPDATE_CURRENT
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      flags = flags or PendingIntent.FLAG_IMMUTABLE
    }
    return flags
  }

  private fun iconForAction(actionId: String): Int {
    return when (actionId) {
      "session_pause" -> android.R.drawable.ic_media_pause
      "session_resume" -> android.R.drawable.ic_media_play
      "session_skip" -> android.R.drawable.ic_media_next
      else -> android.R.drawable.ic_media_play
    }
  }
}
