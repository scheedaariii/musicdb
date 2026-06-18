// Das Datenmodell für die Darstellung einer Band.
// Enthält alle relevanten Felder, die eine Band beschreiben. Diese werden in Zukunft über verschieden Kategorien verteilt sein und hier zusammengefügt

class Band {
  final String title;        // Name der Band (Pflichtfeld)
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
