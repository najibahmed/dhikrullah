package com.example.dhikir_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONArray

/** BOOT_COMPLETED -> re-arm future alarms from the timestamps Dart already
 * persisted. Never calculates prayer times natively — persisted
 * `alarm_scheduled_times` is the only source (per alarm_api_contract.md). */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SCHEDULED_TIMES = "flutter.alarm_scheduled_times"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_SCHEDULED_TIMES, null) ?: return

        val now = System.currentTimeMillis()
        try {
            val entries = JSONArray(raw)
            // Entries are persisted ascending by epochMillis and may hold
            // both a today and tomorrow occurrence per prayer — arm only
            // the nearest, since AlarmArmer's PendingIntent identity is
            // keyed by prayerId alone and a second arm() for the same
            // prayer would silently replace the first.
            val armedPrayerIds = mutableSetOf<String>()
            for (i in 0 until entries.length()) {
                val entry = entries.getJSONObject(i)
                val prayerId = entry.getString("prayerId")
                val epochMillis = entry.getLong("epochMillis")
                val label = entry.optString("label", prayerId)
                if (prayerId !in AlarmArmer.prayerLabels) continue
                if (epochMillis <= now) continue
                if (!armedPrayerIds.add(prayerId)) continue
                AlarmArmer.arm(context, prayerId, epochMillis, label)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to restore alarms from $KEY_SCHEDULED_TIMES", e)
        }
    }
}
