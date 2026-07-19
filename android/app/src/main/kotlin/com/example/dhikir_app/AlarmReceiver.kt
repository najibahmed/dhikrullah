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
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerId = intent.getStringExtra(EXTRA_PRAYER_ID) ?: return
        val serviceIntent = Intent(context, ForegroundAlarmService::class.java)
            .putExtra(EXTRA_PRAYER_ID, prayerId)
        ContextCompat.startForegroundService(context, serviceIntent)
    }
}
