// lib/core/constants/app_constants.dart
// Central place for every magic value used across the app.
// Rule: no literal coordinates, zoom levels, URLs, or storage keys anywhere else in the code.

import 'package:latlong2/latlong.dart';

class AppConstants {
  // Prevent instantiation — this class is only a namespace for constants.
  AppConstants._();

  // ── Fallback location ──────────────────────────────────────────────────────
  // Shown on the map before GPS permission is granted or a fix is obtained.
  // Chittagong, Bangladesh (from the original project plan).
  static const double fallbackLat = 22.3569;
  static const double fallbackLng = 91.7832;

  // LatLng is the type flutter_map uses for all coordinates.
  // Defined here so screens never construct it with raw literals.
  static final LatLng fallbackCenter = LatLng(fallbackLat, fallbackLng);

  // ── Map defaults ───────────────────────────────────────────────────────────
  // Zoom level 13 shows the city district level — detailed enough to see streets.
  // Zoom range: 0 (world) to 19 (building level).
  static const double defaultZoom = 13.0;

  // Zoom used when the "My location" button re-centers the map.
  // Slightly closer than defaultZoom so the user sees their street clearly.
  static const double myLocationZoom = 15.0;

  // ── Tile layer ─────────────────────────────────────────────────────────────
  // OpenStreetMap standard tile URL. {z}, {x}, {y} are replaced by flutter_map
  // with the current zoom and tile coordinates.
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Required by the OSM tile usage policy. Must be the app's package name.
  // See: https://operations.osmfoundation.org/policies/tiles/
  static const String userAgentPackage = 'com.example.geo_tracker';

  // ── Local storage ──────────────────────────────────────────────────────────
  // The SharedPreferences key that holds the JSON list of saved places.
  // Defined here so StorageService and tests use the same key.
  static const String savedPlacesKey = 'saved_places';

  // ── Tracking constants (used in Phase 4) ───────────────────────────────────
  // Only update the marker when the user has moved at least this many meters.
  // Setting this to 0 gives many updates and a noisy, jittery path.
  static const int trackingDistanceFilterMeters = 10;

  // Ignore a GPS fix if its accuracy is worse than this (Phase 4, optional filter).
  static const double minAccuracyMeters = 50.0;
}
