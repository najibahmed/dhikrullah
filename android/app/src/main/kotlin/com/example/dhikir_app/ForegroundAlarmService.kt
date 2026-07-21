package com.example.dhikir_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/** Native alarm playback lifecycle: audio + vibration + ongoing notification,
 * auto-stopping when playback completes (per alarm_foreground_service.md).
 * Optionally launches FullScreenAlarmActivity via full-screen intent when
 * alarm_fullscreen_<Label> is on and the OS grants full-screen-intent use. */
class ForegroundAlarmService : Service() {

    companion object {
        private const val TAG = "ForegroundAlarmService"
        const val ACTION_DISMISS = "com.example.dhikir_app.action.DISMISS_ALARM"
        const val ACTION_ALARM_STOPPED = "com.example.dhikir_app.action.ALARM_STOPPED"
        private const val CHANNEL_ID = "alarm_playback_channel"
        private const val NOTIFICATION_ID = 1001
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_VIBRATE_PREFIX = "flutter.alarm_vibrate_"
        private const val KEY_FULLSCREEN_PREFIX = "flutter.alarm_fullscreen_"
        private val VIBRATE_PATTERN = longArrayOf(0, 1000, 1000)
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        @Suppress("DEPRECATION")
        vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_DISMISS) {
            stopAlarm()
            stopSelf(startId)
            return START_NOT_STICKY
        }

        val prayerId = intent?.getStringExtra(AlarmReceiver.EXTRA_PRAYER_ID)
        if (prayerId == null) {
            stopSelf(startId)
            return START_NOT_STICKY
        }
        val label = intent.getStringExtra(AlarmReceiver.EXTRA_PRAYER_LABEL) ?: prayerId

        startForeground(NOTIFICATION_ID, buildNotification(prayerId, label))
        if (isVibrationEnabled(prayerId)) startVibration()
        if (isRingerSilentOrVibrate()) {
            Log.i(TAG, "Ringer is silent/vibrate — skipping adhan playback for $prayerId")
        } else {
            startPlayback()
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Prayer Alarms",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Full prayer alarm playback, separate from prayer reminders"
            setSound(null, null)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(prayerId: String, label: String): android.app.Notification {
        val dismissIntent = Intent(this, ForegroundAlarmService::class.java).setAction(ACTION_DISMISS)
        val dismissPendingIntent = PendingIntent.getService(
            this,
            0,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(label)
            .setContentText("Prayer alarm is playing")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(0, "Dismiss", dismissPendingIntent)

        if (isFullscreenEnabled(prayerId) && AlarmPermissions.canUseFullScreenIntent(this)) {
            val fullScreenIntent = Intent(this, FullScreenAlarmActivity::class.java)
                .putExtra(FullScreenAlarmActivity.EXTRA_PRAYER_ID, prayerId)
                .putExtra(FullScreenAlarmActivity.EXTRA_PRAYER_LABEL, label)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val fullScreenPendingIntent = PendingIntent.getActivity(
                this,
                0,
                fullScreenIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.setFullScreenIntent(fullScreenPendingIntent, true)
        }

        return builder.build()
    }

    private fun isVibrationEnabled(prayerId: String): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean("$KEY_VIBRATE_PREFIX$prayerId", true)
    }

    private fun isFullscreenEnabled(prayerId: String): Boolean {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean("$KEY_FULLSCREEN_PREFIX$prayerId", false)
    }

    /** Silent and Vibrate ringer modes both suppress adhan audio — vibration
     * still follows [isVibrationEnabled] unchanged, it isn't forced on. */
    private fun isRingerSilentOrVibrate(): Boolean {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL
    }

    private fun startVibration() {
        val vib = vibrator ?: return
        if (!vib.hasVibrator()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vib.vibrate(VibrationEffect.createWaveform(VIBRATE_PATTERN, 0))
        } else {
            @Suppress("DEPRECATION")
            vib.vibrate(VIBRATE_PATTERN, 0)
        }
    }

    private fun startPlayback() {
        try {
            val player = MediaPlayer.create(this, R.raw.adhan_makkah)
            if (player == null) {
                Log.w(TAG, "MediaPlayer.create returned null for R.raw.adhan_makkah — notification-only alarm")
                return
            }
            mediaPlayer = player
            player.setOnCompletionListener {
                stopAlarm()
                stopSelf()
            }
            player.start()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start adhan playback, falling back to notification-only", e)
            mediaPlayer = null
        }
    }

    private fun stopAlarm() {
        vibrator?.cancel()
        mediaPlayer?.let {
            try {
                if (it.isPlaying) it.stop()
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping MediaPlayer", e)
            }
            it.release()
        }
        mediaPlayer = null
        sendBroadcast(Intent(ACTION_ALARM_STOPPED).setPackage(packageName))
        NotificationManagerCompat.from(this).cancel(NOTIFICATION_ID)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }
}
