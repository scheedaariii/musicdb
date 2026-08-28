// genre.dart
// Das Datenmodell eines Genres.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Genre implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;         // Name des Genres

  final String descriptionText; // Beschreibung
  final int bandCount;        // Anzahl Bands mit diesem Genre
  final List<String> bandIds; // Verknüpfung zu diesen Bands

  const Genre({
    required this.id,
    required this.title,
    required this.bandCount,
    required this.bandIds,
    this.descriptionText = '',
  });

  // Daten aus Firestore laden
  factory Genre.fromMap(String id, Map<String, dynamic> map) => Genre(
        id: id,
        title: map['title'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        bandCount: 0,
        bandIds: const [],
      );

  // Nur Name und Beschreibung werden in Firestore gespeichert. Der Link zwischen Band/Genre kommt von den Bands
  Map<String, dynamic> toMap() => {
        'title': title,
        'descriptionText': descriptionText,
      };

  // Ein Genre hat keine übergeordnete Band, daher bleibt die Zeile leer
  @override
  String get subtitle => '';

  @override
  String get trailing => bandCount == 1 ? '1 Band' : '$bandCount Bands';

  @override
  String get description => descriptionText;

  @override
  IconData get icon => Icons.category_outlined;

  @override
  List<InfoField> get infoFields => [
        InfoField(
          icon: Icons.library_music,
          label: 'Bands',
          value: trailing,
        ),
      ];

  @override
  bool matches(String query) => matchesQuery(query, [title, trailing]);
}
