// lib/main.dart
// App entry point. All configuration lives in app.dart (theme, routes)
// and the MultiProvider below.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/location_provider.dart';

void main() {
  // Required before using async platform channels (e.g., SharedPreferences,
  // geolocator) before runApp. Safe to call even when not strictly needed.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // MultiProvider wraps the whole app so any screen can access any provider.
    // Providers are added one per phase:
    //   Phase 2: LocationProvider ← added now
    //   Phase 5: SavedPlacesProvider
    //   Phase 7: NearbyProvider
    //   Phase 8: RouteProvider
    MultiProvider(
      providers: [
        // ChangeNotifierProvider creates LocationProvider once and disposes it
        // when the app closes. The lazy: false flag means it is created
        // immediately at startup — we want the permission check to happen as
        // early as possible, not the first time a widget reads from it.
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
          lazy: false,
        ),
      ],
      child: const GeoTrackerApp(),
    ),
  );
}
