// Das Datenmodell eines Albums. 

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import 'database_item.dart';
import 'info_field.dart';

class Album implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;            // Name des Albums

  final List<String> bandIds;    // Verknüpfung zu den Bands
  final List<String> genreIds;   // Verknüpfung zu den Genres
  final String releaseDate;      // Release-Datum, mindestens das Jahr
  final String descriptionText;  // Beschreibung, bei neuen Alben leer

  const Album({
    required this.id,
    required this.title,
    required this.bandIds,
    this.genreIds = const [],
    this.releaseDate = '',
    this.descriptionText = '',
  });

  // Baut ein Album aus einem Firestore-Dokument auf
  factory Album.fromMap(String id, Map<String, dynamic> map) => Album(
        id: id,
        title: map['title'] as String? ?? '',
        bandIds: List<String>.from(map['bandIds'] as List? ?? const []),
        genreIds: List<String>.from(map['genreIds'] as List? ?? const []),
        releaseDate: map['releaseDate'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
      );

  // Die Felder, die in Firestore gespeichert werden. 
  Map<String, dynamic> toMap() => {
        'title': title,
        'bandIds': bandIds,
        'genreIds': genreIds,
        'releaseDate': releaseDate,
        'descriptionText': descriptionText,
      };

  // Die Namen der Bands dieses Albums
  List<String> get bandNames => bandIds
      .map((id) => repo.bandById(id)?.title)
      .whereType<String>()
      .toList();

  // Die Namen der Genres dieses Albums
  List<String> get genreNames => genreIds
      .map((id) => repo.genreById(id)?.title)
      .whereType<String>()
      .toList();

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
  List<InfoField> get infoFields {
    final List<String> baende = bandNames;
    final List<String> genres = genreNames;
    return [
      if (baende.isNotEmpty)
        InfoField(
          icon: Icons.library_music,
          label: baende.length == 1 ? 'Band' : 'Bands',
          value: baende.join(', '),
        ),
      if (releaseDate.isNotEmpty)
        InfoField(
            icon: Icons.calendar_today, label: 'Erschienen', value: releaseDate),
      if (genres.isNotEmpty)
        InfoField(
          icon: Icons.category_outlined,
          label: genres.length == 1 ? 'Genre' : 'Genres',
          value: genres.join(', '),
        ),
    ];
  }

  @override
  bool matches(String query) => matchesQuery(
        query,
        [title, ...bandNames, ...genreNames, releaseDate],
      );
}
