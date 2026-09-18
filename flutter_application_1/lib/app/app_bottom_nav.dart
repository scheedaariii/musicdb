// Die Bottom Navigation der App als eigenes Widget.Wird in der gesammten App angezeigt

import 'package:flutter/material.dart';

// Der aktuell gewählte Tab (0 = Database, 1 = Info, 2 = Profil). Als ValueNotifier, damit auch aufgesetzte Seiten den Tab wechseln können.
final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

class AppBottomNav extends StatelessWidget {
  final bool popToRoot;

  const AppBottomNav({super.key, this.popToRoot = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedTab,
      builder: (context, currentIndex, child) {
        return BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: (index) {
            // Gewählten Bereich merken
            selectedTab.value = index;

            // Auf Unterseiten zurück zur Hauptseite
            if (popToRoot) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Datenbank',
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
        );
      },
    );
  }
}
