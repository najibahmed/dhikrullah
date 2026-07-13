# Prayer Time gap-closure + About Us — Implementation Plan

Companion to `01_prayer_time_module.md` (spec + implementation-status annotations). This plan closes the approved subset of the ❌/⚠ gaps identified there, and adds a single-developer "About Us" page. Decisions below were confirmed with the user before writing this plan.

## Decisions locked in

- **Madhab**: add a user-facing setting (Hanafi/Shafi), default **Hanafi** (spec default), replacing the hardcoded `Madhab.shafi` in `PrayerTimeProvider._prayerTimesFor`.
- **Location mode**: stays **GPS-only** — no manual city entry, no `geocoding` dependency, no location-name panel. Reverse geocoding is explicitly out of scope.
- **In scope**: current-prayer detection/remaining-time/progress, forbidden-time detection + dashboard/detail states, Ramadan-derived extras (Sehri/Iftar/Tahajjud/Qiyam via existing `adhan_dart`/`hijri` packages, no new deps), an accessibility pass, and a **Tahajjud notification option** (own on/off toggle + reminder, not just a display value).
- **Out of scope** (stay ❌, not touched this round): calculation-method picker, mosque manual offset, per-prayer notification pre-offset, location info/geocoding panel, manual city mode.
- **About Us**: static app-info page with placeholder developer fields (name/bio/contact marked clearly as placeholders) — no personal content to inject, no new dependency (version hardcoded to match `pubspec.yaml`, not `package_info_plus`).
- **Constraints carried through every phase**: don't touch `dhikir`, `counter`, `favorites`, `analytics`, `my_dhikir` features or their Hive/routing wiring. Keep state management as-is — `ChangeNotifier` + `Provider` + `SharedPreferences`, no new packages, no Entity/Repository/UseCase layers (per `CLAUDE.md`). New logic is added as plain getters/small data classes inside the existing `lib/features/prayer_time/` subfolders (`providers/`, `services/`, `widgets/`, `screens/`, plus a new `models/`), mirroring the pattern already used for `nextPrayer` (a Dart record) and the existing `*Service` static classes.

Key facts confirmed from `adhan_dart` source (`PrayerTimes.dart`, `SunnahTimes.dart`):
- `PrayerTimes` already exposes `currentPrayer({DateTime? date})`, `sunset`, `ishaBefore`, `fajrAfter` — not currently called anywhere in the app.
- `SunnahTimes(prayerTimes)` gives `middleOfTheNight` / `lastThirdOfTheNight` — not instantiated anywhere yet.
- `Madhab` enum is `{shafi(1), hanafi(2)}`.
- Ramadan detection: no library support — derive by checking `HijriCalendar.fromDate(now).hMonth == 9`.

---

## Phase 1 — Current prayer, remaining time, progress, Madhab setting

File: `lib/features/prayer_time/providers/prayer_time_provider.dart`

- Add `Madhab madhab` field, persisted key `prayer_madhab` (store as string `'hanafi'|'shafi'`, default `hanafi`), loaded in `_loadSettings()`, mutated via new `Future<void> setMadhab(Madhab)` (persist + `_recompute()` + `notifyListeners()`, mirrors `setHijriOffset`).
- Wire `madhab` into `_prayerTimesFor`: `CalculationMethodParameters.muslimWorldLeague()..madhab = madhab` (replaces hardcoded `Madhab.shafi`).
- Add a `currentPrayer` getter, same record-type style as the existing `nextPrayer`:
  ```dart
  ({String name, DateTime start, DateTime end, double progress})? get currentPrayer
  ```
  Implementation: `times.currentPrayer()` for the name/start (via `timeForPrayer`), end = start time of `times.nextPrayer()` (handle the `ishaBefore`/`fajrAfter` wraparound cases using the already-present `ishaBefore`/`fajrAfter` fields), progress = `elapsed / totalDuration` clamped `[0.0, 1.0]`.
- Add `Duration? get currentPrayerRemaining` (end − now).

## Phase 2 — Forbidden time detection

New file: `lib/features/prayer_time/models/forbidden_period.dart` — one small plain class (not a layered entity, just a data holder, consistent with the `nextPrayer` record style but named since there are 5 of them):
```dart
class ForbiddenPeriod {
  final String name;
  final DateTime start;
  final DateTime end;
  const ForbiddenPeriod({required this.name, required this.start, required this.end});
  bool contains(DateTime t) => t.isAfter(start) && t.isBefore(end);
}
```

