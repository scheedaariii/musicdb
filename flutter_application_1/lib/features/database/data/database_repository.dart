// database_repository.dart
// Hält die Daten der App zur Laufzeit und stellt die Verknüpfungen her.
//
// Die Listen starten mit den Seed-Daten und können über das Formular
// ergänzt werden. Die Daten leben nur im Arbeitsspeicher: Nach einem
// Neustart der App sind neu erfasste Einträge wieder weg. Für echte
// Persistenz wäre Firestore der nächste Schritt.

import '../domain/album.dart';
import '../domain/band.dart';
import '../domain/database_category.dart';
import '../domain/database_item.dart';
import '../domain/genre.dart';
import '../domain/musician.dart';
import '../domain/related_section.dart';
import '../domain/role.dart';
import '../domain/song.dart';
import 'album_mock_data.dart';
import 'band_mock_data.dart';
import 'musician_mock_data.dart';
import 'song_mock_data.dart';

class DatabaseRepository {
  DatabaseRepository._();

  // Einzige Instanz, damit alle Screens dieselben Daten sehen
  static final DatabaseRepository instance = DatabaseRepository._();

  // Veränderbare Listen, gestartet mit den Seed-Daten
  final List<Band> bands = [...seedBands];
  final List<Musician> musicians = [...seedMusicians];
  final List<Album> albums = [...seedAlbums];
  final List<Song> songs = [...seedSongs];

  // Zusätzlich erfasste Genres und Rollen, die noch keinem
  // Eintrag zugeordnet sind
  final List<String> extraGenres = [];
  final List<String> extraRoles = [];

  // ---------- Abgeleitete Listen ----------

  // Genres ergeben sich aus den Bands, ergänzt um eigene Einträge
  List<Genre> get genres {
    final Map<String, List<String>> bandsProGenre = {};

    for (final Band band in bands) {
      for (final String name in band.genres) {
        bandsProGenre.putIfAbsent(name, () => []).add(band.id);
      }
    }
    for (final String name in extraGenres) {
      bandsProGenre.putIfAbsent(name, () => []);
    }

    final List<String> namen = bandsProGenre.keys.toList()..sort();

    return [
      for (final String name in namen)
        Genre(
          id: _slug(name),
          title: name,
          bandCount: bandsProGenre[name]!.length,
          bandIds: bandsProGenre[name]!,
        ),
    ];
  }

  // Rollen ergeben sich aus den Musikern, ergänzt um eigene Einträge
  List<Role> get roles {
    final Map<String, List<String>> musikerProRolle = {};

    for (final Musician musician in musicians) {
      for (final String name in musician.roles) {
        musikerProRolle.putIfAbsent(name, () => []).add(musician.id);
      }
    }
    for (final String name in extraRoles) {
      musikerProRolle.putIfAbsent(name, () => []);
    }

    final List<String> namen = musikerProRolle.keys.toList()..sort();

    return [
      for (final String name in namen)
        Role(
          id: _slug(name),
          title: name,
          musicianIds: musikerProRolle[name]!,
        ),
    ];
  }

  // Namen für die Auswahl-Listen im Formular
  List<String> get genreNames => genres.map((g) => g.title).toList();
  List<String> get roleNames => roles.map((r) => r.title).toList();
  List<String> get bandNames => bands.map((b) => b.title).toList();
  List<String> get albumNames => albums.map((a) => a.title).toList();

  // ---------- Kategorien ----------

  List<DatabaseItem> entriesOf(CategoryKind kind) {
    switch (kind) {
      case CategoryKind.bands:
        return bands;
      case CategoryKind.musiker:
        return musicians;
      case CategoryKind.alben:
        return albums;
      case CategoryKind.songs:
        return songs;
      case CategoryKind.genres:
        return genres;
      case CategoryKind.rolle:
        return roles;
    }
  }

  // Name, Icon und Beschreibungstexte stehen bei CategoryKind selbst.
  // Das Repository steuert nur die aktuellen Einträge bei.
  DatabaseCategory categoryOf(CategoryKind kind) =>
      DatabaseCategory(kind: kind, entries: entriesOf(kind));

  List<DatabaseCategory> get categories =>
      CategoryKind.values.map(categoryOf).toList();

  // ---------- Verknüpfungen ----------

  Band? bandById(String id) {
    for (final Band band in bands) {
      if (band.id == id) return band;
    }
    return null;
  }

  Musician? musicianById(String id) {
    for (final Musician musician in musicians) {
      if (musician.id == id) return musician;
    }
    return null;
  }

