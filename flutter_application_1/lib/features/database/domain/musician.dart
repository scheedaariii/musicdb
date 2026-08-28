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
    this.descriptionText = '',
  });

  // Baut einen Musiker aus einem Firestore-Dokument auf -> Mit Hilfe von AI von lokalne Datenfiles auf Firestore umgebaut
  factory Musician.fromMap(String id, Map<String, dynamic> map) => Musician(
        id: id,
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        bandIds: List<String>.from(map['bandIds'] as List? ?? const []),
        bandNames: List<String>.from(map['bandNames'] as List? ?? const []),
        roles: List<String>.from(map['roles'] as List? ?? const []),
      );

  // Die Felder, die in Firestore gespeichert werden. 
  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
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
