// song.dart
// Das Datenmodell eines Songs.
// Neu erfasste Songs werden über albumIds mit Alben verknüpft.
// Die Bestandsdaten sind zusätzlich direkt mit ihrer Band verknüpft.

import 'package:flutter/material.dart';
import 'database_item.dart';
import 'info_field.dart';

class Song implements DatabaseItem {
  @override
  final String id;

  @override
  final String title;             // Name des Songs

  final List<String> albumIds;    // Verknüpfung zu den Alben
  final List<String> albumNames;  // Namen der Alben für die Anzeige
  final List<String> bandIds;     // Verknüpfung zur Band (Bestandsdaten)
  final List<String> bandNames;   // Name der Band für die Anzeige
  final int durationSeconds;      // Spieldauer in Sekunden
  final String releaseDate;       // Release-Datum, optional

  const Song({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.albumIds = const [],
    this.albumNames = const [],
    this.bandIds = const [],
    this.bandNames = const [],
    this.releaseDate = '',
  });

  // Spieldauer als "5:32"
  String get duration {
    if (durationSeconds <= 0) return '';

    final int minuten = durationSeconds ~/ 60;
    final String sekunden = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minuten:$sekunden';
  }

  // Die Band sagt in der Liste mehr aus, sonst das Album
  @override
  String get subtitle =>
      bandNames.isNotEmpty ? bandNames.join(' · ') : albumNames.join(' · ');

  @override
  String get trailing => duration;

  // Der Text wird aus den Feldern gebildet
  @override
  String get description {
    final String bandText = bandNames.isEmpty
        ? ''
        : bandNames.length == 1
            ? 'der Band ${bandNames.first}'
            : 'der Bands ${bandNames.join(', ')}';

    final String albumText = albumNames.isEmpty
        ? ''
        : albumNames.length == 1
            ? 'vom Album ${albumNames.first}'
            : 'von den Alben ${albumNames.join(', ')}';

    // Beide Angaben zusammensetzen, je nachdem was vorhanden ist
    final List<String> teile = [
      if (bandText.isNotEmpty) bandText,
      if (albumText.isNotEmpty) albumText,
    ];
    final String herkunft =
        teile.isEmpty ? 'als Song' : 'als Song ${teile.join(' ')}';

    final String dauerText = durationSeconds > 0
        ? ' Die hinterlegte Spieldauer beträgt $duration Minuten.'
        : '';

    return '$title ist in der MusicDB $herkunft erfasst.$dauerText';
  }

  @override
  IconData get icon => Icons.music_note;

  @override
  List<InfoField> get infoFields => [
        if (albumNames.isNotEmpty)
          InfoField(
            icon: Icons.album,
            label: albumNames.length == 1 ? 'Album' : 'Alben',
            value: albumNames.join(', '),
          ),
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
        if (durationSeconds > 0)
          InfoField(
              icon: Icons.timer_outlined, label: 'Spieldauer', value: duration),
      ];

  @override
  bool matches(String query) => matchesQuery(
        query,
        [title, ...albumNames, ...bandNames, duration],
      );
}
