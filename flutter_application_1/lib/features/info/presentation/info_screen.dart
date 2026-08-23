// info_screen.dart
// Der Info-Bereich der App.
// Enthält einen Drawer mit Links zu Impressum, Datenschutz und Nutzungsbedingungen.
// Beispiel Texte per ai Generiert
// Goldene Akzente in den Titeln AI generiert

import 'package:flutter/material.dart';
import '../../../app/app_drawer.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),

      // Drawer mit den Links zu Impressum, Datenschutz und Nutzungsbedingungen
      drawer: const AppDrawer(),

      // Body: Inhalt des Info-Screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo-Bereich
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // App-Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.library_music,
                      color: AppColors.gold,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App-Name
                  const Text(
                    'MusicDB',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Version
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Über die App
            const SectionCard(
              title: 'Über die App',
              content:
                  'MusicDB ist deine persönliche Musik-Datenbank. '
                  'Entdecke und verwalte Informationen über Bands aus allen Genres – '
                  'von Rock über Metal bis hin zu Electronic und Jazz.',
            ),

            const SizedBox(height: 12),

            // Funktionen
            const SectionCard(
              title: 'Funktionen',
              content:
                  'Durchsuche eine kuratierte Liste von Bands, '
                  'lese detaillierte Informationen zu Genre, Herkunft und Geschichte. '
                  'Die App ist dein persönlicher Begleiter für die Welt der Musik.',
            ),

            const SizedBox(height: 12),

            // Entwickelt für
            const SectionCard(
              title: 'Entwickelt für',
              content:
                  'Diese App wurde im Rahmen des Moduls Mobile Apps '
                  'an der TEKO Schweizerische Fachschule AG entwickelt.',
            ),

          ],
        ),
      ),
    );
  }
}
