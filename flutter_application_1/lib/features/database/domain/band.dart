// band.dart
// Das Datenmodell einer Band.
// Eine Band kann mehrere Genres haben.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Band implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;          // Name der Band

  final String descriptionText;  // Beschreibung, bei neuen Bands leer
  final List<String> genres;     // Musikgenres der Band
  final String origin;           // Herkunft
  final String founded;          // Gründungsjahr

  const Band({
    required this.id,
    required this.title,
    required this.genres,
    this.descriptionText = '',
    this.origin = '',
    this.founded = '',
  });

  // Baut eine Band aus einem Firestore-Dokument auf
  factory Band.fromMap(String id, Map<String, dynamic> map) => Band(
        id: id,
        title: map['title'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
        genres: List<String>.from(map['genres'] as List? ?? const []),
        origin: map['origin'] as String? ?? '',
        founded: map['founded'] as String? ?? '',
      );

  // Die Felder, die in Firestore gespeichert werden. Die id ist keine
  // eigene Spalte, sondern die Dokument-ID.
  Map<String, dynamic> toMap() => {
        'title': title,
        'descriptionText': descriptionText,
        'genres': genres,
        'origin': origin,
        'founded': founded,
      };

  // Neu erfasste Bands haben noch keinen Beschreibungstext.
  // Dann wird der Text aus den vorhandenen Feldern gebildet.
  @override
  String get description {
    if (descriptionText.isNotEmpty) return descriptionText;

    final String genreText =
        genres.isEmpty ? '' : ' Als Genre ${genres.length == 1 ? 'ist' : 'sind'} $genre hinterlegt.';
    final String jahrText =
        founded.isEmpty ? '' : ' Gegründet wurde sie $founded.';

    return '$title ist in der MusicDB als Band erfasst.$genreText$jahrText';
  }

  // Alle Genres als Text, z.B. "Heavy Metal / Thrash Metal"
  String get genre => genres.join(' / ');

  // Genre und Herkunft als zweite Zeile in der Liste
  @override
  String get subtitle {
    final List<String> teile = [
      if (genres.isNotEmpty) genre,
      if (origin.isNotEmpty) origin,
    ];
    return teile.join(' · ');
  }

  @override
  String get trailing => founded.isEmpty ? '' : 'seit $founded';

  @override
  IconData get icon => Icons.music_note;

  @override
  List<InfoField> get infoFields => [
        if (genres.isNotEmpty)
          InfoField(icon: Icons.album, label: 'Genre', value: genre),
        if (origin.isNotEmpty)
          InfoField(icon: Icons.place, label: 'Herkunft', value: origin),
        if (founded.isNotEmpty)
          InfoField(
              icon: Icons.calendar_today, label: 'Gegründet', value: founded),
      ];

  @override
  bool matches(String query) =>
      matchesQuery(query, [title, genre, origin, founded]);
}
