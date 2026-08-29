// database_category_screen.dart
// Zeigt die Einträge einer ausgewählten Kategorie an
// (Bands, Musiker, Alben, Songs, Genres oder Rolle).
// Die Kategorie wird über den Konstruktor übergeben, der Aufbau ist für
// alle Kategorien identisch.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import '../domain/database_category.dart';
import '../domain/database_item.dart';
import '../domain/info_field.dart';
import '../../../app/app_bottom_nav.dart';
import 'add_data_screen.dart';
import 'database_widgets.dart';
import '../../../app/app_colors.dart';

class DatabaseCategoryScreen extends StatefulWidget {
  // Die ausgewählte Kategorie wird beim Öffnen des Screens übergeben
  final CategoryKind kind;

  const DatabaseCategoryScreen({
    super.key,
    required this.kind,
  });

  @override
  State<DatabaseCategoryScreen> createState() => _DatabaseCategoryScreenState();
}

class _DatabaseCategoryScreenState extends State<DatabaseCategoryScreen> {
  // Steuert das Suchfeld und hält den aktuellen Suchbegriff
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bei jedem Aufbau frisch holen, damit neue Einträge sofort erscheinen
    final DatabaseCategory category = repo.categoryOf(widget.kind);

    // Nur die Einträge anzeigen, welche zum Suchbegriff passen
    final List<DatabaseItem> gefiltert =
        category.entries.where((entry) => entry.matches(_query)).toList();

    return Scaffold(
      // AppBar zeigt den Kategorienamen als Titel
      appBar: AppBar(
        title: Text(category.title),
        // Inkl. Zurückpfeil
      ),

      // Scrollbarer Body um die längeren Listen anzuzeigen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit Icon und Kategoriename
            DetailHeader(
              icon: category.icon,
              title: category.title,
              subtitle: category.subtitle,
            ),

            const SizedBox(height: 20),

            // Info-Feld mit der Anzahl der Einträge
            InfoBox(
              field: InfoField(
                icon: Icons.list_alt,
                label: 'Einträge',
                value: '${category.entries.length}',
              ),
            ),

            const SizedBox(height: 12),

            // Suchfeld zum Filtern der Einträge dieser Seite
            SearchField(
              controller: _searchController,
              hintText: '${category.title} durchsuchen',
              showClear: _query.isNotEmpty,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchController.clear();
                  _query = '';
                });
              },
            ),

            const SizedBox(height: 24),

            SectionTitle(text: 'Über ${category.title}'),

            const SizedBox(height: 12),

            // Beschreibungstext der Kategorie
            Text(
              category.description,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.text,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            SectionTitle(text: category.entryLabel),

            const SizedBox(height: 12),

            // Hinweis, falls die Suche keine Treffer liefert
            if (gefiltert.isEmpty)
              const EmptyHint()
            else
              // Eine Box pro gefundenem Eintrag
              for (final DatabaseItem entry in gefiltert) ...[
                ItemRow(item: entry, onReturn: () => setState(() {})),
                const SizedBox(height: 12),
              ],

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Derselbe Plus-Button wie auf der Übersicht.
      // Die Kategorie ist hier fest vorgegeben und im Formular gesperrt.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddDataScreen(fixedCategory: widget.kind),
            ),
          );
          // Nach der Rückkehr neu aufbauen, damit neue Einträge erscheinen
          if (mounted) setState(() {});
        },
        child: const Icon(Icons.add, size: 28),
      ),

      // Bottom Navigation auch auf der Listenseite
      bottomNavigationBar: const AppBottomNav(popToRoot: true),
    );
  }
}
