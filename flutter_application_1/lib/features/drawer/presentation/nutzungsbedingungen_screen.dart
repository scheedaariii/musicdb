// Zeigt die Nutzungsbedingungen der App an.
// Wird über den Drawer im InfoScreen geöffnet.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent -> Dieser Teil wurde ebenfalls mit AI erstellt da ich es selbst nicht hingekriegt habe die Goldakazente einzufügen.

import 'package:flutter/material.dart';
import '../../../app/app_widgets.dart';

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
            const SectionCard(
              title: 'Geltungsbereich',
              content:
                  'Diese Nutzungsbedingungen gelten für die Verwendung der MusicDB App. '
                  'Mit der Nutzung der App erklären Sie sich mit diesen Bedingungen einverstanden.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Nutzung der App',
              content:
                  'Die MusicDB App darf ausschliesslich für private, nicht-kommerzielle Zwecke '
                  'genutzt werden. Eine Weitergabe, Vervielfältigung oder kommerzielle Nutzung '
                  'der App oder ihrer Inhalte ist ohne ausdrückliche Genehmigung nicht gestattet.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Haftung',
              content:
                  'Wir übernehmen keine Haftung für die Richtigkeit und Vollständigkeit '
                  'der in der App enthaltenen Informationen. Die Nutzung der App erfolgt '
                  'auf eigene Verantwortung des Nutzers.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
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
}
