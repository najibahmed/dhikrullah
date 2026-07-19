package com.example.dhikir_app

import android.app.Service
import android.content.Intent
import android.os.IBinder

/** Stub — phase 4 adds startForeground()+notification, MediaPlayer playback of
 * res/raw/athan, vibration and auto-stop. AlarmReceiver already targets this class
 * so the arm -> fire -> receiver -> service chain is wired end to end. */
class ForegroundAlarmService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // TODO(phase 4): read AlarmReceiver.EXTRA_PRAYER_ID, startForeground with
        // ongoing notification, play athan, vibrate, auto-stop on completion.
        return START_NOT_STICKY
    }
}
