# Kibla Compass Module

**Feature:** Qibla Compass
**Project:** Dhikr App (`dhikir_app`)
**Approach:** Minimal — compass sensor + reuse of existing prayer-time location. No new GPS logic, no Clean Architecture layers.

---

## Goal

Show the direction of the Kaaba: a rotating compass dial with a Qibla marker, live status (Facing Qibla / Turn left / Turn right), and heading/bearing readouts. Works fully offline once a location has been cached.

---

## What already exists (reuse, don't rebuild)

- **Route:** `RouteNames.qibla` (`/qibla`) in `lib/core/routing/route_names.dart`, wired in `lib/core/routing/app_routes.dart`.
- **Entry point:** home screen Quick Actions tile navigates to it.
- **Location:** `lib/features/prayer_time/services/location_service.dart` — permission handling, fresh GPS fix, SharedPreferences cache. `PrayerTimeProvider.coordinates` holds coords in memory.
- **Localization:** gen-l10n `.arb` files (en + bn), accessed via `context.l10n`.

---

## Packages

- `flutter_compass` — device heading stream. **Only new dependency.**
- `geolocator` — already present (used indirectly via `LocationService`).
- Do **not** add `permission_handler`, `sensors_plus`, `vector_math`, or any qibla package.

---

## Folder structure

```
lib/features/qibla/
├── screens/
│   └── qibla_screen.dart      # UI + screen-local state
└── services/
    └── qibla_calculator.dart  # pure bearing math
```

No `data/`, `domain/`, `presentation/`, repositories, or use cases — per CLAUDE.md.

---

## Phases

### Phase 1 — Dependency

Add `flutter_compass` to `pubspec.yaml`, `flutter pub get`.

### Phase 2 — Bearing math

`QiblaCalculator` (static, pure):

- `bearing(lat, lng)` — great-circle initial bearing to Kaaba (21.422487, 39.826206), normalized 0–360°.
- `difference(heading, bearing)` — signed shortest turn, −180..180 (negative = turn left).

### Phase 3 — Screen

`QiblaScreen` as `StatefulWidget` (screen-scoped state, no global provider).

**Location resolution** (in `initState`, one-shot):

1. `PrayerTimeProvider.coordinates` (already in memory)
2. else `LocationService.getCachedCoordinates()`
3. else `LocationService.checkAndRequestPermission()` + `getCurrentCoordinates()`

**Heading:** `StreamBuilder` on `FlutterCompass.events`.

**UI states:**

| State | UI |
|---|---|
| Resolving location | spinner |
| No location / denied | message + Open Settings + Retry (existing l10n strings) |
| No compass sensor (`events` null or `heading` null) | unsupported-device message |
| Ready | compass view |

**Compass view:** dial rotated by `-heading` via `AnimatedRotation` (cumulative turns to avoid 359°→0° spin-around), Kaaba icon placed at bearing on the dial, fixed top marker, status text, heading°/bearing° readouts. All colors from `Theme.of(context)`.

**Direction status:** `|difference| ≤ 5°` → Facing Qibla; `< 0` → Turn left; `> 0` → Turn right.

### Phase 4 — Localization

New keys in `app_en.arb` + `app_bn.arb`: `qiblaFacing`, `qiblaTurnLeft`, `qiblaTurnRight`, `qiblaHeadingLabel`, `qiblaBearingLabel`, `qiblaNoSensor`. Reuse existing `locationDeniedMessage`, `openSettingsButton`, `commonRetry`. Regenerate with `flutter gen-l10n`.

### Phase 5 — Verify

- `flutter analyze` clean.
- Bearing sanity check: Dhaka (23.8103, 90.4125) → ≈ 278°.
- Manual on-device test (user handles).

---

## Avoid

- New state-management or router packages.
- `permission_handler` (geolocator + `LocationService` already cover permissions).
- Repository / UseCase / DataSource layers.
- Any new GPS code — location comes only through `LocationService`.
