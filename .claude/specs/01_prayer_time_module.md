# Salah Time Module Requirements

## Overview

The Salah Time module provides accurate prayer times and prayer status information based on the user's current location and timezone.

The module must support offline calculations after obtaining location coordinates and should update automatically throughout the day without requiring manual refresh.

The feature should provide both quick access information on the home dashboard and detailed daily prayer information on a dedicated screen.

---

# Implementation Status (as of 2026-07-14)

Legend: ✅ Implemented · ⚠ Partial · ❌ Missing

| Area | Status | Notes |
| --- | --- | --- |
| Prayer time calc (adhan_dart, offline) | ✅ | `providers/prayer_time_provider.dart` |
| GPS location + permission | ✅ | `services/location_service.dart` — GPS only, no manual city fallback |
| Hijri date (offset ±1) | ✅ | `core/widgets/date_header_row.dart` |
| Hijri day-start setting (Midnight vs Sunset/Maghrib) | ✅ | `HijriDayStart` enum + `displayHijriOffsetDays` getter in `prayer_time_provider.dart`; dedicated `screens/hijri_settings_screen.dart`, reached via a chevron on the dashboard's Hijri date line |
| Gregorian date on dashboard | ✅ | `core/widgets/date_header_row.dart` |
| Sunrise/Sunset on dashboard date row | ✅ | `core/widgets/date_header_row.dart` (icon + time, optional params) |
| Home dashboard: current-prayer card | ✅ | `widgets/prayer_time_card.dart` — name, start/end range, countdown, progress bar, secondary-theme-color fill; hides itself during the Isha→Tahajjud gap (see Known limitation below) instead of showing stale data |
| Home dashboard: next-prayer card | ✅ | `widgets/prayer_schedule_cards.dart` (`PrayerScheduleSection`) — separate outlined card below the current-prayer card |
| Home dashboard: Sehri/Iftar card | ✅ | `widgets/prayer_schedule_cards.dart` — flips between "Today's Schedule"/"Iftar starts in" and "Tomorrow's Schedule"/"Sehri ends in" around Maghrib, `HH:MM:SS` live countdown |
| Home dashboard: forbidden times reference card | ✅ | `widgets/forbidden_times_card.dart` — always visible (not gated to normal status), highlights the currently-active window |
| Forbidden-time state (dashboard + details) | ✅ | `activeForbiddenPeriod`/`forbiddenPeriods` in the provider; dashboard forbidden card + detail-screen inline warning cards + `_ForbiddenTimesSection` |
| Before-Fajr / Ramadan card states | ✅ | Ramadan Sehri/Iftar wording via `HijriCalendar` month check; before-Fajr folds into the unified prayer cycle below rather than a separate card state |
| Unified prayer cycle (Tahajjud→Fajr→Ishraq→Chasht→Dhuhr→Asr→Maghrib→Isha) | ✅ | `_buildWindows`/`_prayerWindows` in `prayer_time_provider.dart` — replaces raw `adhan_dart` `Prayer`-enum branching everywhere (dashboard cards, detail list, notifications) with one shared window list. Ishraq starts 15min after sunrise (reuses the Sunrise-forbidden window's own end); Chasht starts at the sunrise↔Dhuhr midpoint; both are new, not in the original spec |
| Prayer details screen: daily schedule | ✅ | `screens/prayer_time_screen.dart` — 3-state (✓/●/○) indicator, each row shows a `start – end` range (not just a single time); Sunrise/Sunset kept as extra non-highlightable marker rows |
| Sunrise/Sunset/Sehri/Iftar/middle-of-night/last-third/Tahajjud/Qiyam | ✅ | `_AdditionalInfoSection` in `prayer_time_screen.dart`, via `SunnahTimes` |
| Forbidden period list (5 periods) | ⚠ | 3 implemented (Sunrise, Zawal, Sunset) — `Fajr→Sunrise` and `Asr→Sunset` from the original 5-period spec were not built as separate forbidden windows; the equivalent guidance is covered by the current-prayer card's own Fajr/Asr window display instead |
| Location info panel (city/country/coords/method/madhab) | ❌ | no reverse geocoding; coordinates exist but aren't surfaced |
| Calculation method setting | ❌ | hardcoded to Muslim World League, not user-selectable |
| Madhab setting | ✅ | `Madhab` field + `setMadhab`, default Hanafi, `_MadhabSection` (`SegmentedButton`) in `prayer_time_screen.dart` |
| Time format (12h/24h) setting | ❌ | uses `TimeOfDay.format(context)` (follows device locale, not a user toggle) |
| Location mode (GPS vs manual city) | ❌ | GPS-only |
| Notification on/off per prayer | ✅ | `screens/prayer_time_screen.dart` settings section, `prayerLabels` (5 obligatory) |
| Notification on/off per optional prayer (Tahajjud/Ishraq/Chasht) | ✅ | `optionalNotificationLabels`, default off; `prayer_notification_service.dart`'s generalized optional-label loop (ids 10-15) |
| Notification custom offset (5/10/15/30 min before) | ❌ | only exact-time notification exists |
| Mosque manual time adjustment (+/- min per prayer) | ❌ | not built |
| Current-prayer detection exposed to UI | ✅ | `currentPrayer` getter, driven by the unified window list, not raw `adhan_dart` |
| Current-prayer remaining time / progress % | ✅ | `currentPrayerRemaining`, `currentPrayer.progress` |
| Forbidden-time detection (`isForbiddenTime`) | ✅ | `isForbiddenTime`/`activeForbiddenPeriod` |
| Daily refresh (midnight rollover) | ✅ | `PrayerTimeProvider.today` getter recomputes on date change |
| Daily refresh (location/timezone/settings change) | ⚠ | only re-renders via Provider; no explicit change-triggered recompute for timezone shifts |
| Explicit state machine (Loading/PermissionRequired/GPSDisabled/LocationUnavailable/Error/Normal/Forbidden) | ✅ | `PrayerStatus` enum — note: the originally-planned separate `tahajjud` status case was removed; Tahajjud is now just another name inside `normal`, rendered identically to every other prayer (per explicit user decision to "treat every prayer the same") |
| Domain model entities (CurrentPrayerEntity, NextPrayerEntity, ForbiddenPeriodEntity, DailyPrayerSummaryEntity, LocationEntity) | ❌ | raw `adhan_dart` `PrayerTimes`/`Prayer` types + plain Dart records used directly; per this repo's [[CLAUDE.md]] simplicity rule, formal entity/DTO layers are intentionally avoided |
| Packages: `geocoding` | ❌ | not added — needed for city/country name display |
| Packages: `permission_handler` | ❌ | not added — permission requests instead go through `geolocator`'s and `flutter_local_notifications`' own built-in permission APIs, which cover the same need without an extra dependency |
| Countdown tick rate | ✅ | every second (`Timer.periodic(Duration(seconds: 1))`) in `prayer_time_card.dart` and `prayer_schedule_cards.dart` |
| Accessibility (large fonts / screen readers) | ⚠ | `Semantics` labels added to the dashboard card; no dedicated large-text-scale audit |

**Biggest open decision:** this spec's Settings section (configurable calculation method, manual mosque offsets, notification pre-offsets, manual city location) remains out of scope, as previously agreed. Building the items still marked ❌ above is a distinct follow-up scope, not a bug in the current build.

**Known limitation (by design):** Tahajjud's recommended start is the last third of the night, but Isha's own window still ends at middle-of-night (kept as-is per explicit user instruction) — this leaves an intentional gap between middle-of-night and last-third-of-night where no prayer is "current." The dashboard's current-prayer card hides itself during that gap (rather than crash or show stale data); the Next Prayer card keeps showing "Tahajjud" throughout, since `nextPrayerPeriod` looks for the next upcoming window regardless of whether one is currently active.

---

# Product Goals

The module should allow users to:

* Know the current prayer and remaining time. ✅
* Know the next prayer and countdown. ✅
* Know whether prayer is currently forbidden. ✅
* View complete daily prayer times. ✅
* View sunrise and sunset times. ✅
* View Sehri and Iftar times. ✅
* View prayer-related information without opening another app. ✅
* Continue using prayer times offline after initial location retrieval. ✅

---

# Core Features

## Home Dashboard Prayer Card ✅ Implemented (location name not shown — no reverse geocoding, out of scope)

The home screen should contain a compact prayer status card.

### During Prayer Time ✅ Implemented (location name not shown)

Display:

* Current prayer name
* Current prayer start time
* Current prayer end time
* Remaining time until current prayer ends
* Next prayer name
* Next prayer start time
* Countdown until next prayer starts
* Prayer progress percentage
* User location name

Example:

```text
Current Prayer
Asr

Ends in 01:12:32

Started 03:45 PM
Ends 06:28 PM

Next Prayer
Maghrib in 01:12:32
```

---

### During Forbidden Time ✅ Implemented

When prayer is forbidden the card changes state.

Display:

* Forbidden time title
* Reason for prohibition
* Remaining forbidden duration
* Next available prayer
* Countdown until prayer becomes permissible

Example:

```text
Forbidden Time

Sunrise Period

Ends in 00:11:23

Next Prayer
Dhuhr in 04:22:10
```

---

### Before Fajr State ✅ Implemented (folds into the unified Tahajjud→Fajr window rather than a separate card state — see the unified-cycle row in the status table)

Display:

* Current state: Night
* Fajr countdown
* Sehri end time

Example:

```text
Fajr starts in 01:35:22
Sehri ends at 04:18 AM
```

---

### Ramadan State ✅ Implemented (Sehri/Iftar card + label swap; a dedicated Ramadan visual theme was not built, just the data/wording)

Additional information:

* Sehri ending time
* Iftar countdown
* Iftar time

Example:

```text
Iftar in 02:18:22
Maghrib at 06:37 PM
```

---

# Prayer Details Screen ✅ Implemented

The details screen provides complete information for the current day.

---

## Daily Prayer Schedule ✅ Implemented (3-state ✓/●/○ indicator; rows show a start–end range, and include Ishraq/Chasht/Tahajjud beyond the spec's original 6)

Display all prayer times:

| Prayer  | Time  |
| ------- | ----- |
| Fajr    | 04:18 |
| Sunrise | 05:33 |
| Dhuhr   | 12:05 |
| Asr     | 15:42 |
| Maghrib | 18:36 |
| Isha    | 19:52 |

Each prayer row must support:

* Prayer name
* Prayer time
* Current prayer indicator
* Upcoming prayer indicator
* Completed prayer indicator

Example:

```text
✓ Fajr
✓ Dhuhr
● Asr
○ Maghrib
○ Isha
```

---

## Additional Daily Information ✅ Implemented

Display:

* Sunrise time
* Sunset time
* Sehri end time
* Iftar time
* Middle of night
* Last third of night
* Tahajjud start time
* Qiyam time

---

## Forbidden Prayer Times ⚠ Partial (3 of the 5 listed periods below — Sunrise, Zawal, Sunset; see the status-table note)

Display all forbidden periods.

### Forbidden Period 1

After Fajr until Sunrise.

```text
Fajr → Sunrise
```

---

### Forbidden Period 2

Sunrise period.

```text
Sunrise → Sunrise + 15 minutes
```

---

### Forbidden Period 3

Zawal period.

```text
Dhuhr - 10 minutes → Dhuhr
```

---

### Forbidden Period 4

After Asr until Sunset.

```text
Asr → Sunset
```

---

### Forbidden Period 5

Sunset period.

```text
Sunset - 15 minutes → Sunset
```

Each forbidden period should show:

* Name
* Start time
* End time
* Current active state

---

## Location Information ❌ Missing (coordinates exist internally but aren't surfaced anywhere; no reverse geocoding for city/country)

Display:

* City name
* Country name
* Coordinates
* Calculation method
* Madhab
* Last location update time

---

# Settings Requirements ⚠ Partial (Hijri offset ±1 day + day-start Midnight/Sunset, Madhab Hanafi/Shafi, per-prayer + optional-prayer notification on/off exist; calc method/time format/location mode/mosque offset/notification pre-offset remain out of scope)

---

## Prayer Calculation Method ❌ Missing — hardcoded to Muslim World League, no picker

Supported methods:

* Muslim World League
* Umm Al-Qura
* Egyptian
* Karachi
* Dubai
* Kuwait
* Singapore
* Turkey
* Moonsighting Committee

Default:

```text
Muslim World League
```

---

## Madhab Selection ✅ Implemented — Hanafi default, matches this spec

Supported values:

* Hanafi
* Shafi

Default:

```text
Hanafi
```

---

## Time Format ❌ Missing — currently follows device locale via `TimeOfDay.format(context)`, not a user-facing toggle

Supported values:

* 12 hour
* 24 hour

---

## Location Mode ❌ Missing — GPS-only, no manual city fallback/override

Supported values:

* Automatic GPS location
* Manual city selection

---

## Prayer Notification Settings ⚠ Partial — enable/disable per prayer works; custom offset does not exist (always fires at exact prayer time)

Each prayer supports:

* Enable notification
* Disable notification
* Custom offset

Supported offsets:

* At prayer time
* 5 minutes before
* 10 minutes before
* 15 minutes before
* 30 minutes before

---

## Mosque Adjustment Offset ❌ Missing

Allow users to adjust prayer times manually.

Example:

```text
Fajr +2 min
Maghrib -1 min
```

---

# Functional Requirements

---

## Current Prayer Detection ✅ Implemented — `PrayerTimeProvider.currentPrayer`, driven by the unified window list (not raw `adhan_dart` calls)

The module must determine:

```text
currentPrayer(now)
```

Example:

```text
12:40 PM -> Dhuhr
04:10 PM -> Asr
```

---

## Next Prayer Detection ✅ Implemented — `PrayerTimeProvider.nextPrayer`

The module must determine:

```text
nextPrayer(now)
```

Example:

```text
Current: Asr
Next: Maghrib
```

---

## Current Prayer Remaining Time ✅ Implemented — `currentPrayerRemaining`

Formula:

```text
nextPrayerTime - currentTime
```

---

## Next Prayer Countdown ✅ Implemented — home card ticks every second; not separately shown on the details screen (not required there)

Formula:

```text
nextPrayerStartTime - currentTime
```

---

## Forbidden Time Detection ✅ Implemented — `isForbiddenTime`/`activeForbiddenPeriod`

The module must determine:

```text
isForbiddenTime(now)
```

If true:

* Determine forbidden type.
* Determine end time.
* Determine next valid prayer.

---

## Prayer Progress Calculation ✅ Implemented — `currentPrayer.progress`

Formula:

```text
elapsedPrayerDuration / totalPrayerDuration
```

Returns:

```text
0.0 -> 1.0
```

---

## Daily Refresh Logic ⚠ Partial

Prayer times should refresh:

* At midnight ✅ (`PrayerTimeProvider.today` getter recomputes when the calendar day rolls over)
* When location changes ❌ (no repeated GPS polling/refresh after initial fetch)
* When timezone changes ❌ (not explicitly handled)
* When calculation settings change ❌ (no settings to change yet — method/madhab are hardcoded)

---

# State Management Requirements ✅ Implemented — `PrayerStatus` enum (loading/permissionRequired/gpsDisabled/locationUnavailable/error/forbidden/normal); Tahajjud no longer gets its own status case, it's just another name within `normal` (see status-table note)

The module should expose:

## Loading State

```text
Loading prayer times...
```

---

## Permission Required State

```text
Location permission required
```

---

## GPS Disabled State

```text
Please enable location service
```

---

## Location Unavailable State

```text
Unable to determine location
```

---

## Error State

```text
Unable to calculate prayer times
```

---

## Normal State

Prayer information available.

---

## Forbidden State

Prayer forbidden information available.

---

# Edge Cases ⚠ Partial — only date rollover is explicitly handled; the rest rely on unverified library defaults

The module must support:

* Permission denied
* Permission permanently denied
* GPS disabled
* Invalid coordinates
* No internet connection
* Timezone changes
* Device clock changes
* Daylight saving changes
* App resumes from background
* Date rollover while app is open
* Crossing midnight
* High latitude locations
* Failed geocoding lookup

---

# Domain Models ❌ Missing — the app uses `adhan_dart`'s raw `PrayerTimes`/`Prayer` types directly instead of these entities. Note: this repo's [[CLAUDE.md]] explicitly avoids Clean-Architecture-style Entity/DTO layering, so these should be introduced (if at all) as plain data classes for the features listed above, not a formal domain layer

## PrayerTimeEntity

```text
fajr
sunrise
dhuhr
asr
maghrib
isha
```

---

## CurrentPrayerEntity

```text
prayerName
startTime
endTime
remainingDuration
progress
```

---

## NextPrayerEntity

```text
prayerName
startTime
remainingDuration
```

---

## ForbiddenPeriodEntity

```text
type
startTime
endTime
remainingDuration
```

---

## DailyPrayerSummaryEntity

```text
fajr
sunrise
dhuhr
asr
maghrib
isha
sehri
iftar
sunset
middleOfNight
lastThirdNight
tahajjudStart
```

---

## LocationEntity

```text
latitude
longitude
city
country
timezone
```



# Recommended Packages

## Prayer Calculation ✅ Implemented (using `adhan_dart`, the Dart port — plain `adhan` is a Flutter/Dart-incompatible native package)

```text
adhan
```

---

## Location ✅ Implemented

```text
geolocator
```

---

## Reverse Geocoding ❌ Missing — not added, needed for city/country display

```text
geocoding
```

---

## Permissions ⚠ Not added as a separate package — `geolocator` and `flutter_local_notifications` each expose their own permission-request APIs, which cover the same need

```text
permission_handler
```



## Notifications ✅ Implemented

```text
flutter_local_notifications
timezone
```

---

# Performance Requirements ⚠ Partial

* Prayer calculations should happen only once per day. ✅ (`PrayerTimeProvider._recompute` is lazy, triggered only on date rollover)
* Countdown updates should happen every second. ✅ (`Timer.periodic(Duration(seconds: 1))` in both `prayer_time_card.dart` and `prayer_schedule_cards.dart`)
* Location updates should not occur continuously. ✅ (GPS fetched once in `init()`, not polled)
* Battery usage should remain minimal. ✅ (follows from the above)
* UI updates should rebuild only required widgets. ✅ (`context.watch<PrayerTimeProvider>()` scoped to the card/screen, not the whole tree)

---


# Accessibility Requirements ❌ Not explicitly verified

Support:

* Large fonts
* Screen readers


---

# Acceptance Criteria

The feature is complete when:

* User can view current prayer. ✅
* User can view next prayer. ✅
* User can view remaining time. ✅ both current-prayer remaining and next-prayer countdown
* User can view all daily prayer times. ✅ (Tahajjud/Fajr/Ishraq/Chasht/Dhuhr/Asr/Maghrib/Isha + Sunrise/Sunset markers)
* User can view forbidden periods. ✅ (3 of the 5 originally listed — see Forbidden Prayer Times note)
* User can view sunrise and sunset. ✅ (dashboard date row + detail-screen list + Additional Info)
* User can view Sehri and Iftar. ✅
* Prayer information updates automatically. ✅ recomputes on date rollover; countdown ticks every second
* App works offline after location retrieval. ✅ (adhan_dart calc is fully offline once coordinates are known)
* Notifications work correctly. ⚠ on/off per prayer (obligatory + optional) works; no custom pre-offset, not device-tested end-to-end yet
* Settings persist after app restart. ✅ Hijri offset, Hijri day-start, Madhab, per-prayer toggles — all via SharedPreferences
* Time calculations remain correct across date changes and timezone changes. ⚠ date-change handled; timezone-change behavior unverified

---

# Future Enhancements

* Prayer tracking history
* Missed prayer tracking
* Prayer streaks
* Home screen widgets
* Wear OS support
* Smart watch notifications
* Nearby mosque finder
* Qibla direction integration
* Ramadan dashboard
* Monthly prayer calendar
* Prayer time sharing
* Prayer time export
* Multiple city support
