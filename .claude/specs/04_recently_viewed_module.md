# 04 — Recently Viewed Module (Dhikir + Dua, Quran-ready)

Status: planned · Branch: `chores` · Date: 2026-10-17

## 1. Goal

Home shows a horizontal "Recently viewed" strip of the last dhikir and duas the user opened (Quran later). Tapping a card reopens that exact item.

## 2. Current draft — findings

The draft is uncommitted: `lib/features/recent/`, plus edits in `lib/main.dart`, `home_screen.dart` and `dhikir_detail_screen.dart`.

| # | Problem | Where |
|---|---|---|
| 1 | `RecentStoreProvider.load()` is never called, so the list is empty after every restart | `recent_store_provider.dart`, `main.dart` |
| 2 | `openRecent` switch does nothing; it only has commented-out GoRouter calls (CLAUDE.md forbids GoRouter) | `recent_section.dart` |
| 3 | Always records `RecentType.dhikr`, with `subtitle: widget.dhikir.title` (a copy of the title) | `dhikir_detail_screen.dart` |
| 4 | Saves a copy of `title`, so it goes stale on en↔bn switch or custom rename; a deleted custom dhikir stays in the list | `recent_item.dart` |
| 5 | Saves a collection in SharedPreferences, but CLAUDE.md says collection data belongs in Hive | `recent_store_provider.dart` |
| 6 | Duas are never recorded; `DuaCard` can't be tapped; no way to open a specific dua | `dua_card.dart`, `dua_list_screen.dart` |
| 7 | `'Recently viewed'` is hardcoded (not in l10n); card ignores the dhikir color | `recent_section.dart` |
| 8 | Folder names `model/provider/view` don't match the repo's `models/providers/widgets/services` | `lib/features/recent/` |

## 3. Decisions (confirmed)

| Topic | Decision |
|---|---|
| Storage | Hive box `recent_items_v1`, plain `Map` values. No adapter, no typeId, no build_runner |
| Stored fields | References only: `type`, `id`, `categoryId` (dua), `openedAt` (ms since epoch). Titles are looked up at render time in the current locale |
| Dhikir trigger | Opening `DhikirDetailScreen` (built-in and custom) |
| Dua trigger | Tapping a `DuaCard` in `DuaListScreen` (ripple, no navigation) |
| Recent dua tap | `pushNamed(duaList)` directly; the list scrolls to the dua and briefly highlights it; back goes to Home |
| Limits | No duplicates (type+id), newest first, keep 10, show 10, "Clear" in header with confirm, invalid entries removed automatically |
| UI | Above Quick Actions (current slot), horizontal colored cards |
| Quran | Extension point only (§11) |

## 4. Target layout

```
lib/features/recent/
  models/recent_item.dart
  services/recent_service.dart
  providers/recent_provider.dart
  widgets/recent_section.dart     // RecentSection + _RecentCard
```

Delete the old `model/`, `provider/` and `view/` folders.

---

## Phase 1 — Data layer

### 1.1 `models/recent_item.dart`

```dart
enum RecentType { dhikir, dua } // quran added in §11

class RecentItem {
  final RecentType type;
  final String id;          // dhikirId | dua id as string
  final String? categoryId; // dua only
  final DateTime openedAt;

  String get key => '${type.name}:$id'; // Hive key → natural dedup

  RecentItem.dhikir(this.id) : type = RecentType.dhikir, categoryId = null, openedAt = DateTime.now();
  RecentItem.dua(int duaId, String this.categoryId) : type = RecentType.dua, id = '$duaId', openedAt = DateTime.now();

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'id': id,
        'categoryId': categoryId,
        'openedAt': openedAt.millisecondsSinceEpoch,
      };

  /// Returns null for unknown `type` (forward/backward compat).
  static RecentItem? fromMap(Map m) { ... }
}
```

`openedAt` is a timestamp used only for "time ago" and ordering. It is not a progress key, so the `"yyyy-MM-dd"` string rule doesn't apply here.

### 1.2 `services/recent_service.dart`

