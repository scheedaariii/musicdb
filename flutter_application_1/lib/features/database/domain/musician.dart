// musician.dart
// Das Datenmodell eines Musikers.
// Ein Musiker kann in mehreren Bands spielen und mehrere Rollen haben.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Musician implements DatabaseItem {
  @override
  final String id;

  final String firstName;        // Vorname
  final String lastName;         // Nachname
  final List<String> bandIds;    // Verknüpfung zu den Bands
  final List<String> bandNames;  // Namen der Bands für die Anzeige
  final List<String> roles;      // Instrumente bzw. Rollen in der Band

  const Musician({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bandIds,
    required this.bandNames,
    required this.roles,
  });

  // Vor- und Nachname zusammen
  @override
  String get title => '$firstName $lastName'.trim();

  // Alle Rollen als Text, z.B. "Gesang, Gitarre"
  String get role => roles.join(', ');

  // Spielt der Musiker in mehr als einer Band?
  bool get hasMultipleBands => bandNames.length > 1;

  // Beschriftung im Singular oder Plural
  String get bandLabel => hasMultipleBands ? 'Bands' : 'Band';

  // Alle Bands als Aufzählung, z.B. "Metallica und Nirvana"
  String get bandsText {
    if (bandNames.isEmpty) return '';
    if (bandNames.length == 1) return bandNames.first;

    final String alleAusserLetzte =
        bandNames.sublist(0, bandNames.length - 1).join(', ');
    return '$alleAusserLetzte und ${bandNames.last}';
  }

  // Bei mehreren Bands werden alle mit Mittelpunkt getrennt angezeigt
  @override
  String get subtitle => bandNames.join(' · ');

  @override
  String get trailing => role;

  // Der Text wird aus den Feldern gebildet, damit keine erfundenen
  // Angaben zu realen Personen entstehen.
  @override
  String get description {
    final String bandText = bandNames.isEmpty
        ? '$title ist in der MusicDB erfasst.'
        : hasMultipleBands
            ? '$title ist in der MusicDB als Mitglied der Bands $bandsText erfasst.'
            : '$title ist in der MusicDB als Mitglied der Band $bandsText erfasst.';

    if (roles.isEmpty) return bandText;

    final String rolleText = roles.length == 1
        ? ' Als Rolle ist $role hinterlegt.'
        : ' Als Rollen sind $role hinterlegt.';

    return '$bandText$rolleText';
  }

  @override
  IconData get icon => Icons.person_outline;

  @override
  List<InfoField> get infoFields => [
        if (bandNames.isNotEmpty)
          InfoField(
            icon: Icons.library_music,
            label: bandLabel,
            value: bandNames.join(', '),
          ),
        if (roles.isNotEmpty)
          InfoField(
            icon: Icons.piano,
            label: roles.length == 1 ? 'Rolle' : 'Rollen',
            value: role,
          ),
      ];

  @override
  bool matches(String query) =>
      matchesQuery(query, [title, ...bandNames, ...roles]);
}
