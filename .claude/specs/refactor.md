# Refactor Proposal: Feature-Based Architecture Migration

Status: Draft for team review — no implementation started.
Scope: `dhikir_app` (Flutter, Android-only). Planning document only; see rules at the end.

## 1. Current architecture analysis

Layer-based structure today: `lib/core`, `lib/data`, `lib/models`, `lib/providers`, `lib/screens`, `lib/services`, `lib/widgets`.

- **State/DI**: `provider` package. Two global providers (`ThemeProvider`, `FavoritesProvider`) constructed once in `main.dart` via `MultiProvider`. One screen-scoped provider exists today, `DhikirCalendarProvider`, created per-screen in `dhikir_calendar_screen.dart` — this is the *only* screen in the app where business logic (streaks, completion %, month navigation) lives outside a `State` class. Every other screen (`dhikir_detail_screen`, `session_counter_screen`, `analytics_screen`, `add_dhikir_screen`, `my_dhikir_screen`, `home_screen`) holds progress/session/CRUD logic directly in `State` and calls `HiveService`/`CustomDhikirService` imperatively with manual `setState`.
- **Persistence**: `HiveService` (boxes `dhikir_progress_v2`, `dhikir_favorites_v1`) is the shared gateway for progress + favorites, used by both built-in and custom dhikir. `CustomDhikirService` (box `custom_dhikir_v1`) owns only custom-dhikir metadata and delegates favorite/progress logic back to `HiveService`. `ThemeProvider` persists via `shared_preferences` (key `theme_mode`), independent of Hive. Init order in `main.dart` is `HiveService.init()` → `CustomDhikirService.init()` (adapter registration dependency) → `ThemeProvider.load()` → `runApp`.
- **Routing**: no router package, no named routes. Every navigation is an inline `Navigator.push(MaterialPageRoute(builder: ...))`. Refresh-after-return is handled ad hoc per call site — some do `setState(() {})` after `await`, some use `.then((_) => setState(() {}))`, some rely on the provider's own reactivity and do nothing. This is inconsistent across near-identical call sites (e.g. three separate places push `SessionCounterScreen` with three slightly different refresh idioms).
- **Theming**: `MaterialApp` defines full light/dark `ThemeData` in `main.dart` (Material 3, `google_fonts`), but it is **not consumed anywhere** — zero `Theme.of(context)` reads in the codebase. `AppColors` (`lib/core/app_colors.dart`, fixed light-mode palette) is read directly in only 2 files. The other 16 UI files use hardcoded `Color(0x...)` literals (271 occurrences total), heaviest in `analytics_screen.dart` (53), `dhikir_calendar_screen.dart` (38), `my_dhikir_screen.dart` (40).
- **Dhikir data model**: built-in dhikir are `const DhikirItem` in `lib/data/dhikir_data.dart` (no Hive). Custom dhikir are `CustomDhikirItem` Hive objects. Both normalize to a `SessionDhikir` view type before rendering so grid/list/session UI doesn't branch on origin.
- **Hive schema**: `DhikirProgress` (`typeId: 0`): `dhikirId`(0), `completedDates`(1), `dailyCounts`(2). `CustomDhikirItem` (`typeId: 1`): `id`(0), `title`(1), `arabicText`(2), `transliteration`(3), `englishMeaning`(4), `colorHex`(5), `icon`(6), `isFavorite`(7), `createdAt`(8). Both fully sequential, no gaps, no schema-version marker anywhere in the repo.

## 2. Problems with the current structure

1. **No consistent state ownership boundary.** Business logic (goal tracking, streaks, CRUD, analytics aggregation) is scattered across `State` classes instead of providers, making it untestable without a widget tree and inconsistent with the one screen (`DhikirCalendarScreen`) that already does it right.
2. **UI directly depends on persistence.** 9+ screens/widgets import `HiveService`/`CustomDhikirService` directly. Any future change to those services' APIs requires touching UI files, and there's no single seam to add caching, error handling, or swap storage later.
3. **Theming is effectively unimplemented.** The `ThemeData` object exists but is dead code — dark mode toggle changes `ThemeMode` with no visible effect on 16 of 18 UI files. This isn't a "some widgets migrated, some didn't" situation; it's a ground-up gap.
4. **Inconsistent navigation refresh pattern** risks stale UI (a screen that mutates data but whose caller forgets to refresh) and makes it harder to onboard new screens correctly by copying an existing call site (three different idioms to choose from, no clear "correct" one).
5. **Layer-based folders scale poorly** for a team: adding a feature currently means touching `screens/`, `widgets/`, and possibly `models/`/`providers/` — four directories for one conceptual unit of work, and no folder boundary signals which widgets are feature-local vs shared.

## 3. Proposed folder structure

