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

  const Album({
    required this.id,
    required this.title,
    required this.bandIds,
    required this.bandNames,
    this.genres = const [],
    this.releaseDate = '',
  });

  // Nur das Jahr aus dem Release-Datum
  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;

  @override
  String get subtitle => bandNames.join(' · ');

  @override
  String get trailing => year;

  // Der Text wird aus den Feldern gebildet
  @override
  String get description {
    final String bandText = bandNames.isEmpty
        ? '$title ist in der MusicDB als Album erfasst.'
        : bandNames.length == 1
            ? '$title ist in der MusicDB als Album der Band ${bandNames.first} erfasst.'
            : '$title ist in der MusicDB als Album der Bands ${bandNames.join(', ')} erfasst.';

    if (releaseDate.isEmpty) return bandText;
    return '$bandText Als Release-Datum ist $releaseDate hinterlegt.';
  }

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
