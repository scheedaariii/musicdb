// form_widgets.dart
// Die Eingabe-Bausteine des Erfassungsformulars.
// Alle Felder sehen aus wie die weissen Boxen der Datenseiten.

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

  const FormTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.hintText = '',
    this.numbersOnly = false,
    this.maxLength,
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

// Auswahlfeld mit mehreren Auswahlen.
// Die getroffenen Auswahlen erscheinen als Chips und können
// über das Kreuz wieder entfernt werden.
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

// Datumsfeld, öffnet den Kalender der Plattform
class FormDateField extends StatelessWidget {
  final String label;
  final String value;
  final String hintText;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const FormDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
    this.hintText = 'Datum auswählen',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),

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
  final VoidCallback onPressed;

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
