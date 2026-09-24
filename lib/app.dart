// lib/app.dart
// MaterialApp: sets the theme (light + dark), title, and the home widget.
// Routes for pushed screens (PlaceDetails) will be added in Phase 5.

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';

class GeoTrackerApp extends StatelessWidget {
  const GeoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoTracker',
      debugShowCheckedModeBanner: false,

      // Light and dark themes come from AppTheme — never from ColorScheme.fromSeed.
      // The system's brightness setting determines which is active.
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      home: const HomeShell(),
    );
  }
}
