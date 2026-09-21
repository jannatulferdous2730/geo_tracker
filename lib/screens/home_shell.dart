// lib/screens/home_shell.dart
// Hosts the bottom NavigationBar with 3 tabs: Map, Saved, Nearby.
// Only the Map tab is functional in Phase 1.
// Saved and Nearby show a placeholder until Phases 5 and 7.

import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'saved_places_screen.dart';
import 'nearby_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Current selected tab index. 0 = Map, 1 = Saved, 2 = Nearby.
  int _selectedIndex = 0;

  // The three tab screens. Defined here so they are not rebuilt on every tab switch.
  // IndexedStack keeps all three alive, which will matter when the MapController
  // needs to stay alive while the user visits the Saved tab (Phase 5).
  static const List<Widget> _screens = [
    MapScreen(),
    SavedPlacesScreen(),
    NearbyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the inactive screens in memory but hidden.
      // This is important for the map: if we used PageView or Navigator.push,
      // the MapController would be disposed every time the user switches tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Nearby',
          ),
        ],
      ),
    );
  }
}
