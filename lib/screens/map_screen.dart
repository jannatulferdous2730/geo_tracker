// lib/screens/map_screen.dart
// Main map screen — Tab 0 of HomeShell.
// Phase 2: shows permission prompt on error, location info card on success.
// Phase 3: user marker and accuracy circle added here.
// Phase 4: tracking controls added here.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/location_provider.dart';
import '../services/location_service.dart';
import '../widgets/location_info_card.dart';
import '../widgets/permission_prompt.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  // One MapController per map screen — owned here, never shared.
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Register as a lifecycle observer so we can detect app-resume events (T2.7).
    WidgetsBinding.instance.addObserver(this);

    // Ask the provider to check permission and get the first fix.
    // Use addPostFrameCallback so the widget tree is fully built before we call
    // anything that might trigger notifyListeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().init();
    });
  }

  @override
  void dispose() {
    // Unregister the lifecycle observer to avoid memory leaks.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── T2.7: Lifecycle observer ────────────────────────────────────────────────
  // Called when the app comes back to the foreground (e.g., user returns from
  // the Settings app after granting location permission).
  // The provider's onResume() only re-runs init() if we were in an error state,
  // so this is safe to call every time the app resumes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<LocationProvider>().onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this widget whenever LocationProvider notifies.
    // For Phase 3+, we will switch to context.select to limit rebuilds to
    // only the parts that actually changed (T3.5).
    final provider = context.watch<LocationProvider>();

    return Stack(
      children: [
        // ── Map (always visible underneath) ───────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: AppConstants.fallbackCenter,
            initialZoom: AppConstants.defaultZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.tileUrlTemplate,
              userAgentPackageName: AppConstants.userAgentPackage,
            ),

            // Phase 3: CircleLayer (accuracy ring) goes here.
            // Phase 3: MarkerLayer (user dot) goes here.
            // Phase 4: PolylineLayer (walked path) goes here.
            // Phase 7: MarkerLayer (nearby pins) goes here.
            // Phase 8: MarkerLayer (destination) + PolylineLayer (route) go here.

            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
              alignment: AttributionAlignment.bottomRight,
            ),
          ],
        ),

        // ── Permission / error overlay ─────────────────────────────────────────
        // Shown in front of the map when GPS is unavailable.
        // Using a semi-opaque card so the map is still visible underneath —
        // design.md section 11 says "don't replace the map, overlay it".
        if (provider.status == LocationStatus.error &&
            provider.issue != null) ...[
          // Dim the map to focus attention on the prompt.
          const ModalBarrier(color: Colors.black38, dismissible: false),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: PermissionPrompt(
                  issue: provider.issue!,
                  onPrimaryAction: _primaryAction(provider),
                  // Secondary "Allow location" button is only for deniedForever.
                  onSecondaryAction:
                      provider.issue == LocationIssue.permissionDeniedForever
                          ? provider.retry
                          : null,
                ),
              ),
            ),
          ),
        ],

        // ── Loading indicator ──────────────────────────────────────────────────
        // Shown while waiting for the first GPS fix.
        if (provider.status == LocationStatus.loading)
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Getting location…'),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ── Location info card ─────────────────────────────────────────────────
        // T2.8: shows lat/lng and accuracy when we have a fix.
        // Positioned bottom-left so it does not overlap the OSM attribution (bottom-right).
        if (provider.hasPosition)
          Positioned(
            left: 16,
            bottom: 16,
            child: LocationInfoCard(
              latitude: provider.currentPosition!.latitude,
              longitude: provider.currentPosition!.longitude,
              accuracy: provider.accuracy,
            ),
          ),
      ],
    );
  }

  // Returns the correct primary action callback for each LocationIssue.
  VoidCallback _primaryAction(LocationProvider provider) {
    switch (provider.issue) {
      case LocationIssue.serviceDisabled:
        return provider.openLocationSettings;
      case LocationIssue.permissionDeniedForever:
        return provider.openAppSettings;
      case LocationIssue.permissionDenied:
      case LocationIssue.timeout:
      case null:
        return provider.retry;
    }
  }
}
