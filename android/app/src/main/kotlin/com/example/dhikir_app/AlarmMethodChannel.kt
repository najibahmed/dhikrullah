package com.example.dhikir_app

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Kotlin side of the `dhikir_app/alarm` MethodChannel — arms/cancels exact
 * alarms via AlarmManager. Never calls back into Dart; never calculates
 * prayer times (per alarm_api_contract.md). */
class AlarmMethodChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "dhikir_app/alarm"

        /** Must match lib/features/alarm/models/alarm_settings.dart's alarmPrayerLabels. */
        private val prayerLabels = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Tahajjud")
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
                if (prayerId == null || epochMillis == null || prayerId !in prayerLabels) {
                    result.error("invalid_args", "prayerId/epochMillis missing or unknown prayerId", null)
                    return
                }
                armAlarm(prayerId, epochMillis)
                result.success(null)
            }
            "cancelAlarm" -> {
                val prayerId = call.argument<String>("prayerId")
                if (prayerId == null || prayerId !in prayerLabels) {
                    result.error("invalid_args", "unknown prayerId", null)
                    return
                }
                cancelAlarm(prayerId)
                result.success(null)
            }
            "cancelAllAlarms" -> {
                prayerLabels.forEach { cancelAlarm(it) }
                result.success(null)
            }
            "canScheduleExactAlarms" -> result.success(canScheduleExactAlarms())
            "openExactAlarmSettings" -> {
                openExactAlarmSettings()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun alarmManager(): AlarmManager =
        activity.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun pendingIntentFor(prayerId: String): PendingIntent {
        val intent = Intent(activity, AlarmReceiver::class.java)
            .putExtra(AlarmReceiver.EXTRA_PRAYER_ID, prayerId)
        val requestCode = prayerLabels.indexOf(prayerId)
        return PendingIntent.getBroadcast(
            activity,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun armAlarm(prayerId: String, epochMillis: Long) {
        val pendingIntent = pendingIntentFor(prayerId)
        alarmManager().setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            epochMillis,
            pendingIntent
        )
    }

    private fun cancelAlarm(prayerId: String) {
        alarmManager().cancel(pendingIntentFor(prayerId))
    }

    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager().canScheduleExactAlarms()
        } else {
            true
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