  // Liefert die verknüpften Einträge zu einem Eintrag
  List<RelatedSection> relatedFor(DatabaseItem item) {
    final List<RelatedSection> sections = [];

    // Band: ihre Musiker, Alben und Songs
    if (item is Band) {
      _addSection(sections, 'Musiker',
          musicians.where((m) => m.bandIds.contains(item.id)));
      _addSection(
          sections, 'Alben', albums.where((a) => a.bandIds.contains(item.id)));
      _addSection(
          sections, 'Songs', songs.where((s) => s.bandIds.contains(item.id)));
      return sections;
    }

    // Musiker: alle Bands, in denen er spielt
    if (item is Musician) {
      _addSection(sections, item.bandLabel, _bandsByIds(item.bandIds));
      return sections;
    }

    // Album: seine Bands und die Songs des Albums
    if (item is Album) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);

      _addSection(sections, _label(gefundeneBands.length, 'Band', 'Bands'),
          gefundeneBands);
      _addSection(
          sections, 'Songs', songs.where((s) => s.albumIds.contains(item.id)));
      return sections;
    }

    // Song: seine Bands und seine Alben, beide Verknüpfungen werden gezeigt
    if (item is Song) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);
      final List<Album> gefundeneAlben =
          albums.where((a) => item.albumIds.contains(a.id)).toList();

      _addSection(sections, _label(gefundeneBands.length, 'Band', 'Bands'),
          gefundeneBands);
      _addSection(sections, _label(gefundeneAlben.length, 'Album', 'Alben'),
          gefundeneAlben);
      return sections;
    }

    // Genre: alle Bands mit diesem Genre
    if (item is Genre) {
      _addSection(
          sections, 'Bands mit diesem Genre', _bandsByIds(item.bandIds));
      return sections;
    }

    // Rolle: alle Musiker mit dieser Rolle
    if (item is Role) {
      _addSection(sections, 'Musiker mit dieser Rolle',
          _musiciansByIds(item.musicianIds));
      return sections;
    }

    return sections;
  }

  // Hängt einen Abschnitt an, aber nur wenn es überhaupt Einträge gibt.
  // Das ersetzt das mehrfach wiederholte "if (... isNotEmpty) sections.add(...)".
  void _addSection(
    List<RelatedSection> sections,
    String label,
    Iterable<DatabaseItem> items,
  ) {
    final List<DatabaseItem> gefunden = items.toList();
    if (gefunden.isEmpty) return;

    sections.add(RelatedSection(label: label, items: gefunden));
  }

  // Beschriftung im Singular oder Plural, z.B. "Band" oder "Bands"
  String _label(int anzahl, String eins, String mehrere) =>
      anzahl == 1 ? eins : mehrere;

  // Sucht zu jeder ID die Band. IDs ohne Treffer werden übersprungen.
  // Wichtig: bandById wird pro ID nur ein Mal aufgerufen. Vorher stand der
  // Aufruf zwei Mal da (einmal in der Prüfung, einmal für den Wert).
  List<Band> _bandsByIds(List<String> ids) {
    final List<Band> gefunden = [];
    for (final String id in ids) {
      final Band? band = bandById(id);
      if (band != null) gefunden.add(band);
    }
    return gefunden;
  }

  List<Musician> _musiciansByIds(List<String> ids) {
    final List<Musician> gefunden = [];
    for (final String id in ids) {
      final Musician? musician = musicianById(id);
      if (musician != null) gefunden.add(musician);
    }
    return gefunden;
  }

  // Wandelt im Formular ausgewählte Namen in IDs um.
  // Namen ohne Treffer werden übersprungen, statt die App abstürzen zu lassen.
  List<String> idsForBandNames(List<String> namen) => [
        for (final String name in namen)
          for (final Band band in bands)
            if (band.title == name) band.id,
      ];

  List<String> idsForAlbumNames(List<String> namen) => [
        for (final String name in namen)
          for (final Album album in albums)
            if (album.title == name) album.id,
      ];

  // ---------- Neue Einträge speichern ----------

  void addBand(Band band) => bands.add(band);
  void addMusician(Musician musician) => musicians.add(musician);
  void addAlbum(Album album) => albums.add(album);
  void addSong(Song song) => songs.add(song);

  void addGenre(String name) {
    if (!genreNames.contains(name)) extraGenres.add(name);
  }

  void addRole(String name) {
    if (!roleNames.contains(name)) extraRoles.add(name);
  }

  // IDs für neue Einträge, mit Zähler gegen Doppelvergabe
  String newId(String name, List<String> vorhandeneIds) {
    final String basis = _slug(name);
    if (basis.isEmpty) return 'eintrag-${vorhandeneIds.length + 1}';

    String kandidat = basis;
    int zaehler = 2;
    while (vorhandeneIds.contains(kandidat)) {
      kandidat = '$basis-$zaehler';
      zaehler++;
    }
    return kandidat;
  }
}

// Wandelt einen Namen in eine ID um, z.B. "Pink Floyd" -> "pink-floyd"
String _slug(String text) {
  final String ersetzt = text
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss');

  final String nurErlaubte = ersetzt.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  return nurErlaubte.replaceAll(RegExp(r'^-+|-+$'), '');
}

// Kurzer Zugriff für die Screens
final DatabaseRepository repo = DatabaseRepository.instance;
