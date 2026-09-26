# Feature 2: Permission and Current Location

## 1. What this feature does

The first time the app opens it asks the user for location permission. Once
granted it gets a single GPS fix and shows the coordinates in a floating info
card at the bottom-left of the map. Every possible failure mode (GPS off,
permission denied, permanently denied, timeout) shows the correct message and
action button directly on the screen. When the user returns from the Settings
app the screen re-checks automatically — no manual restart needed.

The user sees:
- A "Getting location…" spinner at the top while the fix is loading.
- A permission dialog shown by Android (the system OS dialog, not custom UI).
- If something goes wrong: a dimmed map with a centred prompt card showing the
  exact failure reason and one primary button.
- On success: a floating card bottom-left showing `LAT`, `LNG` to 5 decimal
  places and `Accuracy ±N m`.

---

## 2. Files added or changed

| File | Change |
|------|--------|
| `lib/services/location_service.dart` | **New.** `LocationIssue` enum + `LocationService` with `ensureReady()`, `getCurrentPosition()`, `openLocationSettings()`, `openAppSettings()`. |
| `lib/providers/location_provider.dart` | **New.** `LocationStatus` enum + `LocationProvider` with `init()`, `retry()`, `onResume()`, `@visibleForTesting` helpers, and `FakeLocationProvider`. |
| `lib/widgets/permission_prompt.dart` | **New.** Presentational widget mapping each `LocationIssue` to copy + action button. |
| `lib/widgets/location_info_card.dart` | **New.** Floating card showing lat/lng and accuracy. |
| `lib/screens/map_screen.dart` | **Rewritten.** Added lifecycle observer, permission overlay, loading indicator, and info card. |
| `lib/main.dart` | **Updated.** `MultiProvider` added with `LocationProvider`. |
| `android/app/src/main/AndroidManifest.xml` | **Updated.** Added `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions. |
| `test/location_provider_test.dart` | **New.** 17 unit tests. |

---

## 3. How it works (flow)

```
App starts
  |
  v
main.dart: MultiProvider creates LocationProvider(lazy: false)
  |
  v
MapScreen.initState():
  WidgetsBinding.addObserver(this)           ← registers for lifecycle events
  addPostFrameCallback → provider.init()     ← safe: tree is built first
  |
  v
LocationProvider.init():
  _status = loading → notifyListeners()      ← spinner appears
  |
  v
LocationService.ensureReady()
  Step 1: Geolocator.isLocationServiceEnabled()
    → false? return LocationIssue.serviceDisabled
  Step 2: Geolocator.checkPermission()
    → whileInUse/always? skip step 3
    → denied? go to step 3
    → deniedForever? return LocationIssue.permissionDeniedForever
  Step 3: Geolocator.requestPermission()     ← system dialog appears
    → denied again? return LocationIssue.permissionDenied
  → null (all good)
  |
  v
LocationService.getCurrentPosition()
  Geolocator.getCurrentPosition(accuracy: high, distanceFilter: 0)
    .timeout(15 s, onTimeout: throw _TimeoutSentinel)
    → _TimeoutSentinel caught → return LocationIssue.timeout
    → success → return LatLng + accuracy
  |
  v
LocationProvider:
  success → _status = success, _currentPosition = fix → notifyListeners()
  error   → _status = error,   _issue = issue    → notifyListeners()
  |
  v
MapScreen.build() (context.watch):
  status == loading  → show spinner
  status == error    → show ModalBarrier + PermissionPrompt card
  hasPosition == true → show LocationInfoCard bottom-left

User goes to Settings, grants permission, returns:
  |
  v
AppLifecycleState.resumed
  → MapScreen.didChangeAppLifecycleState()
  → provider.onResume()
  → if status == error: init() again
```

---

## 4. Key lines of code

### `location_service.dart` lines 12–28 — `LocationIssue` enum
```dart
enum LocationIssue {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
}
```
**Why it matters:** Using a named enum instead of raw strings or exceptions means
the Dart compiler enforces that every caller handles every case. If you add a new
value and forget to update `PermissionPrompt`'s switch, the analyzer reports a
missing case immediately. Unit test `LocationIssue has exactly 4 values` catches
the same thing at runtime.
**Without it:** You would use `String` error codes or `Exception` subclasses.
Neither gives you compiler-enforced exhaustive switch coverage.

---

### `location_service.dart` lines 46–95 — `ensureReady()` call order
```dart
// Step 1: service check
serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) return LocationIssue.serviceDisabled;

// Step 2: read current permission (no dialog)
permission = await Geolocator.checkPermission();

