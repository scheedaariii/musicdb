// role.dart
// Das Datenmodell einer Rolle (Instrument bzw. Aufgabe in einer Band).
//
// Die Musiker-Zugehörigkeit (musicianIds) wird weiterhin aus den Rollen
// der erfassten Musiker abgeleitet. Der Name und eine optionale
// Beschreibung liegen dagegen als eigenes Dokument in der Firestore-
// Sammlung "roles" (siehe DatabaseRepository.load/addRole).

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Role implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;              // Name der Rolle, z.B. "Schlagzeug"

  final String descriptionText;    // Beschreibung, falls erfasst
  final List<String> musicianIds;  // Musiker mit dieser Rolle

  const Role({
    required this.id,
    required this.title,
    required this.musicianIds,
    this.descriptionText = '',
  });

  // Baut eine Rolle aus einem Firestore-Dokument auf
  factory Role.fromMap(String id, Map<String, dynamic> map) => Role(
        id: id,
        title: map['title'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        musicianIds: const [],
      );

  // Nur Name und Beschreibung werden in Firestore gespeichert, die Musiker-Zugehörigkeit ergibt sich aus den Musikern selbst.
  Map<String, dynamic> toMap() => {
        'title': title,
        'descriptionText': descriptionText,
      };

  int get musicianCount => musicianIds.length;

  // Eine Rolle hat keine übergeordnete Band, daher bleibt die Zeile leer
  @override
  String get subtitle => '';

  @override
  String get trailing =>
      musicianCount == 1 ? '1 Musiker' : '$musicianCount Musiker';

  @override
  String get description => descriptionText;

  @override
  IconData get icon => Icons.piano;

  @override
  List<InfoField> get infoFields => [
        InfoField(
          icon: Icons.person_outline,
          label: 'Musiker',
          value: trailing,
        ),
      ];

  @override
  bool matches(String query) => matchesQuery(query, [title, trailing]);
}
