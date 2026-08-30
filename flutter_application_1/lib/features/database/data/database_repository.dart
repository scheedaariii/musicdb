// database_repository.dart
// Zuständig für die Firebase-Verknüpfung und das Management der Daten.
// Die Listen werden beim Start über load() aus Firestore gefüllt. Neu
// erfasste Einträge landen sofort in der jeweiligen Liste und werden im
// Hintergrund nach Firestore geschrieben.
//
// Verknüpfungen zwischen Einträgen (z.B. welche Bands ein Musiker hat)
// werden ausschliesslich über IDs gespeichert (bandIds, genreIds, ...).
// Es gibt nirgends eine zusätzlich gespeicherte Kopie eines Namens - der
// Name wird bei Bedarf immer frisch über die passende ...ById-Methode
// nachgeschlagen (siehe z.B. Musician.bandNames). Dadurch braucht eine
// Umbenennung (updateBand, updateGenre, ...) auch nirgends sonst
// nachgezogen zu werden: sie ändert nur das eine betroffene Dokument.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../app/app_messenger.dart';
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

  // Lädt die Daten aus Firestore. Wird beim App-Start einmal abgewartet,
  // bevor die Oberfläche erscheint.
  Future<void> load() async {
    if (_loaded) return;

    final QuerySnapshot<Map<String, dynamic>> bandsSnapshot =
        await _db.collection('bands').get();
    bands.addAll(
        bandsSnapshot.docs.map((doc) => Band.fromMap(doc.id, doc.data())));

    final QuerySnapshot<Map<String, dynamic>> musiciansSnapshot =
        await _db.collection('musicians').get();
    musicians.addAll(musiciansSnapshot.docs
        .map((doc) => Musician.fromMap(doc.id, doc.data())));

    final QuerySnapshot<Map<String, dynamic>> albumsSnapshot =
        await _db.collection('albums').get();
    albums.addAll(
        albumsSnapshot.docs.map((doc) => Album.fromMap(doc.id, doc.data())));

    final QuerySnapshot<Map<String, dynamic>> songsSnapshot =
        await _db.collection('songs').get();
    songs.addAll(
        songsSnapshot.docs.map((doc) => Song.fromMap(doc.id, doc.data())));

    final QuerySnapshot<Map<String, dynamic>> genresSnapshot =
        await _db.collection('genres').get();
    genres.addAll(
        genresSnapshot.docs.map((doc) => Genre.fromMap(doc.id, doc.data())));

    final QuerySnapshot<Map<String, dynamic>> rolesSnapshot =
        await _db.collection('roles').get();
    roles.addAll(
        rolesSnapshot.docs.map((doc) => Role.fromMap(doc.id, doc.data())));

    _loaded = true;
  }

  // Schreibt im Hintergrund nach Firestore, ohne dass die App darauf warten
  // muss. Schlägt der Schreibvorgang fehl (z.B. keine Internetverbindung),
  // bleibt die bereits lokal geänderte Ansicht bestehen - die Nutzerin/der
  // Nutzer wird aber per SnackBar informiert, statt dass der Fehler nur in
  // der Konsole landet und die Änderung unbemerkt verloren geht.
  void _write(Future<void> Function() write) {
    write().catchError((Object error) {
      debugPrint('Firestore-Schreibvorgang fehlgeschlagen: $error');
      appMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Speichern fehlgeschlagen. Bitte Internetverbindung prüfen.',
          ),
        ),
      );
    });
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

  // Name, Icon und Beschreibungstexte stehen bei CategoryKind selbst.
  // Das Repository steuert nur die aktuellen Einträge bei.
  DatabaseCategory categoryOf(CategoryKind kind) =>
      DatabaseCategory(kind: kind, entries: entriesOf(kind));

  List<DatabaseCategory> get categories =>
      CategoryKind.values.map(categoryOf).toList();

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
  // Wird gebraucht, wenn eine Detailseite eine Verknüpfung aus einem
  // Auswahlfeld (Namen) in einen Eintrag auflöst.

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

    // Album: beteiligte Bands und die Songs des Albums
    if (item is Album) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);

      _addSection(
          sections,
          gefundeneBands.length == 1 ? 'Band' : 'Bands',
          gefundeneBands);
      _addSection(
          sections, 'Songs', songs.where((s) => s.albumIds.contains(item.id)));
      return sections;
    }

    // Song: Beteiligte Bands und zugehörige Alben
    if (item is Song) {
      final List<Band> gefundeneBands = _bandsByIds(item.bandIds);
      final List<Album> gefundeneAlben =
          albums.where((a) => item.albumIds.contains(a.id)).toList();

      _addSection(
          sections,
          gefundeneBands.length == 1 ? 'Band' : 'Bands',
          gefundeneBands);
      _addSection(
          sections,
          gefundeneAlben.length == 1 ? 'Album' : 'Alben',
          gefundeneAlben);
      return sections;
    }

    // Genre: alle Bands mit diesem Genre
    if (item is Genre) {
      _addSection(sections, 'Bands mit diesem Genre',
          bands.where((b) => b.genreIds.contains(item.id)));
      return sections;
    }

    // Rolle: alle Musiker mit dieser Rolle
    if (item is Role) {
      _addSection(sections, 'Musiker mit dieser Rolle',
          musicians.where((m) => m.roleIds.contains(item.id)));
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

  void addBand({
    required String title,
    List<String> genreIds = const [],
    String founded = '',
    String origin = '',
    String descriptionText = '',
  }) {
    final doc = _db.collection('bands').doc();
    final Band band = Band(
      id: doc.id,
      title: title,
      genreIds: genreIds,
      founded: founded,
      origin: origin,
      descriptionText: descriptionText,
    );
    bands.add(band);
    _write(() => doc.set(band.toMap()));
  }

  void addMusician({
    required String firstName,
    required String lastName,
    String dateOfBirth = '',
    List<String> bandIds = const [],
    List<String> roleIds = const [],
    String descriptionText = '',
  }) {
    final doc = _db.collection('musicians').doc();
    final Musician musician = Musician(
      id: doc.id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      bandIds: bandIds,
      roleIds: roleIds,
      descriptionText: descriptionText,
    );
    musicians.add(musician);
    _write(() => doc.set(musician.toMap()));
  }

  void addAlbum({
    required String title,
    List<String> bandIds = const [],
    List<String> genreIds = const [],
    String releaseDate = '',
    String descriptionText = '',
  }) {
    final doc = _db.collection('albums').doc();
    final Album album = Album(
      id: doc.id,
      title: title,
      bandIds: bandIds,
      genreIds: genreIds,
      releaseDate: releaseDate,
      descriptionText: descriptionText,
    );
    albums.add(album);
    _write(() => doc.set(album.toMap()));
  }

  void addSong({
    required String title,
    int durationSeconds = 0,
    List<String> albumIds = const [],
    List<String> bandIds = const [],
    String releaseDate = '',
    String descriptionText = '',
  }) {
    final doc = _db.collection('songs').doc();
    final Song song = Song(
      id: doc.id,
      title: title,
      durationSeconds: durationSeconds,
      albumIds: albumIds,
      bandIds: bandIds,
      releaseDate: releaseDate,
      descriptionText: descriptionText,
    );
    songs.add(song);
    _write(() => doc.set(song.toMap()));
  }

  void addGenre({required String title, String descriptionText = ''}) {
    final doc = _db.collection('genres').doc();
    final Genre genre = Genre(
      id: doc.id,
      title: title,
      descriptionText: descriptionText,
    );
    genres.add(genre);
    _write(() => doc.set(genre.toMap()));
  }

  void addRole({required String title, String descriptionText = ''}) {
    final doc = _db.collection('roles').doc();
    final Role role = Role(
      id: doc.id,
      title: title,
      descriptionText: descriptionText,
    );
    roles.add(role);
    _write(() => doc.set(role.toMap()));
  }

 // ---------- Bestehende Einträge ändern ----------

  void updateBand(Band band) {
    final int index = bands.indexWhere((b) => b.id == band.id);
    if (index == -1) return;
    bands[index] = band;
    _write(() => _db.collection('bands').doc(band.id).set(band.toMap()));
  }

  void updateMusician(Musician musician) {
    final int index = musicians.indexWhere((m) => m.id == musician.id);
    if (index == -1) return;
    musicians[index] = musician;
    _write(() =>
        _db.collection('musicians').doc(musician.id).set(musician.toMap()));
  }

  void updateAlbum(Album album) {
    final int index = albums.indexWhere((a) => a.id == album.id);
    if (index == -1) return;
    albums[index] = album;
    _write(() => _db.collection('albums').doc(album.id).set(album.toMap()));
  }

  void updateSong(Song song) {
    final int index = songs.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    songs[index] = song;
    _write(() => _db.collection('songs').doc(song.id).set(song.toMap()));
  }

  void updateGenre(Genre genre) {
    final int index = genres.indexWhere((g) => g.id == genre.id);
    if (index == -1) return;
    genres[index] = genre;
    _write(() => _db.collection('genres').doc(genre.id).set(genre.toMap()));
  }

  void updateRole(Role role) {
    final int index = roles.indexWhere((r) => r.id == role.id);
    if (index == -1) return;
    roles[index] = role;
    _write(() => _db.collection('roles').doc(role.id).set(role.toMap()));
  }

// ---------- Verknüpfungen auf beiden Seiten ändern ----------
  // Eine Detailseite kann eine Verknüpfung zeigen, die als Feld beim jeweils anderen Eintrag gespeichert ist (z.B. zeigt eine Band ihre Songs, aber die Verknüpfung liegt in Song.bandIds). Ich hatte bei Tests diese inkonsistenz entdeckt. Um das sauber umzusetzten musste ich AI zur Hilfe nehmen.


  void addBandToMusician(String musicianId, String bandId) {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (musician.bandIds.contains(bandId)) return;

    updateMusician(Musician(
      id: musician.id,
      firstName: musician.firstName,
      lastName: musician.lastName,
      dateOfBirth: musician.dateOfBirth,
      descriptionText: musician.descriptionText,
      roleIds: musician.roleIds,
      bandIds: [...musician.bandIds, bandId],
    ));
  }

  void removeBandFromMusician(String musicianId, String bandId) {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (!musician.bandIds.contains(bandId)) return;

    updateMusician(Musician(
      id: musician.id,
      firstName: musician.firstName,
      lastName: musician.lastName,
      dateOfBirth: musician.dateOfBirth,
      descriptionText: musician.descriptionText,
      roleIds: musician.roleIds,
      bandIds: musician.bandIds.where((id) => id != bandId).toList(),
    ));
  }

  void addBandToAlbum(String albumId, String bandId) {
    final Album? album = albumById(albumId);
    if (album == null) return;
    if (album.bandIds.contains(bandId)) return;

    updateAlbum(Album(
      id: album.id,
      title: album.title,
      genreIds: album.genreIds,
      releaseDate: album.releaseDate,
      descriptionText: album.descriptionText,
      bandIds: [...album.bandIds, bandId],
    ));
  }

  void removeBandFromAlbum(String albumId, String bandId) {
    final Album? album = albumById(albumId);
    if (album == null) return;
    if (!album.bandIds.contains(bandId)) return;

    updateAlbum(Album(
      id: album.id,
      title: album.title,
      genreIds: album.genreIds,
      releaseDate: album.releaseDate,
      descriptionText: album.descriptionText,
      bandIds: album.bandIds.where((id) => id != bandId).toList(),
    ));
  }

  void addBandToSong(String songId, String bandId) {
    final Song? song = songById(songId);
    if (song == null) return;
    if (song.bandIds.contains(bandId)) return;

    updateSong(Song(
      id: song.id,
      title: song.title,
      durationSeconds: song.durationSeconds,
      releaseDate: song.releaseDate,
      descriptionText: song.descriptionText,
      albumIds: song.albumIds,
      bandIds: [...song.bandIds, bandId],
    ));
  }

  void removeBandFromSong(String songId, String bandId) {
    final Song? song = songById(songId);
    if (song == null) return;
    if (!song.bandIds.contains(bandId)) return;

    updateSong(Song(
      id: song.id,
      title: song.title,
      durationSeconds: song.durationSeconds,
      releaseDate: song.releaseDate,
      descriptionText: song.descriptionText,
      albumIds: song.albumIds,
      bandIds: song.bandIds.where((id) => id != bandId).toList(),
    ));
  }

  void addAlbumToSong(String songId, String albumId) {
    final Song? song = songById(songId);
    if (song == null) return;
    if (song.albumIds.contains(albumId)) return;

    updateSong(Song(
      id: song.id,
      title: song.title,
      durationSeconds: song.durationSeconds,
      releaseDate: song.releaseDate,
      descriptionText: song.descriptionText,
      bandIds: song.bandIds,
      albumIds: [...song.albumIds, albumId],
    ));
  }

  void removeAlbumFromSong(String songId, String albumId) {
    final Song? song = songById(songId);
    if (song == null) return;
    if (!song.albumIds.contains(albumId)) return;

    updateSong(Song(
      id: song.id,
      title: song.title,
      durationSeconds: song.durationSeconds,
      releaseDate: song.releaseDate,
      descriptionText: song.descriptionText,
      bandIds: song.bandIds,
      albumIds: song.albumIds.where((id) => id != albumId).toList(),
    ));
  }

  void addGenreToBand(String bandId, String genreId) {
    final Band? band = bandById(bandId);
    if (band == null) return;
    if (band.genreIds.contains(genreId)) return;

    updateBand(Band(
      id: band.id,
      title: band.title,
      origin: band.origin,
      founded: band.founded,
      descriptionText: band.descriptionText,
      genreIds: [...band.genreIds, genreId],
    ));
  }

  void removeGenreFromBand(String bandId, String genreId) {
    final Band? band = bandById(bandId);
    if (band == null) return;
    if (!band.genreIds.contains(genreId)) return;

    updateBand(Band(
      id: band.id,
      title: band.title,
      origin: band.origin,
      founded: band.founded,
      descriptionText: band.descriptionText,
      genreIds: band.genreIds.where((id) => id != genreId).toList(),
    ));
  }

  void addRoleToMusician(String musicianId, String roleId) {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (musician.roleIds.contains(roleId)) return;

    updateMusician(Musician(
      id: musician.id,
      firstName: musician.firstName,
      lastName: musician.lastName,
      dateOfBirth: musician.dateOfBirth,
      descriptionText: musician.descriptionText,
      bandIds: musician.bandIds,
      roleIds: [...musician.roleIds, roleId],
    ));
  }

  void removeRoleFromMusician(String musicianId, String roleId) {
    final Musician? musician = musicianById(musicianId);
    if (musician == null) return;
    if (!musician.roleIds.contains(roleId)) return;

    updateMusician(Musician(
      id: musician.id,
      firstName: musician.firstName,
      lastName: musician.lastName,
      dateOfBirth: musician.dateOfBirth,
      descriptionText: musician.descriptionText,
      bandIds: musician.bandIds,
      roleIds: musician.roleIds.where((id) => id != roleId).toList(),
    ));
  }

  // ---------- Einträge löschen ----------
  // Ein Eintrag wird komplett entfernt, inklusive aller Stellen, an denen er bei einem anderen Eintrag verknüpft ist (z.B. eine gelöschte Band bei jedem ihrer Musiker, Alben und Songs). 

  void deleteBand(String id) {
    for (final Musician musician in [...musicians]) {
      if (musician.bandIds.contains(id)) {
        removeBandFromMusician(musician.id, id);
      }
    }
    for (final Album album in [...albums]) {
      if (album.bandIds.contains(id)) removeBandFromAlbum(album.id, id);
    }
    for (final Song song in [...songs]) {
      if (song.bandIds.contains(id)) removeBandFromSong(song.id, id);
    }

    bands.removeWhere((b) => b.id == id);
    _write(() => _db.collection('bands').doc(id).delete());
  }

  void deleteMusician(String id) {
    musicians.removeWhere((m) => m.id == id);
    _write(() => _db.collection('musicians').doc(id).delete());
  }

  void deleteAlbum(String id) {
    for (final Song song in [...songs]) {
      if (song.albumIds.contains(id)) removeAlbumFromSong(song.id, id);
    }

    albums.removeWhere((a) => a.id == id);
    _write(() => _db.collection('albums').doc(id).delete());
  }

  void deleteSong(String id) {
    songs.removeWhere((s) => s.id == id);
    _write(() => _db.collection('songs').doc(id).delete());
  }

  void deleteGenre(String id) {
    for (final Band band in [...bands]) {
      if (band.genreIds.contains(id)) removeGenreFromBand(band.id, id);
    }

    genres.removeWhere((g) => g.id == id);
    _write(() => _db.collection('genres').doc(id).delete());
  }

  void deleteRole(String id) {
    for (final Musician musician in [...musicians]) {
      if (musician.roleIds.contains(id)) {
        removeRoleFromMusician(musician.id, id);
      }
    }

    roles.removeWhere((r) => r.id == id);
    _write(() => _db.collection('roles').doc(id).delete());
  }
}

// Ein Tipp von einem Kollegen der Flutter beruflich nutzt. Antelle von DatabaseRepository.instance kan einfach nur der Term repo verwendet werden. Vereinfacht das Arbeiten im Code.
final DatabaseRepository repo = DatabaseRepository.instance;
