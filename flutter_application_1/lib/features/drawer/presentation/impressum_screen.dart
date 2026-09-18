// Zeigt das Impressum der App an.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent per AI generiert
import 'package:flutter/material.dart';
import '../../../app/app_widgets.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impressum')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionCard(
              title: 'Angaben gemäss Informationspflicht',
              content:
                  'MusicDB App\n'
                  'Seefeldstrasse 45\n'
                  '8008 Zürich\n'
                  'Schweiz',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Kontakt',
              content:
                  'E-Mail: info@musicdb.ch\n'
                  'Telefon: +41 44 000 00 00',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Haftungsausschluss',
              content:
                  'Die Inhalte dieser App wurden mit grösstmöglicher Sorgfalt erstellt. '
                  'Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte '
                  'können wir jedoch keine Gewähr übernehmen. '
                  'Als Diensteanbieter sind wir für eigene Inhalte verantwortlich.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Urheberrecht',
              content:
                  'Die durch uns erstellten Inhalte und Werke in dieser App unterliegen '
                  'dem schweizerischen Urheberrecht. Die Vervielfältigung, Bearbeitung, '
                  'Verbreitung und jede Art der Verwertung ausserhalb der Grenzen des '
                  'Urheberrechts bedürfen der schriftlichen Zustimmung.',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
