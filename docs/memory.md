# Memory: GeoTracker

> **Owner:** agent. Updated after every task. Newest entries at the top of each section.
> Do not edit planning docs (`product_requirement_document.md`, `rules.md`, `design.md`, `architecture.md`).
> **Rule:** Never delete any entry. Add dates when updating.

---

## Status

| Date | Current phase | Next step |
|------|--------------|-----------|
| 2026-09-27 | Phase 2 — COMPLETE ✅ | T2.12 [You] experiments + explain it back, then begin Phase 3 |
| 2026-09-21 | Phase 1 — COMPLETE ✅ | Begin Phase 2 |

---

## Package versions

| Package | Version | Resolved |
|---------|---------|---------|
| `flutter_map` | 8.3.2 | 2026-09-21 |
| `latlong2` | 0.10.1 | 2026-09-21 |
| `geolocator` | 14.0.3 | 2026-09-21 |
| `provider` | 6.1.5+1 | 2026-09-21 |
| `shared_preferences` | 2.5.5 | 2026-09-21 |
| `http` | 1.6.0 | 2026-09-21 |
| `flutter_lints` | 6.0.0 | 2026-09-21 |

Flutter SDK: stable channel (Dart sdk `^3.12.0` per pubspec).

---

## Decisions

| # | Date | Decision | Reason | Task |
|---|------|----------|--------|------|
| D1 | 2026-09-21 | Package name: `com.example.geo_tracker` | Default, user chose to keep it | T1.2 |
| D2 | 2026-09-21 | Fonts (Bricolage Grotesque, Figtree) deferred to Phase 9 | Keep Phase 1 simple | T1.2 |
| D3 | 2026-09-21 | `MultiProvider` not added until Phase 2 | `nested` package asserts `children.isNotEmpty`; empty MultiProvider crashes | T1.8 |
| D4 | 2026-09-26 | 15-second timeout on `getCurrentPosition` | Prevents infinite spinner indoors; generous for cold GPS start outdoors | T2.3 |
| D5 | 2026-09-26 | `_TimeoutSentinel` class instead of `TimeoutException` | `catch (_)` maps `TimeoutException` to `serviceDisabled` — sentinel keeps paths unambiguous | T2.3 |
| D6 | 2026-09-26 | `ChangeNotifierProvider(lazy: false)` for `LocationProvider` | Permission check starts at app launch, not on first widget read | T2.4 |
| D7 | 2026-09-26 | `addPostFrameCallback` to call `init()` from `initState` | Prevents `setState() called during build` error | T2.4 |
| D8 | 2026-09-26 | `FakeLocationProvider` kept in production file, not test/ | Compiles with real provider — API changes caught at compile time | T2.9 |
| D9 | 2026-09-26 | No `ACCESS_BACKGROUND_LOCATION` permission | App tracks foreground only; background needs extra App Store justification | T2.1 |

---

## Config changes

| Date | File | Change | Task |
|------|------|--------|------|
| 2026-09-21 | `pubspec.yaml` | Added `flutter_map`, `latlong2`, `geolocator`, `provider`, `shared_preferences`, `http` | T1.2 |
| 2026-09-21 | `android/app/src/main/AndroidManifest.xml` | Added `INTERNET` permission | T1.7 |
| 2026-09-21 | `android/gradle.properties` | Added `kotlin.incremental=false`; fixed trailing space on `android.builtInKotlin=false` | T1.8 |
| 2026-09-26 | `android/app/src/main/AndroidManifest.xml` | Added `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` | T2.1 |

---

## Completed tasks

### Phase 1 — Setup and show the map (completed 2026-09-21)

