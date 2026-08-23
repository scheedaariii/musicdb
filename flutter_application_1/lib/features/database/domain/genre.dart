// genre.dart
// Das Datenmodell eines Genres.
//
// Die Bandzugehörigkeit (bandCount/bandIds) wird weiterhin aus den
// Genre-Angaben der Bands abgeleitet. Der Name und eine optionale
// Beschreibung liegen dagegen als eigenes Dokument in der Firestore-
// Sammlung "genres" (siehe DatabaseRepository.load/addGenre).

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Genre implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;         // Name des Genres, z.B. "Thrash Metal"

  final String descriptionText; // Beschreibung, falls erfasst
  final int bandCount;        // Anzahl Bands mit diesem Genre
  final List<String> bandIds; // Verknüpfung zu diesen Bands

  const Genre({
    required this.id,
    required this.title,
    required this.bandCount,
    required this.bandIds,
    this.descriptionText = '',
  });

  // Baut ein Genre aus einem Firestore-Dokument auf. bandCount/bandIds
  // werden nicht gespeichert, sondern nachträglich aus den Bands ermittelt.
  factory Genre.fromMap(String id, Map<String, dynamic> map) => Genre(
        id: id,
        title: map['title'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        bandCount: 0,
        bandIds: const [],
      );

  // Nur Name und Beschreibung werden in Firestore gespeichert, die
  // Bandzugehörigkeit ergibt sich aus den Bands selbst.
  Map<String, dynamic> toMap() => {
        'title': title,
        'descriptionText': descriptionText,
      };

  // Ein Genre hat keine übergeordnete Band, daher bleibt die Zeile leer
  @override
  String get subtitle => '';

  @override
  String get trailing => bandCount == 1 ? '1 Band' : '$bandCount Bands';

  // Der Text wird aus den Feldern gebildet
  @override
  String get description {
    if (descriptionText.isNotEmpty) return descriptionText;

    if (bandCount == 0) {
      return '$title ist eine der Musikrichtungen in der MusicDB. '
          'Aktuell ist diesem Genre noch keine Band zugeordnet.';
    }
    if (bandCount == 1) {
      return '$title ist eine der Musikrichtungen in der MusicDB. '
          'Aktuell ist eine Band mit diesem Genre erfasst.';
    }
    return '$title ist eine der Musikrichtungen in der MusicDB. '
        'Aktuell sind $bandCount Bands mit diesem Genre erfasst.';
  }

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