Static class, same style as `CustomDhikirService`.

- `static const _boxName = 'recent_items_v1';` (**compatibility contract:** never rename)
- `static const maxItems = 10;`
- `init()` → `Hive.openBox<Map>(_boxName)`
- `getAll()` → parse with `fromMap`, drop nulls, sort by `openedAt` desc
- `record(item)` → `put(item.key, item.toMap())`, then delete the oldest beyond `maxItems`
- `remove(String key)`, `clear()`

### 1.3 `main.dart`

```dart
await HiveService.init();
await CustomDhikirService.init();
await RecentService.init();   // new
```

Register `ChangeNotifierProvider(create: (_) => RecentProvider())` in the existing `MultiProvider` (it replaces `RecentStoreProvider`).

### 1.4 `providers/recent_provider.dart`

App-wide `ChangeNotifier`.

- `List<RecentItem> items` read synchronously from `RecentService.getAll()` in the constructor, so there is no async `load()` to forget.
- `Future<void> record(RecentItem)`, `Future<void> remove(String key)`, `Future<void> clear()` — each one writes to Hive, refreshes `items` and calls `notifyListeners()`.

## Phase 2 — Looking up display data

`RecentProvider` (or a helper in `widgets/`) turns `RecentItem` into a view model:

```dart
sealed class RecentEntry { RecentItem item; }
class RecentDhikirEntry extends RecentEntry { SessionDhikir dhikir; }
class RecentDuaEntry   extends RecentEntry { DuaItem dua; String categoryName; List<DuaItem> categoryDuas; }
```

- **Dhikir:** look in built-in `dhikirList` by id → `SessionDhikir.fromItem`; otherwise `CustomDhikirService.getById(id)` → `SessionDhikir.fromCustom`; if missing, `remove(key)`. Display title: `localizedDhikirTitle(context, id) ?? dhikir.title`.
- **Dua:** the provider holds a `DuaData` cache per `languageCode`, loaded with the existing `DuaService.load(lang)`. `RecentSection` calls `ensureDuaData(lang)` from `didChangeDependencies`, which reloads when the app locale changes. Dua ids and category ids were verified identical in `all_dua_en.json` and `all_dua_bn.json` (126 duas, 27 categories). While loading, show a skeleton card. If the id is unknown after loading, call `remove(key)`.
- Remove invalid entries after the frame (`addPostFrameCallback`), never during `build`.

## Phase 3 — Recording hooks

