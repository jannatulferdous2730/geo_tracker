// lib/main.dart
// App entry point. Keeps this file as small as possible — all configuration
// lives in app.dart (theme, routes) or the providers list below.

import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Required when using async APIs before runApp (e.g., SharedPreferences.getInstance).
  // Harmless when not strictly needed, so we call it as a habit from the start.
  WidgetsFlutterBinding.ensureInitialized();

  // MultiProvider is added in Phase 2 when the first real provider (LocationProvider)
  // is created. The nested package asserts that children must not be empty,
  // so we do not use MultiProvider with an empty list.
  runApp(const GeoTrackerApp());
}