`prayer_time_provider.dart`:
- Add `List<ForbiddenPeriod> get forbiddenPeriods` computed from `today`: `Fajr→Sunrise`, `Sunrise→Sunrise+15m`, `Dhuhr-10m→Dhuhr`, `Asr→Sunset` (using `times.sunset`), `Sunset-15m→Sunset`.
- Add `ForbiddenPeriod? get activeForbiddenPeriod` (first period containing `DateTime.now()`, else null) and `bool get isForbiddenTime => activeForbiddenPeriod != null`.

## Phase 3 — Dashboard card states + lightweight status enum

Files: `lib/features/prayer_time/providers/prayer_time_provider.dart`, `lib/features/prayer_time/widgets/prayer_time_card.dart`, `lib/features/prayer_time/services/location_service.dart`

- `location_service.dart`: distinguish GPS-off vs permission-denied — add `static Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();` (thin wrapper, no new dependency).
- `prayer_time_provider.dart`: add `bool gpsServiceEnabled` field, set during `init()`. Add a computed (not persisted) status getter:
  ```dart
  enum PrayerStatus { loading, permissionRequired, gpsDisabled, locationUnavailable, error, forbidden, normal }
  PrayerStatus get status
  ```
  Pure derivation from existing fields (`locationGranted`, `gpsServiceEnabled`, `coordinates`, `today`, `isForbiddenTime`) — no new persisted state, no state-machine package.
- `prayer_time_card.dart`:
  - Tick every **second** (`Timer.periodic(const Duration(seconds: 1), ...)`) instead of every minute, per spec's performance requirement — cheap since it's just `setState` on a small widget.
  - Branch rendering on `provider.status`:
    - `permissionRequired`/`gpsDisabled` → existing "enable location" prompt (reuse current row, adjust copy per state).
    - `loading`/`locationUnavailable`/`error` → existing spinner/placeholder row.
    - `forbidden` → new compact state: forbidden period name, countdown to its end, next prayer name + countdown (reuses `activeForbiddenPeriod` + `nextPrayer`).
    - `normal` → extend current next-prayer row into the full "current prayer" layout from the spec: current prayer name, start/end time, remaining time, a slim `LinearProgressIndicator` (`currentPrayer.progress`), then next prayer + countdown underneath.
  - Ramadan variant: if `HijriCalendar.fromDate(DateTime.now().add(Duration(days: provider.hijriOffsetDays))).hMonth == 9`, swap the current-prayer subtitle line to show Sehri (`today.fajr`) / Iftar (`today.maghrib`) countdown wording instead of generic prayer wording — same widget, no separate screen/state.
  - Before-Fajr case falls naturally out of `currentPrayer` returning the pre-Fajr night period; show "Fajr starts in …" + "Sehri ends at …" copy when `currentPrayer.name == 'Isha'` and `now` is before `today.fajr`.

## Phase 4 — Prayer Details screen upgrades + Tahajjud notification option

Files: `lib/features/prayer_time/screens/prayer_time_screen.dart`, `lib/features/prayer_time/providers/prayer_time_provider.dart`, `lib/features/prayer_time/services/prayer_notification_service.dart`

- `_PrayerListSection`: replace the single `prayer == next` highlight with a 3-state indicator using `provider.currentPrayer`/`nextPrayer`: ✓ (before current), ● (current), ○ (upcoming) — icon/color per state, keep the existing `ListTile` structure.
- New `_AdditionalInfoSection`: sunrise, sunset (`times.sunset`, currently unused), Sehri end (`= times.fajr`), Iftar (`= times.maghrib`), middle of night, last third of night, Tahajjud start (`= middleOfTheNight`), Qiyam (`= lastThirdOfTheNight`) — via `SunnahTimes(times)`. Simple `ListTile`/`Row` list, same visual style as `_PrayerListSection`.
- New `_ForbiddenTimesSection`: list `provider.forbiddenPeriods`, highlight the one matching `provider.activeForbiddenPeriod`.
- New `_MadhabSection`: `SegmentedButton<Madhab>` (Hanafi/Shafi) next to the existing `_HijriOffsetSection`, calling `provider.setMadhab`.
- Insert these sections into the existing `ListView` between `_PrayerListSection` and `_NotificationSettingsSection` (order: schedule → additional info → forbidden times → notifications → madhab → hijri offset).

