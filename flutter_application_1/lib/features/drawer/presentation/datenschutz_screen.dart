// Zeigt die Datenschutzerklärung der App an.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent mit AI generiert

import 'package:flutter/material.dart';
import '../../../app/app_widgets.dart';

class DatenschutzScreen extends StatelessWidget {
  const DatenschutzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datenschutz')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionCard(
              title: 'Datenschutzerklärung',
              content:
                  'Der Schutz Ihrer persönlichen Daten ist uns ein besonderes Anliegen. '
                  'Wir verarbeiten Ihre Daten daher ausschliesslich auf Grundlage der '
                  'gesetzlichen Bestimmungen des Schweizer Datenschutzgesetzes (DSG).',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Welche Daten wir speichern',
              content:
                  'Diese App speichert keine persönlichen Daten auf externen Servern. '
                  'Alle Daten verbleiben ausschliesslich auf Ihrem Gerät und werden '
                  'nicht an Dritte weitergegeben.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Ihre Rechte',
              content:
                  'Sie haben jederzeit das Recht auf Auskunft über Ihre gespeicherten '
                  'Daten, deren Herkunft und Empfänger sowie den Zweck der Datenverarbeitung. '
                  'Ausserdem haben Sie ein Recht auf Berichtigung, Sperrung oder Löschung '
                  'dieser Daten.',
            ),

            const SizedBox(height: 12),

            const SectionCard(
              title: 'Kontakt',
              content:
                  'Bei Fragen zum Datenschutz wenden Sie sich bitte an:\n'
                  'datenschutz@musicdb.ch',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
