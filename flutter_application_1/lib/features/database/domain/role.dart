// Das Datenmodell einer Rolle (Instrument bzw. Aufgabe in einer Band).

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import 'database_item.dart';
import 'info_field.dart';

class Role implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;              // Name der Rolle, z.B. "Schlagzeug"

  final String descriptionText;    // Beschreibung, falls erfasst

  const Role({
    required this.id,
    required this.title,
    this.descriptionText = '',
  });

  // Baut eine Rolle aus einem Firestore-Dokument auf
  factory Role.fromMap(String id, Map<String, dynamic> map) => Role(
        id: id,
        title: map['title'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
      );

  // Die Felder, die in Firestore gespeichert werden.
  Map<String, dynamic> toMap() => {
        'title': title,
        'descriptionText': descriptionText,
      };

  // Die Musiker, die diese Rolle ausüben
  List<String> get musicianIds => repo.musicians
      .where((musician) => musician.roleIds.contains(id))
      .map((musician) => musician.id)
      .toList();

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
