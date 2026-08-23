// database_item.dart
// Gemeinsame Schnittstelle für alle Einträge der Datenbank
// (Bands, Musiker, Alben, Songs und Genres).
//
// Jedes Modell behält seine eigenen, fachlich sinnvollen Felder und liefert
// über diese Schnittstelle nur, was die Listen- und Detailseiten anzeigen
// müssen. Dadurch genügt ein einziger Listen- und ein einziger Detailscreen
// für alle Kategorien.

import 'package:flutter/material.dart';
import 'info_field.dart';

abstract class DatabaseItem {
  // Eindeutige Kennung, später die Dokument-ID aus Firestore
  String get id;

  // Erste Zeile in der Liste und Titel der Detailseite
  String get title;

  // Zweite Zeile in der Liste, leer wenn nicht benötigt
  String get subtitle;

  // Wert rechts in der Listenzeile (Instrument, Jahr, Länge, Anzahl)
  String get trailing;

  // Fliesstext im Abschnitt "Über ..." der Detailseite
  String get description;

  // Icon in Liste und Detail-Header
  IconData get icon;

  // Die Info-Boxen der Detailseite
  List<InfoField> get infoFields;

  // Prüft, ob der Eintrag zum Suchbegriff passt
  bool matches(String query);
}

// Gemeinsame Suchlogik für alle Modelle.
//
// Vorher hatte jedes Modell dieselben vier Zeilen (klein schreiben, trimmen,
// leere Eingabe abfangen, vergleichen) noch einmal ausgeschrieben. Jetzt
// übergibt jedes Modell nur noch die Werte, in denen gesucht werden soll.
//
// Beispiel: matchesQuery(query, [title, ...bandNames])
bool matchesQuery(String query, List<String> values) {
  final String q = query.toLowerCase().trim();

  // Ohne Suchbegriff passt jeder Eintrag
  if (q.isEmpty) return true;

  return values.any((value) => value.toLowerCase().contains(q));
}
