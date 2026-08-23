// Die globale Bottom Navigation der App.
// Wechselt zwischen den drei Hauptbereichen: Database, Info, Profil.

import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';
import '../features/database/presentation/database_overview_screen.dart';
import '../features/info/presentation/info_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  // Die akutellen Hauptbereiche der App
  static const List<Widget> _screens = [
    DatabaseOverviewScreen(),
    InfoScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Der gewählte Tab liegt in selectedTab, damit ihn auch aufgesetzte
    // Seiten (Listen, Details, Formular) umschalten können
    return ValueListenableBuilder<int>(
      valueListenable: selectedTab,
      builder: (context, currentIndex, child) {
        return Scaffold(
          // Aufrufen des aktuell ausgewählten Screens
          body: _screens[currentIndex],

          // Bottom Navigation mit drei Tabs
          bottomNavigationBar: const AppBottomNav(),
        );
      },
    );
  }
}
