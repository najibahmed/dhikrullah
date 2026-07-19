package com.example.dhikir_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/** Shared AlarmManager arm/cancel logic — used by both AlarmMethodChannel
 * (live app requests) and BootReceiver (restore after reboot), so the two
 * never construct PendingIntents differently for the same prayer. */
object AlarmArmer {

    /** Must match lib/features/alarm/models/alarm_settings.dart's alarmPrayerLabels. */
    val prayerLabels = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Tahajjud")

    private fun alarmManager(context: Context): AlarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun pendingIntentFor(context: Context, prayerId: String): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java)
            .putExtra(AlarmReceiver.EXTRA_PRAYER_ID, prayerId)
        val requestCode = prayerLabels.indexOf(prayerId)
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun arm(context: Context, prayerId: String, epochMillis: Long) {
        alarmManager(context).setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            epochMillis,
            pendingIntentFor(context, prayerId)
        )
    }

    fun cancel(context: Context, prayerId: String) {
        alarmManager(context).cancel(pendingIntentFor(context, prayerId))
    }

    fun cancelAll(context: Context) {
        prayerLabels.forEach { cancel(context, it) }
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager(context).canScheduleExactAlarms()
        } else {
            true
        }
    }
}
