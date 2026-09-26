// lib/providers/location_provider.dart
// ChangeNotifier that holds the current GPS state.
// Rule (architecture.md): providers call services, never geolocator directly.
// Rule: no business logic in widgets — the widget reads from this provider.

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

// The three coarse states the UI needs to distinguish.
enum LocationStatus {
  // init() has not been called yet.
  idle,
  // Waiting for ensureReady() or getCurrentPosition() to return.
  loading,
  // A GPS fix is available in [currentPosition].
  success,
  // Something went wrong — see [issue] for the specific reason.
  error,
}

class LocationProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  LocationStatus _status = LocationStatus.idle;
  LatLng? _currentPosition;
  double? _accuracy; // metres, as reported by the GPS chip
  LocationIssue? _issue;

  // Read-only getters — widgets use these, never access the private fields.
  LocationStatus get status => _status;
  LatLng? get currentPosition => _currentPosition;
  double? get accuracy => _accuracy;
  LocationIssue? get issue => _issue;

  // Convenience booleans used by the UI.
  bool get isLoading => _status == LocationStatus.loading;
  bool get hasPosition => _currentPosition != null;

  // ── init ───────────────────────────────────────────────────────────────────
  // Called once when LocationProvider is first created (from MultiProvider).
  // Checks permission and gets the first GPS fix.
  // The method is idempotent — safe to call again if already loading/success.
  Future<void> init() async {
    // Guard: don't start a second parallel request.
    if (_status == LocationStatus.loading) return;

    _status = LocationStatus.loading;
    _issue = null;
    notifyListeners(); // tells the UI to show a loading indicator

    // Step 1: Check service status and permission.
    final readyIssue = await LocationService.ensureReady();
    if (readyIssue != null) {
      _status = LocationStatus.error;
      _issue = readyIssue;
      notifyListeners();
      return;
    }

    // Step 2: Get the first GPS fix.
    final result = await LocationService.getCurrentPosition();
    if (result.issue != null) {
      _status = LocationStatus.error;
      _issue = result.issue;
      notifyListeners();
      return;
    }

    // Step 3: Success — update the state.
    _currentPosition = result.position;
    _accuracy = result.accuracy;
    _status = LocationStatus.success;
    _issue = null;
    notifyListeners();
  }

  // ── retry ───────────────────────────────────────────────────────────────────
  // Called by the UI's "retry" or "allow location" buttons.
  // Resets state and runs init() again from scratch.
  Future<void> retry() => init();

  // ── openLocationSettings / openAppSettings ──────────────────────────────────
  // Delegate to the service so widgets never import geolocator.
  Future<void> openLocationSettings() =>
      LocationService.openLocationSettings();

  Future<void> openAppSettings() => LocationService.openAppSettings();

  // ── onResume ─────────────────────────────────────────────────────────────────
  // T2.7: called when the app returns to foreground (from the lifecycle observer).
  // Only re-runs if we were in an error state — avoids unnecessary network calls
  // when the app resumes normally.
  void onResume() {
    if (_status == LocationStatus.error) {
      init();
    }
  }

  // ── Test helper ─────────────────────────────────────────────────────────────
  // @visibleForTesting: only FakeLocationProvider (in test/) should call this.
  // Sets the internal state directly so tests can verify getter contracts
  // without going through the real Geolocator platform channel.
  @visibleForTesting
  void setStateForTest({
    required LocationStatus status,
    LatLng? position,
    double? accuracy,
    LocationIssue? issue,
  }) {
    _status = status;
    _currentPosition = position;
    _accuracy = accuracy;
    _issue = issue;
    // Do NOT call notifyListeners() — tests check state synchronously.
  }
}

// ── FakeLocationProvider ──────────────────────────────────────────────────────
// Used in tests only. Overrides init() to drive state transitions without
// requiring a real GPS or platform channel.
// Keep this in the production file (not in test/) so it compiles with the
// real provider and catches API-change errors at compile time.
@visibleForTesting
class FakeLocationProvider extends LocationProvider {
  FakeLocationProvider({required this.issueToReturn});

  // Set to null to simulate a successful GPS fix.
  LocationIssue? issueToReturn;

  @override
  Future<void> init() async {
    if (issueToReturn != null) {
      setStateForTest(status: LocationStatus.error, issue: issueToReturn);
    } else {
      setStateForTest(
        status: LocationStatus.success,
        // Fake position: (1.0, 2.0) — clearly synthetic, not a real coordinate.
        position: LatLng(1.0, 2.0),
        accuracy: 10.0,
        issue: null,
      );
    }
    notifyListeners();
  }
}
