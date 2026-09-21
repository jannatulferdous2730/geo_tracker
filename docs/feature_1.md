# Feature 1: Setup and Show the Map

## 1. What this feature does

The app opens to a working, pannable, and zoomable map of the world built with
OpenStreetMap tiles. There is no GPS, no permission prompt, and no markers yet —
just the map as a solid foundation for every phase that follows.

The user sees:
- A full-screen map centred on Chittagong, Bangladesh (22.3569, 91.7832).
- Smooth pan and pinch-to-zoom.
- A small "OpenStreetMap contributors" attribution in the bottom-right corner.
- A bottom navigation bar with three tabs: **Map**, **Saved**, **Nearby**
  (Saved and Nearby show a placeholder for now).
- The design theme: teal primary color, pale chart-paper background — not the
  default Flutter purple.

---

## 2. Files added or changed

| File | Role |
|------|------|
| `lib/main.dart` | App entry point: calls `WidgetsFlutterBinding.ensureInitialized()` and `runApp`. |
| `lib/app.dart` | `MaterialApp` with light/dark theme and `HomeShell` as the home widget. |
| `lib/core/constants/app_constants.dart` | All magic values: fallback coords, zoom levels, tile URL, package name, storage key, tracking constants. |
| `lib/core/theme/app_colors.dart` | Every color token from the design system (light, dark, semantic, category). |
| `lib/core/theme/app_text_styles.dart` | Eight text style tokens (display, headline, title, body, label, caption, data) + spacing constants. |
| `lib/core/theme/app_theme.dart` | Builds `ThemeData` for light and dark from the tokens above. |
| `lib/screens/home_shell.dart` | `NavigationBar` with 3 tabs, `IndexedStack` to keep all screens alive. |
| `lib/screens/map_screen.dart` | `FlutterMap` with `TileLayer` and `RichAttributionWidget`. |
| `lib/screens/saved_places_screen.dart` | Placeholder (Phase 5). |
| `lib/screens/nearby_screen.dart` | Placeholder (Phase 7). |
| `android/app/src/main/AndroidManifest.xml` | Added `INTERNET` permission so release builds can reach the tile server. |
| `pubspec.yaml` | Added `flutter_map`, `latlong2`, `geolocator`, `provider`, `shared_preferences`, `http`. |
| All stub files in `models/`, `services/`, `providers/`, `widgets/` | Empty files with a one-line header comment establishing the folder structure. |

---

## 3. How it works (flow)

```
User opens the app
  |
  v
main.dart: WidgetsFlutterBinding.ensureInitialized() -> runApp(GeoTrackerApp())
  |
  v
app.dart: MaterialApp applies AppTheme.light / AppTheme.dark based on system setting
  |
  v
HomeShell: NavigationBar tab 0 (Map) is selected by default
  |
  v
IndexedStack shows MapScreen at index 0
  |
  v
MapScreen._mapController = MapController()
  |
  v
FlutterMap: reads MapOptions (initialCenter from AppConstants, zoom 13)
  |
  v
TileLayer: sends HTTPS requests to tile.openstreetmap.org/{z}/{x}/{y}.png
  |
  v
Android OS checks AndroidManifest.xml -> INTERNET permission granted -> requests go through
  |
  v
Tile images arrive -> map renders -> user sees streets and can pan/zoom
  |
  v
RichAttributionWidget: shows "OpenStreetMap contributors" (legally required)
```

---

## 4. Key lines of code

### `app_constants.dart` line 19 — `fallbackCenter`
```dart
static final LatLng fallbackCenter = LatLng(fallbackLat, fallbackLng);
```
**Why it matters:** `FlutterMap` needs a `LatLng` as the starting camera position.
By computing it once here from `fallbackLat` and `fallbackLng`, no screen ever
contains raw coordinate literals. If you change the fallback city, you change it
in one place only.
**Without it:** you would write `LatLng(22.3569, 91.7832)` directly in `map_screen.dart` —
a magic number that is impossible to search for or explain.

---