```
lib/
  core/
    theme/          # ThemeData definitions (light/dark), extracted from main.dart
    routing/         # route name constants + route table / onGenerateRoute
    persistence/      # HiveService, CustomDhikirService — cross-feature data gateways
    models/          # DhikirProgress, CustomDhikirItem (+ .g.dart) — the Hive compatibility contract
    data/            # dhikir_data.dart — built-in catalog, read by multiple features
    providers/        # ThemeProvider, FavoritesProvider — app-wide only
    widgets/         # widgets used by 2+ features (promote here only when actually shared)
  features/
    dhikir/          # home grid, dhikir detail, calendar
      screens/
      widgets/
      providers/     # DhikirCalendarProvider (existing), new DhikirDetailProvider
    my_dhikir/       # my-dhikir list + add/edit form
      screens/
      providers/     # new MyDhikirProvider (shared by list + edit form)
    counter/         # session counter screen + counter tab/launcher widgets
      screens/
      widgets/
      providers/     # new SessionCounterProvider
    favorites/
      screens/
      widgets/
    analytics/
      screens/
      providers/     # new AnalyticsProvider
```

Rules for this layout:
- A widget starts in its feature's folder. Only move it to `core/widgets/` once a second feature actually needs it — don't pre-place things there speculatively.
- `CustomDhikirService` stays in `core/persistence/`, not under `features/my_dhikir/`, because it's read by `home`, `counter`, `favorites`, and `analytics` too, not just the my-dhikir feature. Only the create/edit *screens* are my-dhikir-specific.
- Hive-registered models stay centralized in `core/models/` (never duplicated per feature) since they are a compatibility contract shared across features, not a feature concern.

## 4. Provider organization strategy

Three tiers, chosen by how widely the provider's state is shared — do not default to the widest tier:

