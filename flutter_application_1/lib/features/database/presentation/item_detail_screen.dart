// item_detail_screen.dart
// Zeigt die Detailinformationen eines einzelnen Eintrags an.
// Funktioniert für alle Kategorien gleich: Band, Musiker, Album, Song und
// Genre liefern über die Schnittstelle DatabaseItem ihre eigenen Felder,
// dieser Screen stellt sie einheitlich dar.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import '../domain/database_item.dart';
import '../domain/info_field.dart';
import '../domain/related_section.dart';
import 'database_widgets.dart';
import '../../../app/app_bottom_nav.dart';
import '../../../app/app_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  // Der ausgewählte Eintrag wird beim Öffnen des Screens übergeben
  final DatabaseItem item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // Die verknüpften Einträge, z.B. die Musiker einer Band
    final List<RelatedSection> sections = repo.relatedFor(item);

    return Scaffold(
      // AppBar zeigt den Namen des Eintrags als Titel
      appBar: AppBar(
        title: Text(item.title),
        // Inkl. Zurückpfeil
      ),

      // Scrollbarer Body um längere Listen anzuzeigen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit Icon und Name
            DetailHeader(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
            ),

            const SizedBox(height: 20),

            // Die Info-Felder des Eintrags
            for (final InfoField field in item.infoFields) ...[
              InfoBox(field: field),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 12),

            SectionTitle(text: 'Über ${item.title}'),

            const SizedBox(height: 12),

            // Beschreibungstext des Eintrags
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.text,
                height: 1.6,
              ),
            ),

            // Verknüpfte Einträge, jeweils als eigener Abschnitt
            for (final RelatedSection section in sections) ...[
              const SizedBox(height: 24),

              SectionTitle(text: section.label),

              const SizedBox(height: 12),

              for (final DatabaseItem related in section.items) ...[
                ItemRow(item: related),
                const SizedBox(height: 12),
              ],
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Bottom Navigation auch auf der Detailseite
      bottomNavigationBar: const AppBottomNav(popToRoot: true),
    );
  }
}
