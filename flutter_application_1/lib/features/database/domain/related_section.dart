// Ein Abschnitt mit verknüpften Einträgen auf einer Detailseite, z.B. die Musiker einer Band oder die Bands eines Genres.
// Die Einträge sind selbst wieder DatabaseItems und dadurch antippbar.

import 'database_item.dart';

class RelatedSection {
  final String label; // Überschrift, z.B. "Musiker"
  final List<DatabaseItem> items; // Die verknüpften Einträge

  const RelatedSection({required this.label, required this.items});
}
