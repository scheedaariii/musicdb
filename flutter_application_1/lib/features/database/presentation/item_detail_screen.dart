// item_detail_screen.dart
// Zeigt die Detailinformationen eines einzelnen Eintrags an und erlaubt es,
// ihn zu bearbeiten. Funktioniert für alle Kategorien gleich: Band, Musiker,
// Album, Song, Genre und Rolle liefern über die Schnittstelle DatabaseItem
// ihre eigenen Felder, dieser Screen stellt sie einheitlich dar.
//
// Der Stift-Button oben schaltet die Seite in den Bearbeitungsmodus, auch
// der Name/Titel ist editierbar. Verknüpfungen sind überall nur über IDs
// gespeichert (siehe die Modelle in domain/), nirgends liegt eine Kopie
// eines Namens - eine Umbenennung ändert daher immer nur das eine
// betroffene Dokument, ohne dass an anderer Stelle etwas nachgezogen
// werden müsste. Sobald etwas geändert wurde, erscheint der Speichern-
// Button.
//
// Verknüpfungen, die auf der Detailseite nur als Liste erscheinen (z.B.
// die Songs einer Band), werden nicht bei der Band selbst gespeichert,
// sondern beim jeweils anderen Eintrag (Song.bandIds). Deshalb schreibt
// das Speichern in diesen Fällen auch den anderen Eintrag zurück.

import 'package:flutter/material.dart';
import '../data/database_repository.dart';
import '../domain/album.dart';
import '../domain/band.dart';
import '../domain/database_item.dart';
import '../domain/genre.dart';
import '../domain/info_field.dart';
import '../domain/musician.dart';
import '../domain/related_section.dart';
import '../domain/role.dart';
import '../domain/song.dart';
import 'database_widgets.dart';
import 'form_widgets.dart';
import '../../../app/app_bottom_nav.dart';
import '../../../app/app_colors.dart';

class ItemDetailScreen extends StatefulWidget {
  // Der ausgewählte Eintrag wird beim Öffnen des Screens übergeben
  final DatabaseItem item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _editing = false;
  bool _dirty = false;

  bool _populating = false;

  // Änderung (Feedback "keine WriteSperren"): wird während eines laufenden Speicher- oder Löschvorgangs auf true gesetzt und sperrt so lange die Speichern-/Bearbeiten-/ Löschen-Buttons. Verhindert doppeltes auslösen.

  bool _saving = false;

  // Der aktuelle Stand des Eintrags. Wird nach dem Speichern neu aus dem Repository geholt, damit die Seite sofort den neuen Stand zeigt.

  late DatabaseItem _item = widget.item;

  // Eingabefelder für den Bearbeitungsmodus - Name/Titel: bei Band, Album, Song, Genre und Rolle

  final TextEditingController _titleField = TextEditingController();
  // Vor- und Nachname: nur bei Musikern 
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _foundedYear = TextEditingController();
  final TextEditingController _origin = TextEditingController();
  final TextEditingController _durationSeconds = TextEditingController();
  final TextEditingController _description = TextEditingController();
  // Für das eine Datumsfeld, das eine Kategorie jeweils braucht 
  String _dateValue = '';

  // Eigene Mehrfachauswahlen (direkt beim Eintrag gespeichert). 

  final List<String> _genreSelection = [];
  final List<String> _bandSelection = [];
  final List<String> _roleSelection = [];
  final List<String> _albumSelection = [];

  // Verknüpfungen, die eigentlich beim jeweils anderen Eintrag gespeichert sind (z.B. die Musiker einer Band liegen in Musician.bandIds)

  final List<String> _relatedBandSelection = [];
  final List<String> _relatedMusicianSelection = [];
  final List<String> _relatedAlbumSelection = [];
  final List<String> _relatedSongSelection = [];

