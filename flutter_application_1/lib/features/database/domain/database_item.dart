// Gemeinsame Schnittstelle für alle Einträge der Datenbank. Auf diese Weise wird nur ein Widget benötigt für den Seitenaufbau anstell von einem Pro Kategorie. Das hatte mich gestört beim entwickeln und ich habe per AI einen Weg gesucht das zu umgehen.
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

// Suchlogik für alle Modelle.

bool matchesQuery(String query, List<String> values) {
  final String q = query.toLowerCase().trim();

  // Ohne Suchbegriff passt jeder Eintrag
  if (q.isEmpty) return true;

  return values.any((value) => value.toLowerCase().contains(q));
}
