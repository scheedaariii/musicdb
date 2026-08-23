// role.dart
// Das Datenmodell einer Rolle (Instrument bzw. Aufgabe in einer Band).
//
// Rollen werden wie Genres aus den Bestandsdaten abgeleitet: Sie ergeben
// sich aus den Rollen der erfassten Musiker. Zusätzlich können über das
// Formular eigene Rollen erfasst werden, diese haben zu Beginn noch
// keinen Musiker.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Role implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;              // Name der Rolle, z.B. "Schlagzeug"

  final List<String> musicianIds;  // Musiker mit dieser Rolle

  const Role({
    required this.id,
    required this.title,
    required this.musicianIds,
  });

  int get musicianCount => musicianIds.length;

  // Eine Rolle hat keine übergeordnete Band, daher bleibt die Zeile leer
  @override
  String get subtitle => '';

  @override
  String get trailing =>
      musicianCount == 1 ? '1 Musiker' : '$musicianCount Musiker';

  // Der Text wird aus den Feldern gebildet
  @override
  String get description {
    if (musicianCount == 0) {
      return '$title ist als Rolle in der MusicDB erfasst. '
          'Aktuell ist dieser Rolle noch kein Musiker zugeordnet.';
    }
    if (musicianCount == 1) {
      return '$title ist als Rolle in der MusicDB erfasst. '
          'Aktuell ist ein Musiker mit dieser Rolle erfasst.';
    }
    return '$title ist als Rolle in der MusicDB erfasst. '
        'Aktuell sind $musicianCount Musiker mit dieser Rolle erfasst.';
  }

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
