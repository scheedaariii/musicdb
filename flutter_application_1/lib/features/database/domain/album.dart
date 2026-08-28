// album.dart
// Das Datenmodell eines Albums.
// Ein Album kann mehreren Bands und mehreren Genres zugeordnet sein.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Album implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;            // Name des Albums

  final List<String> bandIds;    // Verknüpfung zu den Bands
  final List<String> bandNames;  // Namen der Bands für die Anzeige
  final List<String> genres;     // Genres des Albums
  final String releaseDate;      // Release-Datum, mindestens das Jahr
  final String descriptionText;  // Beschreibung, bei neuen Alben leer

  const Album({
    required this.id,
    required this.title,
    required this.bandIds,
    required this.bandNames,
    this.genres = const [],
    this.releaseDate = '',
    this.descriptionText = '',
  });

  // Baut ein Album aus einem Firestore-Dokument auf
  factory Album.fromMap(String id, Map<String, dynamic> map) => Album(
        id: id,
        title: map['title'] as String? ?? '',
        bandIds: List<String>.from(map['bandIds'] as List? ?? const []),
        bandNames: List<String>.from(map['bandNames'] as List? ?? const []),
        genres: List<String>.from(map['genres'] as List? ?? const []),
        releaseDate: map['releaseDate'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
      );

  // Die Felder, die in Firestore gespeichert werden. Die id ist keine
  // eigene Spalte, sondern die Dokument-ID.
  Map<String, dynamic> toMap() => {
        'title': title,
        'bandIds': bandIds,
        'bandNames': bandNames,
        'genres': genres,
        'releaseDate': releaseDate,
        'descriptionText': descriptionText,
      };

  // Nur das Jahr aus dem Release-Datum
  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;

  @override
  String get subtitle => bandNames.join(' · ');

  @override
  String get trailing => year;

  @override
  String get description => descriptionText;

  @override
  IconData get icon => Icons.album;

  @override
  List<InfoField> get infoFields => [
        if (bandNames.isNotEmpty)
          InfoField(
            icon: Icons.library_music,
            label: bandNames.length == 1 ? 'Band' : 'Bands',
            value: bandNames.join(', '),
          ),
        if (releaseDate.isNotEmpty)
          InfoField(
              icon: Icons.calendar_today,
              label: 'Erschienen',
              value: releaseDate),
        if (genres.isNotEmpty)
          InfoField(
            icon: Icons.category_outlined,
            label: genres.length == 1 ? 'Genre' : 'Genres',
            value: genres.join(', '),
          ),
      ];

  @override
  bool matches(String query) => matchesQuery(
        query,
        [title, ...bandNames, ...genres, releaseDate],
      );
}