**Tahajjud as its own notifiable prayer time** (currently missing — the 5 obligatory prayers have on/off toggles, Tahajjud is display-only):
- `prayer_time_provider.dart`: extend the persisted notification map with a `'Tahajjud'` key (`prayer_notify_Tahajjud`, default `false` — opt-in since it's nafl, unlike the 5 obligatory prayers defaulting to `true`). `_rescheduleNotifications()` computes `SunnahTimes(todayTimes).middleOfTheNight` (and the equivalent for tomorrow) and passes it through alongside the existing 5 prayer times.
- `prayer_notification_service.dart`: `scheduleForDay` gains an optional `DateTime? tahajjudToday, DateTime? tahajjudTomorrow` pair, scheduled under two new fixed IDs (10/11, after the existing 0-9), title `"Tahajjud"`, body `"Time for Tahajjud."` — skipped entirely when the Tahajjud toggle is off, same past-time-skip logic as the other 5.
- `_NotificationSettingsSection` (in `prayer_time_screen.dart`): add a `SwitchListTile` for `'Tahajjud'` below the 5 existing ones, bound to the same `setPrayerNotification('Tahajjud', value)` mutator (already generic over label).

## Phase 5 — Accessibility pass

Files: `prayer_time_card.dart`, `prayer_time_screen.dart`, `date_header_row.dart`

- Add `Semantics(label: ...)` to icon-only/tap-only regions (the card's `GestureDetector`, forbidden/progress indicators) so screen readers announce state, not just an icon.
- Confirm no fixed-height `Text`/`Row` clips under large `MediaQuery` text scale (switch any hardcoded `SizedBox`-constrained text rows to `Flexible`/`Wrap` where the spec-driven additions in Phase 3/4 introduce new rows) — spot-check, not a rewrite.
- No new dependency; this rides along with the widgets touched in Phases 3–4 rather than a separate pass over untouched code.

## Phase 6 — About Us page

New feature folder `lib/features/about/`:
- `lib/features/about/screens/about_screen.dart` — `StatelessWidget`, `Scaffold` + `AppBar(title: 'About')`. Sections: app name ("Daily Dhikir"), version (hardcode `'1.0.0'` to match `pubspec.yaml`'s `version:` — no `package_info_plus` dependency), one-line app description (reuse `pubspec.yaml`'s description), then a "Developer" section with clearly-labeled placeholder fields (`'Developer name — TODO'`, `'Short bio — TODO'`, `'Contact — TODO'`) as plain `Text` widgets the user edits later.

Routing (mirrors the no-args `prayerTime` route):
- `lib/core/routing/route_names.dart`: add `static const String about = '/about';`.
- `lib/core/routing/app_routes.dart`: add `case RouteNames.about: return MaterialPageRoute(settings: settings, builder: (_) => const AboutScreen());` + import.

Entry point — `lib/features/dhikir/screens/home_screen.dart`:
- No settings/drawer/overflow-menu currently exists anywhere in the app, so add one small `IconButton(icon: Icons.info_outline)` into the existing `SliverAppBar.actions` list (alongside the current `_NavButton`s for "My Dhikir"/"Analytics"), navigating via `Navigator.pushNamed(context, RouteNames.about)`. This is the only touch to `home_screen.dart` in this whole plan — one action added to an existing list, not a structural change.

---

## Explicitly not touched

`lib/features/dhikir/`, `lib/features/counter/`, `lib/features/favorites/`, `lib/features/analytics/`, `lib/features/my_dhikir/` and their screens/services/Hive boxes — no edits. `home_screen.dart` gets exactly one new `IconButton` in an existing actions list, nothing else. No new state-management package, no `geocoding`/`package_info_plus`/`intl` dependency, no calculation-method picker, no mosque offset, no notification pre-offset, no manual-city location.

## Verification

1. `flutter analyze` — no new lints introduced (user runs `flutter build`/`flutter run` themselves).
2. Manually walk: home dashboard shows current-prayer block with live progress bar; force device clock to a forbidden window (e.g. right after Fajr) → card switches to forbidden state; before Fajr → night/Sehri copy.
3. Prayer Details screen: confirm ✓/●/○ per-prayer indicators change as time passes across a day boundary (or by adjusting device clock), additional-info section shows 8 values, forbidden section highlights the active period, Madhab toggle switches Hanafi/Shafi and visibly shifts Asr time.
4. Toggle Madhab and Hijri offset, restart app, confirm both persisted (`SharedPreferences`).
4a. Enable the Tahajjud notification toggle, confirm a reminder fires at the computed middle-of-night time (or by temporarily setting device clock near it); confirm it stays off by default and off-state persists across restart.
5. Tap the new info icon on home → About screen opens, shows app name/version/description + placeholder developer fields.
6. Confirm no other feature screen (dhikir grid, counter, favorites, analytics, my dhikir) changed behavior or files.
