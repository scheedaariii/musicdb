// Zuständig für die Firebase-Verknüpfung und das Management der Daten.
// Die Listen werden beim Start über load() aus Firestore gefüllt. Neu erfasste Einträge landen erst in der jeweiligen Liste, nachdem das Schreiben nach Firestore erfolgreich war (siehe _write unten).
// Verknüpfungen zwischen Einträgen (z.B. welche Bands ein Musiker hat) werden ausschliesslich über IDs gespeichert (bandIds, genreIds, ...).
//
// Überarbeitung Feedback zwischenabgabe: Die add-/update-/delete- Methoden sind jetzt async und geben Future<void> zurück, damit die aufrufenden Screens den Abschluss des Schreibvorgangs abwarten können
// Ausserdem kennt dieses Repository die Flutter-UI nicht mehr direkt (siehe lastError). Die Änderungen Zur verbesserung des Kaskadenverhaltens und atomarität konnten nur durch AI unterstützung umgesetzt werden.
//
// Änderung (Datenzugehörigkeit): Jede Person hat jetzt ihre eigene, private Datenbank statt einer gemeinsamen für alle. load() lädt darum nur noch die Daten der eingeloggten Person, und reset() leert beim Abmelden alles wieder, damit das nächste Konto nicht die Daten des vorherigen sieht.
//
// Feedback Sehr grosses Repository: Experimentiert mit part / part of Direktiven. Das gibt einfach mehrere kleinere Files und verringert nicht wirklich den content des database_repositories. Ansonsten keinen sinnvollen Weg gefunden das File zu verkleinern.

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
  final List<Genre> genres = [];
  final List<Role> roles = [];

  bool _loaded = false;

  // Wer gerade eingeloggt ist - bestimmt, wessen Daten geladen/gespeichert werden.
  String? _uid;

  // Änderung (Feedback "UI-Fehlermeldungen aus Repository"): Vorher hat dieses Repository bei einem Schreibfehler direkt eine SnackBar angezeigt (import von flutter/material.dart und app_messenger.dart). Jetzt wird der Fehlertext nur noch hier abgelegt.

  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);

  // Liefert die Daten der eingeloggten Person statt einer für alle gemeinsamen Liste.
  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _db.collection('users').doc(_uid).collection(name);

  // Lädt die Daten aus Firestore. Wird beim App-Start einmal abgewartet, bevor die Oberfläche erscheint.

  Future<void> load(String uid) async {
    if (_loaded) return;
    _uid = uid;

    final QuerySnapshot<Map<String, dynamic>> bandsSnapshot = await _collection(
      'bands',
    ).get();
    bands.addAll(
      bandsSnapshot.docs.map((doc) => Band.fromMap(doc.id, doc.data())),
    );

    final QuerySnapshot<Map<String, dynamic>> musiciansSnapshot =
        await _collection('musicians').get();
    musicians.addAll(
      musiciansSnapshot.docs.map((doc) => Musician.fromMap(doc.id, doc.data())),
    );

    final QuerySnapshot<Map<String, dynamic>> albumsSnapshot =
        await _collection('albums').get();
    albums.addAll(
      albumsSnapshot.docs.map((doc) => Album.fromMap(doc.id, doc.data())),
    );

    final QuerySnapshot<Map<String, dynamic>> songsSnapshot = await _collection(
      'songs',
    ).get();
    songs.addAll(
      songsSnapshot.docs.map((doc) => Song.fromMap(doc.id, doc.data())),
    );

    final QuerySnapshot<Map<String, dynamic>> genresSnapshot =
        await _collection('genres').get();
    genres.addAll(
      genresSnapshot.docs.map((doc) => Genre.fromMap(doc.id, doc.data())),
    );

    final QuerySnapshot<Map<String, dynamic>> rolesSnapshot = await _collection(
      'roles',
    ).get();
    roles.addAll(
      rolesSnapshot.docs.map((doc) => Role.fromMap(doc.id, doc.data())),
    );

    _loaded = true;
  }

  // Wird beim Abmelden aufgerufen, damit die nächste Person nicht kurz die Daten der vorherigen sieht.
  void reset() {
    bands.clear();
    musicians.clear();
    albums.clear();
    songs.clear();
    genres.clear();
    roles.clear();
    _uid = null;
    _loaded = false;
  }

  // Änderung (Feedback "Änderungen werden lokal vor Firebase-Erfolg übernommen, kein
  // Rollback bei Schreibfehlern"):
  // _write wartet den Schreibvorgang jetzt ab und meldet per Rückgabewert, ob er erfolgreich war.

  Future<bool> _write(Future<void> Function() write) async {
    try {
      await write();
      return true;
    } catch (error) {
      debugPrint('Firestore-Schreibvorgang fehlgeschlagen: $error');
      lastError.value =
          'Speichern fehlgeschlagen. Bitte Internetverbindung prüfen.';
      return false;
    }
  }

  // Änderung (Feedback "verknüpfte Updates nicht atomar"):
  // Hilfsmethode für Löschvorgänge, die mehrere Dokumente gleichzeitig betreffen (z.B. eine Band löschen und dabei die bandIds bei jedem ihrer Musiker/Alben/Songs entfernen).
  // Alle Schreibvorgänge werden in einem WriteBatch gesammelt und in einem Schritt committet.

  Future<bool> _commitBatch(void Function(WriteBatch batch) build) {
    final WriteBatch batch = _db.batch();
    build(batch);
    return _write(() => batch.commit());
  }

  // ---------- Namen für die Auswahl-Listen im Formular ----------

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

  // Name, Icon und Beschreibungstexte stehen bei CategoryKind selbst. Das Repository steuert nur die aktuellen Einträge bei.

  DatabaseCategory categoryOf(CategoryKind kind) =>
      DatabaseCategory(kind: kind, entries: entriesOf(kind));

  List<DatabaseCategory> get categories =>
      CategoryKind.values.map(categoryOf).toList();

  // ---------- Statistiken fürs Profil ----------
  // Ein Song hat kein eigenes Genre-Feld, darum wird sein Genre über die verknüpften Bands/Alben ermittelt (genreWithMostSongs).

  // Genre mit den meisten Bands
  Genre? get genreWithMostBands {
    Genre? bestes;
    int besterWert = 0;
    for (final Genre genre in genres) {
      final int anzahl = bands
          .where((b) => b.genreIds.contains(genre.id))
          .length;
      if (anzahl > besterWert) {
        bestes = genre;
        besterWert = anzahl;
      }
    }
    return bestes;
  }

  // Zähler abfüllen für das Genre mit den meisten Bands.
  int get genreWithMostBandsCount {
    final Genre? genre = genreWithMostBands;
    if (genre == null) return 0;
    return bands.where((b) => b.genreIds.contains(genre.id)).length;
  }

  // Genre mit den meisten Songs
  Genre? get genreWithMostSongs {
    final Map<String, int> anzahlProGenre = {};
    for (final Song song in songs) {
      final Set<String> genreIds = {};
      for (final String bandId in song.bandIds) {
        genreIds.addAll(bandById(bandId)?.genreIds ?? const []);
      }
      for (final String albumId in song.albumIds) {
        genreIds.addAll(albumById(albumId)?.genreIds ?? const []);
      }
      for (final String genreId in genreIds) {
        anzahlProGenre[genreId] = (anzahlProGenre[genreId] ?? 0) + 1;
      }
    }
    if (anzahlProGenre.isEmpty) return null;
    final String besteId = anzahlProGenre.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return genreById(besteId);
  }

  // Zähler abfüllen für das Genre mit den meisten Songs.
  int get genreWithMostSongsCount {
    final Genre? genre = genreWithMostSongs;
    if (genre == null) return 0;
    int anzahl = 0;
    for (final Song song in songs) {
      final Set<String> genreIds = {};
      for (final String bandId in song.bandIds) {
        genreIds.addAll(bandById(bandId)?.genreIds ?? const []);
      }
      for (final String albumId in song.albumIds) {
        genreIds.addAll(albumById(albumId)?.genreIds ?? const []);
      }
      if (genreIds.contains(genre.id)) anzahl++;
    }
    return anzahl;
  }

  // Band mit den meisten Songs
  Band? get bandWithMostSongs {
    Band? beste;
    int besterWert = 0;
    for (final Band band in bands) {
      final int anzahl = songs.where((s) => s.bandIds.contains(band.id)).length;
      if (anzahl > besterWert) {
        beste = band;
        besterWert = anzahl;
      }
    }
    return beste;
  }

  // Zähler abfüllen für die Band mit den meisten Songs.
  int get bandWithMostSongsCount {
    final Band? band = bandWithMostSongs;
    if (band == null) return 0;
    return songs.where((s) => s.bandIds.contains(band.id)).length;
  }

  // Band mit den meisten Alben
  Band? get bandWithMostAlbums {
    Band? beste;
    int besterWert = 0;
    for (final Band band in bands) {
      final int anzahl = albums
          .where((a) => a.bandIds.contains(band.id))
          .length;
      if (anzahl > besterWert) {
        beste = band;
        besterWert = anzahl;
      }
    }
    return beste;
  }

  // Zähler abfüllen für die Band mit den meisten Alben.
  int get bandWithMostAlbumsCount {
    final Band? band = bandWithMostAlbums;
    if (band == null) return 0;
    return albums.where((a) => a.bandIds.contains(band.id)).length;
  }

  // ---------- Verknüpfungen: Suche per ID ----------

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

  Album? albumById(String id) {
    for (final Album album in albums) {
      if (album.id == id) return album;
    }
    return null;
  }

  Song? songById(String id) {
    for (final Song song in songs) {
      if (song.id == id) return song;
    }
    return null;
  }

  Genre? genreById(String id) {
    for (final Genre genre in genres) {
      if (genre.id == id) return genre;
    }
    return null;
  }

  Role? roleById(String id) {
    for (final Role role in roles) {
      if (role.id == id) return role;
    }
    return null;
  }

  // ---------- Verknüpfungen: Suche per Titel ----------
  // Wird gebraucht, wenn eine Detailseite eine Verknüpfung aus einem Auswahlfeld (Namen) in einen Eintrag auflöst.

  Band? bandByTitle(String title) {
    for (final Band band in bands) {
      if (band.title == title) return band;
    }
    return null;
  }

  Musician? musicianByTitle(String title) {
    for (final Musician musician in musicians) {
      if (musician.title == title) return musician;
    }
    return null;
  }

  Album? albumByTitle(String title) {
    for (final Album album in albums) {
      if (album.title == title) return album;
    }
    return null;
  }

  Song? songByTitle(String title) {
    for (final Song song in songs) {
      if (song.title == title) return song;
    }
    return null;
  }

  Genre? genreByTitle(String title) {
    for (final Genre genre in genres) {
      if (genre.title == title) return genre;
    }
    return null;
  }

  Role? roleByTitle(String title) {
    for (final Role role in roles) {
      if (role.title == title) return role;
    }
    return null;
  }

  // Liefert die verknüpften Einträge zu einem Eintrag

  List<RelatedSection> relatedFor(DatabaseItem item) {
    final List<RelatedSection> sections = [];

    // Band: ihre Musiker, Alben und Songs

    if (item is Band) {
      _addSection(
        sections,
        'Musiker',
        musicians.where((m) => m.bandIds.contains(item.id)),
      );
      _addSection(
        sections,
        'Alben',
        albums.where((a) => a.bandIds.contains(item.id)),
      );
      _addSection(
        sections,
        'Songs',
        songs.where((s) => s.bandIds.contains(item.id)),
      );
      return sections;
    }

    // Musiker: alle Bands, in denen er spielt

    if (item is Musician) {
      _addSection(sections, item.bandLabel, _bandsByIds(item.bandIds));
      return sections;
    }

    // Album: beteiligte Bands und die Songs des Albums

    if (item is Album) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);

      _addSection(
        sections,
        gefundeneBands.length == 1 ? 'Band' : 'Bands',
        gefundeneBands,
      );
      _addSection(
        sections,
        'Songs',
        songs.where((s) => s.albumIds.contains(item.id)),
      );
      return sections;
    }

    // Song: Beteiligte Bands und zugehörige Alben

    if (item is Song) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);
      final List<Album> gefundeneAlben = albums
          .where((a) => item.albumIds.contains(a.id))
          .toList();

      _addSection(
        sections,
        gefundeneBands.length == 1 ? 'Band' : 'Bands',
        gefundeneBands,
      );
      _addSection(
        sections,
        gefundeneAlben.length == 1 ? 'Album' : 'Alben',
        gefundeneAlben,
      );
      return sections;
    }

    // Genre: alle Bands mit diesem Genre

    if (item is Genre) {
      _addSection(
        sections,
        'Bands mit diesem Genre',
        bands.where((b) => b.genreIds.contains(item.id)),
      );
      return sections;
    }

    // Rolle: alle Musiker mit dieser Rolle

    if (item is Role) {
      _addSection(
        sections,
        'Musiker mit dieser Rolle',
        musicians.where((m) => m.roleIds.contains(item.id)),
      );
      return sections;
    }

    return sections;
  }

  // Hängt einen Abschnitt an, aber nur wenn es überhaupt Einträge gibt. Wurde mit AI ergänzt, ich konnte selbst keine passende Lösung finden.

  void _addSection(
    List<RelatedSection> sections,
    String label,
    Iterable<DatabaseItem> items,
  ) {
    final List<DatabaseItem> gefunden = items.toList();
    if (gefunden.isEmpty) return;

    sections.add(RelatedSection(label: label, items: gefunden));
  }

  // Sucht zu jeder ID die Band. IDs ohne Treffer werden übersprungen.

  List<Band> _bandsByIds(List<String> ids) {
    final List<Band> gefunden = [];
    for (final String id in ids) {
      final Band? band = bandById(id);
      if (band != null) gefunden.add(band);
    }
    return gefunden;
  }

  // Wandelt im Formular ausgewählte Namen in IDs um. Namen ohne Treffer werden übersprungen (vermeidet fehler)

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

  List<String> idsForGenreNames(List<String> namen) => [
    for (final String name in namen)
      for (final Genre genre in genres)
        if (genre.title == name) genre.id,
  ];

  List<String> idsForRoleNames(List<String> namen) => [
    for (final String name in namen)
      for (final Role role in roles)
        if (role.title == name) role.id,
  ];

  // ---------- Neue Einträge speichern ----------
  // Änderung nach feedback: alle addX-Methoden sind jetzt async und warten den Schreibvorgang ab, bevor der neue Eintrag der lokalen Liste hinzugefügt wird. Leider habe ich für diese Änderung AI unterstüzung benötigt.

  Future<void> addBand({
    required String title,
    List<String> genreIds = const [],
    String founded = '',
    String origin = '',
    String descriptionText = '',
  }) async {
    final doc = _collection('bands').doc();
    final Band band = Band(
      id: doc.id,
      title: title,
      genreIds: genreIds,
      founded: founded,
      origin: origin,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(band.toMap()))) {
      bands.add(band);
    }
  }

  Future<void> addMusician({
    required String firstName,
    required String lastName,
    String dateOfBirth = '',
    List<String> bandIds = const [],
    List<String> roleIds = const [],
    String descriptionText = '',
  }) async {
    final doc = _collection('musicians').doc();
    final Musician musician = Musician(
      id: doc.id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      bandIds: bandIds,
      roleIds: roleIds,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(musician.toMap()))) {
      musicians.add(musician);
    }
  }

  Future<void> addAlbum({
    required String title,
    List<String> bandIds = const [],
    List<String> genreIds = const [],
    String releaseDate = '',
    String descriptionText = '',
  }) async {
    final doc = _collection('albums').doc();
    final Album album = Album(
      id: doc.id,
      title: title,
      bandIds: bandIds,
      genreIds: genreIds,
      releaseDate: releaseDate,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(album.toMap()))) {
      albums.add(album);
    }
  }

  Future<void> addSong({
    required String title,
    int durationSeconds = 0,
    List<String> albumIds = const [],
    List<String> bandIds = const [],
    String releaseDate = '',
    String descriptionText = '',
  }) async {
    final doc = _collection('songs').doc();
    final Song song = Song(
      id: doc.id,
      title: title,
      durationSeconds: durationSeconds,
      albumIds: albumIds,
      bandIds: bandIds,
      releaseDate: releaseDate,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(song.toMap()))) {
      songs.add(song);
    }
  }

  Future<void> addGenre({
    required String title,
    String descriptionText = '',
  }) async {
    final doc = _collection('genres').doc();
    final Genre genre = Genre(
      id: doc.id,
      title: title,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(genre.toMap()))) {
      genres.add(genre);
    }
  }

  Future<void> addRole({
    required String title,
    String descriptionText = '',
  }) async {
    final doc = _collection('roles').doc();
    final Role role = Role(
      id: doc.id,
      title: title,
      descriptionText: descriptionText,
    );
    if (await _write(() => doc.set(role.toMap()))) {
      roles.add(role);
    }
  }

  // ---------- Bestehende Einträge ändern ----------
  // Änderung nach Feedback: analog zu den addX-Methoden auch hier zuerst schreiben und abwarten, die lokale Liste erst danach aktualisieren.

  Future<void> updateBand(Band band) async {
    if (!bands.any((b) => b.id == band.id)) return;
    if (await _write(
      () => _collection('bands').doc(band.id).set(band.toMap()),
    )) {
      final int index = bands.indexWhere((b) => b.id == band.id);
      if (index != -1) bands[index] = band;
    }
  }

  Future<void> updateMusician(Musician musician) async {
    if (!musicians.any((m) => m.id == musician.id)) return;
    if (await _write(
      () => _collection('musicians').doc(musician.id).set(musician.toMap()),
    )) {
      final int index = musicians.indexWhere((m) => m.id == musician.id);
      if (index != -1) musicians[index] = musician;
    }
  }

  Future<void> updateAlbum(Album album) async {
    if (!albums.any((a) => a.id == album.id)) return;
    if (await _write(
      () => _collection('albums').doc(album.id).set(album.toMap()),
    )) {
      final int index = albums.indexWhere((a) => a.id == album.id);
      if (index != -1) albums[index] = album;
    }
  }

  Future<void> updateSong(Song song) async {
    if (!songs.any((s) => s.id == song.id)) return;
    if (await _write(
      () => _collection('songs').doc(song.id).set(song.toMap()),
    )) {
      final int index = songs.indexWhere((s) => s.id == song.id);
      if (index != -1) songs[index] = song;
    }
  }

  Future<void> updateGenre(Genre genre) async {
    if (!genres.any((g) => g.id == genre.id)) return;
    if (await _write(
      () => _collection('genres').doc(genre.id).set(genre.toMap()),
    )) {
      final int index = genres.indexWhere((g) => g.id == genre.id);
      if (index != -1) genres[index] = genre;
    }
  }

  Future<void> updateRole(Role role) async {
    if (!roles.any((r) => r.id == role.id)) return;
    if (await _write(
      () => _collection('roles').doc(role.id).set(role.toMap()),
    )) {
      final int index = roles.indexWhere((r) => r.id == role.id);
      if (index != -1) roles[index] = role;
    }
  }

  // ---------- Verknüpfungen auf beiden Seiten ändern ----------
  // Eine Detailseite kann eine Verknüpfung zeigen, die als Feld beim jeweils anderen Eintrag gespeichert ist (z.B. zeigt eine Band ihre Songs, aber die Verknüpfung liegt in Song.bandIds). Ich hatte bei Tests diese inkonsistenz entdeckt. Um das sauber umzusetzten musste ich AI zur Hilfe nehmen.
  //
  // Änderung nach Feedback: alle diese Methoden sind jetzt async und warten die zugrundeliegende updateX()-Methode ab.
  // Reine Hilfsfunktionen ohne Seiteneffekt: liefern eine Kopie des Eintrags ohne die angegebene ID. Damit wird nun der atomare Zustand gewährt.

  Musician _musicianWithoutBand(Musician m, String bandId) => Musician(
    id: m.id,
    firstName: m.firstName,
    lastName: m.lastName,
    dateOfBirth: m.dateOfBirth,
    descriptionText: m.descriptionText,
    roleIds: m.roleIds,
    bandIds: m.bandIds.where((id) => id != bandId).toList(),
  );

  Album _albumWithoutBand(Album a, String bandId) => Album(
    id: a.id,
    title: a.title,
    genreIds: a.genreIds,
    releaseDate: a.releaseDate,
    descriptionText: a.descriptionText,
    bandIds: a.bandIds.where((id) => id != bandId).toList(),
  );

  Song _songWithoutBand(Song s, String bandId) => Song(
    id: s.id,
    title: s.title,
    durationSeconds: s.durationSeconds,
    releaseDate: s.releaseDate,
    descriptionText: s.descriptionText,
    albumIds: s.albumIds,
    bandIds: s.bandIds.where((id) => id != bandId).toList(),
  );

  Song _songWithoutAlbum(Song s, String albumId) => Song(
    id: s.id,
    title: s.title,
    durationSeconds: s.durationSeconds,
    releaseDate: s.releaseDate,
    descriptionText: s.descriptionText,
    bandIds: s.bandIds,
    albumIds: s.albumIds.where((id) => id != albumId).toList(),
  );

  Band _bandWithoutGenre(Band b, String genreId) => Band(
    id: b.id,
    title: b.title,
    origin: b.origin,
    founded: b.founded,
    descriptionText: b.descriptionText,
    genreIds: b.genreIds.where((id) => id != genreId).toList(),
  );

  Musician _musicianWithoutRole(Musician m, String roleId) => Musician(
    id: m.id,
    firstName: m.firstName,
    lastName: m.lastName,
    dateOfBirth: m.dateOfBirth,
    descriptionText: m.descriptionText,
    bandIds: m.bandIds,
    roleIds: m.roleIds.where((id) => id != roleId).toList(),
  );

  Future<void> addBandToMusician(String musicianId, String bandId) async {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (musician.bandIds.contains(bandId)) return;

    await updateMusician(
      Musician(
        id: musician.id,
        firstName: musician.firstName,
        lastName: musician.lastName,
        dateOfBirth: musician.dateOfBirth,
        descriptionText: musician.descriptionText,
        roleIds: musician.roleIds,
        bandIds: [...musician.bandIds, bandId],
      ),
    );
  }

  Future<void> removeBandFromMusician(String musicianId, String bandId) async {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (!musician.bandIds.contains(bandId)) return;

    await updateMusician(_musicianWithoutBand(musician, bandId));
  }

  Future<void> addBandToAlbum(String albumId, String bandId) async {
    final Album? album = albumById(albumId);
    if (album == null) return;
    if (album.bandIds.contains(bandId)) return;

    await updateAlbum(
      Album(
        id: album.id,
        title: album.title,
        genreIds: album.genreIds,
        releaseDate: album.releaseDate,
        descriptionText: album.descriptionText,
        bandIds: [...album.bandIds, bandId],
      ),
    );
  }

  Future<void> removeBandFromAlbum(String albumId, String bandId) async {
    final Album? album = albumById(albumId);
    if (album == null) return;
    if (!album.bandIds.contains(bandId)) return;

    await updateAlbum(_albumWithoutBand(album, bandId));
  }

  Future<void> addBandToSong(String songId, String bandId) async {
    final Song? song = songById(songId);
    if (song == null) return;
    if (song.bandIds.contains(bandId)) return;

    await updateSong(
      Song(
        id: song.id,
        title: song.title,
        durationSeconds: song.durationSeconds,
        releaseDate: song.releaseDate,
        descriptionText: song.descriptionText,
        albumIds: song.albumIds,
        bandIds: [...song.bandIds, bandId],
      ),
    );
  }

  Future<void> removeBandFromSong(String songId, String bandId) async {
    final Song? song = songById(songId);
    if (song == null) return;
    if (!song.bandIds.contains(bandId)) return;

    await updateSong(_songWithoutBand(song, bandId));
  }

  Future<void> addAlbumToSong(String songId, String albumId) async {
    final Song? song = songById(songId);
    if (song == null) return;
    if (song.albumIds.contains(albumId)) return;

    await updateSong(
      Song(
        id: song.id,
        title: song.title,
        durationSeconds: song.durationSeconds,
        releaseDate: song.releaseDate,
        descriptionText: song.descriptionText,
        bandIds: song.bandIds,
        albumIds: [...song.albumIds, albumId],
      ),
    );
  }

  Future<void> removeAlbumFromSong(String songId, String albumId) async {
    final Song? song = songById(songId);
    if (song == null) return;
    if (!song.albumIds.contains(albumId)) return;

    await updateSong(_songWithoutAlbum(song, albumId));
  }

  Future<void> addGenreToBand(String bandId, String genreId) async {
    final Band? band = bandById(bandId);
    if (band == null) return;
    if (band.genreIds.contains(genreId)) return;

    await updateBand(
      Band(
        id: band.id,
        title: band.title,
        origin: band.origin,
        founded: band.founded,
        descriptionText: band.descriptionText,
        genreIds: [...band.genreIds, genreId],
      ),
    );
  }

  Future<void> removeGenreFromBand(String bandId, String genreId) async {
    final Band? band = bandById(bandId);
    if (band == null) return;
    if (!band.genreIds.contains(genreId)) return;

    await updateBand(_bandWithoutGenre(band, genreId));
  }

  Future<void> addRoleToMusician(String musicianId, String roleId) async {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (musician.roleIds.contains(roleId)) return;

    await updateMusician(
      Musician(
        id: musician.id,
        firstName: musician.firstName,
        lastName: musician.lastName,
        dateOfBirth: musician.dateOfBirth,
        descriptionText: musician.descriptionText,
        bandIds: musician.bandIds,
        roleIds: [...musician.roleIds, roleId],
      ),
    );
  }

  Future<void> removeRoleFromMusician(String musicianId, String roleId) async {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (!musician.roleIds.contains(roleId)) return;

    await updateMusician(_musicianWithoutRole(musician, roleId));
  }

  // ---------- Einträge löschen ----------
  // Ein Eintrag wird komplett entfernt, inklusive aller Stellen, an denen er bei einem anderen Eintrag verknüpft ist (z.B. eine gelöschte Band bei jedem ihrer Musiker, Alben und Songs).
  //
  // Änderung (Feedback "verknüpfte Updates nicht atomar" + "kein Rollback bei Schreibfehlern"):
  // Bei Kaskaden werden jetzt alle betroffenen Dokumente in einem WriteBatch gesammelt und zusammen committet (siehe _commitBatch), und die lokalen Listen werden erst nach erfolgreichem Commit angepasst.

  Future<void> deleteBand(String id) async {
    final List<Musician> betroffeneMusiker = musicians
        .where((m) => m.bandIds.contains(id))
        .map((m) => _musicianWithoutBand(m, id))
        .toList();
    final List<Album> betroffeneAlben = albums
        .where((a) => a.bandIds.contains(id))
        .map((a) => _albumWithoutBand(a, id))
        .toList();
    final List<Song> betroffeneSongs = songs
        .where((s) => s.bandIds.contains(id))
        .map((s) => _songWithoutBand(s, id))
        .toList();

    final bool success = await _commitBatch((batch) {
      for (final Musician m in betroffeneMusiker) {
        batch.set(_collection('musicians').doc(m.id), m.toMap());
      }
      for (final Album a in betroffeneAlben) {
        batch.set(_collection('albums').doc(a.id), a.toMap());
      }
      for (final Song s in betroffeneSongs) {
        batch.set(_collection('songs').doc(s.id), s.toMap());
      }
      batch.delete(_collection('bands').doc(id));
    });
    if (!success) return;

    for (final Musician m in betroffeneMusiker) {
      final int idx = musicians.indexWhere((x) => x.id == m.id);
      if (idx != -1) musicians[idx] = m;
    }
    for (final Album a in betroffeneAlben) {
      final int idx = albums.indexWhere((x) => x.id == a.id);
      if (idx != -1) albums[idx] = a;
    }
    for (final Song s in betroffeneSongs) {
      final int idx = songs.indexWhere((x) => x.id == s.id);
      if (idx != -1) songs[idx] = s;
    }
    bands.removeWhere((b) => b.id == id);
  }

  Future<void> deleteMusician(String id) async {
    if (await _write(() => _collection('musicians').doc(id).delete())) {
      musicians.removeWhere((m) => m.id == id);
    }
  }

  Future<void> deleteAlbum(String id) async {
    final List<Song> betroffeneSongs = songs
        .where((s) => s.albumIds.contains(id))
        .map((s) => _songWithoutAlbum(s, id))
        .toList();

    final bool success = await _commitBatch((batch) {
      for (final Song s in betroffeneSongs) {
        batch.set(_collection('songs').doc(s.id), s.toMap());
      }
      batch.delete(_collection('albums').doc(id));
    });
    if (!success) return;

    for (final Song s in betroffeneSongs) {
      final int idx = songs.indexWhere((x) => x.id == s.id);
      if (idx != -1) songs[idx] = s;
    }
    albums.removeWhere((a) => a.id == id);
  }

  Future<void> deleteSong(String id) async {
    if (await _write(() => _collection('songs').doc(id).delete())) {
      songs.removeWhere((s) => s.id == id);
    }
  }

  Future<void> deleteGenre(String id) async {
    final List<Band> betroffeneBands = bands
        .where((b) => b.genreIds.contains(id))
        .map((b) => _bandWithoutGenre(b, id))
        .toList();

    final bool success = await _commitBatch((batch) {
      for (final Band b in betroffeneBands) {
        batch.set(_collection('bands').doc(b.id), b.toMap());
      }
      batch.delete(_collection('genres').doc(id));
    });
    if (!success) return;

    for (final Band b in betroffeneBands) {
      final int idx = bands.indexWhere((x) => x.id == b.id);
      if (idx != -1) bands[idx] = b;
    }
    genres.removeWhere((g) => g.id == id);
  }

  Future<void> deleteRole(String id) async {
    final List<Musician> betroffeneMusiker = musicians
        .where((m) => m.roleIds.contains(id))
        .map((m) => _musicianWithoutRole(m, id))
        .toList();

    final bool success = await _commitBatch((batch) {
      for (final Musician m in betroffeneMusiker) {
        batch.set(_collection('musicians').doc(m.id), m.toMap());
      }
      batch.delete(_collection('roles').doc(id));
    });
    if (!success) return;

    for (final Musician m in betroffeneMusiker) {
      final int idx = musicians.indexWhere((x) => x.id == m.id);
      if (idx != -1) musicians[idx] = m;
    }
    roles.removeWhere((r) => r.id == id);
  }
}

// Ein Tipp von einem Kollegen der Flutter beruflich nutzt. Anstelle von DatabaseRepository.instance kann einfach nur der Term repo verwendet werden. Vereinfacht das Arbeiten im Code.

final DatabaseRepository repo = DatabaseRepository.instance;
