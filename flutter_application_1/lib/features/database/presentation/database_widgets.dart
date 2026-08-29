// database_widgets.dart
// Die wiederkehrenden Bausteine des Datenbank-Bereichs.
// Listenseite und Detailseite sind gleich aufgebaut und verwenden
// dieselben Widgets, damit das Design überall identisch bleibt.

import 'package:flutter/material.dart';
import '../domain/database_item.dart';
import '../domain/info_field.dart';
import 'item_detail_screen.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

// Dunkler Header mit grossem Icon, Titel und Untertitel
class DetailHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DetailHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Titel
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // Untertitel nur anzeigen, wenn vorhanden
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Weisse Box mit Icon, Bezeichnung und Wert
class InfoBox extends StatelessWidget {
  final InfoField field;

  const InfoBox({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          // Icon
          Icon(
            field.icon,
            color: AppColors.gold,
            size: 22,
          ),

          const SizedBox(width: 12),

          // Bezeichnung
          Text(
            '${field.label}: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Wert
          Expanded(
            child: Text(
              field.value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Abschnittstitel mit goldener Trennlinie
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),

        const SizedBox(height: 8),

        // Trennlinie
        Container(
          height: 2,
          width: 40,
          color: AppColors.gold,
        ),
      ],
    );
  }
}

// Eine Zeile in einer Eintragsliste.
// Ein Tippen öffnet immer die Detailseite des Eintrags.
class ItemRow extends StatelessWidget {
  final DatabaseItem item;

  // Wird aufgerufen, sobald die Detailseite wieder geschlossen wird. Damit
  // kann die aufrufende Liste sich neu aufbauen, falls der Eintrag dort
  // bearbeitet oder gelöscht wurde (Flutter baut eine Seite beim Zurück-
  // Navigieren sonst nicht automatisch neu auf).
  final VoidCallback? onReturn;

  const ItemRow({super.key, required this.item, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              // Der ausgewählte Eintrag wird übergeben
              builder: (context) => ItemDetailScreen(item: item),
            ),
          );
          onReturn?.call();
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon des Eintrags
              Icon(
                item.icon,
                color: AppColors.gold,
                size: 22,
              ),

              const SizedBox(width: 12),

              // Titel und Untertitel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Zweite Zeile nur anzeigen, wenn vorhanden
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Zusatzinfo rechts
              Text(
                item.trailing,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(width: 6),

              // Pfeil-Icon rechts
              const Icon(
                Icons.chevron_right,
                color: AppColors.gold,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Suchfeld im gleichen Stil wie die Info-Boxen
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.showClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          // Lupen-Icon
          const Icon(
            Icons.search,
            color: AppColors.gold,
            size: 22,
          ),

          const SizedBox(width: 12),

          // Eingabefeld
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                // Ohne Rahmen, damit die Box das Design vorgibt
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Kreuz zum Zurücksetzen, nur bei aktiver Suche
          if (showClear)
            InkWell(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

// Hinweisbox, wenn die Suche keine Treffer liefert
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: appCardDecoration(),
      child: const Text(
        'Keine Einträge gefunden.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
