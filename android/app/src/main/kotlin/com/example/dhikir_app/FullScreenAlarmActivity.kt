package com.example.dhikir_app

import android.app.Activity
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

/** Same layout for every prayer — only the title text changes. Launched via
 * the alarm notification's full-screen intent when alarm_fullscreen_<Label>
 * is enabled for that prayer (per alarm_fullscreen_flow.md). */
class FullScreenAlarmActivity : Activity() {

    companion object {
        const val EXTRA_PRAYER_ID = "prayerId"
        const val EXTRA_PRAYER_LABEL = "prayerLabel"
    }

    private val alarmStoppedReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = finish()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showOverLockScreen()
        setContentView(R.layout.activity_full_screen_alarm)

        val label = intent.getStringExtra(EXTRA_PRAYER_LABEL)
            ?: intent.getStringExtra(EXTRA_PRAYER_ID)
            ?: "Prayer"
        findViewById<TextView>(R.id.tvPrayerName).text = label
        findViewById<TextView>(R.id.tvSubtitle).text = "It's time for $label"
        findViewById<Button>(R.id.btnStop).setOnClickListener { stopAlarmAndFinish() }
    }

    override fun onResume() {
        super.onResume()
        val filter = IntentFilter(ForegroundAlarmService.ACTION_ALARM_STOPPED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(alarmStoppedReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(alarmStoppedReceiver, filter)
        }
    }

    override fun onPause() {
        unregisterReceiver(alarmStoppedReceiver)
        super.onPause()
    }

    private fun showOverLockScreen() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            getSystemService(KeyguardManager::class.java)?.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    private fun stopAlarmAndFinish() {
        startService(
            Intent(this, ForegroundAlarmService::class.java)
                .setAction(ForegroundAlarmService.ACTION_DISMISS)
        )
        finish()
    }
}