  @override
  void initState() {
    super.initState();
    _titleField.addListener(_markDirty);
    _firstName.addListener(_markDirty);
    _lastName.addListener(_markDirty);
    _foundedYear.addListener(_markDirty);
    _origin.addListener(_markDirty);
    _durationSeconds.addListener(_markDirty);
    _description.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleField.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _foundedYear.dispose();
    _origin.dispose();
    _durationSeconds.dispose();
    _description.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_populating || _dirty) return;
    setState(() => _dirty = true);
  }

  //  Bearbeitungsmodus starten (Bearbeiten drücken)

  void _startEditing() {
    final DatabaseItem item = _item;
    _populating = true;

    _titleField.clear();
    _firstName.clear();
    _lastName.clear();
    _foundedYear.clear();
    _origin.clear();
    _durationSeconds.clear();
    _description.text = _descriptionTextOf(item);
    _dateValue = '';
    _genreSelection.clear();
    _bandSelection.clear();
    _roleSelection.clear();
    _albumSelection.clear();
    _relatedBandSelection.clear();
    _relatedMusicianSelection.clear();
    _relatedAlbumSelection.clear();
    _relatedSongSelection.clear();

    if (item is Band) {
      _titleField.text = item.title;
      _foundedYear.text = item.founded;
      _origin.text = item.origin;
      _genreSelection.addAll(item.genreNames);
      _relatedMusicianSelection.addAll(repo.musicians
          .where((m) => m.bandIds.contains(item.id))
          .map((m) => m.title));
      _relatedAlbumSelection.addAll(repo.albums
          .where((a) => a.bandIds.contains(item.id))
          .map((a) => a.title));
      _relatedSongSelection.addAll(repo.songs
          .where((s) => s.bandIds.contains(item.id))
          .map((s) => s.title));
    } else if (item is Musician) {
      _firstName.text = item.firstName;
      _lastName.text = item.lastName;
      _dateValue = item.dateOfBirth;
      _bandSelection.addAll(item.bandNames);
      _roleSelection.addAll(item.roleNames);
    } else if (item is Album) {
      _titleField.text = item.title;
      _dateValue = item.releaseDate;
      _bandSelection.addAll(item.bandNames);
      _genreSelection.addAll(item.genreNames);
      _relatedSongSelection.addAll(repo.songs
          .where((s) => s.albumIds.contains(item.id))
          .map((s) => s.title));
    } else if (item is Song) {
      _titleField.text = item.title;
      _dateValue = item.releaseDate;
      _durationSeconds.text =
          item.durationSeconds > 0 ? item.durationSeconds.toString() : '';
      _albumSelection.addAll(item.albumNames);
      _bandSelection.addAll(item.bandNames);
    } else if (item is Genre) {
      _titleField.text = item.title;
      _relatedBandSelection.addAll(repo.bands
          .where((b) => b.genreIds.contains(item.id))
          .map((b) => b.title));
    } else if (item is Role) {
      _titleField.text = item.title;
      _relatedMusicianSelection.addAll(repo.musicians
          .where((m) => m.roleIds.contains(item.id))
          .map((m) => m.title));
    }

    _populating = false;
    setState(() => _editing = true);
  }

  String _descriptionTextOf(DatabaseItem item) {
    if (item is Band) return item.descriptionText;
    if (item is Musician) return item.descriptionText;
    if (item is Album) return item.descriptionText;
    if (item is Song) return item.descriptionText;
    if (item is Genre) return item.descriptionText;
    if (item is Role) return item.descriptionText;
    return '';
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _dirty = false;
    });
  }

  // ---------- Löschen ----------

  Future<void> _confirmDelete() async {
    final bool? bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: const Text(
          'Wollen Sie den Eintrag wirklich löschen? '
          'Das Element wird komplett gelöscht!',
          style: TextStyle(fontSize: 15, color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Abbrechen',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Löschen',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (bestaetigt != true) return;
    _delete();
  }

  // Löscht den Eintrag überall, auch bei jedem anderen Eintrag, der auf ihn verweist (siehe die delete-Methoden im Repository). Danach gibt es nichts mehr anzuzeigen, also wird die Seite direkt geschlossen.
  // Änderung nach feedback: async, wartet jetzt die jeweilige repo.deleteX()-Methode ab (die selbst erst nach erfolgreichem Firestore-Schreibvorgang die lokalen Listen ändert) und sperrt währenddessen über _saving die Buttons. Die Seite wird erst nach Abschluss geschlossen.

  Future<void> _delete() async {
    if (_saving) return;
    setState(() => _saving = true);

    final DatabaseItem item = _item;

    if (item is Band) {
      await repo.deleteBand(item.id);
    } else if (item is Musician) {
      await repo.deleteMusician(item.id);
    } else if (item is Album) {
      await repo.deleteAlbum(item.id);
    } else if (item is Song) {
      await repo.deleteSong(item.id);
    } else if (item is Genre) {
      await repo.deleteGenre(item.id);
    } else if (item is Role) {
      await repo.deleteRole(item.id);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ---------- Speichern ----------

  // Prüft Pflichtfelder, bevor gespeichert wird: der Name (bzw. Vor- und Nachname bei Musikern) darf nie leer sein, und das Geburtsdatum bei Musikern darf auch beim Bearbeiten nicht entfernt werden.

  void _onSave() {
    if (_item is Musician) {
      if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
        _showMessage('Bitte Vor- und Nachname angeben!');
        return;
      }
      if (_dateValue.isEmpty) {
        _showMessage('Bitte das Geburtsdatum angeben!');
        return;
      }
    } else if (_titleField.text.trim().isEmpty) {
      _showMessage('Bitte einen Namen angeben!');
      return;
    }

    if (!_isNameUnique()) {
      _showMessage('Eintrag ist nicht einzigartig, bitte anpassen!');
      return;
    }

    _save();
  }

  // Änderung nach feeback: _onSave bleibt synchron (die Prüfungen oben brauchen kein await), ruft aber _save() jetzt "fire-and-forget" auf - _save selbst kümmert sich über _saving um die
  // Button-Sperre und wartet den kompletten Speichervorgang inkl. aller Verknüpfungen ab. Prüft, ob der (neue) Name schon bei einem anderen Eintrag derselben Kategorie vorkommt. 

  bool _isNameUnique() {
    final DatabaseItem item = _item;

    if (item is Band) {
      final String neuerTitel = _titleField.text.trim();
      return !repo.bands.any((b) =>
          b.id != item.id &&
          b.title.toLowerCase() == neuerTitel.toLowerCase());
    }
    if (item is Musician) {
      final String vorname = _firstName.text.trim();
      final String nachname = _lastName.text.trim();
      return !repo.musicians.any((m) =>
          m.id != item.id &&
          m.firstName.toLowerCase() == vorname.toLowerCase() &&
          m.lastName.toLowerCase() == nachname.toLowerCase());
    }
    if (item is Album) {
      final String neuerTitel = _titleField.text.trim();
      return !repo.albums.any((a) =>
          a.id != item.id &&
          a.title.toLowerCase() == neuerTitel.toLowerCase());
    }
    if (item is Song) {
      final String neuerTitel = _titleField.text.trim();
      return !repo.songs.any((s) =>
          s.id != item.id &&
          s.title.toLowerCase() == neuerTitel.toLowerCase());
    }
    if (item is Genre) {
      final String neuerName = _titleField.text.trim();
      return !repo.genres.any((g) =>
          g.id != item.id && g.title.toLowerCase() == neuerName.toLowerCase());
    }
    if (item is Role) {
      final String neuerName = _titleField.text.trim();
      return !repo.roles.any((r) =>
          r.id != item.id && r.title.toLowerCase() == neuerName.toLowerCase());
    }
    return true;
  }

  void _showMessage(String text) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          text,
          style: const TextStyle(fontSize: 15, color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Änderung (Feedback "kein Rollback bei Schreibfehlern" + "keine WriteSperren"): _save ist jetzt async und wartet jede repo.updateX()/repo.addXToY()-Aufruf ab.
  // Während des gesamten Vorgangs sperrt _saving den Speichern-Button.

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final DatabaseItem item = _item;

    if (item is Band) {
      await repo.updateBand(Band(
        id: item.id,
        title: _titleField.text.trim(),
        genreIds: repo.idsForGenreNames(_genreSelection),
        founded: _foundedYear.text.trim(),
        origin: _origin.text.trim(),
        descriptionText: _description.text.trim(),
      ));

      await _syncReverse(
        before: repo.musicians
            .where((m) => m.bandIds.contains(item.id))
            .map((m) => m.title)
            .toSet(),
        after: _relatedMusicianSelection,
        onAdd: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          return musician == null
              ? null
              : repo.addBandToMusician(musician.id, item.id);
        },
        onRemove: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          return musician == null
              ? null
              : repo.removeBandFromMusician(musician.id, item.id);
        },
      );

      await _syncReverse(
        before: repo.albums
            .where((a) => a.bandIds.contains(item.id))
            .map((a) => a.title)
            .toSet(),
        after: _relatedAlbumSelection,
        onAdd: (title) {
          final Album? album = repo.albumByTitle(title);
          return album == null
              ? null
              : repo.addBandToAlbum(album.id, item.id);
        },
        onRemove: (title) {
          final Album? album = repo.albumByTitle(title);
          return album == null
              ? null
              : repo.removeBandFromAlbum(album.id, item.id);
        },
      );

      await _syncReverse(
        before: repo.songs
            .where((s) => s.bandIds.contains(item.id))
            .map((s) => s.title)
            .toSet(),
        after: _relatedSongSelection,
        onAdd: (title) {
          final Song? song = repo.songByTitle(title);
          return song == null ? null : repo.addBandToSong(song.id, item.id);
        },
        onRemove: (title) {
          final Song? song = repo.songByTitle(title);
          return song == null
              ? null
              : repo.removeBandFromSong(song.id, item.id);
        },
      );

      _item = repo.bandById(item.id) ?? item;
    } else if (item is Musician) {
      await repo.updateMusician(Musician(
        id: item.id,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        dateOfBirth: _dateValue,
        bandIds: repo.idsForBandNames(_bandSelection),
        roleIds: repo.idsForRoleNames(_roleSelection),
        descriptionText: _description.text.trim(),
      ));
      _item = repo.musicianById(item.id) ?? item;
    } else if (item is Album) {
      await repo.updateAlbum(Album(
        id: item.id,
        title: _titleField.text.trim(),
        bandIds: repo.idsForBandNames(_bandSelection),
        genreIds: repo.idsForGenreNames(_genreSelection),
        releaseDate: _dateValue,
        descriptionText: _description.text.trim(),
      ));

      await _syncReverse(
        before: repo.songs
            .where((s) => s.albumIds.contains(item.id))
            .map((s) => s.title)
            .toSet(),
        after: _relatedSongSelection,
        onAdd: (title) {
          final Song? song = repo.songByTitle(title);
          return song == null ? null : repo.addAlbumToSong(song.id, item.id);
        },
        onRemove: (title) {
          final Song? song = repo.songByTitle(title);
          return song == null
              ? null
              : repo.removeAlbumFromSong(song.id, item.id);
        },
      );

      _item = repo.albumById(item.id) ?? item;
    } else if (item is Song) {
      await repo.updateSong(Song(
        id: item.id,
        title: _titleField.text.trim(),
        durationSeconds: int.tryParse(_durationSeconds.text.trim()) ?? 0,
        albumIds: repo.idsForAlbumNames(_albumSelection),
        bandIds: repo.idsForBandNames(_bandSelection),
        releaseDate: _dateValue,
        descriptionText: _description.text.trim(),
      ));
      _item = repo.songById(item.id) ?? item;
    } else if (item is Genre) {
      await repo.updateGenre(Genre(
        id: item.id,
        title: _titleField.text.trim(),
        descriptionText: _description.text.trim(),
      ));

      await _syncReverse(
        before: repo.bands
            .where((b) => b.genreIds.contains(item.id))
            .map((b) => b.title)
            .toSet(),
        after: _relatedBandSelection,
        onAdd: (title) {
          final Band? band = repo.bandByTitle(title);
          return band == null ? null : repo.addGenreToBand(band.id, item.id);
        },
        onRemove: (title) {
          final Band? band = repo.bandByTitle(title);
          return band == null
              ? null
              : repo.removeGenreFromBand(band.id, item.id);
        },
      );

      _item = repo.genreById(item.id) ?? item;
    } else if (item is Role) {
      await repo.updateRole(Role(
        id: item.id,
        title: _titleField.text.trim(),
        descriptionText: _description.text.trim(),
      ));

      await _syncReverse(
        before: repo.musicians
            .where((m) => m.roleIds.contains(item.id))
            .map((m) => m.title)
            .toSet(),
        after: _relatedMusicianSelection,
        onAdd: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          return musician == null
              ? null
              : repo.addRoleToMusician(musician.id, item.id);
        },
        onRemove: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          return musician == null
              ? null
              : repo.removeRoleFromMusician(musician.id, item.id);
        },
      );

      _item = repo.roleById(item.id) ?? item;
    }

    if (!mounted) return;
    setState(() {
      _editing = false;
      _dirty = false;
      _saving = false;
    });
  }

  // Vergleicht die ursprüngliche mit der aktuell gewählten Auswahl und ruft für jede Änderung die passende Funktion auf.
  // Änderung nach Feedback: async - onAdd/onRemove liefern jetzt ein Future<void>? zurück und alle ausgelösten Schreibvorgänge werden hier gesammelt und gemeinsam abgewartet.

  Future<void> _syncReverse({
    required Set<String> before,
    required List<String> after,
    required Future<void>? Function(String title) onAdd,
    required Future<void>? Function(String title) onRemove,
  }) async {
    final Set<String> afterSet = after.toSet();
    final List<Future<void>> laufendeSchreibvorgaenge = [];

    for (final String title in afterSet) {
      if (!before.contains(title)) {
        final Future<void>? future = onAdd(title);
        if (future != null) laufendeSchreibvorgaenge.add(future);
      }
    }
    for (final String title in before) {
      if (!afterSet.contains(title)) {
        final Future<void>? future = onRemove(title);
        if (future != null) laufendeSchreibvorgaenge.add(future);
      }
    }

    await Future.wait(laufendeSchreibvorgaenge);
  }

  Future<void> _pickDate() async {
    final DateTime? gewaehlt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (gewaehlt == null) return;

    setState(() {
      _dateValue = '${gewaehlt.year.toString().padLeft(4, '0')}-'
          '${gewaehlt.month.toString().padLeft(2, '0')}-'
          '${gewaehlt.day.toString().padLeft(2, '0')}';
    });
    _markDirty();
  }

  // ---------- Die Eingabefelder je nach Kategorie ----------

  List<Widget> _buildEditableFields(DatabaseItem item) {
    if (item is Band) {
      return [
        FormTextField(label: 'Name', controller: _titleField, required: true),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Gründungsjahr',
          controller: _foundedYear,
          numbersOnly: true,
          maxLength: 4,
          hintText: 'JJJJ',
        ),
        const SizedBox(height: 16),
        FormTextField(label: 'Herkunft', controller: _origin),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Genre',
          options: repo.genreNames,
          selected: _genreSelection,
          onAdd: (wert) {
            setState(() => _genreSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _genreSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Musiker',
          options: repo.musicians.map((m) => m.title).toList(),
          selected: _relatedMusicianSelection,
          onAdd: (wert) {
            setState(() => _relatedMusicianSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedMusicianSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Alben',
          options: repo.albumNames,
          selected: _relatedAlbumSelection,
          onAdd: (wert) {
            setState(() => _relatedAlbumSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedAlbumSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Songs',
          options: repo.songs.map((s) => s.title).toList(),
          selected: _relatedSongSelection,
          onAdd: (wert) {
            setState(() => _relatedSongSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedSongSelection.remove(wert));
            _markDirty();
          },
        ),
      ];
    }

    if (item is Musician) {
      return [
        FormTextField(label: 'Vorname', controller: _firstName, required: true),
        const SizedBox(height: 16),
        FormTextField(label: 'Nachname', controller: _lastName, required: true),
        const SizedBox(height: 16),
        FormDateField(
          label: 'Geburtsdatum',
          required: true,
          value: _dateValue,
          onTap: _pickDate,
          onClear: () {
            setState(() => _dateValue = '');
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Bands',
          options: repo.bandNames,
          selected: _bandSelection,
          onAdd: (wert) {
            setState(() => _bandSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _bandSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Rolle',
          options: repo.roleNames,
          selected: _roleSelection,
          onAdd: (wert) {
            setState(() => _roleSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _roleSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
      ];
    }

    if (item is Album) {
      return [
        FormTextField(label: 'Titel', controller: _titleField, required: true),
        const SizedBox(height: 16),
        FormDateField(
          label: 'Release Datum',
          value: _dateValue,
          onTap: _pickDate,
          onClear: () {
            setState(() => _dateValue = '');
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Bands',
          options: repo.bandNames,
          selected: _bandSelection,
          onAdd: (wert) {
            setState(() => _bandSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _bandSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Genre',
          options: repo.genreNames,
          selected: _genreSelection,
          onAdd: (wert) {
            setState(() => _genreSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _genreSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Songs',
          options: repo.songs.map((s) => s.title).toList(),
          selected: _relatedSongSelection,
          onAdd: (wert) {
            setState(() => _relatedSongSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedSongSelection.remove(wert));
            _markDirty();
          },
        ),
      ];
    }

    if (item is Song) {
      return [
        FormTextField(label: 'Titel', controller: _titleField, required: true),
        const SizedBox(height: 16),
        FormDateField(
          label: 'Release Datum',
          value: _dateValue,
          onTap: _pickDate,
          onClear: () {
            setState(() => _dateValue = '');
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Albums',
          options: repo.albumNames,
          selected: _albumSelection,
          onAdd: (wert) {
            setState(() => _albumSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _albumSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Bands',
          options: repo.bandNames,
          selected: _bandSelection,
          onAdd: (wert) {
            setState(() => _bandSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _bandSelection.remove(wert));
            _markDirty();
          },
        ),
        const SizedBox(height: 16),
        FormTextField(
          label: 'Dauer',
          controller: _durationSeconds,
          numbersOnly: true,
          hintText: 'in Sekunden',
        ),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
      ];
    }

    if (item is Genre) {
      return [
        FormTextField(label: 'Name', controller: _titleField, required: true),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Bands',
          options: repo.bandNames,
          selected: _relatedBandSelection,
          onAdd: (wert) {
            setState(() => _relatedBandSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedBandSelection.remove(wert));
            _markDirty();
          },
        ),
      ];
    }

    if (item is Role) {
      return [
        FormTextField(label: 'Name', controller: _titleField, required: true),
        const SizedBox(height: 16),
        FormTextField(
            label: 'Beschreibung', controller: _description, maxLines: 4),
        const SizedBox(height: 16),
        FormFilterableMultiSelect(
          label: 'Musiker',
          options: repo.musicians.map((m) => m.title).toList(),
          selected: _relatedMusicianSelection,
          onAdd: (wert) {
            setState(() => _relatedMusicianSelection.add(wert));
            _markDirty();
          },
          onRemove: (wert) {
            setState(() => _relatedMusicianSelection.remove(wert));
            _markDirty();
          },
        ),
      ];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseItem item = _item;
    final List<RelatedSection> sections =
        _editing ? const [] : repo.relatedFor(item);

    return Scaffold(
      // AppBar zeigt den Namen des Eintrags als Titel
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          if (_editing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Abbrechen',
              onPressed: _cancelEditing,
            ),
        ],
      ),

      // Scrollbarer Body um längere Listen anzuzeigen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit Icon und Name, unabhängig vom Bearbeitungsmodus. Bei Musikern zeigt der Header das Alter statt der Bands, da die Bands bereits in der eigenen Liste weiter unten stehen.
            DetailHeader(
              icon: item.icon,
              title: item.title,
              subtitle: item is Musician ? item.alterText : item.subtitle,
            ),

            const SizedBox(height: 20),

            if (_editing) ...[
              SectionTitle(text: '${item.title} bearbeiten'),
              const SizedBox(height: 12),
              ..._buildEditableFields(item),
              // Platz, damit der Speichern-Button nichts verdeckt
              const SizedBox(height: 80),
            ] else ...[
              // Die Info-Felder des Eintrags
              for (final InfoField field in item.infoFields) ...[
                InfoBox(field: field),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),

              SectionTitle(text: 'Über ${item.title}'),

              const SizedBox(height: 12),

              // Beschreibungstext des Eintrags
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.text,
                  height: 1.6,
                ),
              ),

              // Verknüpfte Einträge, jeweils als eigener Abschnitt
              for (final RelatedSection section in sections) ...[
                const SizedBox(height: 24),

                SectionTitle(text: section.label),

                const SizedBox(height: 12),

                for (final DatabaseItem related in section.items) ...[
                  ItemRow(
                    item: related,
                    onReturn: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              const SizedBox(height: 24),
            ],
          ],
        ),
      ),

      // Im Bearbeitungsmodus nur der Speichern-Button, sobald sich etwas geändert hat. Ausserhalb davon Bearbeiten und Löschen nebeneinander. Hier gibt es noch einen Bug dass das Anklicken eines Felder bereits als Änderung gewertet wird.
      //
      // Änderung (Feedback "keine WriteSperren"): onPressed ist während _saving jeweils null, damit während eines laufenden Speicher-/Löschvorgangs kein zweiter Klick einen weiteren Schreibvorgang auslösen kann.

      floatingActionButton: _editing
          ? (_dirty
              ? FloatingActionButton.extended(
                  onPressed: _saving ? null : _onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Speichern'),
                  shape: const StadiumBorder(),
                )
              : null)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'bearbeiten',
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Bearbeiten'),
                  shape: const StadiumBorder(),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'loeschen',
                  onPressed: _saving ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Löschen'),
                  shape: const StadiumBorder(),
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.white,
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation auch auf der Detailseite
      bottomNavigationBar: const AppBottomNav(popToRoot: true),
    );
  }
}
