# Alarm & Adhan Implementation

## Purpose
Integrate an Android-only prayer alarm module into the existing app without changing the current prayer calculation and notification scheduling.

## Status
All open decisions resolved (2026-07-18). This file is the source of truth for the implementation.

## Existing System
- Prayer calculation exists (`PrayerTimeProvider`, adhan_dart)
- Notification scheduling exists (`PrayerNotificationService`)
- flutter_local_notifications
- Provider state management
- Hive + SharedPreferences

## Resolved Decisions
- **Scope**: 6 alarm-capable prayers — Fajr, Dhuhr, Asr, Maghrib, Isha, Tahajjud. Ishraq/Chasht stay notification-only.
- **Architecture**: native Kotlin. AlarmManager exact alarms → BroadcastReceiver → ForegroundService (MediaPlayer) → optional native FullScreenAlarmActivity. Flutter side: settings UI + scheduling only, bridged via MethodChannel. No new Flutter packages.
- **Audio**: single bundled tone `assets/audio/adhan_makkah.mp3` (declare in pubspec) mirrored into `android/app/src/main/res/raw/adhan_makkah.mp3` so native MediaPlayer plays without the Flutter engine. No tone picker; ToneId reserved for future.
- **Persistence**: SharedPreferences only. Native reads the same `FlutterSharedPreferences` store. No new Hive box/typeId.
- **Rescheduling**: Flutter precomputes alarm timestamps for today + tomorrow (+48h) on app open and on alarm-setting change, persists them, arms via MethodChannel. Native BootReceiver re-arms from persisted timestamps only (future ones only). App unopened 2+ days → alarms lapse until next open (accepted; same limitation as notifications).
- **Playback end**: auto-stop. Audio finishes → vibration stops, notification cleared, fullscreen finishes, service stops itself. Dismiss only cuts it short.
- **Tahajjud time**: window start (last third of night, from existing provider) + offset.
- **Offset**: -60..+60 minutes, step 5, per prayer.
- **Defaults**: enabled=false, offset=0, vibration=on, fullscreen=off, tone=adhan_makkah.
- **Coexistence**: alarms independent of reminder notifications; both may be enabled for the same prayer.
- **Settings UI**: alarm section added to the existing per-prayer bell bottom sheet (`prayer_notification_bottom_sheet.dart`), shown only for the 6 alarm-capable prayers.

## New Modules

### Dart (Flutter)
- **AlarmService** — entry point; initialize, schedule/cancel/reschedule, dismiss; talks to Kotlin over MethodChannel.
- **AlarmSettingsRepository** — per-prayer settings in SharedPreferences.
- **AlarmScheduler** (Dart part) — converts prayer time + offset into alarm timestamps for today + tomorrow, persists them for boot restore.

### Kotlin (android/)
- **AlarmMethodChannel** — MethodChannel handler in MainActivity; arm/cancel exact alarms, query state.
- **AlarmReceiver** — BroadcastReceiver; alarm fires → starts ForegroundAlarmService.
- **ForegroundAlarmService** — audio focus, vibration, MediaPlayer playback of res/raw/adhan_makkah, ongoing notification, auto-stop on completion.
- **FullScreenAlarmActivity** — native activity; prayer name + stop button; launched via full-screen intent when enabled.
- **BootReceiver** — BOOT_COMPLETED → re-arm future alarms from persisted timestamps.

## SharedPreferences Keys
Labels match existing prayer labels (`Fajr`, `Dhuhr`, `Asr`, `Maghrib`, `Isha`, `Tahajjud`), same pattern as `prayer_notify_<Label>`:

- `alarm_enabled_<Label>` — bool, default false
- `alarm_offset_<Label>` — int minutes, -60..+60 step 5, default 0
- `alarm_vibrate_<Label>` — bool, default true
- `alarm_fullscreen_<Label>` — bool, default false
- `alarm_scheduled_times` — JSON list of upcoming armed alarms `{prayerId, epochMillis, label}` for BootReceiver restore. `prayerId` (`Fajr`..`Tahajjud`) is the fixed English settings key; `label` is the locale-aware display name computed by Dart at schedule time (via `prayerDisplayNameFor`) and shown as the native notification/full-screen-activity title, since native Kotlin has no access to Flutter's `AppLocalizations`.

## Flow
Prayer time (from PrayerTimeProvider)
→ Apply per-prayer offset
→ Persist timestamps + arm via MethodChannel (AlarmManager exact)
→ Alarm fires → AlarmReceiver → ForegroundAlarmService
→ If fullscreen enabled: launch FullScreenAlarmActivity (full-screen intent)
→ Else: ongoing foreground notification only
→ User dismisses OR audio completes
→ Stop playback + vibration
→ Remove notification / finish activity
→ Stop service

## Phases
1. Dart data model + AlarmSettingsRepository (SharedPreferences)
2. Dart AlarmScheduler: timestamp computation + persistence (+48h)
3. ~~MethodChannel bridge + Kotlin AlarmMethodChannel + AlarmReceiver (arm/cancel exact alarms)~~ done
4. ~~ForegroundAlarmService: MediaPlayer + vibration + ongoing notification + auto-stop~~ done
5. ~~BootReceiver restore~~ done
6. ~~FullScreenAlarmActivity (optional per prayer)~~ done
7. ~~Permissions flows (exact alarm, full-screen intent special access on Android 14+)~~ done
8. ~~Bottom-sheet alarm UI section + reschedule triggers~~ done
9. ~~Testing~~ done (on-device, Pixel 5 / Android 14)

See:
- alarm_api_contract.md
- alarm_android_setup.md
- alarm_foreground_service.md
- alarm_fullscreen_flow.md