### `map_screen.dart` lines 44–47 — `TileLayer` with `userAgentPackageName`
```dart
TileLayer(
  urlTemplate: AppConstants.tileUrlTemplate,
  userAgentPackageName: AppConstants.userAgentPackage,
),
```
**Why it matters:** `urlTemplate` tells flutter_map where to get map images.
`userAgentPackageName` is sent as the HTTP `User-Agent` header with every tile
request. The OpenStreetMap tile usage policy requires an identifying User-Agent.
Without it (or with a generic one like `"myapp"`), the OSM tile servers may
block or heavily rate-limit your app.
**Without it:** tiles load during development but may silently fail for other
users or in production. The OSM policy page is at
https://operations.osmfoundation.org/policies/tiles/

---

### `map_screen.dart` lines 53–59 — `RichAttributionWidget`
```dart
RichAttributionWidget(
  attributions: [
    TextSourceAttribution('OpenStreetMap contributors'),
  ],
  alignment: AttributionAlignment.bottomRight,
),
```
**Why it matters:** OpenStreetMap data is licensed under the Open Database
License (ODbL), which **requires** visible credit to "OpenStreetMap contributors".
Hiding or removing this is a license violation, not just a courtesy.
**Without it:** the app violates the ODbL. Most production apps have been
rejected from app stores for this reason.

---

### `map_screen.dart` line 23 — `MapController`
```dart
final MapController _mapController = MapController();
```
**Why it matters:** `MapController` lets you move the camera from code, not just
from the user's fingers. Phase 2 uses it to jump to the user's real GPS position.
Phase 3 uses it for the "My location" button. Owned here in `_MapScreenState` —
not in a provider — because `architecture.md` says one controller per map screen.
**Without it:** you cannot programmatically move the camera. The map starts at
the fallback position and stays there forever.

---

### `home_shell.dart` line 37 — `IndexedStack`
```dart
body: IndexedStack(
  index: _selectedIndex,
  children: _screens,
),
```
**Why it matters:** `IndexedStack` keeps all three screens in memory at the same
time but only shows the one matching `index`. This is critical for the map: a
`PageView` or `Navigator.push` approach would *destroy and recreate* `MapScreen`
every time the user switches tabs, losing the `MapController` and resetting the
camera position. With `IndexedStack`, the map stays alive.
**Without it:** switching to the Saved tab and back would reset the map to the
fallback location every time.

---

### `app_theme.dart` line 50 — explicit `ColorScheme`
```dart
colorScheme: const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  ...
),
```
**Why it matters:** Flutter's `ColorScheme.fromSeed` generates colours
algorithmically from one seed — the exact hex values you designed are not
guaranteed. Using an explicit `ColorScheme` ensures every colour is exactly what
`design.md` specifies.
**Without it:** the teal `#0B7285` designed for the app may become a slightly
different generated shade that breaks the design intent.

---

### `AndroidManifest.xml` — `INTERNET` permission
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
**Why it matters:** Android blocks all network access by default. Without this
permission, tile requests are silently dropped. In **debug** builds, the Flutter
tool temporarily adds internet access to the debug manifest — so tiles appear to
work during development. In a **release** build, the main manifest is used and
tiles go grey. Adding it to the main manifest fixes both.
**Without it:** the app looks fine in debug, but the map is blank grey squares
in `flutter run --release`.

---

## 5. Config changes (AndroidManifest / Info.plist / pubspec)

### `android/app/src/main/AndroidManifest.xml`

| Entry | Why needed | What happens if missing |
|-------|-----------|------------------------|
| `<uses-permission android:name="android.permission.INTERNET"/>` | Allows the app to open TCP/IP connections. Required for tile downloads, Overpass (Phase 7), OSRM (Phase 8). | Tiles are grey in release builds. Debug builds may still work because the debug manifest adds internet separately. |

Reference: https://developer.android.com/reference/android/Manifest.permission#INTERNET

### `pubspec.yaml` — new dependencies

| Package | Version | Why added now |
|---------|---------|--------------|
| `flutter_map` | 8.3.2 | The map widget — `FlutterMap`, `TileLayer`, `MapController`. |
| `latlong2` | 0.10.1 | Provides the `LatLng` type used by `flutter_map` for all coordinates. |
| `geolocator` | 14.0.3 | GPS, permissions, position stream. Not used yet, but its Android Gradle setup must be in place early (see geolocator README). |
| `provider` | 6.1.5+1 | State management (`ChangeNotifier`, `MultiProvider`). Added now so the structure is ready for Phase 2. |
| `shared_preferences` | 2.5.5 | Local key-value storage. Not used until Phase 5 (saved places). |
| `http` | 1.6.0 | HTTP client for REST API calls. Not used until Phase 7 (Overpass). |

