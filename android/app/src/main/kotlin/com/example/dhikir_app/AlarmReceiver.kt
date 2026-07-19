package com.example.dhikir_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

/** Fires when an armed AlarmManager alarm goes off. Starts ForegroundAlarmService,
 * which owns playback/vibration/notification (phase 4). */
class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_PRAYER_ID = "prayerId"
        const val EXTRA_PRAYER_LABEL = "prayerLabel"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerId = intent.getStringExtra(EXTRA_PRAYER_ID) ?: return
        val label = intent.getStringExtra(EXTRA_PRAYER_LABEL) ?: prayerId
        val serviceIntent = Intent(context, ForegroundAlarmService::class.java)
            .putExtra(EXTRA_PRAYER_ID, prayerId)
            .putExtra(EXTRA_PRAYER_LABEL, label)
        ContextCompat.startForegroundService(context, serviceIntent)
    }
}
