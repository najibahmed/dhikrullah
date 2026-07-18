# Prayer Time screen redesign — spec

## Context

`lib/features/prayer_time/screens/prayer_time_screen.dart` currently renders one long `ListView` for *today only*: prayer rows, additional-info rows, notification toggles, and Madhab picker all stacked in one scrollable column. This redesign splits it into (a) a focused single-date prayer-time view with prev/next/calendar date navigation and (b) a separate combined Settings page for notifications + Asr/Madhab calculation, reached via a gear icon in the AppBar.

Status: **spec only — not implemented yet.**

## Interaction spec

**AppBar**: title "Prayer Times", one gear/settings icon action → pushes new combined `PrayerTimeSettingsScreen`.

**Fixed top date-nav card** (no infinite scroll of dates):
- Layout: `[◀ prev]  [date info, centered]  [next ▶]`.
- Date info shows both calendars — Hijri line + Gregorian line, same visual info `DateHeaderRow` already renders, just for an arbitrary selected date instead of always `DateTime.now()`.
- Tapping the card body (not the arrows) opens Flutter's standard `showDatePicker` (Gregorian month grid). Picking a date jumps the view to that date; the card's Hijri line recomputes from the picked Gregorian date + the existing hijri-offset/day-start logic.
- Tapping ◀/▶ moves the selected date by 1 day.

**Date change transition**: whenever the selected date changes (arrows or picker), the prayer-list content below fades in and slides up slightly (translateY ~12–16px → 0, combined with opacity 0 → 1). Implemented with an `AnimatedSwitcher` (custom `transitionBuilder` combining `FadeTransition` + `SlideTransition`) keyed by the selected date — stock Flutter primitive, no new package.

**Prayer list for the selected date** (flat, merged — not separate sections):
One ordered list of rows, each a time (or time range) + a bell icon on the right:
`Tahajjud → Fajr → Sunrise → Ishraq → Chasht → Dhuhr → Asr → Sunset → Maghrib → Isha`, with the existing forbidden-time warning card (`_ForbiddenWarningCard`) inserted inline at the correct position when the selected date's forbidden window overlaps (same logic as today, generalized to the selected date). This absorbs what are currently three separate sections (`_PrayerListSection`, `_AdditionalInfoSection`, `_ForbiddenTimesSection`) into one row-builder function.

**Bell icon per row**:
1. First-ever tap anywhere on any bell icon, before OS notification permission is granted: trigger the permission request (reuses `PrayerNotificationService`'s existing permission-request path / `provider.init()`'s permission flow).
   - If granted → proceed to open the bottom sheet (step 2).
   - If denied → show a `SnackBar`/dialog telling the user notifications are off and how to enable them in system settings; bottom sheet does **not** open.
2. Once permission is granted (this tap or a previous one), tapping a prayer's bell opens a modal bottom sheet at 70% screen height, titled with that prayer's name, containing:
   - On/off toggle for that prayer's notification (same underlying setting as today: `provider.prayerNotificationsEnabled[label]` / `provider.setPrayerNotification(label, value)` — global per prayer label, applies every day, **not** per specific calendar date, matching the existing data model and `PrayerNotificationService`'s today+tomorrow-only scheduling).
   - A sound picker: **Default** / **Silent** (two options only — no custom audio asset exists in the project yet; true custom-tone selection is out of scope for this pass).

## Provider changes needed

`lib/features/prayer_time/providers/prayer_time_provider.dart` currently only exposes today-relative getters (`today`, `displayPrayerWindows`, `currentPrayer`, `forbiddenPeriods`, `activeForbiddenPeriod`, `sehriIftarInfo`, `displayHijriOffsetDays` — all implicitly `DateTime.now()`-based). The redesign needs date-parameterized equivalents:

- Expose a public `PrayerTimes? prayerTimesForDate(DateTime date)` — generalizes the existing private `_prayerTimesFor(DateTime date)` (already date-parameterized, just private) with a small bounded cache (e.g. a size-capped `Map<String, PrayerTimes>` keyed by `yyyy-MM-dd`, holding ~7-14 entries with simple LRU eviction) so prev/next taps around the current date are instant, without needing to cache the whole app lifetime.
- Add `int hijriOffsetForDate(DateTime date)` — generalizes `displayHijriOffsetDays`'s sunset-rollover check (currently hardcoded to check *today's* Maghrib) to check the given date's own Maghrib instead, using `prayerTimesForDate(date)`.
- Add date-parameterized variants of `forbiddenPeriodsFor(DateTime date)` and the "is this window active" check (generalizing `forbiddenPeriods`/`activeForbiddenPeriod`, which currently build off `today`/`DateTime.now()`).
- Add persisted per-prayer sound preference: new prefs keys `prayer_sound_$label` (`'default'`/`'silent'`), a `Map<String, String> prayerSoundChoice` field + `Future<void> setPrayerSound(String label, String value)` mirroring the existing `setPrayerNotification` pattern (lines 416-422 today). `_rescheduleNotifications()` picks this up when scheduling today/tomorrow (silent → schedule with a silent/no-sound notification channel; this is additive to `PrayerNotificationService`, not a redesign of it).
- `coordinates` (existing field) and `madhab` (existing field) are reused as-is — no change, since `PrayerTimes` computation already only depends on `(date, coordinates, madhab)`.