// Step 3: request only when needed
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
```
**Why the order matters:**
- Checking the service before the permission prevents showing the permission
  dialog when GPS is off — the dialog would succeed but the fix would still fail.
- `checkPermission()` before `requestPermission()` means the app never shows the
  dialog on every launch if the user already granted permission. Android shows the
  dialog only once; calling `requestPermission()` when already granted is harmless
  but wasteful.
- Only calling `requestPermission()` when status is `denied` (not `deniedForever`)
  respects Android's rule: after `deniedForever`, the dialog is suppressed by the
  OS — showing it would confuse the user with a silent no-op.
**Without it:** Dialog appears every launch, or GPS-off is not detected until
after a failed `getCurrentPosition()` call.

---

### `location_service.dart` lines 112–116 — `.timeout()` with `_TimeoutSentinel`
```dart
).timeout(
  const Duration(seconds: 15),
  onTimeout: () => throw _TimeoutSentinel(),
);
```
**Why it matters:** `Geolocator.getCurrentPosition()` can hang indefinitely with
no sky view (indoors, basement, dense canopy). Without a timeout the UI spinner
would spin forever. 15 seconds is generous enough for a cold GPS start outdoors
but short enough to show a retry option quickly indoors.

`_TimeoutSentinel` (line 149) is a private typed exception used as a sentinel.
The `catch (_)` block below it would also catch the timeout if we used
`TimeoutException` directly — that would wrongly return `serviceDisabled` instead
of `timeout`. The sentinel makes the two paths unambiguous.
**Without it:** The app hangs forever with no GPS signal. Indoors = unusable.

---

### `location_provider.dart` lines 43–75 — `init()` state machine
```dart
Future<void> init() async {
  if (_status == LocationStatus.loading) return;  // guard

  _status = LocationStatus.loading;
  notifyListeners();    // spinner appears

  final readyIssue = await LocationService.ensureReady();
  if (readyIssue != null) {
    _status = LocationStatus.error;
    _issue = readyIssue;
    notifyListeners();  // prompt appears
    return;
  }

  final result = await LocationService.getCurrentPosition();
  if (result.issue != null) { ... }

  _currentPosition = result.position;
  _status = LocationStatus.success;
  notifyListeners();    // info card appears
}
```
**Why `notifyListeners()` is called twice on success:** The first call at line 49
triggers the loading spinner immediately. The second call at line 74 replaces the
spinner with the info card. Without the first call the UI shows nothing during the
(potentially 5–15 second) GPS acquisition.

**Why the guard at line 45:** If the user taps Retry while `init()` is already
running (possible because `retry()` delegates to `init()`), two parallel calls
would race. The guard ensures only one is active at a time.

---

### `location_provider.dart` lines 93–97 — `onResume()`
```dart
void onResume() {
  if (_status == LocationStatus.error) {
    init();
  }
}
```
**Why it matters:** When the user leaves the app to grant permission in Settings
and comes back, Android fires `AppLifecycleState.resumed`. This method re-runs
`init()` only when we were in an error state, avoiding a redundant GPS call if
the app resumes normally (e.g., after answering a call).
**Without it:** The user grants permission in Settings, returns to the app, and
the error prompt is still showing. They have to kill and reopen the app.

---

### `map_screen.dart` lines 24, 32, 45, 55–59 — `WidgetsBindingObserver`
```dart
class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  void initState() {
    WidgetsBinding.instance.addObserver(this);   // line 32: register
    ...
  }
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // line 45: unregister ← critical
    super.dispose();
  }
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {     // line 56
      context.read<LocationProvider>().onResume();
    }
  }
}
```
**Why `removeObserver` at line 45 is critical:** If you forget to unregister,
the `WidgetsBinding` holds a reference to `_MapScreenState` forever. This is a
memory leak and will also cause `context.read()` calls to run on a disposed
widget tree, throwing `FlutterError: Looking up a deactivated widget's ancestor`.

---

