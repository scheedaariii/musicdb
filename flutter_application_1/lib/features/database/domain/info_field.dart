// Ein einzelnes Info-Feld auf einer Detailseite (die weissen Boxen). Jedes Modell liefert seine eigenen Felder, die Detailseite muss dadurch nicht wissen, um welche Art von Eintrag es sich handelt.

import 'package:flutter/material.dart';

class InfoField {
  final IconData icon; // Icon links in der Box
  final String label; // Bezeichnung
  final String value; // Wert

  const InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });
}