No change needed to `PrayerNotificationService` itself — it already only schedules today+tomorrow and already reschedules on every settings change via `_rescheduleNotifications()`; the new sound-choice field just needs to be read by it when building each `NotificationDetails`.

## New/changed files

1. **`lib/core/routing/route_names.dart`** — add `static const String prayerTimeSettings = '/prayer-time-settings';`
2. **`lib/core/routing/app_routes.dart`** — register the new route, `MaterialPageRoute(builder: (_) => const PrayerTimeSettingsScreen())`.
3. **`lib/features/prayer_time/screens/prayer_time_settings_screen.dart`** (new) — combined settings page, same `StatelessWidget` + `Scaffold(appBar: AppBar(title: Text('Prayer Settings')), body: ListView(...))` template as `lib/features/prayer_time/screens/hijri_settings_screen.dart`. Body = today's `_NotificationSettingsSection` + `_MadhabSection` content (moved here verbatim from `prayer_time_screen.dart`, no logic change — both already just read/write `PrayerTimeProvider`).
4. **`lib/features/prayer_time/screens/prayer_time_screen.dart`** (rewritten) — becomes a `StatefulWidget` holding `DateTime _selectedDate` (default `DateTime.now()`, normalized to midnight). `AppBar` gains the settings gear action. Body = fixed `_DateNavCard` (prev/next + tap-to-pick, using the generalized `DateHeaderRow`/date logic) + `AnimatedSwitcher`-wrapped merged row list built from `provider.prayerTimesForDate(_selectedDate)` etc. Old `_AdditionalInfoSection`/`_ForbiddenTimesSection`/`_NotificationSettingsSection`/`_MadhabSection` classes are removed from this file (notification+Madhab moved to file #3; additional-info + forbidden-time rows folded into the merged row builder).
5. **`lib/core/widgets/date_header_row.dart`** — add an optional `DateTime? date` param (defaults to `DateTime.now()` to preserve the two existing call sites in `home_screen.dart` and the old prayer screen behavior) so it can render an arbitrary selected date instead of only "today".
6. **`lib/features/prayer_time/widgets/prayer_notification_bottom_sheet.dart`** (new) — the 70%-height modal sheet widget (prayer name title, on/off `SwitchListTile`, sound `RadioListTile`/segmented picker for Default/Silent), opened via `showModalBottomSheet(context: context, isScrollControlled: true, builder: ...)` sized with `FractionallySizedBox(heightFactor: 0.7, ...)` — same trigger pattern already used for `SessionSetupSheet` in `home_screen.dart` (`showModalBottomSheet` + `isScrollControlled: true`).

## Reuse notes

- Row rendering (`_prayerRow`, `_markerRow`, `_ForbiddenWarningCard`) from the current file is reused, just re-fed from `provider.prayerTimesForDate(_selectedDate)`/`forbiddenPeriodsFor(_selectedDate)` instead of `provider.today`/`provider.forbiddenPeriods`, plus a bell `IconButton` added to each prayer row's trailing area.
- `hijri_settings_screen.dart`'s custom option-row style (`_dayStartOption`, lines 135-174) is the template for the sound-choice picker in the new bottom sheet.
- `home_screen.dart`'s `showModalBottomSheet(isScrollControlled: true, ...)` call (for `SessionSetupSheet`) is the template for the new prayer-notification bottom sheet's launch code.
- Permission-request flow reuses whatever `PrayerNotificationService`/`provider.init()` already does for requesting Android notification permission — no new permission-plugin needed.

## Assumptions / open items

- Sound choice is limited to Default/Silent since no custom audio asset ships with the app; true custom-tone selection would need new asset files + platform channel work, out of scope here.
- Date range for prev/next is unbounded in principle (just ±1 day per tap, computed on demand) — no pre-generated list, so no upper/lower bound needed; `prayerTimesForDate` works for any `DateTime` the adhan calculation accepts.
- Bottom-sheet notification toggle stays **global per prayer label** (not per specific date) since that matches the current data model and `PrayerNotificationService`'s today+tomorrow-only scheduling.

## Verification (once implemented)

- `flutter analyze` clean.
- Manual (user-driven): confirm prev/next arrows animate correctly, calendar picker jumps date and Hijri line updates, forbidden-time card appears inline on the correct date, bell icon requests permission on first tap then opens the 70% bottom sheet, gear icon opens the combined settings page with working notification toggles + Madhab picker.
