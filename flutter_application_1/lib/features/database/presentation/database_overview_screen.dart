// Übersichtsseite des Datenbank-Bereichs. Aufbau analog zu den Detailseiten: Header, Textbox und Info-Boxen.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import '../domain/database_category.dart';
import 'add_data_screen.dart';
import 'database_category_screen.dart';
import 'database_widgets.dart';
import '../../../app/app_drawer.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class DatabaseOverviewScreen extends StatefulWidget {
  const DatabaseOverviewScreen({super.key});

  @override
  State<DatabaseOverviewScreen> createState() => _DatabaseOverviewScreenState();
}

class _DatabaseOverviewScreenState extends State<DatabaseOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    // Bei jedem Aufbau die aktuellen Kategorien holen, damit neu erfasste Einträge sofort mitgezählt werden in der Liste. 
    final List<DatabaseCategory> categories = repo.categories;

    return Scaffold(
      // AppBar mit dem Titel der Seite
      appBar: AppBar(
        title: const Text('MusicDB – Database'),
      ),

      // nav drawer laden
      drawer: const AppDrawer(),

      // Scrollbarer Body, damit die Liste auch auf kleinen Geräten passt
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit grossem Icon und Titel
            const DetailHeader(
              icon: Icons.storage,
              title: 'Database',
              subtitle: 'Übersicht aller Datenpunkte',
            ),

            const SizedBox(height: 20),

            // Kurzer Hinweistext
            const TextCard(
              text:
                  'Hier ist deine persönliche Musik-Datenbank. Tippe auf eine '
                  'Kategorie, um ihre Einträge zu sehen, oder erfasse über das '
                  'Plus unten rechts einen neuen Eintrag.',
            ),

            const SizedBox(height: 24),

            const SectionTitle(text: 'Datenpunkte'),

            const SizedBox(height: 12),

            // Eine Box pro Kategorie
            for (final DatabaseCategory category in categories) ...[
              _CategoryRow(category: category),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Runder Plus-Button unten rechts, öffnet das Erfassungsformular. Von hier aus ist die Kategorie frei wählbar.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDataScreen(),
            ),
          );
          // Nach der Rückkehr neu aufbauen, damit neue Einträge erscheinen
          if (mounted) setState(() {});
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// Eigenes Widget für eine Kategorie-Box in der Übersicht.

class _CategoryRow extends StatelessWidget {
  final DatabaseCategory category;

  const _CategoryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(),

      // Tippen auf die Box öffnet die Listenseite der Kategorie
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Die ausgewählte Kategorie wird übergeben
              builder: (context) => DatabaseCategoryScreen(kind: category.kind),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon der Kategorie
              Icon(
                category.icon,
                color: AppColors.gold,
                size: 22,
              ),

              const SizedBox(width: 12),

              // Bezeichnung und Kurzbeschreibung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      category.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Anzahl der Einträge
              Text(
                '${category.entries.length}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(width: 6),

              // Pfeil-Icon rechts
              const Icon(
                Icons.chevron_right,
                color: AppColors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
