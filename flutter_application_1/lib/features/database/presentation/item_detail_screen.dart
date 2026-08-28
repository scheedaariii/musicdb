// item_detail_screen.dart
// Zeigt die Detailinformationen eines einzelnen Eintrags an und erlaubt es,
// ihn zu bearbeiten. Funktioniert für alle Kategorien gleich: Band, Musiker,
// Album, Song, Genre und Rolle liefern über die Schnittstelle DatabaseItem
// ihre eigenen Felder, dieser Screen stellt sie einheitlich dar.
//
// Der Stift-Button oben schaltet die Seite in den Bearbeitungsmodus. Der
// Name/Titel eines Eintrags bleibt bewusst nicht editierbar: Er ist bei
// jedem anderen Eintrag, der darauf verweist, als Text mitgespeichert
// (z.B. Musician.bandNames), eine Umbenennung müsste all diese Kopien
// nachziehen. Alle anderen Felder lassen sich anpassen, sobald etwas
// geändert wurde erscheint der Speichern-Button.
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

  // Während _startEditing() die Felder mit den Ausgangswerten befüllt,
  // sollen die Listener nicht schon "geändert" melden.
  bool _populating = false;

  // Der aktuelle Stand des Eintrags. Wird nach dem Speichern neu aus dem
  // Repository geholt, damit die Seite sofort den neuen Stand zeigt.
  late DatabaseItem _item = widget.item;

  // ---------- Eingabefelder für den Bearbeitungsmodus ----------
  final TextEditingController _foundedYear = TextEditingController();
  final TextEditingController _origin = TextEditingController();
  final TextEditingController _durationSeconds = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _releaseDate = '';

  // Eigene Mehrfachauswahlen (direkt beim Eintrag gespeichert)
  final List<String> _genreSelection = [];
  final List<String> _bandSelection = [];
  final List<String> _roleSelection = [];
  final List<String> _albumSelection = [];

  // Verknüpfungen, die eigentlich beim jeweils anderen Eintrag gespeichert
  // sind (z.B. die Musiker einer Band liegen in Musician.bandIds)
  final List<String> _relatedBandSelection = [];
  final List<String> _relatedMusicianSelection = [];
  final List<String> _relatedAlbumSelection = [];
  final List<String> _relatedSongSelection = [];

  // Die Ausgangswerte der Textfelder, um echte Textänderungen von blossem
  // Antippen (Cursor setzen) zu unterscheiden. TextEditingController meldet
  // nämlich auch reine Cursor-Bewegungen als Änderung.
  String _originalFoundedYear = '';
  String _originalOrigin = '';
  String _originalDuration = '';
  String _originalDescription = '';

  @override
  void initState() {
    super.initState();
    _foundedYear.addListener(_checkTextDirty);
    _origin.addListener(_checkTextDirty);
    _durationSeconds.addListener(_checkTextDirty);
    _description.addListener(_checkTextDirty);
  }

  @override
  void dispose() {
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

  // Wird bei jeder Änderung eines Textfelds aufgerufen, auch bei reinem
  // Antippen. Setzt "dirty" daher nur, wenn sich der Text wirklich vom
  // Ausgangswert unterscheidet.
  void _checkTextDirty() {
    if (_populating) return;

    final bool geaendert = _foundedYear.text != _originalFoundedYear ||
        _origin.text != _originalOrigin ||
        _durationSeconds.text != _originalDuration ||
        _description.text != _originalDescription;

    if (geaendert) _markDirty();
  }

  // ---------- Bearbeitungsmodus starten ----------

  void _startEditing() {
    final DatabaseItem item = _item;
    _populating = true;

    _foundedYear.clear();
    _origin.clear();
    _durationSeconds.clear();
    _description.text = _descriptionTextOf(item);
    _releaseDate = '';
    _genreSelection.clear();
    _bandSelection.clear();
    _roleSelection.clear();
    _albumSelection.clear();
    _relatedBandSelection.clear();
    _relatedMusicianSelection.clear();
    _relatedAlbumSelection.clear();
    _relatedSongSelection.clear();

    if (item is Band) {
      _foundedYear.text = item.founded;
      _origin.text = item.origin;
      _genreSelection.addAll(item.genres);
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
      _bandSelection.addAll(item.bandNames);
      _roleSelection.addAll(item.roles);
    } else if (item is Album) {
      _releaseDate = item.releaseDate;
      _bandSelection.addAll(item.bandNames);
      _genreSelection.addAll(item.genres);
      _relatedSongSelection.addAll(repo.songs
          .where((s) => s.albumIds.contains(item.id))
          .map((s) => s.title));
    } else if (item is Song) {
      _releaseDate = item.releaseDate;
      _durationSeconds.text =
          item.durationSeconds > 0 ? item.durationSeconds.toString() : '';
      _albumSelection.addAll(item.albumNames);
      _bandSelection.addAll(item.bandNames);
    } else if (item is Genre) {
      _relatedBandSelection.addAll(item.bandIds
          .map((id) => repo.bandById(id)?.title)
          .whereType<String>());
    } else if (item is Role) {
      _relatedMusicianSelection.addAll(item.musicianIds
          .map((id) => repo.musicianById(id)?.title)
          .whereType<String>());
    }

    _originalFoundedYear = _foundedYear.text;
    _originalOrigin = _origin.text;
    _originalDuration = _durationSeconds.text;
    _originalDescription = _description.text;

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

  // ---------- Speichern ----------

  void _save() {
    final DatabaseItem item = _item;

    if (item is Band) {
      repo.updateBand(Band(
        id: item.id,
        title: item.title,
        genres: [..._genreSelection],
        founded: _foundedYear.text.trim(),
        origin: _origin.text.trim(),
        descriptionText: _description.text.trim(),
      ));

      _syncReverse(
        before: repo.musicians
            .where((m) => m.bandIds.contains(item.id))
            .map((m) => m.title)
            .toSet(),
        after: _relatedMusicianSelection,
        onAdd: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          if (musician != null) repo.addBandToMusician(musician.id, item.id);
        },
        onRemove: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          if (musician != null) {
            repo.removeBandFromMusician(musician.id, item.id);
          }
        },
      );

      _syncReverse(
        before: repo.albums
            .where((a) => a.bandIds.contains(item.id))
            .map((a) => a.title)
            .toSet(),
        after: _relatedAlbumSelection,
        onAdd: (title) {
          final Album? album = repo.albumByTitle(title);
          if (album != null) repo.addBandToAlbum(album.id, item.id);
        },
        onRemove: (title) {
          final Album? album = repo.albumByTitle(title);
          if (album != null) repo.removeBandFromAlbum(album.id, item.id);
        },
      );

      _syncReverse(
        before: repo.songs
            .where((s) => s.bandIds.contains(item.id))
            .map((s) => s.title)
            .toSet(),
        after: _relatedSongSelection,
        onAdd: (title) {
          final Song? song = repo.songByTitle(title);
          if (song != null) repo.addBandToSong(song.id, item.id);
        },
        onRemove: (title) {
          final Song? song = repo.songByTitle(title);
          if (song != null) repo.removeBandFromSong(song.id, item.id);
        },
      );

      _item = repo.bandById(item.id) ?? item;
    } else if (item is Musician) {
      repo.updateMusician(Musician(
        id: item.id,
        firstName: item.firstName,
        lastName: item.lastName,
        bandIds: repo.idsForBandNames(_bandSelection),
        bandNames: [..._bandSelection],
        roles: [..._roleSelection],
        descriptionText: _description.text.trim(),
      ));
      _item = repo.musicianById(item.id) ?? item;
    } else if (item is Album) {
      repo.updateAlbum(Album(
        id: item.id,
        title: item.title,
        bandIds: repo.idsForBandNames(_bandSelection),
        bandNames: [..._bandSelection],
        genres: [..._genreSelection],
        releaseDate: _releaseDate,
        descriptionText: _description.text.trim(),
      ));

      _syncReverse(
        before: repo.songs
            .where((s) => s.albumIds.contains(item.id))
            .map((s) => s.title)
            .toSet(),
        after: _relatedSongSelection,
        onAdd: (title) {
          final Song? song = repo.songByTitle(title);
          if (song != null) repo.addAlbumToSong(song.id, item.id);
        },
        onRemove: (title) {
          final Song? song = repo.songByTitle(title);
          if (song != null) repo.removeAlbumFromSong(song.id, item.id);
        },
      );

      _item = repo.albumById(item.id) ?? item;
    } else if (item is Song) {
      repo.updateSong(Song(
        id: item.id,
        title: item.title,
        durationSeconds: int.tryParse(_durationSeconds.text.trim()) ?? 0,
        albumIds: repo.idsForAlbumNames(_albumSelection),
        albumNames: [..._albumSelection],
        bandIds: repo.idsForBandNames(_bandSelection),
        bandNames: [..._bandSelection],
        releaseDate: _releaseDate,
        descriptionText: _description.text.trim(),
      ));
      _item = repo.songById(item.id) ?? item;
    } else if (item is Genre) {
      repo.updateGenreDescription(item.id, _description.text.trim());

      _syncReverse(
        before: repo.bands
            .where((b) => b.genres.contains(item.title))
            .map((b) => b.title)
            .toSet(),
        after: _relatedBandSelection,
        onAdd: (title) {
          final Band? band = repo.bandByTitle(title);
          if (band != null) repo.addGenreToBand(band.id, item.title);
        },
        onRemove: (title) {
          final Band? band = repo.bandByTitle(title);
          if (band != null) repo.removeGenreFromBand(band.id, item.title);
        },
      );

      DatabaseItem aktualisiertesGenre = item;
      for (final Genre genre in repo.genres) {
        if (genre.id == item.id) aktualisiertesGenre = genre;
      }
      _item = aktualisiertesGenre;
    } else if (item is Role) {
      repo.updateRoleDescription(item.id, _description.text.trim());

      _syncReverse(
        before: repo.musicians
            .where((m) => m.roles.contains(item.title))
            .map((m) => m.title)
            .toSet(),
        after: _relatedMusicianSelection,
        onAdd: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          if (musician != null) {
            repo.addRoleToMusician(musician.id, item.title);
          }
        },
        onRemove: (title) {
          final Musician? musician = repo.musicianByTitle(title);
          if (musician != null) {
            repo.removeRoleFromMusician(musician.id, item.title);
          }
        },
      );

      DatabaseItem aktualisierteRolle = item;
      for (final Role rolle in repo.roles) {
        if (rolle.id == item.id) aktualisierteRolle = rolle;
      }
      _item = aktualisierteRolle;
    }

    setState(() {
      _editing = false;
      _dirty = false;
    });
  }

  // Vergleicht die ursprüngliche mit der aktuell gewählten Auswahl und
  // ruft für jede Änderung die passende Funktion auf.
  void _syncReverse({
    required Set<String> before,
    required List<String> after,
    required void Function(String title) onAdd,
    required void Function(String title) onRemove,
  }) {
    final Set<String> afterSet = after.toSet();

    for (final String title in afterSet) {
      if (!before.contains(title)) onAdd(title);
    }
    for (final String title in before) {
      if (!afterSet.contains(title)) onRemove(title);
    }
  }

  Future<void> _pickReleaseDate() async {
    final DateTime? gewaehlt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (gewaehlt == null) return;

    setState(() {
      _releaseDate = '${gewaehlt.year.toString().padLeft(4, '0')}-'
          '${gewaehlt.month.toString().padLeft(2, '0')}-'
          '${gewaehlt.day.toString().padLeft(2, '0')}';
    });
    _markDirty();
  }

  // ---------- Die Eingabefelder je nach Kategorie ----------

  List<Widget> _buildEditableFields(DatabaseItem item) {
    if (item is Band) {
      return [
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
        FormDateField(
          label: 'Release Datum',
          value: _releaseDate,
          onTap: _pickReleaseDate,
          onClear: () {
            setState(() => _releaseDate = '');
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
        FormDateField(
          label: 'Release Datum',
          value: _releaseDate,
          onTap: _pickReleaseDate,
          onClear: () {
            setState(() => _releaseDate = '');
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
            )
          else
            TextButton.icon(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit_outlined, color: AppColors.white),
              label: const Text(
                'Bearbeiten',
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),

      // Scrollbarer Body um längere Listen anzuzeigen
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit Icon und Name, unabhängig vom Bearbeitungsmodus
            DetailHeader(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
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
                  ItemRow(item: related),
                  const SizedBox(height: 12),
                ],
              ],

              const SizedBox(height: 24),
            ],
          ],
        ),
      ),

      // Erscheint erst, sobald im Bearbeitungsmodus etwas geändert wurde.
      // Ohne eigene shape würde das globale Theme (CircleBorder, gedacht für
      // den runden Plus-Button) auch hier greifen und den Text abschneiden.
      floatingActionButton: (_editing && _dirty)
          ? FloatingActionButton.extended(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Speichern'),
              shape: const StadiumBorder(),
            )
          : null,

      // Bottom Navigation auch auf der Detailseite
      bottomNavigationBar: const AppBottomNav(popToRoot: true),
    );
  }
}
