# Salah Time Module Requirements

## Overview

The Salah Time module provides accurate prayer times and prayer status information based on the user's current location and timezone.

The module must support offline calculations after obtaining location coordinates and should update automatically throughout the day without requiring manual refresh.

The feature should provide both quick access information on the home dashboard and detailed daily prayer information on a dedicated screen.

---

# Implementation Status (as of 2026-07-13)

Legend: ✅ Implemented · ⚠ Partial · ❌ Missing

| Area | Status | Notes |
| --- | --- | --- |
| Prayer time calc (adhan_dart, offline) | ✅ | `providers/prayer_time_provider.dart` |
| GPS location + permission | ✅ | `services/location_service.dart` — GPS only, no manual city fallback |
| Hijri date (offset ±1) | ✅ | `core/widgets/date_header_row.dart` |
| Gregorian date on dashboard | ✅ | `core/widgets/date_header_row.dart` |
| Home dashboard: next-prayer card | ⚠ | `widgets/prayer_time_card.dart` — shows next prayer + countdown only |
| Home dashboard: current-prayer info, progress %, location name | ❌ | not built |
| Forbidden-time state (dashboard + details) | ❌ | no forbidden-period logic at all |
| Before-Fajr / Ramadan card states | ❌ | not built |
| Prayer details screen: daily schedule | ⚠ | `screens/prayer_time_screen.dart` — times shown; only highlights *next* prayer, no completed/current/upcoming 3-state indicator |
| Sunrise/Sunset/Sehri/Iftar/middle-of-night/last-third/Tahajjud/Qiyam | ❌ | not computed (adhan_dart's `SunnahTimes` class covers middle/last-third but isn't wired in) |
| Forbidden period list (5 periods) | ❌ | not built |
| Location info panel (city/country/coords/method/madhab) | ❌ | no reverse geocoding; coordinates exist but aren't surfaced |
| Calculation method setting | ❌ | hardcoded to Muslim World League, not user-selectable |
| Madhab setting | ❌ | hardcoded to **Shafi** — conflicts with this spec's default of **Hanafi** |
| Time format (12h/24h) setting | ❌ | uses `TimeOfDay.format(context)` (follows device locale, not a user toggle) |
| Location mode (GPS vs manual city) | ❌ | GPS-only |
| Notification on/off per prayer | ✅ | `screens/prayer_time_screen.dart` settings section |
| Notification custom offset (5/10/15/30 min before) | ❌ | only exact-time notification exists |
| Mosque manual time adjustment (+/- min per prayer) | ❌ | not built |
| Current-prayer detection exposed to UI | ⚠ | `adhan_dart`'s `currentPrayer()` is available on the package object but the provider never calls it — only `nextPrayer` is exposed |
| Current-prayer remaining time / progress % | ❌ | not computed |
| Forbidden-time detection (`isForbiddenTime`) | ❌ | not built |
| Daily refresh (midnight rollover) | ✅ | `PrayerTimeProvider.today` getter recomputes on date change |
| Daily refresh (location/timezone/settings change) | ⚠ | only re-renders via Provider; no explicit change-triggered recompute for timezone shifts |
| Explicit state machine (Loading/PermissionRequired/GPSDisabled/LocationUnavailable/Error/Normal/Forbidden) | ❌ | only a single `locationGranted` bool + null-checks, no GPS-disabled-vs-denied distinction, no explicit error state |
| Domain model entities (CurrentPrayerEntity, NextPrayerEntity, ForbiddenPeriodEntity, DailyPrayerSummaryEntity, LocationEntity) | ❌ | raw `adhan_dart` `PrayerTimes`/`Prayer` types used directly; per this repo's [[CLAUDE.md]] simplicity rule, formal entity/DTO layers are intentionally avoided — if these are wanted as plain data classes (not a Clean Architecture layer) that's a smaller, compatible addition |
| Packages: `geocoding` | ❌ | not added — needed for city/country name display |
| Packages: `permission_handler` | ❌ | not added — permission requests instead go through `geolocator`'s and `flutter_local_notifications`' own built-in permission APIs, which cover the same need without an extra dependency |
| Countdown tick rate | ⚠ | spec asks for per-second updates; `prayer_time_card.dart` ticks every **minute** (`Timer.periodic(Duration(minutes: 1))`) |
| Accessibility (large fonts / screen readers) | ❌ | not explicitly reviewed; relies on default Flutter widget semantics only |

