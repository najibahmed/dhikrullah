# Foreground Service

Native Kotlin `ForegroundAlarmService`, type `mediaPlayback`.

## Lifecycle
Alarm fires (AlarmReceiver)
→ Start foreground service
→ Acquire audio focus
→ Start vibration (if alarm_vibrate_<Label> true)
→ Play `res/raw/athan.mp3` via MediaPlayer
→ Show ongoing notification
→ If fullscreen enabled: full-screen intent launches FullScreenAlarmActivity
→ Wait for dismiss OR MediaPlayer completion
→ Stop audio
→ Cancel vibration
→ Remove notification / finish activity
→ Stop foreground
→ Stop service

## Auto-stop
MediaPlayer onCompletion → same teardown as dismiss. No looping, no timeout needed.

## Notification
- Prayer name
- Dismiss action
- Ongoing
- High priority
- Alarm category
- Own channel (separate from `prayer_times` reminder channels)

## AlarmManager
Exact alarm (setExactAndAllowWhileIdle)
One request per prayer (6 max: 5 obligatory + Tahajjud)
Offset -60..+60 step 5
Timestamps precomputed by Dart, +48h horizon

## Errors
Missing raw asset → notification-only alarm, log
Log failures
Never crash service
