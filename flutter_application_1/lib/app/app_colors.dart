// app_colors.dart
// Die Farbpalette der App an einer einzigen Stelle.
//
// Vorher standen dieselben Hex-Werte (z.B. 0xFF242F40) über 90 Mal verteilt
// im Code. Wer die Farbe ändern wollte, musste jede Stelle einzeln suchen.
// Jetzt gibt es pro Farbe genau einen Namen und genau einen Wert.
//
// Farbschema erstellt mit coolors.co:
// https://coolors.co/363636-242f40-cca43b-e5e5e5-ffffff

import 'package:flutter/material.dart';

class AppColors {
  // Private Konstruktor: Von dieser Klasse soll niemand ein Objekt erzeugen,
  // sie ist nur eine Sammlung von Konstanten.
  const AppColors._();

  // Hauptfarbe: AppBar, Überschriften, Header-Boxen
  static const Color darkBlue = Color(0xFF242F40);

  // Akzentfarbe: Icons, Trennlinien, aktiver Tab
  static const Color gold = Color(0xFFCCA43B);

  // Hintergrund der Seiten
  static const Color background = Color(0xFFE5E5E5);

  // Flächen der Karten und Boxen
  static const Color white = Color(0xFFFFFFFF);

  // Fliesstext
  static const Color text = Color(0xFF363636);

  // Beschriftungen neben einem Wert
  static const Color textLight = Color(0xFF666666);

  // Nebeninformationen und Platzhaltertexte
  static const Color textMuted = Color(0xFF999999);

  // Schatten unter den Karten
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.06);
}
