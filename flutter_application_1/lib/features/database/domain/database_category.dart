// Die Kategorien der Datenbank (Bands, Musiker, Alben, Songs, Genres, Rolle). DatabaseCategory verbindet eine Kategorie mit ihren aktuellen Einträgen.

import 'package:flutter/material.dart';
import 'database_item.dart';

enum CategoryKind {
  bands(
    title: 'Bands',
    subtitle: 'Alle erfassten Bands',
    icon: Icons.library_music,
    description:
        'Alle in der MusicDB erfassten Bands. Zu jeder Band werden das '
        'Genre, die Herkunft und das Gründungsjahr angezeigt. Ein Tippen '
        'auf einen Eintrag öffnet die Detailseite der Band.',
    entryLabel: 'Alle Bands',
  ),

  musiker(
    title: 'Musiker',
    subtitle: 'Bandmitglieder und ihre Instrumente',
    icon: Icons.person_outline,
    description:
        'Hier sind alle Musiker der erfassten Bands aufgelistet. '
        'Neben dem Namen wird die zugehörige Band sowie das Instrument '
        'beziehungsweise die Rolle innerhalb der Band angezeigt.',
    entryLabel: 'Alle Musiker',
  ),

  alben(
    title: 'Alben',
    subtitle: 'Veröffentlichungen der Bands',
    icon: Icons.album,
    description:
        'Eine Übersicht der bekanntesten Alben aller erfassten Bands. '
        'Zu jedem Album werden die veröffentlichende Band und das '
        'Erscheinungsjahr angezeigt.',
    entryLabel: 'Alle Alben',
  ),

  songs(
    title: 'Songs',
    subtitle: 'Einzelne Titel aus den Alben',
    icon: Icons.music_note,
    description:
        'Eine Auswahl bekannter Songs der erfassten Bands. '
        'Zu jedem Titel werden die Zuordnung und die Spieldauer angezeigt.',
    entryLabel: 'Alle Songs',
  ),

  genres(
    title: 'Genres',
    subtitle: 'Musikrichtungen der Bands',
    icon: Icons.category_outlined,
    description:
        'Die Musikrichtungen, welche in der Datenbank vertreten sind. '
        'Zu jedem Genre wird angezeigt, wie viele Bands dieses Genre '
        'spielen.',
    entryLabel: 'Alle Genres',
  ),

  rolle(
    title: 'Rolle',
    subtitle: 'Instrumente und Aufgaben in einer Band',
    icon: Icons.piano,
    description:
        'Die Rollen, welche die erfassten Musiker in ihren Bands '
        'übernehmen. Zu jeder Rolle wird angezeigt, wie viele Musiker '
        'sie ausüben.',
    entryLabel: 'Alle Rollen',
  );

  const CategoryKind({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.entryLabel,
  });

  final String title; // Name der Kategorie
  final String subtitle; // Kurzbeschreibung
  final IconData icon; // Icon in Liste und Header
  final String description; // Beschreibungstext auf der Listenseite
  final String entryLabel; // Überschrift über der Eintragsliste

  // Sucht die Kategorie zu einem angezeigten Namen, z.B. für das Formular.
  static CategoryKind? byTitle(String title) {
    for (final CategoryKind kind in values) {
      if (kind.title == title) return kind;
    }
    return null;
  }

  // Alle Kategorienamen, z.B. für das Auswahlfeld im Formular
  static List<String> get allTitles => [
    for (final CategoryKind kind in values) kind.title,
  ];
}

// Eine Kategorie zusammen mit ihren aktuellen Einträgen.
class DatabaseCategory {
  final CategoryKind kind;
  final List<DatabaseItem> entries;

  const DatabaseCategory({required this.kind, required this.entries});

  String get title => kind.title;
  String get subtitle => kind.subtitle;
  IconData get icon => kind.icon;
  String get description => kind.description;
  String get entryLabel => kind.entryLabel;
}
