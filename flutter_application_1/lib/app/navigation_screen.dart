// navigation_screen.dart
// Enthält die globale Bottom Navigation der App.
// Wechselt zwischen den drei Hauptbereichen: Bands, Info, Profil.

import 'package:flutter/material.dart';
import '../features/bands/presentation/band_list_screen.dart';
import '../features/info/presentation/info_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // Speichert den aktuell angezeigten Tab-Index (0 = Bands, 1 = Info, 2 = Profil)
  int _currentIndex = 1;

  // Die drei Hauptbereiche der App
  final List<Widget> _screens = const [
    BandListScreen(),
    InfoScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Zeigt den jeweils ausgewählten Screen an
      body: _screens[_currentIndex],

      // Bottom Navigation mit drei Tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        // Beim Tippen auf einen Tab: Index aktualisieren → Screen wechselt
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Bands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
