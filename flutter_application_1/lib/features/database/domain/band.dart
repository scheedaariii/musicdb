// Das Datenmodell einer Band.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import 'database_item.dart';
import 'info_field.dart';

class Band implements DatabaseItem {
  @override
  final String id;

  @override
  final String title; // Name der Band

  final String descriptionText; // Beschreibung, bei neuen Bands leer
  final List<String> genreIds; // Verknüpfung zu den Genres
  final String origin; // Herkunft
  final String founded; // Gründungsjahr

  const Band({
    required this.id,
    required this.title,
    required this.genreIds,
    this.descriptionText = '',
    this.origin = '',
    this.founded = '',
  });

  // Baut eine Band aus einem Firestore-Dokument auf
  factory Band.fromMap(String id, Map<String, dynamic> map) => Band(
    id: id,
    title: map['title'] as String? ?? '',
    descriptionText: map['descriptionText'] as String? ?? '',
    genreIds: List<String>.from(map['genreIds'] as List? ?? const []),
    origin: map['origin'] as String? ?? '',
    founded: map['founded'] as String? ?? '',
  );

  // Die Felder, die in Firestore gespeichert werden.
  Map<String, dynamic> toMap() => {
    'title': title,
    'descriptionText': descriptionText,
    'genreIds': genreIds,
    'origin': origin,
    'founded': founded,
  };

  @override
  String get description => descriptionText;

  // Die Namen der Genres dieser Band
  List<String> get genreNames => genreIds
      .map((id) => repo.genreById(id)?.title)
      .whereType<String>()
      .toList();

  // Alle Genres als Text, z.B. "Heavy Metal / Thrash Metal"
  String get genre => genreNames.join(' / ');

  // Genre und Herkunft als zweite Zeile in der Liste
  @override
  String get subtitle {
    final List<String> teile = [
      if (genreIds.isNotEmpty) genre,
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
    if (genreIds.isNotEmpty)
      InfoField(icon: Icons.album, label: 'Genre', value: genre),
    if (origin.isNotEmpty)
      InfoField(icon: Icons.place, label: 'Herkunft', value: origin),
    if (founded.isNotEmpty)
      InfoField(icon: Icons.calendar_today, label: 'Gegründet', value: founded),
  ];

  @override
  bool matches(String query) =>
      matchesQuery(query, [title, genre, origin, founded]);
}
