// app_drawer.dart
// Wiederverwendbarer Drawer für die ganze App.
// Wird in allen Hauptscreens eingebunden.

import 'package:flutter/material.dart';
import '../features/drawer/presentation/impressum_screen.dart';
import '../features/drawer/presentation/datenschutz_screen.dart';
import '../features/drawer/presentation/nutzungsbedingungen_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF242F40)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.library_music, color: Color(0xFFCCA43B), size: 36),
                const SizedBox(height: 8),
                const Text('MusicDB',
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Color(0xFF242F40)),
            title: const Text('Impressum'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ImpressumScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Color(0xFF242F40)),
            title: const Text('Datenschutz'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DatenschutzScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Color(0xFF242F40)),
            title: const Text('Nutzungsbedingungen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NutzungsbedingungenScreen()));
            },
          ),
        ],
      ),
    );
  }
}