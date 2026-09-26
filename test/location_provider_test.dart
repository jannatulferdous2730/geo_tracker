// test/location_provider_test.dart
// Unit tests for LocationIssue, LocationStatus, and LocationProvider (T2.9).
//
// Testing strategy:
// LocationService wraps Geolocator static methods which need a real platform
// channel. We test the layers we own without touching it:
//   1. LocationIssue enum — all 4 values exist (compiler catches UI gaps).
//   2. LocationStatus enum — all 4 values exist.
//   3. LocationProvider initial state — idle, no position, no issue.
//   4. State machine transitions via FakeLocationProvider (defined in the
//      production file with @visibleForTesting so it compiles with real code).
//
// Full GPS integration is verified on a real device in T2.10.

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_tracker/providers/location_provider.dart';
import 'package:geo_tracker/services/location_service.dart';

void main() {
  // ── 1. LocationIssue enum ─────────────────────────────────────────────────
  group('LocationIssue', () {
    test('has exactly 4 values', () {
      // When a new value is added without updating PermissionPrompt's switch,
      // this test fails and reminds the developer to handle it in the UI.
      expect(LocationIssue.values.length, equals(4));
    });

    test('contains all expected cases', () {
      expect(LocationIssue.values, containsAll([
        LocationIssue.serviceDisabled,
        LocationIssue.permissionDenied,
        LocationIssue.permissionDeniedForever,
        LocationIssue.timeout,
      ]));
    });
  });

  // ── 2. LocationStatus enum ────────────────────────────────────────────────
  group('LocationStatus', () {
    test('has exactly 4 values', () {
      expect(LocationStatus.values.length, equals(4));
    });

    test('contains idle, loading, success, error', () {
      expect(LocationStatus.values, containsAll([
        LocationStatus.idle,
        LocationStatus.loading,
        LocationStatus.success,
        LocationStatus.error,
      ]));
    });
  });

  // ── 3. LocationProvider initial state ─────────────────────────────────────
  group('LocationProvider initial state', () {
    late LocationProvider p;
    setUp(() => p = LocationProvider());
    tearDown(() => p.dispose());

    test('status is idle', () => expect(p.status, LocationStatus.idle));
    test('isLoading is false', () => expect(p.isLoading, isFalse));
    test('hasPosition is false', () => expect(p.hasPosition, isFalse));
    test('currentPosition is null', () => expect(p.currentPosition, isNull));
    test('issue is null', () => expect(p.issue, isNull));
    test('accuracy is null', () => expect(p.accuracy, isNull));
  });

  // ── 4. State machine via FakeLocationProvider ─────────────────────────────
  group('LocationProvider state machine', () {
    for (final issue in LocationIssue.values) {
      test('error state stores $issue and status=error', () async {
        final p = FakeLocationProvider(issueToReturn: issue);
        await p.init();

        expect(p.status, LocationStatus.error,
            reason: 'status should be error for $issue');
        expect(p.issue, issue,
            reason: 'issue should be $issue');
        expect(p.isLoading, isFalse);
        expect(p.hasPosition, isFalse);
        p.dispose();
      });
    }

    test('success state sets status=success and position', () async {
      final p = FakeLocationProvider(issueToReturn: null);
      await p.init();

      expect(p.status, LocationStatus.success);
      expect(p.issue, isNull);
      expect(p.hasPosition, isTrue);
      expect(p.currentPosition, isNotNull);
      expect(p.currentPosition!.latitude, closeTo(1.0, 0.001));
      p.dispose();
    });

    test('retry() calls init() again and can change state', () async {
      final p = FakeLocationProvider(issueToReturn: LocationIssue.timeout);
      await p.init();
      expect(p.status, LocationStatus.error);

      // Simulate the user tapping Retry — this time GPS succeeds.
      p.issueToReturn = null;
      await p.retry();
      expect(p.status, LocationStatus.success);
      p.dispose();
    });
  });
}