**`dhikir_detail_screen.dart`.** Replace the draft call:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<RecentProvider>().record(RecentItem.dhikir(widget.dhikir.id));
});
```

Remove the relative imports `../../recent/model/...` and use package imports.

**`dua_card.dart`.**

- Add an optional `VoidCallback? onTap` and `bool highlighted = false`.
- Wrap the content in `Material(color: colorScheme.surface, borderRadius: 18)` + `InkWell` so taps show a ripple.
- Replace the `Container` with an `AnimatedContainer` (300ms) whose border is `colorScheme.primary` 2px when `highlighted`, otherwise transparent.

**`dua_list_screen.dart`.** Pass `onTap: () => context.read<RecentProvider>().record(RecentItem.dua(dua.id, dua.category))`.

## Phase 4 — Navigation (named routes only)

**`app_routes.dart`.**

```dart
class DuaListArgs {
  final String categoryName;
  final List<DuaItem> duas;
  final int? initialDuaId; // new
  ...
}
```

Pass `initialDuaId` to `DuaListScreen`.

**`DuaListScreen`.**

- Categories have at most 8 duas, so switch `ListView.builder` to `SingleChildScrollView` + `Column`. A plain `ListView(children:)` still lays out lazily, so an off-screen target card would have no context to scroll to (found in device testing).
- If `initialDuaId != null`: give the target card a `GlobalKey`. In a post-frame callback, run `Scrollable.ensureVisible(key.currentContext!, alignment: 0.1, duration: 350ms)`. Set `_highlightId = initialDuaId`, then clear it after 1500ms with `setState`, which fades the border out.

**`_RecentCard.onTap`.**

- Dhikir:
  ```dart
  await Navigator.pushNamed(context, RouteNames.dhikirDetail,
      arguments: DhikirDetailArgs(dhikir: entry.dhikir));
  onReturn(); // HomeWidget setState → grid counts refresh
  ```
  The detail screen records the view itself, so there's no extra record call here.
- Dua:
  ```dart
  context.read<RecentProvider>().record(RecentItem.dua(dua.id, dua.category));
  Navigator.pushNamed(context, RouteNames.duaList,
      arguments: DuaListArgs(categoryName: entry.categoryName,
                             duas: entry.categoryDuas,
                             initialDuaId: dua.id));
  ```

`RecentSection` takes `VoidCallback onReturn`. In `home_screen.dart` it becomes `RecentSection(onReturn: () => setState(() {}))`, so it's no longer `const`.

## Phase 5 — UI

### Wireframe (light)

```
┌──────────────────────────────────────────────┐
│ Recently viewed                      Clear   │  titleMedium w600 / TextButton
│ ┌────────────┐ ┌────────────┐ ┌──────────    │
│ │ 📿  DHIKIR │ │ 🤲    DUA  │ │ 📿  DHIKIR   │  emoji 24 · chip labelSmall
│ │            │ │            │ │              │
│ │ Subhanallah│ │ Morning    │ │ Alhamdu…     │  titleSmall w600, 2 lines
│ │            │ │ remembr…   │ │              │
│ │ 2h ago     │ │ Morning·1d │ │ 5m ago       │  bodySmall
│ └────────────┘ └────────────┘ └──────────    │
└──────────────────────────────────────────────┘
   ↑ placed after PrayerScheduleSection, before Quick Actions
