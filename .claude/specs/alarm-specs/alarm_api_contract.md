# Alarm API Contract

> Purpose:
>
> Define the public contracts between the Alarm module and the existing application.
>
> This document specifies interfaces and responsibilities only.
> It does not contain implementation details.

---

# Rules

- Never bypass these contracts.
- Existing modules communicate only through public APIs.
- Keep the Alarm module isolated from the notification scheduler.
- Avoid circular dependencies.
- All scheduling must go through AlarmService.
- Dart and Kotlin communicate only through the MethodChannel.

---

# Scope

Alarm-capable prayers: Fajr, Dhuhr, Asr, Maghrib, Isha, Tahajjud.
Ishraq/Chasht: notification-only, no alarm API surface.

---

# Module Dependency

PrayerTimeProvider (existing, Dart)
        │
        ▼
AlarmService (Dart)
        │
        ▼
AlarmScheduler (Dart: timestamps + persistence)
        │
        ▼ MethodChannel
AlarmMethodChannel (Kotlin)
        │
        ▼
Android AlarmManager
        │
        ▼
AlarmReceiver → ForegroundAlarmService (Kotlin, MediaPlayer)
        │
        ▼
Notification / FullScreenAlarmActivity

---

# Public Services

## AlarmService (Dart)

Purpose

Primary entry point.

Responsibilities

- Initialize module
- Schedule alarms
- Cancel alarms
- Reschedule alarms (app open, settings change)
- Dismiss active alarm
- Query alarm state

Public API

initialize()

schedulePrayerAlarm()

scheduleAllPrayerAlarms()

cancelPrayerAlarm()

cancelAllPrayerAlarms()

reschedulePrayerAlarms()

dismissAlarm()

isAlarmRunning()

---

## AlarmSettingsRepository (Dart)

Purpose

Persist per-prayer alarm settings in SharedPreferences.

Keys (Label = Fajr | Dhuhr | Asr | Maghrib | Isha | Tahajjud)

- alarm_enabled_<Label> — bool, default false
- alarm_offset_<Label> — int, -60..+60 step 5, default 0
- alarm_vibrate_<Label> — bool, default true
- alarm_fullscreen_<Label> — bool, default false
- alarm_scheduled_times — JSON list {prayerId, label, epochMillis}

Public API

get()

save()

update()

delete()

---

## AlarmScheduler (Dart)

Purpose

Convert prayer time + offset into alarm timestamps (today + tomorrow), persist for boot restore, arm via MethodChannel.

Public API

schedule()

cancel()

cancelAll()

restore()

---

## MethodChannel (Dart ↔ Kotlin)

Channel: `dhikir_app/alarm`

Dart → Kotlin

- armAlarm(prayerId, label, epochMillis)
- cancelAlarm(prayerId)
- cancelAllAlarms()
- dismissActiveAlarm()
- isAlarmRunning()
- canScheduleExactAlarms()
- canUseFullScreenIntent()
- openExactAlarmSettings()
- openFullScreenIntentSettings()

Kotlin side never calls back into Dart for alarm firing — service is fully native.

---

## ForegroundAlarmService (Kotlin)

Purpose

Manage alarm playback lifecycle natively.

Public API (intents)

start()

stop()

isRunning()

---

## AdhanPlayer (Kotlin, inside service)

Purpose

Play bundled `res/raw/athan.mp3` via MediaPlayer.

Public API

initialize()

play()

stop()

dispose()

---

# Models

## AlarmSettings

Contains

PrayerId

Enabled (default false)

OffsetMinutes (default 0)

ToneId (reserved — single tone "athan" for now, no picker)

VibrationEnabled (default true)

FullscreenEnabled (default false)

---

## AlarmRequest

Contains

PrayerId

PrayerName

PrayerTime

AlarmTime

Settings

---

## ActiveAlarm

Contains

PrayerId

StartTime

IsFullscreen

ToneId

---

# Event Flow

Prayer calculation (existing)

↓

AlarmService

↓

AlarmScheduler (persist +48h timestamps)

↓

MethodChannel → AlarmManager

↓

AlarmReceiver → ForegroundAlarmService

↓

Notification / Fullscreen

↓

Dismiss OR audio completes (auto-stop)

↓

ForegroundAlarmService.stop()

---

# Ownership

Prayer times

Owned by

Prayer module

---

Alarm scheduling

Owned by

Alarm module

---

Reminder notifications

Owned by

Notification module

---

Audio playback

Owned by

Alarm module (native)

---

# Communication Rules

Alarm module

MUST NOT

Calculate prayer times (Dart or Kotlin — BootReceiver restores persisted timestamps only).

---

Alarm module

MUST NOT

Modify reminder notifications. Alarm and reminder notification may both be enabled for the same prayer.

---

Alarm module

MUST

Use existing prayer calculation (PrayerTimeProvider).

---

Alarm module

MUST

Read settings from AlarmSettingsRepository.

---

# State Flow

Idle

↓

Scheduled

↓

Triggered

↓

Playing

↓

Dismissed / AutoStopped

↓

Completed

---

# Error Contract

Scheduling failure

↓

Log

↓

Return failure

---

Missing audio

↓

Fallback

↓

Notification-only alarm (no default asset beyond athan)

---

Permission denied

↓

Return explicit status

↓

Never crash

---

Foreground service failure

↓

Stop alarm safely

↓

Log error

---

# Future Extension Points

Reserved for

- Custom MP3
- Device alarm tones (ToneId already in model)
- Snooze
- Auto stop timeout (before audio end)
- Wear OS
- iOS implementation

These features must not require breaking the existing public APIs.
