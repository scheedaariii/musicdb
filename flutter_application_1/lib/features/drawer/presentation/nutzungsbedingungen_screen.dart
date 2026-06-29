// Zeigt die Nutzungsbedingungen der App an.
// Wird über den Drawer im InfoScreen geöffnet.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent -> Dieser Teil wurde ebenfalls mit AI erstellt da ich es selbst nicht hingekriegt habe die Goldakazente einzufügen.

import 'package:flutter/material.dart';

class NutzungsbedingungenScreen extends StatelessWidget {
  const NutzungsbedingungenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzungsbedingungen'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Geltungsbereich',
              content:
                  'Diese Nutzungsbedingungen gelten für die Verwendung der MusicDB App. '
                  'Mit der Nutzung der App erklären Sie sich mit diesen Bedingungen einverstanden.',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Nutzung der App',
              content:
                  'Die MusicDB App darf ausschliesslich für private, nicht-kommerzielle Zwecke '
                  'genutzt werden. Eine Weitergabe, Vervielfältigung oder kommerzielle Nutzung '
                  'der App oder ihrer Inhalte ist ohne ausdrückliche Genehmigung nicht gestattet.',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Haftung',
              content:
                  'Wir übernehmen keine Haftung für die Richtigkeit und Vollständigkeit '
                  'der in der App enthaltenen Informationen. Die Nutzung der App erfolgt '
                  'auf eigene Verantwortung des Nutzers.',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Änderungen',
              content:
                  'Wir behalten uns das Recht vor, diese Nutzungsbedingungen jederzeit '
                  'zu ändern. Die aktuellen Nutzungsbedingungen sind stets in der App abrufbar. '
                  'Stand: Januar 2025',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Wiederverwendbares Abschnitts-Widget
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
