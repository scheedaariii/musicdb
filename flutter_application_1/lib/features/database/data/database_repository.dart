// database_repository.dart
// Hält die Daten der App zur Laufzeit, lädt sie aus Firestore und stellt
// die Verknüpfungen her.
//
// Die Listen werden beim Start über load() aus Firestore gefüllt. Ist die
// Datenbank beim allerersten Start noch leer, werden einmalig die
// bisherigen Mock-Daten hochgeladen. Neu erfasste Einträge landen sofort
// in der jeweiligen Liste (für eine reaktionsschnelle UI) und werden im
// Hintergrund nach Firestore geschrieben.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Veränderbare Listen, gefüllt durch load()
  final List<Band> bands = [];
  final List<Musician> musicians = [];
  final List<Album> albums = [];
  final List<Song> songs = [];

  // Eigenständig gespeicherte Genres und Rollen (Name + Beschreibung),
  // aus der jeweiligen Firestore-Sammlung geladen. Die Bandzugehörigkeit
  // bzw. Musiker-Zugehörigkeit wird davon getrennt aus bands/musicians
  // abgeleitet, siehe die genres/roles-Getter unten.
  final List<Genre> _storedGenres = [];
  final List<Role> _storedRoles = [];

  bool _loaded = false;

  // Lädt die Daten aus Firestore. Ist die Datenbank noch leer (erster
  // Start), werden vorher die bisherigen Mock-Daten hochgeladen. Wird
  // beim App-Start einmal abgewartet, bevor die Oberfläche erscheint.
  Future<void> load() async {
    if (_loaded) return;

    final QuerySnapshot<Map<String, dynamic>> bandsSnapshot =
        await _db.collection('bands').get();

    if (bandsSnapshot.docs.isEmpty) {
      await _migrateSeedData();
    } else {
      bands.addAll(
          bandsSnapshot.docs.map((doc) => Band.fromMap(doc.id, doc.data())));

      final QuerySnapshot<Map<String, dynamic>> musiciansSnapshot =
          await _db.collection('musicians').get();
      musicians.addAll(musiciansSnapshot.docs
          .map((doc) => Musician.fromMap(doc.id, doc.data())));

      final QuerySnapshot<Map<String, dynamic>> albumsSnapshot =
          await _db.collection('albums').get();
      albums.addAll(albumsSnapshot.docs
          .map((doc) => Album.fromMap(doc.id, doc.data())));

      final QuerySnapshot<Map<String, dynamic>> songsSnapshot =
          await _db.collection('songs').get();
      songs.addAll(
          songsSnapshot.docs.map((doc) => Song.fromMap(doc.id, doc.data())));
    }

    QuerySnapshot<Map<String, dynamic>> genresSnapshot =
        await _db.collection('genres').get();
    if (genresSnapshot.docs.isEmpty) {
      await _migrateGenreNames();
      genresSnapshot = await _db.collection('genres').get();
    }
    _storedGenres.addAll(
        genresSnapshot.docs.map((doc) => Genre.fromMap(doc.id, doc.data())));

    QuerySnapshot<Map<String, dynamic>> rolesSnapshot =
        await _db.collection('roles').get();
    if (rolesSnapshot.docs.isEmpty) {
      await _migrateRoleNames();
      rolesSnapshot = await _db.collection('roles').get();
    }
    _storedRoles.addAll(
        rolesSnapshot.docs.map((doc) => Role.fromMap(doc.id, doc.data())));

    _loaded = true;
  }

  // Einmaliger Upload der Genre-Namen, die bisher nur als Angaben bei den
  // Bands existierten, als eigene Dokumente ohne Beschreibung. So bekommt
  // jedes bereits vorhandene Genre wie gewünscht ein eigenes Dokument.
  Future<void> _migrateGenreNames() async {
    final Set<String> namen = {};
    for (final Band band in bands) {
      namen.addAll(band.genres);
    }
    if (namen.isEmpty) return;

    final WriteBatch batch = _db.batch();
    for (final String name in namen) {
      batch.set(_db.collection('genres').doc(_slug(name)), {
        'title': name,
        'descriptionText': '',
      });
    }
    await batch.commit();
  }

  // Einmaliger Upload der Rollen-Namen, die bisher nur als Angaben bei den
  // Musikern existierten, als eigene Dokumente ohne Beschreibung.
  Future<void> _migrateRoleNames() async {
    final Set<String> namen = {};
    for (final Musician musician in musicians) {
      namen.addAll(musician.roles);
    }
    if (namen.isEmpty) return;

    final WriteBatch batch = _db.batch();
    for (final String name in namen) {
      batch.set(_db.collection('roles').doc(_slug(name)), {
        'title': name,
        'descriptionText': '',
      });
    }
    await batch.commit();
  }

  // Einmaliger Upload der bisherigen Mock-Daten, wenn Firestore noch
  // leer ist. So dient band_mock_data.dart & Co. weiterhin als
  // Ausgangsdatensatz, ohne ein separates Skript zu benötigen.
  Future<void> _migrateSeedData() async {
    final WriteBatch batch = _db.batch();

    for (final Band band in seedBands) {
      batch.set(_db.collection('bands').doc(band.id), band.toMap());
    }
    for (final Musician musician in seedMusicians) {
      batch.set(_db.collection('musicians').doc(musician.id), musician.toMap());
    }
    for (final Album album in seedAlbums) {
      batch.set(_db.collection('albums').doc(album.id), album.toMap());
    }
    for (final Song song in seedSongs) {
      batch.set(_db.collection('songs').doc(song.id), song.toMap());
    }

    await batch.commit();

    bands.addAll(seedBands);
    musicians.addAll(seedMusicians);
    albums.addAll(seedAlbums);
    songs.addAll(seedSongs);
  }

  // Schreibt im Hintergrund nach Firestore, ohne dass die aufrufende
  // Stelle darauf warten muss. Fehler landen in der Konsole statt die
  // App abstürzen zu lassen.
  void _write(Future<void> Function() write) {
    write().catchError((Object error) {
      debugPrint('Firestore-Schreibvorgang fehlgeschlagen: $error');
    });
  }

  // ---------- Abgeleitete Listen ----------

  // Genres ergeben sich aus den Bands, ergänzt um eigenständig erfasste
  // Genres. Die Beschreibung kommt, falls vorhanden, aus _storedGenres.
  List<Genre> get genres {
    final Map<String, List<String>> bandsProGenre = {};

    for (final Band band in bands) {
      for (final String name in band.genres) {
        bandsProGenre.putIfAbsent(name, () => []).add(band.id);
      }
    }
    for (final Genre gespeichert in _storedGenres) {
      bandsProGenre.putIfAbsent(gespeichert.title, () => []);
    }

    final List<String> namen = bandsProGenre.keys.toList()..sort();

    return [
      for (final String name in namen)
        Genre(
          id: _slug(name),
          title: name,
          descriptionText: _genreDescription(name),
          bandCount: bandsProGenre[name]!.length,
          bandIds: bandsProGenre[name]!,
        ),
    ];
  }

  // Rollen ergeben sich aus den Musikern, ergänzt um eigenständig erfasste
  // Rollen. Die Beschreibung kommt, falls vorhanden, aus _storedRoles.
  List<Role> get roles {
    final Map<String, List<String>> musikerProRolle = {};

    for (final Musician musician in musicians) {
      for (final String name in musician.roles) {
        musikerProRolle.putIfAbsent(name, () => []).add(musician.id);
      }
    }
    for (final Role gespeichert in _storedRoles) {
      musikerProRolle.putIfAbsent(gespeichert.title, () => []);
    }

    final List<String> namen = musikerProRolle.keys.toList()..sort();

    return [
      for (final String name in namen)
        Role(
          id: _slug(name),
          title: name,
          descriptionText: _roleDescription(name),
          musicianIds: musikerProRolle[name]!,
        ),
    ];
  }

  // Sucht die hinterlegte Beschreibung zu einem Namen. Ohne Treffer bleibt
  // sie leer, dann greift der automatisch gebildete Text im jeweiligen Modell.
  String _genreDescription(String title) {
    for (final Genre eintrag in _storedGenres) {
      if (eintrag.title == title) return eintrag.descriptionText;
    }
    return '';
  }

  String _roleDescription(String title) {
    for (final Role eintrag in _storedRoles) {
      if (eintrag.title == title) return eintrag.descriptionText;
    }
    return '';
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

  void addBand(Band band) {
    bands.add(band);
    _write(() => _db.collection('bands').doc(band.id).set(band.toMap()));
  }

  void addMusician(Musician musician) {
    musicians.add(musician);
    _write(() =>
        _db.collection('musicians').doc(musician.id).set(musician.toMap()));
  }

  void addAlbum(Album album) {
    albums.add(album);
    _write(() => _db.collection('albums').doc(album.id).set(album.toMap()));
  }

  void addSong(Song song) {
    songs.add(song);
    _write(() => _db.collection('songs').doc(song.id).set(song.toMap()));
  }

  void addGenre(String name, {String description = ''}) {
    if (genreNames.contains(name)) return;

    final Genre eintrag = Genre(
      id: _slug(name),
      title: name,
      descriptionText: description,
      bandCount: 0,
      bandIds: const [],
    );
    _storedGenres.add(eintrag);
    _write(() =>
        _db.collection('genres').doc(eintrag.id).set(eintrag.toMap()));
  }

  void addRole(String name, {String description = ''}) {
    if (roleNames.contains(name)) return;

    final Role eintrag = Role(
      id: _slug(name),
      title: name,
      descriptionText: description,
      musicianIds: const [],
    );
    _storedRoles.add(eintrag);
    _write(
        () => _db.collection('roles').doc(eintrag.id).set(eintrag.toMap()));
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
