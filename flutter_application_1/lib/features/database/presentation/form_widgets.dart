// Die Eingabe-Bausteine des Erfassungsformulars. Alle Felder sehen aus wie die weissen Boxen der Datenseiten.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

// Die beiden Textstile, die in allen Formularfeldern vorkommen
const TextStyle _wertStil = TextStyle(fontSize: 14, color: AppColors.text);
const TextStyle _hinweisStil =
    TextStyle(fontSize: 14, color: AppColors.textMuted);

// Beschriftung eines Feldes, Pflichtfelder mit rotem Stern
class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const FieldLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
          children: [
            // Pflichtfeld-Markierung
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Einzeiliges Texteingabefeld
class FormTextField extends StatelessWidget {
  final String label;
  final bool required;
  final TextEditingController controller;
  final String hintText;
  final bool numbersOnly;
  final int? maxLength;
  final int maxLines;

  const FormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.hintText = '',
    this.numbersOnly = false,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, required: required),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: appCardDecoration(),
          child: TextField(
            controller: controller,
            keyboardType:
                numbersOnly ? TextInputType.number : TextInputType.text,
            inputFormatters: numbersOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            maxLength: maxLength,
            maxLines: maxLines,
            style: _wertStil,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: _hinweisStil,
              border: InputBorder.none,
              isDense: true,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// Auswahlfeld mit einer einzelnen Auswahl
class FormDropdown extends StatelessWidget {
  final String label;
  final bool required;
  final String? value;
  final List<String> options;
  final String hintText;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const FormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.required = false,
    this.hintText = 'Bitte auswählen',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, required: required),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: appCardDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              // Gesperrt, wenn das Formular aus einer Kategorie geöffnet wurde
              onChanged: enabled ? onChanged : null,
              hint: Text(
                hintText,
                style: _hinweisStil,
              ),
              icon: Icon(
                enabled ? Icons.arrow_drop_down : Icons.lock_outline,
                color: enabled ? AppColors.gold : AppColors.textMuted,
                size: enabled ? 24 : 18,
              ),
              style: _wertStil,
              items: [
                for (final String option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: _wertStil,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Auswahlfeld mit mehreren Auswahlen. Die getroffenen Auswahlen erscheinen als Chips und können über das Kreuz wieder entfernt werden. Habe ich selbst nicht hinbekommen und mit Hilfe von AI hinzugefügt.
class FormMultiSelect extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final String hintText;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const FormMultiSelect({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
    this.hintText = 'Bitte auswählen',
  });

  @override
  Widget build(BuildContext context) {
    // Bereits gewählte Einträge nicht nochmals anbieten
    final List<String> offen =
        options.where((o) => !selected.contains(o)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: appCardDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: null,
              isExpanded: true,
              onChanged: offen.isEmpty
                  ? null
                  : (gewaehlt) {
                      if (gewaehlt != null) onAdd(gewaehlt);
                    },
              hint: Text(
                offen.isEmpty ? 'Keine weitere Auswahl' : hintText,
                style: _hinweisStil,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: offen.isEmpty ? AppColors.textMuted : AppColors.gold,
              ),
              items: [
                for (final String option in offen)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: _wertStil,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Die getroffene Auswahl
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final String eintrag in selected)
                Chip(
                  label: Text(
                    eintrag,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.gold),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteIconColor: AppColors.textMuted,
                  onDeleted: () => onRemove(eintrag),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// Auswahlfeld mit mehreren Auswahlen und Suchfeld, für lange Listen wie alle Musiker oder alle Songs. Selbes verhalten für Chips wie bei class FormMultiSelect extends StatelessWidget weiter oben.
class FormFilterableMultiSelect extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const FormFilterableMultiSelect({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Bereits gewählte Einträge nicht weiter anzeigen.
    final List<String> offen = options.where((o) => !selected.contains(o)).toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),

        Container(
          padding: const EdgeInsets.only(left: 16, right: 4),
          decoration: appCardDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  offen.isEmpty ? 'Keine weitere Auswahl' : 'Hinzufügen',
                  style: _hinweisStil,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: offen.isEmpty ? AppColors.textMuted : AppColors.gold,
                ),
                onPressed:
                    offen.isEmpty ? null : () => _openPicker(context, offen),
              ),
            ],
          ),
        ),

        // Die getroffene Auswahl
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final String eintrag in selected)
                Chip(
                  label: Text(
                    eintrag,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.gold),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteIconColor: AppColors.textMuted,
                  onDeleted: () => onRemove(eintrag),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _openPicker(BuildContext context, List<String> offen) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          _FilterSheet(title: label, options: offen, onSelected: onAdd),
    );
  }
}

// Der Inhalt des Bottom-Sheets: Suchfeld oben, gefilterte Liste darunter. Führt eine eigene Kopie der Optionen, damit ausgewählte Einträge sofort aus der Liste verschwinden, ohne das Sheet zu schliessen. Auch dieser Teil ist mir Hilfe von AI enstanden.
class _FilterSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final TextEditingController _search = TextEditingController();
  late final List<String> _verbleibend = [...widget.options];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String suchbegriff = _search.text.toLowerCase().trim();
    final List<String> gefiltert = suchbegriff.isEmpty
        ? _verbleibend
        : _verbleibend
            .where((o) => o.toLowerCase().contains(suchbegriff))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                hintText: 'Suchen',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: gefiltert.isEmpty
                  ? const Center(
                      child: Text(
                        'Keine Treffer',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: gefiltert.length,
                      itemBuilder: (context, index) {
                        final String eintrag = gefiltert[index];
                        return ListTile(
                          title: Text(eintrag, style: _wertStil),
                          trailing:
                              const Icon(Icons.add, color: AppColors.gold),
                          onTap: () {
                            widget.onSelected(eintrag);
                            setState(() => _verbleibend.remove(eintrag));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Datumsfeld, öffnet den Kalender der Plattform
class FormDateField extends StatelessWidget {
  final String label;
  final String value;
  final String hintText;
  final bool required;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const FormDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
    this.hintText = 'Datum auswählen',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, required: required),

        Container(
          decoration: appCardDecoration(),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.gold, size: 20),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      value.isEmpty ? hintText : value,
                      style: value.isEmpty ? _hinweisStil : _wertStil,
                    ),
                  ),

                  // Kreuz zum Zurücksetzen, nur bei gesetztem Datum
                  if (value.isNotEmpty)
                    InkWell(
                      onTap: onClear,
                      child: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 18),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Der Speichern-Button am Ende des Formulars
class SaveButton extends StatelessWidget {
  // Änderung (Feedback "keine WriteSperren"): SaveButton.onPressed auf VoidCallback? umgestellt, damit er während _saving deaktiviert werden kann.
  
  final VoidCallback? onPressed;

  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save_outlined, size: 20),
        label: const Text(
          'Speichern',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
