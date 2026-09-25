// lib/services/location_service.dart
// All GPS interaction lives here. No widget or provider ever imports geolocator directly.
// Rule (architecture.md): services handle external platform APIs; providers call services.

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// ── LocationIssue ──────────────────────────────────────────────────────────────
// Every failure mode the GPS stack can return, as a named value.
// Using an enum (not raw strings or exceptions) means the compiler catches
// every unhandled case in a switch and the UI can show the exact right message.
enum LocationIssue {
  // The device's location service (GPS switch) is turned off.
  // Action: direct the user to Location Settings.
  serviceDisabled,

  // The user tapped "Deny" on the runtime dialog but can be asked again.
  // Action: show a rationale and re-request with Geolocator.requestPermission().
  permissionDenied,

  // The user tapped "Don't ask again" (Android) or denied twice (iOS).
  // Action: show a message and open App Settings with Geolocator.openAppSettings().
  permissionDeniedForever,

  // getCurrentPosition did not return within the allowed time window.
  // Action: show a retry button.
  timeout,
}

// ── LocationService ────────────────────────────────────────────────────────────
class LocationService {
  // Private constructor — call the static methods directly; no instance needed.
  LocationService._();

  // ── ensureReady ──────────────────────────────────────────────────────────────
  // Checks that the GPS service is on AND that permission is granted.
  // Returns null when everything is ready, or the specific LocationIssue that
  // prevents us from proceeding.
  //
  // Call order matters:
  //   1. isLocationServiceEnabled — if GPS is off, permission checks are moot.
  //   2. checkPermission           — read the current grant without a dialog.
  //   3. requestPermission         — show the system dialog only when needed.
  //
  // This method never throws. All platform exceptions are caught internally.
  static Future<LocationIssue?> ensureReady() async {
    // Step 1: Is the GPS/location service switch on?
    // Geolocator.isLocationServiceEnabled() checks the Android
    // "Location" toggle in Quick Settings — not the app permission.
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      serviceEnabled = false;
    }

    if (!serviceEnabled) {
      return LocationIssue.serviceDisabled;
    }

    // Step 2: Read the current permission state without prompting.
    // This is important: we must not show the dialog on every launch.
    // If the user already granted permission we skip straight to success.
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
    } catch (_) {
      return LocationIssue.permissionDenied;
    }

    // Step 3: Request if not yet granted.
    // We only call requestPermission when the status is `denied` (the initial
    // state, or after one denial on Android). After `deniedForever` the dialog
    // is suppressed by the OS — calling requestPermission again is pointless and
    // confusing, so we return the appropriate issue directly.
    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission();
      } catch (_) {
        return LocationIssue.permissionDenied;
      }
    }

    // Map the geolocator enum to our own LocationIssue values.
    if (permission == LocationPermission.deniedForever) {
      return LocationIssue.permissionDeniedForever;
    }

    if (permission == LocationPermission.denied) {
      return LocationIssue.permissionDenied;
    }

    // LocationPermission.whileInUse or .always — both are fine for this app.
    return null; // null = no issue = ready to get a position
  }

  // ── getCurrentPosition ───────────────────────────────────────────────────────
  // T2.3 — implemented below.
  // Returns the device's current GPS fix, or null + sets [issue] on failure.
  // Callers must call ensureReady() first.
  static Future<({LatLng? position, double? accuracy, LocationIssue? issue})>
      getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        // LocationSettings is the geolocator 9+ API.
        // LocationAccuracy.high requests the best possible fix.
        // distanceFilter: 0 means "give me the first fix regardless of movement".
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        // 15 seconds is generous enough for a cold GPS start indoors.
        // Without a timeout this call can hang forever when the GPS has no sky view.
        const Duration(seconds: 15),
        onTimeout: () => throw _TimeoutSentinel(),
      );
      return (
        position: LatLng(pos.latitude, pos.longitude),
        accuracy: pos.accuracy,
        issue: null,
      );
    } on _TimeoutSentinel {
      return (position: null, accuracy: null, issue: LocationIssue.timeout);
    } catch (_) {
      // Any other platform exception (e.g., service toggled off mid-call).
      return (
        position: null,
        accuracy: null,
        issue: LocationIssue.serviceDisabled,
      );
    }
  }

  // ── openLocationSettings ─────────────────────────────────────────────────────
  // Opens the device's main Location Settings page.
  // Used when issue == serviceDisabled.
  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();

  // ── openAppSettings ──────────────────────────────────────────────────────────
  // Opens the app's Settings page so the user can grant permission manually.
  // Used when issue == permissionDeniedForever.
  static Future<void> openAppSettings() => Geolocator.openAppSettings();
}

// Private sentinel used to distinguish our own timeout from any other exception.
// Using a typed sentinel avoids catching unrelated errors.
class _TimeoutSentinel implements Exception {}
