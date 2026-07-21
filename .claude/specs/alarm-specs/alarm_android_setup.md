# Android Setup

## Permissions
Already in manifest:
- POST_NOTIFICATIONS
- SCHEDULE_EXACT_ALARM
- RECEIVE_BOOT_COMPLETED

Add:
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_MEDIA_PLAYBACK
- WAKE_LOCK
- USE_FULL_SCREEN_INTENT

## Manifest
Register (Kotlin, app package):
- AlarmReceiver (exported=false)
- BootReceiver (BOOT_COMPLETED intent filter)
- ForegroundAlarmService (foregroundServiceType="mediaPlayback")
- FullScreenAlarmActivity (showWhenLocked, turnScreenOn, excludeFromRecents)

## Audio Asset
- `assets/audio/adhan_makkah.mp3` declared in pubspec (Flutter side, future preview use)
- Mirrored to `android/app/src/main/res/raw/adhan_makkah.mp3` — native MediaPlayer source

## Exact Alarm Flow
App start / alarm enable
→ Check canScheduleExactAlarms
→ Granted: arm
→ Denied: navigate to exact-alarm settings
→ Retry arming on return

## Full-Screen Intent (Android 14+)
User enables fullscreen for a prayer
→ Check NotificationManager.canUseFullScreenIntent()
→ Denied: navigate to full-screen intent special access settings
→ Fullscreen falls back to notification-only until granted

## Boot
BOOT_COMPLETED
→ BootReceiver reads `alarm_scheduled_times` from FlutterSharedPreferences
→ Re-arm future timestamps only
→ No prayer calculation natively — persisted timestamps are the only source

## Error Handling
- Permission denied → explicit status, never crash
- Alarm schedule failure → log, return failure
- Missing res/raw asset → fallback to notification-only alarm, log
- Invalid offset → clamp to -60..+60