- **Global** (`core/providers/`, registered once in `main.dart`'s `MultiProvider`): `ThemeProvider`, `FavoritesProvider`. Criterion: state genuinely used app-wide, independent of any one feature. Do not add a third global provider without a concrete cross-feature need.
- **Feature providers** (`features/<name>/providers/`, constructed where that feature's navigator subtree starts, shared by 2+ screens within the same feature): new `MyDhikirProvider` shared between the my-dhikir list screen and the add/edit form (both need the same custom-dhikir CRUD state). This tier is new — introduced specifically because these two screens currently duplicate list-refresh logic.
- **Screen-scoped** (`features/<name>/providers/`, constructed per single screen, disposed on pop): existing `DhikirCalendarProvider` (keep as-is, it's already the reference pattern), new `DhikirDetailProvider`, new `SessionCounterProvider`, new `AnalyticsProvider`. Criterion: logic used by exactly one screen.

Not every screen needs a provider. `favorite_screen.dart` and simple widgets with only UI-toggle state (expand/collapse, animation flags) stay as plain `StatefulWidget` — introducing a provider there would be unnecessary abstraction.

## 5. Routing strategy

- Add `core/routing/route_names.dart` (string constants) and `core/routing/app_routes.dart` (an `onGenerateRoute` function or `Map<String, WidgetBuilder>`), wired into `MaterialApp` in `main.dart`.
- For routes needing constructor arguments today (`DhikirDetailScreen(dhikir)`, `SessionCounterScreen(dhikirList, sharedGoal)`, `AddDhikirScreen(existing)`), define a small typed arguments class per route (e.g. `DhikirDetailArgs`) passed via `RouteSettings.arguments` and cast in `onGenerateRoute` — avoids passing untyped `Map`s through navigation.
- Standardize the pop/refresh contract as part of this migration (it's the one behavior fix riding along with an otherwise-mechanical change): every named route that can mutate shared data returns a `bool`/result via `Navigator.pop(context, result)`, and every caller uniformly does `final changed = await Navigator.pushNamed(...); if (changed == true) setState(() {});`. This replaces the three inconsistent idioms found today.
- Do not add GoRouter or any router package — named routes are sufficient for this app's navigation depth.

## 6. Theme migration strategy

Given zero current `Theme.of(context)` usage and 271 hardcoded color literals across 16 files, this is not a quick swap — plan it as the longest-running, lowest-priority-per-commit phase:

1. Extract the existing `ThemeData` (light/dark) out of `main.dart` into `core/theme/app_theme.dart` — no behavior change, pure move.
2. Do **not** attempt a repo-wide find/replace of all 271 literals in one PR — no automated visual regression coverage exists (no `test/` directory), so a big-bang color change is high risk for low reviewability.
3. Migrate color usage **opportunistically, screen-by-screen**, ideally batched with that screen's folder-structure move (phase 2 below) so each file is only touched once across both migrations.
4. Keep `AppColors` available and unchanged until every consumer has migrated to `Theme.of(context)` — dual-support during the transition, remove it only after the last reference is gone. Don't delete it early "to force migration."

## 7. Service organization strategy

- `HiveService` and `CustomDhikirService` move to `core/persistence/` with no API changes — box names, method signatures, and delegation between the two services stay exactly as they are today.
- Explicitly do not introduce a Repository/UseCase/DTO/Mapper/Entity layer. The refactor's service-layer goal is narrower: stop screens/widgets from importing these services directly. After the provider-extraction phase (below), only provider classes should call `HiveService`/`CustomDhikirService` — never a screen or widget directly.
- No new indirection is added between providers and services; a provider calling `HiveService.getProgress(...)` directly is the intended final shape, matching how `DhikirCalendarProvider` already works.

## 8. Hive migration and compatibility considerations

- **No box renames.** `dhikir_progress_v2`, `dhikir_favorites_v1`, `custom_dhikir_v1` stay exactly as named — box name is a runtime string contract, unrelated to which folder the Dart file defining it lives in.
- **No `typeId` changes.** `DhikirProgress` stays `typeId: 0`, `CustomDhikirItem` stays `typeId: 1`. Never reuse or reorder these.
- **Field index contract**: any new persisted field must use the next unused `@HiveField` index — `3` for `DhikirProgress`, `9` for `CustomDhikirItem`. If a field is ever removed, mark its index as retired with a comment rather than reassigning the number to a new field (reuse corrupts old records on read, since Hive maps by field number, not name).
- **Moving files is zero-risk to data.** Relocating `hive_service.dart`, `custom_dhikir_service.dart`, and the model files into `core/` is a pure import-path change; as long as `HiveService.init()`'s adapter registration (`Hive.registerAdapter(...)`) and box-open calls are copied verbatim, no data is affected.
- **No schema-version marker exists today**, and adding one is out of scope for this refactor — it would be speculative infrastructure with no current breaking change to justify it. Revisit only when a real breaking schema change is needed.
- Every phase that touches persistence-adjacent files must be verified against an **upgrade path** (existing Hive box files from before the change), not just a fresh install — see checklist.

## 9. Incremental migration phases

Each phase is independently shippable and revertable; do not start a phase until the previous one is merged and verified.

**Phase 1 — Routing foundation (no folder moves).** Add the route table alongside existing screens in their current locations. Migrate `Navigator.push(MaterialPageRoute(...))` call sites to `Navigator.pushNamed` one at a time, standardizing the pop/refresh contract (§5) as each one is touched. No files move yet.

**Phase 2 — Folder restructure (pure move, no logic change).** Move files into `core/` and `features/<name>/` per §3, one feature at a time (suggested order: `dhikir` → `my_dhikir` → `counter` → `favorites` → `analytics`), updating only import paths. No behavior change in this phase.

**Phase 3 — Provider extraction.** For each feature with embedded business logic (`dhikir_detail_screen`, `session_counter_screen`, `analytics_screen`, `my_dhikir_screen` + `add_dhikir_screen` together), extract the existing logic verbatim into a new provider (§4) — move code, don't rewrite it. Logic improvements are a separate, later PR so "move" and "improve" are never mixed in one diff.

**Phase 4 — Service boundary cleanup.** Sweep for any remaining direct `HiveService`/`CustomDhikirService` calls from screens/widgets (should be near-zero after phase 3) and remove them. This phase is verification-plus-cleanup, not new work.

**Phase 5 — Theme migration (ongoing, no fixed end date).** Per §6, extract `ThemeData` first, then migrate color usage screen-by-screen, piggybacking on whichever screen phases 2-3 are already touching. Does not block phases 1-4.

## 10. Risk analysis and rollback strategy

| Risk | Mitigation |
|---|---|
| Folder moves break imports broadly | One feature per PR; `flutter analyze` must be clean before merge; small scope makes `git revert` of one PR cheap and isolated. |
| Named-route args lose type safety vs constructor args | Typed arguments class per route instead of raw `Map`/dynamic casts. |
| Provider extraction subtly changes behavior | Move logic verbatim in phase 3; behavioral improvements deferred to a separate follow-up PR, reviewed independently. |
| Hive data loss or corruption | Box names/typeIds never change in any phase; field-index contract (§8) documented here as source of truth for next-free-index; verify upgrade path every phase, not just fresh install. |
| Theming visual regressions | No big-bang literal replacement; screen-by-screen with manual review; `AppColors` kept until fully replaced (dual support, not delete-first). |
| Phase reverted mid-way leaves inconsistent state | Phases are ordered so each starts from a stable, working state — reverting phase N's commits does not require reverting N+1, since later phases don't begin until earlier ones are verified merged. |

## 11. Verification checklist (run after every phase)

- [ ] `flutter analyze` — zero new warnings/errors.
- [ ] `flutter pub get` succeeds; no dependency changes unless the phase explicitly requires one.
- [ ] App builds and launches on an Android emulator/device.
- [ ] Fresh-install smoke test: view dhikir grid, open a dhikir detail, mark a day complete, run a counter session, add/edit/delete a custom dhikir, toggle a favorite, open analytics, toggle light/dark theme.
- [ ] Upgrade-path test: run the new build against an emulator/device that already has Hive box files from before this phase — confirm existing `completedDates`, `dailyCounts`, favorites, and custom dhikir all still load correctly.
- [ ] Diff `dhikir_progress_v2` / `dhikir_favorites_v1` / `custom_dhikir_v1` box names and `typeId: 0` / `typeId: 1` annotations against §8 — confirm unchanged.
- [ ] Git diff for the phase touches only files within that phase's declared scope — no incidental drive-by refactors.