> **Note:** `geolocator` is listed now because it modifies Android Gradle
> requirements (minSdkVersion, Kotlin version). Adding it later can cause build
> failures that are harder to debug. It is better to resolve these early even
> though the package is not used until Phase 2.

---

## 6. Concepts to learn

| Topic | Official documentation |
|-------|----------------------|
| Flutter widgets and the widget tree | https://docs.flutter.dev/ui |
| `StatefulWidget` and `State` lifecycle | https://docs.flutter.dev/ui/interactivity |
| `ThemeData` and `ColorScheme` | https://docs.flutter.dev/cookbook/design/themes |
| `NavigationBar` (Material 3) | https://api.flutter.dev/flutter/material/NavigationBar-class.html |
| `flutter_map` basics (FlutterMap, MapOptions, TileLayer) | https://pub.dev/packages/flutter_map |
| `latlong2` package | https://pub.dev/packages/latlong2 |
| OSM tile usage policy | https://operations.osmfoundation.org/policies/tiles/ |
| Android permissions | https://developer.android.com/training/permissions/declaring |
| OpenStreetMap ODbL license | https://www.openstreetmap.org/copyright |

---

## 7. Common mistakes and errors

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `userAgentPackageName` missing or generic | Tiles may load at first, then get rate-limited or blocked by OSM servers | Set it to the real package name from `pubspec.yaml` |
| `INTERNET` permission only in the debug manifest | Map works in `flutter run` but is grey in `flutter run --release` | Add the permission to `android/app/src/main/AndroidManifest.xml` (the main one) |
| Hot reload after manifest change | The old manifest (without the permission) is still active | Stop the app completely and run `flutter run` again |
| `MultiProvider(providers: const [], ...)` | Crashes with `AssertionError: children.isNotEmpty` | Do not use `MultiProvider` with an empty list; add it only when you have at least one provider |
| Trailing space in `gradle.properties` boolean value | `Cannot parse project property android.builtInKotlin='false '` | Make sure there are no trailing spaces after `true` or `false` in `.properties` files |
| `RichAttributionWidget` removed to save space | License violation (ODbL requires visible credit) | Keep it visible; move it if it overlaps your UI, do not hide it |
| `IndexedStack` replaced with `PageView` | `MapController` is recreated on every tab switch; camera resets to fallback | Use `IndexedStack` to keep all tab screens alive |
| `ColorScheme.fromSeed` used instead of explicit `ColorScheme` | Designed hex values are not used; brand colors look subtly wrong | Use an explicit `ColorScheme` as in `app_theme.dart` lines 50–74 |

---

## 8. Try it yourself

1. **Zoom experiment:** In `map_screen.dart` line 34, change `initialZoom: AppConstants.defaultZoom` to `initialZoom: 1.0`. Hot restart. You should see almost the whole world. Change it to `19.0` and you will see individual buildings (if tiles exist at that zoom). Put it back to `13.0`.

2. **Fallback location:** In `app_constants.dart` lines 14–15, change `fallbackLat` and `fallbackLng` to your own city's coordinates (find them on https://www.openstreetmap.org — right-click on the map). Hot restart and confirm the map opens on your city.

3. **Missing attribution:** Remove the `RichAttributionWidget` block from `map_screen.dart` (lines 53–59). Hot restart. Notice the attribution disappears. Put it back — this is a license requirement, not optional.

4. **Tab switching:** Switch to the Saved tab and then back to Map. Notice the map is still exactly where you left it (same zoom, same position). This is `IndexedStack` working. Now temporarily replace `IndexedStack` with `Column(children: [Expanded(child: _screens[_selectedIndex])])`, hot restart, navigate away from Map and back — the map resets. Undo the change.

---

## 9. Explain it back (written by the developer)

*(Leave this blank. Write it in your own words after completing the "Try it yourself" experiments above.)*

---

## 10. Package versions used

| Package | Version |
|---------|---------|
| `flutter_map` | 8.3.2 |
| `latlong2` | 0.10.1 |
| `geolocator` | 14.0.3 |
| `provider` | 6.1.5+1 |
| `shared_preferences` | 2.5.5 |
| `http` | 1.6.0 |
| `flutter_lints` | 6.0.0 |
| Flutter SDK | stable (Dart sdk `^3.12.0`) |
