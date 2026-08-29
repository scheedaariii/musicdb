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
  final String dateOfBirth;      // Geburtsdatum, Format JJJJ-MM-TT
  final String descriptionText;  // Beschreibung, bei neuen Musikern leer
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
    this.dateOfBirth = '',
    this.descriptionText = '',
  });

  // Baut einen Musiker aus einem Firestore-Dokument auf -> Mit Hilfe von AI von lokalne Datenfiles auf Firestore umgebaut
  factory Musician.fromMap(String id, Map<String, dynamic> map) => Musician(
        id: id,
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        dateOfBirth: map['dateOfBirth'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        bandIds: List<String>.from(map['bandIds'] as List? ?? const []),
        bandNames: List<String>.from(map['bandNames'] as List? ?? const []),
        roles: List<String>.from(map['roles'] as List? ?? const []),
      );

  // Die Felder, die in Firestore gespeichert werden.
  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'descriptionText': descriptionText,
        'bandIds': bandIds,
        'bandNames': bandNames,
        'roles': roles,
      };

  // Vor- und Nachname zusammen
  @override
  String get title => '$firstName $lastName'.trim();

  // Alle Rollen als Text, z.B. "Gesang, Gitarre"
  String get role => roles.join(', ');

  // Spielt der Musiker in mehr als einer Band?
  bool get hasMultipleBands => bandNames.length > 1;

  // Beschriftung im Singular oder Plural
  String get bandLabel => hasMultipleBands ? 'Bands' : 'Band';

  // Alter in Jahren, berechnet aus dateOfBirth. -1, wenn kein Geburtsdatum
  // hinterlegt ist (z.B. bei noch nicht bearbeiteten Bestandsdaten).
  int get age {
    final DateTime? geburtstag = DateTime.tryParse(dateOfBirth);
    if (geburtstag == null) return -1;

    final DateTime heute = DateTime.now();
    int alter = heute.year - geburtstag.year;

    final bool geburtstagDiesesJahrNochNicht =
        heute.month < geburtstag.month ||
            (heute.month == geburtstag.month && heute.day < geburtstag.day);
    if (geburtstagDiesesJahrNochNicht) alter--;

    return alter;
  }

  // Text für den blauen Header der Detailseite, ersetzt dort die Bandliste
  String get alterText => age < 0 ? '' : '$age Jahre';

  // Bei mehreren Bands werden alle mit Mittelpunkt getrennt angezeigt
  @override
  String get subtitle => bandNames.join(' · ');

  @override
  String get trailing => role;

  @override
  String get description => descriptionText;

  @override
  IconData get icon => Icons.person_outline;

  @override
  List<InfoField> get infoFields => [
        if (dateOfBirth.isNotEmpty)
          InfoField(
            icon: Icons.calendar_today,
            label: 'Geburtsdatum',
            value: dateOfBirth,
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