**Biggest open decision:** this spec's Settings section (configurable calculation method, Hanafi-default madhab, manual mosque offsets, notification pre-offsets, manual city location) is materially larger than what was scoped and approved for the first pass (see prior AskUserQuestion answers: fixed Muslim World League + Shafi, GPS-only, on/off-only notifications). Building the items marked ❌ above is a distinct follow-up scope, not a bug in the current build.

---

# Product Goals

The module should allow users to:

* Know the current prayer and remaining time. ❌
* Know the next prayer and countdown. ✅
* Know whether prayer is currently forbidden. ❌
* View complete daily prayer times. ✅
* View sunrise and sunset times. ⚠ sunrise only
* View Sehri and Iftar times. ❌
* View prayer-related information without opening another app. ✅
* Continue using prayer times offline after initial location retrieval. ✅

---

# Core Features

## Home Dashboard Prayer Card ⚠ Partial

The home screen should contain a compact prayer status card.

### During Prayer Time ❌ Missing (only next-prayer name/time/countdown shown; no current-prayer/progress/location)

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

### During Forbidden Time ❌ Missing

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

### Before Fajr State ❌ Missing

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

### Ramadan State ❌ Missing

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

# Prayer Details Screen ⚠ Partial

The details screen provides complete information for the current day.

---

## Daily Prayer Schedule ⚠ Partial (times shown; 3-state ✓/●/○ indicator not implemented — only highlights the next prayer)

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

## Additional Daily Information ❌ Missing

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

## Forbidden Prayer Times ❌ Missing

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

# Settings Requirements ❌ Largely missing (only Hijri offset ± 1 day and per-prayer notification on/off exist today)

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

## Madhab Selection ❌ Missing — hardcoded to Shafi (this spec's default is Hanafi; conflicts with current build, needs a decision)

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

## Current Prayer Detection ⚠ Partial — `adhan_dart`'s `currentPrayer()` exists on the package object but `PrayerTimeProvider` never calls it; only `nextPrayer` is exposed to the UI

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

## Current Prayer Remaining Time ❌ Missing

Formula:

```text
nextPrayerTime - currentTime
```

---

## Next Prayer Countdown ⚠ Partial — shown on the home card (ticks every **minute**, not every second as required below); not shown on the details screen

Formula:

```text
nextPrayerStartTime - currentTime
```

---

## Forbidden Time Detection ❌ Missing

The module must determine:

```text
isForbiddenTime(now)
```

If true:

* Determine forbidden type.
* Determine end time.
* Determine next valid prayer.

---

## Prayer Progress Calculation ❌ Missing

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

# State Management Requirements ❌ Missing — only a single `locationGranted` bool + null-checks on `today`/`nextPrayer`; no distinct GPS-disabled/permanently-denied/error states

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
* Countdown updates should happen every second. ❌ (home card ticks every minute — `Timer.periodic(Duration(minutes: 1))` in `prayer_time_card.dart`)
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

* User can view current prayer. ❌ not shown in UI
* User can view next prayer. ✅
* User can view remaining time. ⚠ next-prayer countdown only, no current-prayer remaining time
* User can view all daily prayer times. ✅ (fajr/sunrise/dhuhr/asr/maghrib/isha listed)
* User can view forbidden periods. ❌
* User can view sunrise and sunset. ⚠ sunrise is in the list; sunset is not shown separately
* User can view Sehri and Iftar. ❌
* Prayer information updates automatically. ⚠ recomputes on date rollover; countdown ticks every minute, not live-second
* App works offline after location retrieval. ✅ (adhan_dart calc is fully offline once coordinates are known)
* Notifications work correctly. ⚠ on/off per prayer works; no custom pre-offset, not device-tested end-to-end yet
* Settings persist after app restart. ✅ for the settings that exist (Hijri offset, per-prayer toggle) via SharedPreferences
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
