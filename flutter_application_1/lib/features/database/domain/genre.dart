// genre.dart
// Das Datenmodell eines Genres.
//
// Ein Genre wird nicht eigenständig erfasst, sondern aus den Genre-Angaben
// der Bands abgeleitet (siehe genre_data.dart). Es erhält trotzdem ein
// eigenes Modell und damit eine eigene Detailseite wie alle anderen
// Einträge auch.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Genre implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;         // Name des Genres, z.B. "Thrash Metal"

  final int bandCount;        // Anzahl Bands mit diesem Genre
  final List<String> bandIds; // Verknüpfung zu diesen Bands

  const Genre({
    required this.id,
    required this.title,
    required this.bandCount,
    required this.bandIds,
  });

  // Ein Genre hat keine übergeordnete Band, daher bleibt die Zeile leer
  @override
  String get subtitle => '';

  @override
  String get trailing => bandCount == 1 ? '1 Band' : '$bandCount Bands';

  // Der Text wird aus den Feldern gebildet
  @override
  String get description {
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
