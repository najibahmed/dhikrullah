# Full Screen Flow

Native Android activity (`FullScreenAlarmActivity`), not Flutter. Default **off** per prayer (`alarm_fullscreen_<Label>`).

## Launch
ForegroundAlarmService decides:
If fullscreen enabled AND canUseFullScreenIntent()
→ Full-screen intent on the alarm notification launches FullScreenAlarmActivity
Else
→ Stay notification only

Activity flags: showWhenLocked, turnScreenOn, excludeFromRecents.

## Android 14+
Full-screen intent needs special access. Requested when user first enables fullscreen for a prayer (openFullScreenIntentSettings). Denied → notification-only fallback.

## UI
- Prayer name
- Stop button

## Stop
Stop button
→ Service stop command
→ Stop audio
→ Stop vibration
→ Remove notification
→ Finish activity
→ Stop service

## Auto-finish
Audio completes without dismiss → service teardown finishes activity too.

## State
Scheduled
→ Triggered
→ Playing
→ Dismissed / AutoStopped
→ Completed
