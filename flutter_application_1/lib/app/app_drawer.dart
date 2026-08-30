// app_drawer.dart
// Wiederverwendbarer Drawer für die ganze App.
// Wird in allen Hauptscreens eingebunden.

import 'package:flutter/material.dart';
import '../features/drawer/presentation/impressum_screen.dart';
import '../features/drawer/presentation/datenschutz_screen.dart';
import '../features/drawer/presentation/nutzungsbedingungen_screen.dart';
import 'app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.darkBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.library_music, color: AppColors.gold, size: 36),
                SizedBox(height: 8),
                Text(
                  'MusicDB',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Die drei Einträge unterscheiden sich nur in Icon, Text und Ziel. Darum ein kleines eigenes Widget statt drei Mal derselbe Code.
          _DrawerLink(
            icon: Icons.business,
            label: 'Impressum',
            openScreen: () => const ImpressumScreen(),
          ),
          _DrawerLink(
            icon: Icons.lock_outline,
            label: 'Datenschutz',
            openScreen: () => const DatenschutzScreen(),
          ),
          _DrawerLink(
            icon: Icons.description_outlined,
            label: 'Nutzungsbedingungen',
            openScreen: () => const NutzungsbedingungenScreen(),
          ),
        ],
      ),
    );
  }
}

// Ein Eintrag im Drawer: schliesst den Drawer und öffnet den Zielscreen.
class _DrawerLink extends StatelessWidget {
  final IconData icon;
  final String label;

  // Eine Funktion, die den Zielscreen erzeugt. So wird der Screen erst gebaut, wenn der Eintrag wirklich angetippt wird.
  final Widget Function() openScreen;

  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.openScreen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkBlue),
      title: Text(label),
      onTap: () {
        // Zuerst den Drawer schliessen, dann die Seite öffnen
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => openScreen()),
        );
      },
    );
  }
}
