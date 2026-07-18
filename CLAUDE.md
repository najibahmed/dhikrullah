# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (package name `dhikir_app`) — a daily dhikir (Islamic remembrance phrase) tracker with per-dhikir 30-day/monthly completion tracking, tap-counter sessions, favorites, and analytics. Only the Android platform is currently scaffolded (see `android/`; no `ios/`, `web/`, etc.) — do not add other platform folders unless asked.

## Commands

```
flutter pub get                      # install dependencies
flutter run                          # run on connected device/emulator
flutter analyze                      # lint (uses analysis_options.yaml -> flutter_lints)
flutter test                         # run tests (no test/ directory exists yet)
flutter build apk                    # build Android release APK
```

Hive model adapters (`*.g.dart`) are generated via `build_runner`. Regenerate after changing any `@HiveType`/`@HiveField` class (`lib/models/*.dart`). This is the only code generation used in this project — do not introduce generators for routing, DI, or state management.

```
dart run build_runner build --delete-conflicting-outputs
```

## Architecture direction (in progress)

The codebase is migrating from a layer-based structure (`lib/core`, `lib/data`, `lib/models`, `lib/providers`, `lib/screens`, `lib/services`, `lib/widgets`) to a **feature-based** structure. Not all code has moved yet — when you touch a screen, migrate its folder; don't do a big-bang rewrite unless asked.

Target layout:

- `lib/features/<feature>/` — e.g. `dhikir/`, `counter`, `favorites`, `analytics`, `my_dhikir`. Each holds its own screens, feature-local widgets, and models in one place instead of splitting across top-level `screens/`, `widgets/`, `models/`.
- `lib/core/` — cross-feature stuff only: theme, routes table, shared Hive/SharedPreferences services, app-wide providers, shared widgets used by 2+ features.
- Keep it flat inside a feature folder unless it grows large enough to need sub-splitting. Don't pre-create empty subfolders "for later."

**Simplicity rule**: prefer a slightly-duplicated widget in two features over a premature shared abstraction. Don't introduce a layer (data/domain/presentation, UseCase, Repository, DTO, Mapper, Entity) just to match a textbook Clean Architecture — this app is small enough that Provider + Hive/SharedPreferences directly is the whole stack.

## State management & dependency injection

**Provider is used for both roles** — no separate DI container (no `get_it`, no service locator). A provider IS the dependency: screens/widgets get services and state the same way, via `context.watch/read<T>()` or constructor injection for plain classes.

- App-wide state/services (`ThemeProvider`, `FavoritesProvider`, any singleton service) are constructed once in `main.dart` and exposed via `MultiProvider`.
- Screen-scoped state (e.g. a calendar's focused month, derived stats) uses a locally-created `ChangeNotifier` constructed by that screen, not hoisted into the global tree.
- Do not add Riverpod or Bloc. If a future need doesn't fit `ChangeNotifier` + `Provider`, raise it before adding a new state library rather than mixing two paradigms.

## Routing

**Named routes via `Navigator.pushNamed`**, registered in one central route table (in `lib/core`, e.g. `routes.dart`) mapping route name constants to builder functions. New screens should be added to this table and navigated to with `Navigator.pushNamed(context, RouteNames.x, arguments: ...)` rather than constructing `MaterialPageRoute` inline at each call site.

- Do not add GoRouter or any router package — plain named routes are enough for this app's navigation depth.
- Screens that mutate shared data and need the caller to refresh should still return a value via `Navigator.pop(context, result)`/`await Navigator.pushNamed(...)`, with the caller doing `setState(() {})` on return — screens don't reactively listen to Hive changes, so this manual refresh pattern stays.
- Older screens not yet migrated to named routes may still use `Navigator.push(MaterialPageRoute(...))` directly; migrate them opportunistically rather than leaving mixed patterns once a screen is otherwise being edited.

## Persistence

Two independent layers, both initialized in `main()` before `runApp`, in this order — `HiveService.init()` must run first because it registers the Hive type adapters that `CustomDhikirService.init()` depends on.

**Hive** — local structured data. Box names and Hive `typeId`s below are load-bearing: renaming a box key or changing a registered `typeId` breaks existing installs' saved data, so treat both as a compatibility contract. Any schema change to a `@HiveType` class needs `dart run build_runner build --delete-conflicting-outputs` afterward.

- `dhikir_progress_v2` — `DhikirProgress` records (`typeId: 0`): completed dates + daily tap counts, keyed by `dhikirId`.
- `dhikir_favorites_v1` — plain `bool` box keyed by `dhikirId`.
- `custom_dhikir_v1` — `CustomDhikirItem` records (`typeId: 1`): metadata for user-created dhikir, managed by `CustomDhikirService`.

Built-in and custom dhikir share the same progress/favorites boxes and keys — there is no separate store per dhikir type. `CustomDhikirService` only owns the metadata box; it delegates all progress and favorite logic back to `HiveService` rather than duplicating it.

**SharedPreferences** — app settings and theme only (currently just the persisted `ThemeMode`, in `ThemeProvider`). Don't put structured/collection data here; that belongs in Hive.

**Dates as strings**: progress is keyed by `"yyyy-MM-dd"` strings (`DhikirProgress.dateKey`), not `DateTime`, both for the Hive map keys and for the `completedDates` list. Streak/heatmap/month-completion calculations all parse/compare these strings — keep new date logic consistent with that format rather than introducing `DateTime`-keyed storage.

## Alarm & Adhan Module

For any alarm-related task, Claude must first read:

- .claude/specs/alarm-specs/alarm_implementation.md
- .claude/specs/alarm-specs/alarm_api_contract.md
- .claude/specs/alarm-specs/alarm_android_setup.md
- .claude/specs/alarm-specs/alarm_foreground_service.md
- .claude/specs/alarm-specs/alarm_fullscreen_flow.md

Rules:
- Keep alarm scheduling separate from reminder notifications.
- Reuse the existing prayer calculation and notification scheduling.
- Use Provider, Hive, SharedPreferences, flutter_local_notifications.
- Use Android exact alarms and a foreground service.
- Full-screen alarm is optional per prayer.
- If full-screen is disabled, dismissal is via the foreground notification.
- Ask questions instead of making assumptions.
- Implement incrementally.

## Theming

**ThemeData only** — going forward, all colors/styles should come from `Theme.of(context)` (light/dark `ThemeData` defined in `main.dart`, Material 3, `google_fonts` Inter + Playfair Display). Some existing widgets still read a fixed-palette `AppColors` (`lib/core/app_colors.dart`) directly instead of `Theme.of(context)`, which is why dark mode isn't fully wired through every screen — when you touch one of these widgets, migrate it to `Theme.of(context)` rather than adding a new `AppColors` reference. Don't reintroduce a second parallel color system.

## Dhikir data model

Two dhikir "kinds", one shape at runtime: built-in dhikir are `const DhikirItem` entries in `lib/data/dhikir_data.dart` (or its future feature-folder home); custom dhikir are `CustomDhikirItem` Hive objects created via the "My Dhikir" screen. Screens normalize both into a common `SessionDhikir` view type before rendering, so grid/list/session code doesn't branch on origin. When adding a feature that touches dhikir data, check whether it needs to handle both sources.

## Avoid introducing

- Riverpod, Bloc, or any state-management package beyond `provider`.
- GoRouter or any router package beyond named routes.
- Clean Architecture layering (UseCase, Repository, DTO, Mapper, Entity) — Provider + Hive/SharedPreferences directly is the intended full stack.
- Service locators (`get_it` or similar).
- Code generation beyond Hive's `build_runner` adapters.