```

### Specs

- Section padding `EdgeInsets.fromLTRB(16, 0, 16, 16)`. The list scrolls horizontally out to the screen edges (negative-margin trick, or apply horizontal padding inside the `ListView` instead).
- Header: `Row(Text(l10n.recentTitle, titleMedium w600), Spacer, TextButton(l10n.recentClear))`. Clear opens an `AlertDialog` with Cancel / Clear (same pattern as `my_dhikir_screen.dart`) and then calls `clear()`.
- List: `SizedBox(height: 132)`, `ListView.separated`, horizontal, separator 12. The title sits in `Expanded` + `Align(bottomLeft)` instead of `Spacer` + fixed text, so taller Bangla glyphs shrink the title area instead of overflowing (108/120 overflowed in device testing).
- Card: width 150, radius 20, padding 14, `InkWell` with the same radius.
  - Dhikir: `bg = adjustForBrightness(dhikir.color, brightness)`, `fg = onColorFor(bg)` (`lib/core/theme/theme_colors.dart`). Same palette as `_DhikirGridCard`.
  - Dhikir today's count: when `HiveService.getProgress(id).countForDate(now) > 0`, the top-right chip shows `l10n.todayCountBadge(count)` ("34× today") on `colorScheme.primary` / `onPrimary`, like the grid badge; at 0 it stays the `DHIKIR` type chip.
  - Dua: `bg = adjustForBrightness(const Color(0xFFFFE0B2), brightness)` (matches the Dua quick-action tint), `fg = onColorFor(bg)`. Icon 🤲.
  - Top row: emoji (left) + type chip (right) in a `Container` with radius 8, `fg.withValues(alpha: .12)` background, uppercase `labelSmall`.
  - `Spacer`, then the title (2 lines, ellipsis), then the meta line: dhikir `timeAgo`; dua `"$timeAgo · $categoryName"` (1 line, ellipsis; time first so it survives truncation).
- Empty list → `SizedBox.shrink()` (section hidden).
- Colors come only from `Theme.of(context)` and the `theme_colors.dart` helpers. No `AppColors`.
- Dark mode: `adjustForBrightness` handles the tint. Check contrast in verification.

## Phase 6 — l10n

Add to `lib/l10n/app_en.arb` and `app_bn.arb`, then regenerate (`flutter gen-l10n` or a build):

| Key | en |
|---|---|
| `recentTitle` | Recently viewed |
| `recentClear` | Clear |
| `recentClearConfirmTitle` | Clear recently viewed? |
| `recentClearConfirmBody` | This removes the list from Home. Your progress is not affected. |
| `recentTypeDhikir` | Dhikir |
| `recentTypeDua` | Dua |
| `recentJustNow` | Just now |
| `recentMinutesAgo` | `{count, plural, =1{1 min ago} other{{count} min ago}}` |
| `recentHoursAgo` | `{count, plural, =1{1h ago} other{{count}h ago}}` |
| `recentDaysAgo` | `{count, plural, =1{1 day ago} other{{count} days ago}}` |

Add a helper to the existing `lib/core/utils/time_format.dart`: `String timeAgo(BuildContext context, DateTime t)`. It returns just now if under 1 min, minutes if under 60 min, hours if under 24 h, otherwise days. Follow the existing number-localization convention, if the file has one, for Bangla digits.

## Phase 7 — Cleanup and verification

- Delete the draft files; make sure no `RecentStoreProvider` references remain.
- Run `flutter analyze`.
- Do the manual checks in §10.

## 8. Files

**New or moved**
- `lib/features/recent/models/recent_item.dart`
- `lib/features/recent/services/recent_service.dart`
- `lib/features/recent/providers/recent_provider.dart`
- `lib/features/recent/widgets/recent_section.dart`

**Edited**
- `lib/main.dart`: service init and provider swap
- `lib/features/dhikir/screens/home_screen.dart`: `RecentSection(onReturn: ...)`
- `lib/features/dhikir/screens/dhikir_detail_screen.dart`: record call
- `lib/features/dua/widgets/dua_card.dart`: `onTap`, `highlighted`
- `lib/features/dua/screens/dua_list_screen.dart`: record, scroll-to, highlight
- `lib/core/routing/app_routes.dart`: `DuaListArgs.initialDuaId`
- `lib/core/utils/time_format.dart`: `timeAgo`
- `lib/l10n/app_en.arb`, `lib/l10n/app_bn.arb`

**Reused**
- `SessionDhikir.fromItem` / `fromCustom` (`features/counter/screens/session_counter_screen.dart`)
- `CustomDhikirService.getById`
- `DuaService.load`
- `localizedDhikirTitle`
- `adjustForBrightness` / `onColorFor`

## 9. Out of scope

- Tracking views from `SessionCounterScreen`
- Long-press to remove a single item
- A "See all" screen
- Syncing recents across devices

## 10. Verification

1. `flutter analyze` is clean.
2. Open 3 dhikir (1 of them custom) and tap 2 duas. Home shows 5 cards, newest first. Reopen one: it moves to the front with no duplicate.
3. Kill and relaunch: the list persists.
4. Switch en↔bn: titles and category names change language.
5. Tap a dhikir card: detail opens. Increment, go back: the Home grid counts refresh.
6. Tap a dua card: the category list opens, scrolled to the dua with the highlight fading. Back returns to Home.
7. Delete a custom dhikir that's in recents: its card disappears.
8. Open 12 distinct items: only the latest 10 remain. Clear → confirm: the section hides.
9. Dark mode: all cards are legible and the chip contrasts with the card.

## 11. Quran extension point (later)

When a Quran feature exists:

- Add `RecentType.quran`. Store `id = '$surahNumber'` and add an `extra: {'ayah': n}` map entry (`fromMap` reads it as optional).
- Look up the surah name from the Quran data source.
- Add `RouteNames.quranReader` and `QuranReaderArgs(surah, initialAyah)` to the route table.
- Record from the reader when scrolling stops (debounced ~1s) so the card resumes at the last ayah.
- Card: 📖 icon, type chip "QURAN", meta "Ayah n · time ago", tint from a theme color.
- Older app builds skip unknown `type` names via `fromMap → null`, so a downgrade doesn't crash.
