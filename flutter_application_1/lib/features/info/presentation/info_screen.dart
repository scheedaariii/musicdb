// info_screen.dart
// Der Info-Bereich der App.
// Enthält einen Drawer mit Links zu Impressum, Datenschutz und Nutzungsbedingungen.
// Beispiel Texte per ai Generiert
// Goldene Akzente in den Titeln AI generiert

import 'package:flutter/material.dart';
import '../../../app/app_drawer.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        // Einblendendes des Hamburger Menüs
      ), //nav drawer laden
      drawer: const AppDrawer(),

      // Drawer mit drei Menüeinträgen
      

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
                color: const Color(0xFF242F40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // App-Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCA43B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.library_music,
                      color: Color(0xFFCCA43B),
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
                      color: Color(0xFFFFFFFF),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Version
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCCA43B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Über die App
            _buildSection(
              title: 'Über die App',
              content:
                  'MusicDB ist deine persönliche Musik-Datenbank. '
                  'Entdecke und verwalte Informationen über Bands aus allen Genres – '
                  'von Rock über Metal bis hin zu Electronic und Jazz.',
            ),

            const SizedBox(height: 12),

            // Funktionen
            _buildSection(
              title: 'Funktionen',
              content:
                  'Durchsuche eine kuratierte Liste von Bands, '
                  'lese detaillierte Informationen zu Genre, Herkunft und Geschichte. '
                  'Die App ist dein persönlicher Begleiter für die Welt der Musik.',
            ),

            const SizedBox(height: 12),

            // Entwickelt für
            _buildSection(
              title: 'Entwickelt für',
              content:
                  'Diese App wurde im Rahmen des Moduls Mobile Apps '
                  'an der TEKO Schweizerische Fachschule AG entwickelt.',
            ),

            const SizedBox(height: 12),

            
          ],
        ),
      ),
    );
  }

  // Textbox-Widget
  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Abschnittstitel mit goldenem Akzent - Akzent wurde per AI generiert
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCA43B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF242F40),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Abschnittstext
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF363636),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
