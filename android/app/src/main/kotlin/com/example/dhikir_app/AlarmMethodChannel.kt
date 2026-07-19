package com.example.dhikir_app

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Kotlin side of the `dhikir_app/alarm` MethodChannel — arms/cancels exact
 * alarms via AlarmArmer and surfaces permission checks via AlarmPermissions.
 * Never calls back into Dart; never calculates prayer times (per
 * alarm_api_contract.md). */
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
                val armed = AlarmArmer.arm(activity, prayerId, epochMillis)
                if (armed) {
                    result.success(null)
                } else {
                    result.error("permission_denied", "Exact alarm permission not granted", null)
                }
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
            "canScheduleExactAlarms" -> result.success(AlarmPermissions.canScheduleExactAlarms(activity))
            "openExactAlarmSettings" -> {
                AlarmPermissions.openExactAlarmSettings(activity)
                result.success(null)
            }
            "canUseFullScreenIntent" -> result.success(AlarmPermissions.canUseFullScreenIntent(activity))
            "openFullScreenIntentSettings" -> {
                AlarmPermissions.openFullScreenIntentSettings(activity)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
