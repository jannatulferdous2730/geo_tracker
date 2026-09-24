# Memory: GeoTracker

> **Owner:** agent. Updated after every task. Newest entries first.
> Do not edit planning docs (`product_requirement_document.md`, `rules.md`, `design.md`, `architecture.md`).

---

## Status

- **Last updated:** 2026-09-21
- **Current phase:** Phase 1 — COMPLETE ✅
- **Next phase:** Phase 2 — Permission and current location
- **Next step:** Wait for developer confirmation, then begin T2.1

---

## Package versions (resolved 2026-09-21)

| Package | Version |
|---------|---------|
| `flutter_map` | 8.3.2 |
| `latlong2` | 0.10.1 |
| `geolocator` | 14.0.3 |
| `provider` | 6.1.5+1 |
| `shared_preferences` | 2.5.5 |
| `http` | 1.6.0 |
| `flutter_lints` | 6.0.0 |

Flutter SDK: stable channel (Dart sdk `^3.12.0` per pubspec).

---

## Decisions

| # | Decision | Reason | Task |
|---|----------|--------|------|
| D1 | Package name: `com.example.geo_tracker` | Default, user chose to keep it | T1.2 |
| D2 | Fonts (Bricolage Grotesque, Figtree) deferred to Phase 9 | Keep Phase 1 simple | T1.2 |
| D3 | `MultiProvider` not added until Phase 2 | `nested` package asserts `children.isNotEmpty`; empty MultiProvider crashes | T1.8 |

---

## Config changes

| File | Change | Task |
|------|--------|------|
| `pubspec.yaml` | Added `flutter_map`, `latlong2`, `geolocator`, `provider`, `shared_preferences`, `http` | T1.2 |
| `android/app/src/main/AndroidManifest.xml` | Added `INTERNET` permission (main manifest, not only debug) | T1.7 |
| `android/gradle.properties` | Added `kotlin.incremental=false`; fixed trailing space on `android.builtInKotlin=false` that caused Gradle parse error | T1.8 (build issue) |

---

## Completed tasks

- [x] T1.1 — Counter app confirmed running on real phone.
- [x] T1.2 — Packages added. Versions recorded above.
- [x] T1.3 — Folder structure created (all stubs in models/, services/, providers/, widgets/, screens/, core/).
- [x] T1.4 — `app_constants.dart` complete. No magic values in widget code.
- [x] T1.5 — Theme files complete: `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`. Light and dark ThemeData with explicit ColorScheme.
- [x] T1.6 — `MapScreen` built: `FlutterMap`, `TileLayer`, `RichAttributionWidget`, `MapController`.
- [x] T1.7 — `INTERNET` permission added to main `AndroidManifest.xml`.
- [x] T1.8 — `HomeShell` with `IndexedStack` and `NavigationBar`. `main.dart` and `app.dart` rewritten.
- [x] T1.9 — `docs/feature_1.md` written with real file names and line numbers. `memory.md` updated.

---

## Known bugs fixed

| Bug | Cause | Fix | Task |
|-----|-------|-----|------|
| `AssertionError: children.isNotEmpty` on launch | `MultiProvider(providers: const [])` — nested package requires non-empty list | Removed empty `MultiProvider`; will add it back in Phase 2 with real providers | T1.8 |
| Gradle build failure: `Cannot parse 'false '` | Trailing space on `android.builtInKotlin=false ` in `gradle.properties` | Removed trailing space | T1.8 |
| `flutter analyze` warning: unused import | `import 'package:latlong2/latlong.dart'` in `map_screen.dart` — `LatLng` is exported by `flutter_map` | Removed the redundant import | T1.6 |

---

## Open questions

_(none)_
