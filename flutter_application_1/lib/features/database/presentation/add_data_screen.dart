// Formular zum Erfassen neuer Einträge. Der Screen wird über den Plus-Button geöffnet. 

import 'package:flutter/material.dart';

import '../data/database_repository.dart';
import '../domain/database_category.dart';
import 'database_widgets.dart';
import 'form_widgets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class AddDataScreen extends StatefulWidget {
  // Vorauswahl, wenn das Formular aus einer Kategorie geöffnet wird
  final CategoryKind? fixedCategory;

  const AddDataScreen({super.key, this.fixedCategory});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  // Die aktuell gewählte Kategorie
  CategoryKind? _kind;

  // Änderung (Feedback "keine WriteSperren"): sperrt während eines laufenden Speichervorgangs den Speichern-Button, damit ein zweiter Klick nicht einen weiteren, doppelten Eintrag anlegt, während noch auf Firestore gewartet wird.
  bool _saving = false;

  // Eingabefelder
  
  final TextEditingController _name = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _foundedYear = TextEditingController();
  final TextEditingController _durationSeconds = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _origin = TextEditingController();

  // Für das eine Datumsfeld, benötigt für Kategorien
  String _dateValue = '';

  // Mehrfachauswahlen
  final List<String> _genres = [];
  final List<String> _bands = [];
  final List<String> _roles = [];
  final List<String> _albums = [];

  @override
  void initState() {
    super.initState();
    // Aus einer Kategorie heraus ist die Kategorie bereits gesetzt
    _kind = widget.fixedCategory;
  }

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _foundedYear.dispose();
    _durationSeconds.dispose();
    _description.dispose();
    _origin.dispose();
    super.dispose();
  }

  bool get _categoryLocked => widget.fixedCategory != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data'),
        // Inkl. Zurückpfeil
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header wie auf den Datenseiten
            const DetailHeader(
              icon: Icons.add_circle_outline,
              title: 'Add Data',
              subtitle: 'Neuen Eintrag erfassen',
            ),

            const SizedBox(height: 20),

            // Hinweistext, ändert sich mit der Auswahl
            _buildHintBox(),

            const SizedBox(height: 24),

            const SectionTitle(text: 'Kategorie'),

            const SizedBox(height: 12),

            // Auswahl der Kategorie, gesperrt bei fester Vorgabe
            FormDropdown(
              label: 'Kategorie',
              required: true,
              enabled: !_categoryLocked,
              value: _kind?.title,
              options: CategoryKind.allTitles,
              hintText: 'Bitte Kategorie auswählen',
              onChanged: (gewaehlt) {
                if (gewaehlt == null) return;
                setState(() {
                  _kind = CategoryKind.byTitle(gewaehlt);
                  _resetFields();
                });
              },
            ),

            // Die Felder der gewählten Kategorie
            if (_kind != null) ...[
              const SizedBox(height: 24),

              SectionTitle(text: _kind!.title),

              const SizedBox(height: 12),

              ..._buildFields(),

              const SizedBox(height: 24),

              // Änderung (Feedback "keine WriteSperren"): onPressed ist während _saving null, SaveButton.onPressed wurde dafür auf VoidCallback? umgestellt.
              SaveButton(onPressed: _saving ? null : _onSave),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Hinweistext oben auf der Seite
  Widget _buildHintBox() {
    return TextCard(
      text: _kind == null
          ? 'Bitte Kategorie auswählen'
          : 'Bitte die benötigten Daten abfüllen.',
    );
  }

  // Setzt alle Felder zurück, wenn die Kategorie wechselt
  void _resetFields() {
    _name.clear();
    _lastName.clear();
    _foundedYear.clear();
    _durationSeconds.clear();
    _description.clear();
    _origin.clear();
    _dateValue = '';
    _genres.clear();
    _bands.clear();
    _roles.clear();
    _albums.clear();
  }

  // Die Eingabefelder je nach Kategorie
  List<Widget> _buildFields() {
    switch (_kind!) {
      case CategoryKind.bands:
        return [
          FormTextField(label: 'Name', required: true, controller: _name),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Gründungsjahr',
            controller: _foundedYear,
            numbersOnly: true,
            maxLength: 4,
            hintText: 'JJJJ',
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Genre',
            options: repo.genreNames,
            selected: _genres,
            onAdd: (wert) => setState(() => _genres.add(wert)),
            onRemove: (wert) => setState(() => _genres.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormTextField(label: 'Herkunft', controller: _origin),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];

      case CategoryKind.musiker:
        return [
          FormTextField(label: 'Vorname', required: true, controller: _name),
          const SizedBox(height: 16),
          FormTextField(
              label: 'Nachname', required: true, controller: _lastName),
          const SizedBox(height: 16),
          FormDateField(
            label: 'Geburtsdatum',
            required: true,
            value: _dateValue,
            onTap: _pickDate,
            onClear: () => setState(() => _dateValue = ''),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Bands',
            options: repo.bandNames,
            selected: _bands,
            onAdd: (wert) => setState(() => _bands.add(wert)),
            onRemove: (wert) => setState(() => _bands.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Rolle',
            options: repo.roleNames,
            selected: _roles,
            onAdd: (wert) => setState(() => _roles.add(wert)),
            onRemove: (wert) => setState(() => _roles.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];

      case CategoryKind.genres:
        return [
          FormTextField(label: 'Name', required: true, controller: _name),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];

      case CategoryKind.rolle:
        return [
          FormTextField(label: 'Name', required: true, controller: _name),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];

      case CategoryKind.alben:
        return [
          FormTextField(label: 'Name', required: true, controller: _name),
          const SizedBox(height: 16),
          FormDateField(
            label: 'Release Datum',
            value: _dateValue,
            onTap: _pickDate,
            onClear: () => setState(() => _dateValue = ''),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Bands',
            options: repo.bandNames,
            selected: _bands,
            onAdd: (wert) => setState(() => _bands.add(wert)),
            onRemove: (wert) => setState(() => _bands.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Genre',
            options: repo.genreNames,
            selected: _genres,
            onAdd: (wert) => setState(() => _genres.add(wert)),
            onRemove: (wert) => setState(() => _genres.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormTextField(
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];

      case CategoryKind.songs:
        return [
          FormTextField(label: 'Name', required: true, controller: _name),
          const SizedBox(height: 16),
          FormDateField(
            label: 'Release Datum',
            value: _dateValue,
            onTap: _pickDate,
            onClear: () => setState(() => _dateValue = ''),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Albums',
            options: repo.albumNames,
            selected: _albums,
            onAdd: (wert) => setState(() => _albums.add(wert)),
            onRemove: (wert) => setState(() => _albums.remove(wert)),
          ),
          const SizedBox(height: 16),
          FormMultiSelect(
            label: 'Bands',
            options: repo.bandNames,
            selected: _bands,
            onAdd: (wert) => setState(() => _bands.add(wert)),
            onRemove: (wert) => setState(() => _bands.remove(wert)),
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
            label: 'Beschreibung',
            controller: _description,
            maxLines: 4,
          ),
        ];
    }
  }

  // Kalender für das jeweilige Datumsfeld der Kategorie
  Future<void> _pickDate() async {
    final DateTime? gewaehlt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (gewaehlt == null) return;

    setState(() {
      // Format JJJJ-MM-TT
      _dateValue = '${gewaehlt.year.toString().padLeft(4, '0')}-'
          '${gewaehlt.month.toString().padLeft(2, '0')}-'
          '${gewaehlt.day.toString().padLeft(2, '0')}';
    });
  }

  // ---------- Speichern ----------

  // Änderung (Feedback "keine WriteSperren" + "kein Rollback bei Schreibfehlern"): async, wartet jetzt  den Firestore-Schreibvorgang ab, siehe (database_repository.dart), bevor zur vorherigen Seite zurückgekehrt wird - vorher wurde sofort zurücknavigiert, ohne auf das Ergebnis des Speicherns zu warten.
  Future<void> _onSave() async {
    if (_saving) return;

    // 1. Pflichtfelder prüfen
    if (!_mandatoryFilled()) {
      _showMessage('Bitte alle Pflichtfelder ausfüllen!');
      return;
    }

    // 2. Eindeutigkeit prüfen
    if (!_isUnique()) {
      _showMessage('Eintrag ist nicht einzigartig, bitte anpassen!');
      return;
    }

    setState(() => _saving = true);

    // 3. Speichern (wird jetzt abgewartet)
    await _save();

    if (!mounted) return;

    // Zurück zur vorherigen Seite, damit die Liste neu aufgebaut wird
    Navigator.pop(context, true);
  }

  bool _mandatoryFilled() {
    if (_name.text.trim().isEmpty) return false;

    // Beim Musiker sind zusätzlich Nachname und Geburtsdatum Pflicht
    if (_kind == CategoryKind.musiker &&
        (_lastName.text.trim().isEmpty || _dateValue.isEmpty)) {
      return false;
    }
    return true;
  }

  // Prüft, ob die Kombination aller Eingaben noch nicht vorkommt
  bool _isUnique() {
    final String name = _name.text.trim();

    switch (_kind!) {
      case CategoryKind.bands:
        final List<String> genreIds = repo.idsForGenreNames(_genres);
        return !repo.bands.any((b) =>
            b.title.toLowerCase() == name.toLowerCase() &&
            b.founded == _foundedYear.text.trim() &&
            _sameSet(b.genreIds, genreIds));

      case CategoryKind.musiker:
        final String nachname = _lastName.text.trim();
        final List<String> bandIds = repo.idsForBandNames(_bands);
        final List<String> roleIds = repo.idsForRoleNames(_roles);
        return !repo.musicians.any((m) =>
            m.firstName.toLowerCase() == name.toLowerCase() &&
            m.lastName.toLowerCase() == nachname.toLowerCase() &&
            _sameSet(m.bandIds, bandIds) &&
            _sameSet(m.roleIds, roleIds));

      case CategoryKind.alben:
        final List<String> bandIds = repo.idsForBandNames(_bands);
        final List<String> genreIds = repo.idsForGenreNames(_genres);
        return !repo.albums.any((a) =>
            a.title.toLowerCase() == name.toLowerCase() &&
            a.releaseDate == _dateValue &&
            _sameSet(a.bandIds, bandIds) &&
            _sameSet(a.genreIds, genreIds));

      case CategoryKind.songs:
        final List<String> albumIds = repo.idsForAlbumNames(_albums);
        final List<String> bandIds = repo.idsForBandNames(_bands);
        return !repo.songs.any((s) =>
            s.title.toLowerCase() == name.toLowerCase() &&
            s.releaseDate == _dateValue &&
            _sameSet(s.albumIds, albumIds) &&
            _sameSet(s.bandIds, bandIds) &&
            s.durationSeconds == _durationValue);

      // Bei Genre und Rolle muss allein der Name eindeutig sein
      case CategoryKind.genres:
        return !repo.genreNames
            .any((g) => g.toLowerCase() == name.toLowerCase());

      case CategoryKind.rolle:
        return !repo.roleNames
            .any((r) => r.toLowerCase() == name.toLowerCase());
    }
  }

  int get _durationValue => int.tryParse(_durationSeconds.text.trim()) ?? 0;

  // Vergleicht zwei Auswahlen unabhängig von der Reihenfolge. Wen z.B. die Genres bei einer Band einmal Trash/Deathmetal und einmal Deathmetal/Trash sind wird es trotzdem als doppelter Eintrag erkannt.
  bool _sameSet(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final Set<String> mengeA = a.map((e) => e.toLowerCase()).toSet();
    final Set<String> mengeB = b.map((e) => e.toLowerCase()).toSet();
    return mengeA.containsAll(mengeB);
  }

  // Änderung nach feedback: async, wartet jetzt den Firestore-Schreibvorgang ab und ergänzt die lokale Liste nur bei Erfolg, siehe database_repository.dart.
  Future<void> _save() async {
    final String name = _name.text.trim();

    switch (_kind!) {
      case CategoryKind.bands:
        await repo.addBand(
          title: name,
          genreIds: repo.idsForGenreNames(_genres),
          founded: _foundedYear.text.trim(),
          origin: _origin.text.trim(),
          descriptionText: _description.text.trim(),
        );
        break;

      case CategoryKind.musiker:
        final String nachname = _lastName.text.trim();
        await repo.addMusician(
          firstName: name,
          lastName: nachname,
          dateOfBirth: _dateValue,
          bandIds: repo.idsForBandNames(_bands),
          roleIds: repo.idsForRoleNames(_roles),
          descriptionText: _description.text.trim(),
        );
        break;

      case CategoryKind.alben:
        await repo.addAlbum(
          title: name,
          bandIds: repo.idsForBandNames(_bands),
          genreIds: repo.idsForGenreNames(_genres),
          releaseDate: _dateValue,
          descriptionText: _description.text.trim(),
        );
        break;

      case CategoryKind.songs:
        await repo.addSong(
          title: name,
          albumIds: repo.idsForAlbumNames(_albums),
          bandIds: repo.idsForBandNames(_bands),
          durationSeconds: _durationValue,
          releaseDate: _dateValue,
          descriptionText: _description.text.trim(),
        );
        break;

      case CategoryKind.genres:
        await repo.addGenre(
          title: name,
          descriptionText: _description.text.trim(),
        );
        break;

      case CategoryKind.rolle:
        await repo.addRole(
          title: name,
          descriptionText: _description.text.trim(),
        );
        break;
    }
  }

  // Meldung bei fehlgeschlagener Prüfung
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
}
