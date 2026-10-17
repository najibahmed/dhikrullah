# 05 — Prayer Times Android Home-Screen Widget

Status: in progress · Branch: `feat/prayer-home-widget` (from `chores`) · Date: 2026-10-17

## 1. Goal

A 4×1 Android launcher widget that shows today's five prayers in one row. Each column has the name on top and the time below. The **next upcoming** prayer is bold, in primary text color, with a gold dot under it. Users can add the widget from the launcher's widget picker, or from inside the app with "Add to Home screen". Tapping the widget opens the Prayer Time screen.

## 2. Wireframe

```
Dark (values-night)                         Light (values)
┌───────────────────────────────────────┐   ┌───────────────────────────────────────┐
│  Fajr   Dhuhr   Asr   Maghrib   Isha  │   │  Fajr   Dhuhr   Asr   Maghrib   Isha  │
│  5:54   11:55   2:14   4:32     5:54  │   │  5:54   11:55   2:14   4:32     5:54  │
│  AM     AM      PM     PM       PM    │   │  ...                                  │
│          •                            │   │          •                            │
└───────────────────────────────────────┘   └───────────────────────────────────────┘
 bg #1C1C1E · grey #8E8E93 · next #FFFFFF      bg #FFFFFF · grey #6B7280 · next #111827
 dot #C9A44C (gold), radius 24dp               dot #C9A44C
```