### `map_screen.dart` line 37–39 — `addPostFrameCallback`
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<LocationProvider>().init();
});
```
**Why not call `init()` directly in `initState()`:** `initState()` runs before
`build()`. If `init()` calls `notifyListeners()` synchronously (it can during
error paths) while the widget tree is still being built, Flutter throws
`setState() or markNeedsBuild() called during build`. `addPostFrameCallback`
defers the call until after the first frame is committed, making it safe.

---

### `map_screen.dart` lines 102–123 — `ModalBarrier` + `PermissionPrompt`
```dart
if (provider.status == LocationStatus.error && provider.issue != null) ...[
  const ModalBarrier(color: Colors.black38, dismissible: false),
  Center(child: ... PermissionPrompt(...)),
],
```
**Why `ModalBarrier`:** Without it the map is interactive underneath the prompt.
The user could pan the map while a prompt is showing, which is confusing.
`dismissible: false` ensures they must use the button — they cannot tap the dim
area to dismiss.

**Why the map is still rendered underneath:** `Stack` renders all children.
The map renders first (index 0), the barrier and prompt render on top (indices 1, 2).
This keeps the app responsive — tiles continue to load in the background.

---

### `main.dart` lines 21–30 — `MultiProvider` with `lazy: false`
```dart
ChangeNotifierProvider<LocationProvider>(
  create: (_) => LocationProvider(),
  lazy: false,
),
```
**Why `lazy: false`:** By default, `provider` creates the provider only when a
widget first reads from it. With `lazy: true` (the default), `LocationProvider`
would not exist until `MapScreen` builds — which means there is a short window
at startup where the permission check has not started yet. With `lazy: false`,
the provider is created immediately when `MultiProvider` is built (i.e., at app
start), so the permission check begins as early as possible.

---

### `AndroidManifest.xml` — location permissions

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
**Why both:**
- `ACCESS_FINE_LOCATION` requests GPS-quality positioning (±3 m). This is the
  one `geolocator` uses.
- `ACCESS_COARSE_LOCATION` is required alongside `FINE` on Android 12+ for the
  runtime permission dialog to appear. Without it the dialog is suppressed on
  Android 12 devices and the user is never asked.
- Neither is `ACCESS_BACKGROUND_LOCATION` — we only need location while the app
  is in use (foreground). Background location would require additional App Store
  justification.

---

## 5. Config changes

### `android/app/src/main/AndroidManifest.xml`

| Entry | Why needed | Missing = |
|-------|-----------|-----------|
| `ACCESS_FINE_LOCATION` | GPS-quality fix. Required by `geolocator`. | `Geolocator.getCurrentPosition()` throws `PermissionDeniedException`. |
| `ACCESS_COARSE_LOCATION` | Android 12+ runtime dialog requirement. | Dialog never shown on Android 12; user permanently stuck at `permissionDenied`. |

Reference: https://developer.android.com/training/location/permissions

---

## 6. Concepts to learn

| Topic | Official documentation |
|-------|----------------------|
| `ChangeNotifier` and `provider` | https://pub.dev/packages/provider |
| `WidgetsBindingObserver` lifecycle | https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html |
| `AppLifecycleState` values | https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html |
| `addPostFrameCallback` | https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html |
| `geolocator` permission flow | https://pub.dev/packages/geolocator |
| Android location permissions | https://developer.android.com/training/location/permissions |
| `Future.timeout()` | https://api.dart.dev/stable/dart-async/Future/timeout.html |
| Dart records (used in `getCurrentPosition` return type) | https://dart.dev/language/records |

---

## 7. Common mistakes and errors

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Missing `ACCESS_COARSE_LOCATION` | Dialog never shown on Android 12+ | Add both FINE and COARSE to the main manifest |
| Calling `requestPermission()` after `deniedForever` | Silent no-op; user confused | Check for `deniedForever` before calling `requestPermission()` |
| Forgetting `removeObserver(this)` in `dispose()` | Memory leak; `Looking up deactivated widget` crash on resume | Always pair `addObserver` with `removeObserver` |
| Calling `init()` directly in `initState()` | `setState() called during build` error | Use `addPostFrameCallback` to defer until after the first frame |
| `MultiProvider` with empty `providers: []` | `AssertionError: children.isNotEmpty` crash on launch | Add at least one provider; do not use `MultiProvider` with an empty list |
| No timeout on `getCurrentPosition` | Spinner hangs forever indoors | Use `.timeout(Duration(seconds: 15))` with a sentinel exception |
| Using `TimeoutException` as the timeout sentinel | `catch (_)` block wrongly maps it to `serviceDisabled` | Use a private typed class (`_TimeoutSentinel`) to distinguish timeout from other errors |
| Calling `context.read()` in `build()` | Does not rebuild when provider changes | Use `context.watch()` in `build()` for reactive rebuilds |

---

## 8. Try it yourself

1. **Force each error state:** In `LocationService.ensureReady()` line 52,
   temporarily `return LocationIssue.serviceDisabled;` before the real check.
   Hot restart — you should see "Location is turned off" with a button.
   Try each of the 4 values in turn. Remove the override when done.

2. **Remove the timeout:** Comment out lines 112–117 in `location_service.dart`
   (the `.timeout()` call). Go inside (no GPS signal), tap Retry. Notice the
   spinner never stops. Uncomment it.

3. **Watch notifyListeners:** Add `print('notify: $_status')` at the top of
   `notifyListeners()` in `location_provider.dart` (by overriding it). Run the
   app. You should see exactly two prints on success: `loading` then `success`.
   Remove the print when done.

4. **Remove `addObserver`:** Comment out line 32 (`addObserver`) and line 45
   (`removeObserver`). Grant location permission. Now go to Settings and come
   back. Notice the error screen does not automatically go away. Uncomment both.

5. **Change the timeout:** On line 115, change `15` to `3`. Immediately tap
   Retry before GPS gets a fix. You should see "Could not get a fix" in about
   3 seconds. Change it back to `15`.

---

## 9. Explain it back

*(Leave this blank. Write it in your own words after completing the experiments.)*

---

## 10. Package versions used

| Package | Version |
|---------|---------|
| `geolocator` | 14.0.3 |
| `provider` | 6.1.5+1 |
| `latlong2` | 0.10.1 |
| `flutter_map` | 8.3.2 |
| Flutter SDK | stable (Dart sdk `^3.12.0`) |
