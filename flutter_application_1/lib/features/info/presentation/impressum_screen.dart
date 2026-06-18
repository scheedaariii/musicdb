// Zeigt das Impressum der App an.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent per AI generiert
import 'package:flutter/material.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Angaben gemäss Informationspflicht',
              content:
                  'MusicDB App\n'
                  'Musterstrasse 12\n'
                  '8000 Zürich\n'
                  'Schweiz',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Kontakt',
              content:
                  'E-Mail: info@musicdb.ch\n'
                  'Telefon: +41 44 000 00 00',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Haftungsausschluss',
              content:
                  'Die Inhalte dieser App wurden mit grösstmöglicher Sorgfalt erstellt. '
                  'Für die Richtigkeit, Vollständigkeit und Aktualität der Inhalte '
                  'können wir jedoch keine Gewähr übernehmen. '
                  'Als Diensteanbieter sind wir für eigene Inhalte verantwortlich.',
            ),

            const SizedBox(height: 12),

            _buildSection(
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

  // Abschnitts-Widget
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
          // Titel mit goldenem Akzent
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF242F40),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Inhalt
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF363636),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
