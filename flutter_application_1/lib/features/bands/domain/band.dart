// band.dart
// Das Datenmodell für eine Band.
// Enthält alle relevanten Felder, die eine Band beschreiben.

class Band {
  final String title;        // Name der Band (Pflichtfeld)
  final String description;  // Beschreibung / Geschichte der Band (Pflichtfeld)
  final String genre;        // Musikgenre der Band
  final String origin;       // Herkunftsland oder -stadt
  final String founded;      // Gründungsjahr

  const Band({
    required this.title,
    required this.description,
    required this.genre,
    required this.origin,
    required this.founded,
  });
}
