package com.example.dhikir_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Kotlin side of the `dhikir_app/alarm` MethodChannel — arms/cancels exact
 * alarms via AlarmArmer. Never calls back into Dart; never calculates
 * prayer times (per alarm_api_contract.md). */
class AlarmMethodChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "dhikir_app/alarm"
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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "armAlarm" -> {
                val prayerId = call.argument<String>("prayerId")
                val epochMillis = call.argument<Number>("epochMillis")?.toLong()
                if (prayerId == null || epochMillis == null || prayerId !in AlarmArmer.prayerLabels) {
                    result.error("invalid_args", "prayerId/epochMillis missing or unknown prayerId", null)
                    return
                }
                AlarmArmer.arm(activity, prayerId, epochMillis)
                result.success(null)
            }
            "cancelAlarm" -> {
                val prayerId = call.argument<String>("prayerId")
                if (prayerId == null || prayerId !in AlarmArmer.prayerLabels) {
                    result.error("invalid_args", "unknown prayerId", null)
                    return
                }
                AlarmArmer.cancel(activity, prayerId)
                result.success(null)
            }
            "cancelAllAlarms" -> {
                AlarmArmer.cancelAll(activity)
                result.success(null)
            }
            "canScheduleExactAlarms" -> result.success(AlarmArmer.canScheduleExactAlarms(activity))
            "openExactAlarmSettings" -> {
                openExactAlarmSettings()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                .setData(Uri.parse("package:${activity.packageName}"))
            activity.startActivity(intent)
        }
    }
}
