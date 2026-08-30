// Das Datenmodell eines Songs.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import 'database_item.dart';
import 'info_field.dart';

class Song implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;             // Name des Songs

  final List<String> albumIds;    // Verknüpfung zu den Alben
  final List<String> bandIds;     // Verknüpfung zu den Bands
  final int durationSeconds;      // Spieldauer in Sekunden
  final String releaseDate;       // Release-Datum, optional
  final String descriptionText;   // Beschreibung, bei neuen Songs leer

  const Song({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.albumIds = const [],
    this.bandIds = const [],
    this.releaseDate = '',
    this.descriptionText = '',
  });

  // Baut einen Song aus einem Firestore-Dokument auf
  factory Song.fromMap(String id, Map<String, dynamic> map) => Song(
        id: id,
        title: map['title'] as String? ?? '',
        durationSeconds: map['durationSeconds'] as int? ?? 0,
        albumIds: List<String>.from(map['albumIds'] as List? ?? const []),
        bandIds: List<String>.from(map['bandIds'] as List? ?? const []),
        releaseDate: map['releaseDate'] as String? ?? '',
        descriptionText: map['descriptionText'] as String? ?? '',
      );

  // Die Felder, die in Firestore gespeichert werden. Die id ist keine
  // eigene Spalte, sondern die Dokument-ID.
  Map<String, dynamic> toMap() => {
        'title': title,
        'durationSeconds': durationSeconds,
        'albumIds': albumIds,
        'bandIds': bandIds,
        'releaseDate': releaseDate,
        'descriptionText': descriptionText,
      };

  // Die Namen der Alben dieses Songs
  List<String> get albumNames => albumIds
      .map((id) => repo.albumById(id)?.title)
      .whereType<String>()
      .toList();

  // Die Namen der Bands dieses Songs
  List<String> get bandNames => bandIds
      .map((id) => repo.bandById(id)?.title)
      .whereType<String>()
      .toList();

  // Spieldauer als "5:32"
  String get duration {
    if (durationSeconds <= 0) return '';

    final int minuten = durationSeconds ~/ 60;
    final String sekunden = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minuten:$sekunden';
  }

  // Die Band sagt in der Liste mehr aus, sonst das Album
  @override
  String get subtitle {
    final List<String> baende = bandNames;
    return baende.isNotEmpty ? baende.join(' · ') : albumNames.join(' · ');
  }

  @override
  String get trailing => duration;

  @override
  String get description => descriptionText;

  @override
  IconData get icon => Icons.music_note;

  @override
  List<InfoField> get infoFields {
    final List<String> alben = albumNames;
    final List<String> baende = bandNames;
    return [
      if (alben.isNotEmpty)
        InfoField(
          icon: Icons.album,
          label: alben.length == 1 ? 'Album' : 'Alben',
          value: alben.join(', '),
        ),
      if (baende.isNotEmpty)
        InfoField(
          icon: Icons.library_music,
          label: baende.length == 1 ? 'Band' : 'Bands',
          value: baende.join(', '),
        ),
      if (releaseDate.isNotEmpty)
        InfoField(
            icon: Icons.calendar_today, label: 'Erschienen', value: releaseDate),
      if (durationSeconds > 0)
        InfoField(
            icon: Icons.timer_outlined, label: 'Spieldauer', value: duration),
    ];
  }

  @override
  bool matches(String query) => matchesQuery(
        query,
        [title, ...albumNames, ...bandNames, duration],
      );
}
