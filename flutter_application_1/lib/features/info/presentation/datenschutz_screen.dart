// Zeigt die Datenschutzerklärung der App an.
// Textliche Inhalte wurden per AI generiert
// Titel mit goldenem Akzent mit AI generiert

import 'package:flutter/material.dart';

class DatenschutzScreen extends StatelessWidget {
  const DatenschutzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Datenschutzerklärung',
              content:
                  'Der Schutz Ihrer persönlichen Daten ist uns ein besonderes Anliegen. '
                  'Wir verarbeiten Ihre Daten daher ausschliesslich auf Grundlage der '
                  'gesetzlichen Bestimmungen des Schweizer Datenschutzgesetzes (DSG).',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Welche Daten wir speichern',
              content:
                  'Diese App speichert keine persönlichen Daten auf externen Servern. '
                  'Alle Daten verbleiben ausschliesslich auf Ihrem Gerät und werden '
                  'nicht an Dritte weitergegeben.',
            ),

            const SizedBox(height: 12),

            _buildSection(
              title: 'Ihre Rechte',
              content:
                  'Sie haben jederzeit das Recht auf Auskunft über Ihre gespeicherten '
                  'Daten, deren Herkunft und Empfänger sowie den Zweck der Datenverarbeitung. '
                  'Ausserdem haben Sie ein Recht auf Berichtigung, Sperrung oder Löschung '
                  'dieser Daten.',
            ),

            const SizedBox(height: 12),

            _buildSection(
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
