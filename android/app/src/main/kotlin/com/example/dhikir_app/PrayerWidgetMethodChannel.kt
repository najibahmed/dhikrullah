package com.bitbirds.simplymuslim

import android.app.Activity
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Kotlin side of the `dhikir_app/widget` MethodChannel — refreshes the
 * home-screen prayer widget, pins it from inside the app, and hands widget
 * tap routes to Dart. Never calculates prayer times (see PrayerWidgetProvider). */
class PrayerWidgetMethodChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "dhikir_app/widget"
        private const val PINNED_REQUEST_CODE = 9102
    }

    private var channel: MethodChannel? = null

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    /** Widget tapped while the app was already running (onNewIntent). */
    fun notifyOpenRoute(intent: Intent) {
        val route = intent.getStringExtra(PrayerWidgetProvider.EXTRA_OPEN_ROUTE) ?: return
        intent.removeExtra(PrayerWidgetProvider.EXTRA_OPEN_ROUTE)
        channel?.invokeMethod("openRoute", route)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "refresh" -> {
                PrayerWidgetProvider.refreshAll(activity)
                result.success(null)
            }
            "consumeLaunchRoute" -> {
                val intent = activity.intent
                val route = intent?.getStringExtra(PrayerWidgetProvider.EXTRA_OPEN_ROUTE)
                intent?.removeExtra(PrayerWidgetProvider.EXTRA_OPEN_ROUTE)
                result.success(route)
            }
            "isPinSupported" -> result.success(isPinSupported())
            "requestPin" -> {
                if (!isPinSupported()) {
                    result.success(false)
                    return
                }
                // Fires once the user confirms the launcher dialog, so the
                // new widget renders populated straight away.
                val onPinned = PendingIntent.getBroadcast(
                    activity,
                    PINNED_REQUEST_CODE,
                    Intent(activity, PrayerWidgetProvider::class.java).setAction(PrayerWidgetProvider.ACTION_PINNED),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                val requested = AppWidgetManager.getInstance(activity).requestPinAppWidget(
                    ComponentName(activity, PrayerWidgetProvider::class.java),
                    null,
                    onPinned,
                )
                result.success(requested)
            }
            else -> result.notImplemented()
        }
    }

    private fun isPinSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            AppWidgetManager.getInstance(activity).isRequestPinAppWidgetSupported
}
