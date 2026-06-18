// Das Datenmodell für die Darstellung einer Band.
// Ein Beispielkonstrukt welches weiter verfeiner wird

class Band {
  final String title;        // Name der Band (
  final String description;  // Beschreibung 
  final String genre;        // Musikgenre der Band
  final String origin;       // Herkunft
  final String founded;      // Gründungsjahr

  const Band({
    required this.title,
    required this.description,
    required this.genre,
    required this.origin,
    required this.founded,
  });
}