- Times use `h:mm a` with `Locale.US`, the same as the app's `time_format.dart` rule (clock times are never localized).
- Names follow the app language (ফজর … এশা in Bangla), written by Dart.
- After Isha: show **tomorrow's** row with Fajr highlighted.
- No data or stale data (the app hasn't been opened for 7+ days, or no location yet): show the names with `—`. Tapping opens the app, which refreshes the data.

## 3. Architecture (same contract as the alarm module)

**Dart computes, native only reads.** This matches `alarm_api_contract.md` and `BootReceiver.kt`: Kotlin never calculates prayer times.

```
PrayerTimeProvider ──► PrayerWidgetService.sync(provider, locale)
                         │ writes JSON → SharedPreferences "prayer_widget_data"
                         │ (native key: FlutterSharedPreferences / "flutter.prayer_widget_data")
                         └► MethodChannel dhikir_app/widget "refresh"
                                         │
                       PrayerWidgetProvider (AppWidgetProvider)
                         ├ reads JSON, picks today/tomorrow + next prayer
                         ├ renders RemoteViews
                         └ schedules own refresh at min(next prayer, midnight)+1s
```

### JSON contract (`prayer_widget_data`, v1)

```json
{
  "v": 1,
  "names": ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"],
  "days": [
    {"date": "2026-10-17", "times": [1760658840000, 1760680500000, 1760692440000, 1760700720000, 1760705640000]}
  ]
}
```

- `days` holds 7 entries, today first, ordered ascending. `times` are epoch milliseconds in Fajr…Isha order.
- `days: []` means there is no location yet.

## 4. Phases

### Phase 1 — Dart writer

- `lib/features/prayer_time/services/prayer_widget_channel.dart`: a thin wrapper over the `dhikir_app/widget` channel:
  - `refresh()`, `consumeLaunchRoute()`, `isPinSupported()`, `requestPin()`
  - `listenOpenRoute(void Function(String))` for the native → Dart `openRoute` call.
- `lib/features/prayer_time/services/prayer_widget_service.dart`: `static Future<void> sync(PrayerTimeProvider p, Locale locale)`.
  - Names come from `lookupAppLocalizations(locale)` (`prayerNameFajr`…).
  - Times come from `p.prayerTimesForDate(day)` for each of the next 7 days.
  - Writes the JSON, then calls `refresh()`.
  - Every failure is swallowed (`MissingPluginException`, `PlatformException`), so not having a widget is never an error.
- When to sync:
  1. `HomeWidget` initState, after `prayerTimeProvider.init()` and next to the alarm reschedule.
  2. `HomeWidget.didChangeDependencies` when the app locale changes.
  3. `PrayerTimeProvider.setMadhab`, which already receives `locale`.

### Phase 2 — Native widget

Kotlin package `com.bitbirds.simplymuslim`, in the existing `kotlin/com/example/dhikir_app/` folder.

- `PrayerWidgetProvider.kt`
  - Handles `onUpdate`, plus `onReceive` for `ACTION_REFRESH`, `ACTION_PINNED`, `BOOT_COMPLETED`, `TIME_SET`, `TIMEZONE_CHANGED` and `LOCALE_CHANGED`. All of them call `refreshAll(context)`.
  - Selection: take the first day whose date is ≥ today's local date. Next prayer = the first time > now. If none is left, move to the next day and pick index 0.
  - Rendering: `RemoteViews(widget_prayer_times)`. The highlighted column gets a bold `SpannableString` and `@color/widget_text_primary`; the others get `widget_text_secondary`. The dot uses `setViewVisibility`.
  - Root click opens a `PendingIntent` to `MainActivity` with extra `open_route=/prayer-time` (`FLAG_IMMUTABLE`).
  - Self-refresh: a broadcast `PendingIntent` (`ACTION_REFRESH`, request code 9100, distinct from `AlarmArmer`'s codes).
    - Uses `setExactAndAllowWhileIdle` when `canScheduleExactAlarms()`, otherwise `setAndAllowWhileIdle`.
    - It's cancelled in `onDisabled`.
- `PrayerWidgetMethodChannel.kt` (`dhikir_app/widget`)
  - `refresh`
  - `consumeLaunchRoute`: returns and clears the activity intent's `open_route` extra.
  - `isPinSupported`: API 26+ and `AppWidgetManager.isRequestPinAppWidgetSupported`.
  - `requestPin`: success callback is a broadcast with `ACTION_PINNED`.
  - `notifyOpenRoute(route)`: native → Dart `openRoute`, used from `MainActivity.onNewIntent`.
- Resources
  - `res/layout/widget_prayer_times.xml`: 5 equal-weight columns; ids `name_0..4`, `time_0..4`, `dot_0..4`.
  - `res/drawable/widget_bg.xml`: rounded rectangle, 24dp, `@color/widget_bg`.
  - `res/values/colors.xml` and `res/values-night/colors.xml`: `widget_bg`, `widget_text_primary`, `widget_text_secondary`, `widget_dot`.
  - `res/values/strings.xml`: `prayer_widget_description`.
  - `res/xml/prayer_widget_info.xml`:
    - minWidth 250dp, minHeight 56dp, targetCellWidth 4, targetCellHeight 1
    - resizeMode horizontal, `updatePeriodMillis="0"`
    - `previewLayout`, `initialLayout`, widgetCategory home_screen
- `AndroidManifest.xml`: a `<receiver .PrayerWidgetProvider exported="false">` with the intent-filter actions and the `android.appwidget.provider` meta-data. The `RECEIVE_BOOT_COMPLETED` and `SCHEDULE_EXACT_ALARM` permissions already exist.

### Phase 3 — Tap → Prayer Time screen

- `navigatorKey` (a global `GlobalKey<NavigatorState>`) in `lib/core/routing/app_routes.dart`, passed to `MaterialApp.navigatorKey` in `main.dart`.
- `SplashScreen`: after `pushReplacementNamed(home)`, call `consumeLaunchRoute()`. If it returns `/prayer-time`, push it.
- Warm start: `MainActivity.onNewIntent` → `notifyOpenRoute` → the Dart handler calls `navigatorKey.currentState?.pushNamed(route)`.
- Only routes in an allowlist (`RouteNames.prayerTime`) are accepted.

### Phase 4 — "Add to Home screen" in the app

- Prayer Time screen AppBar: a `widgets_outlined` action, shown only if `isPinSupported()`.
- About screen: a tile under Theme, with its own section header ("Home screen widget").
- On tap: `sync(...)`, then `requestPin()`. If the result is false, show a SnackBar with `prayerWidgetPinUnsupported`.
- l10n (en and bn):

  | Key | en |
  |---|---|
  | `prayerWidgetSection` | Home screen widget |
  | `prayerWidgetAddToHome` | Add widget to Home screen |
  | `prayerWidgetAddSubtitle` | Show today's prayer times on your phone's Home screen |
  | `prayerWidgetPinUnsupported` | Long-press your Home screen → Widgets → Simply Muslim |

## 5. Files

- **New**
  - `lib/features/prayer_time/services/prayer_widget_channel.dart`
  - `lib/features/prayer_time/services/prayer_widget_service.dart`
  - `PrayerWidgetProvider.kt`, `PrayerWidgetMethodChannel.kt`
  - widget layout, drawable, xml info, colors, strings
- **Edited**
  - `MainActivity.kt`, `AndroidManifest.xml`
  - `main.dart`, `app_routes.dart`, `splash_screen.dart`
  - `home_screen.dart`, `prayer_time_provider.dart`
  - `prayer_time_screen.dart`, `about_screen.dart`
  - `app_en.arb`, `app_bn.arb`

## 6. Out of scope

- A bigger (4×2) layout with countdown or Hijri date
- Per-widget configuration activity
- Showing Sunrise, Tahajjud or other optional times
- iOS

## 7. Verification

1. `flutter analyze` and `flutter build apk --debug` both pass.
2. Pin the widget from the Prayer Time screen: the launcher's pin dialog appears, and once added the widget is already populated.
3. The widget's highlight matches the app's next prayer. Toggle `cmd uimode night yes/no` and check it follows the theme.
4. Bangla app locale shows Bangla names, while times stay `h:mm a`.
5. Changing the device time past Isha shows tomorrow's row with Fajr highlighted.
6. Tapping the widget opens Prayer Time on both a cold and a warm start.
7. After a reboot, the widget still renders from the persisted JSON.
8. With no location, the widget shows `—` and doesn't crash.
