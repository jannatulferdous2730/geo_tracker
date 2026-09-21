// lib/screens/map_screen.dart
// Main map screen — the first tab of HomeShell.
// Shows an OSM tile map with pan, zoom, and the required attribution.
// Layers for the user marker (Phase 3), walked path (Phase 4),
// and nearby/route overlays (Phases 7-8) will be added here later.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../core/constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // One MapController per map screen — owned here, never shared.
  // Other screens request camera moves through a provider callback (Phase 5).
  // (architecture.md rule: one MapController, owned by the map screen.)
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      // mapController lets us move the camera programmatically (e.g., "My location").
      mapController: _mapController,
      options: MapOptions(
        // Start centred on Chittagong. The camera moves to the real position in Phase 2.
        // Using AppConstants so no literal coordinates appear here.
        initialCenter: AppConstants.fallbackCenter,
        initialZoom: AppConstants.defaultZoom,
        // minZoom / maxZoom are not set — flutter_map defaults (0–22) are fine.
      ),
      children: [
        // ── Tile layer ──────────────────────────────────────────────────────
        // TileLayer fetches map image tiles from OpenStreetMap.
        // userAgentPackageName: required by the OSM tile usage policy.
        // If this is missing or generic (e.g., "myapp"), the tile server may
        // block or rate-limit the app. Use the real package name.
        // Policy: https://operations.osmfoundation.org/policies/tiles/
        TileLayer(
          urlTemplate: AppConstants.tileUrlTemplate,
          userAgentPackageName: AppConstants.userAgentPackage,
        ),

        // ── Attribution ─────────────────────────────────────────────────────
        // Required by the OpenStreetMap license (ODbL).
        // Keeping it visible is mandatory — hiding it violates the tile policy.
        // RichAttributionWidget shows a small "?" button with the credit text.
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
          // Align bottom-right so it does not overlap the info card (bottom-left).
          alignment: AttributionAlignment.bottomRight,
        ),

        // Future layers added in later phases (in this order, bottom to top):
        // Phase 8: PolylineLayer (route)
        // Phase 4: PolylineLayer (walked path)
        // Phase 7: MarkerLayer (nearby pins)
        // Phase 5: MarkerLayer (saved place pins)
        // Phase 8: MarkerLayer (destination pin)
        // Phase 3: CircleLayer (accuracy), MarkerLayer (user dot)
      ],
    );
  }

  @override
  void dispose() {
    // MapController does not require explicit disposal in flutter_map 8.x,
    // but listing it here makes the lifecycle clear for learning purposes.
    super.dispose();
  }
}
