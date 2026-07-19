package com.example.dhikir_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log

/** Shared AlarmManager arm/cancel logic — used by both AlarmMethodChannel
 * (live app requests) and BootReceiver (restore after reboot), so the two
 * never construct PendingIntents differently for the same prayer. */
object AlarmArmer {

    private const val TAG = "AlarmArmer"

    /** Must match lib/features/alarm/models/alarm_settings.dart's alarmPrayerLabels. */
    val prayerLabels = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Tahajjud")

    private fun alarmManager(context: Context): AlarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun pendingIntentFor(context: Context, prayerId: String, label: String): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java)
            .putExtra(AlarmReceiver.EXTRA_PRAYER_ID, prayerId)
            .putExtra(AlarmReceiver.EXTRA_PRAYER_LABEL, label)
        val requestCode = prayerLabels.indexOf(prayerId)
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /** [label] is the locale-aware display name computed by Dart at schedule
     * time (native has no access to Flutter's AppLocalizations) — shown as
     * the alarm notification's title; [prayerId] stays the fixed English key.
     * Returns false (never throws) if the OS refused the exact alarm — e.g.
     * SCHEDULE_EXACT_ALARM revoked at runtime on Android 12+. */
    fun arm(context: Context, prayerId: String, epochMillis: Long, label: String): Boolean {
        return try {
            alarmManager(context).setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                epochMillis,
                pendingIntentFor(context, prayerId, label)
            )
            true
        } catch (e: SecurityException) {
            Log.e(TAG, "Exact alarm permission denied for $prayerId", e)
            false
        }
    }

    fun cancel(context: Context, prayerId: String) {
        // PendingIntent matching ignores extras (action/component/requestCode
        // only), so the label passed here doesn't need to match the armed one.
        alarmManager(context).cancel(pendingIntentFor(context, prayerId, prayerId))
    }

    fun cancelAll(context: Context) {
        prayerLabels.forEach { cancel(context, it) }
    }
}