- [x] T1.1 — Counter app confirmed running on real phone.
- [x] T1.2 — Packages added. Versions recorded above.
- [x] T1.3 — Folder structure created (models/, services/, providers/, widgets/, screens/, core/).
- [x] T1.4 — `app_constants.dart` complete. No magic values in widget code.
- [x] T1.5 — Theme files complete: `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`. Light and dark `ThemeData` with explicit `ColorScheme`.
- [x] T1.6 — `MapScreen` built: `FlutterMap`, `TileLayer`, `RichAttributionWidget`, `MapController`.
- [x] T1.7 — `INTERNET` permission added to main `AndroidManifest.xml`.
- [x] T1.8 — `HomeShell` with `IndexedStack` and `NavigationBar`. `main.dart` and `app.dart` rewritten.
- [x] T1.9 — `docs/feature_1.md` written with real file names and line numbers. `memory.md` updated.
- [ ] T1.10 — **[You]** Do "Try it yourself" experiments, write "Explain it back" in `feature_1.md` section 9.

### Phase 2 — Permission and current location (completed 2026-09-27)

- [x] T2.1 — `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` added to manifest. (2026-09-26)
- [x] T2.2 — `LocationIssue` enum (4 values) + `LocationService.ensureReady()` with correct 3-step call order. (2026-09-26)
- [x] T2.3 — `LocationService.getCurrentPosition()` with 15 s timeout and `_TimeoutSentinel`. (2026-09-26)
- [x] T2.4 — `LocationProvider`: `init()`, `retry()`, `onResume()`, `LocationStatus` enum, `lazy: false`, `addPostFrameCallback`. (2026-09-26)
- [x] T2.5 — `PermissionPrompt` widget: all 4 issue types, copy from design.md section 11. (2026-09-26)
- [x] T2.6 — Action buttons wired: `openLocationSettings`, `openAppSettings`, `retry`. (2026-09-26)
- [x] T2.7 — `WidgetsBindingObserver` in `MapScreen`; `onResume()` re-runs `init()` only on error. (2026-09-26)
- [x] T2.8 — `LocationInfoCard`: lat/lng (5 decimals), accuracy, `data` text style (tabular figures). (2026-09-26)
- [x] T2.9 — 17 unit tests pass. `FakeLocationProvider` + `@visibleForTesting setStateForTest()`. (2026-09-26)
- [x] T2.10 — Manual test: app confirmed working on real device. Logs explained. (2026-09-26)
- [x] T2.11 — `docs/feature_2.md` written, `memory.md` updated. (2026-09-27)
- [ ] T2.12 — **[You]** Do 5 experiments in `feature_2.md` section 8, write "Explain it back" in section 9.

---

## Known bugs fixed

| Date | Bug | Cause | Fix | Task |
|------|-----|-------|-----|------|
| 2026-09-21 | `AssertionError: children.isNotEmpty` on launch | `MultiProvider(providers: const [])` — `nested` requires non-empty list | Removed empty `MultiProvider`; added back in T2.4 with real provider | T1.8 |
| 2026-09-21 | Gradle build failure: `Cannot parse 'false '` | Trailing space on `android.builtInKotlin=false ` in `gradle.properties` | Removed trailing space | T1.8 |
| 2026-09-21 | `flutter analyze` warning: unused import | `import 'package:latlong2/latlong.dart'` in `map_screen.dart` | Removed (LatLng re-exported by flutter_map) | T1.6 |
| 2026-09-26 | `flutter analyze` warning: unused import | `import '../core/theme/app_text_styles.dart'` in `location_info_card.dart` | Removed | T2.8 |

---

## Device observations (real-device test log)

| Date | Log entry | Meaning |
|------|-----------|---------|
| 2026-09-26 | `D/FlutterGeolocator: Geolocator foreground service connected` | Plugin initialised correctly — good sign |
| 2026-09-26 | `W/HiTouch_PressGestureDetector: [HiTouch Stop]` | Huawei gesture system noise, not a bug |
| 2026-09-26 | `W/libc: Unable to set property "debug.vulkan.api.version"` | Android 10+ blocks app-side Vulkan property writes; harmless |
| 2026-09-26 | `I/AdrenoVK-0: Unknown struct with type 0x3b...` | Adreno driver ignoring newer Vulkan extension structs from Impeller; harmless |
| 2026-09-26 | `SocketException: Failed host lookup: 'tile.openstreetmap.org'` | Network connectivity issue on device (not code); tiles load when internet is available |

---

## Open questions

_(none — add new questions here as they arise)_
