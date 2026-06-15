// band_list_screen.dart
// Zeigt alle Bands als scrollbare Liste an.
// Beim Antippen einer Band wird die Detailseite geöffnet.

import 'package:flutter/material.dart';
import '../data/band_mock_data.dart';
import '../domain/band.dart';
import 'band_detail_screen.dart';

class BandListScreen extends StatelessWidget {
  const BandListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar mit dem Titel der Seite
      appBar: AppBar(
        title: const Text('MusicDB – Bands'),
      ),

      // Body: scrollbare Liste aller Bands
      body: ListView.builder(
        // Etwas Abstand oben und unten in der Liste
        padding: const EdgeInsets.symmetric(vertical: 8),

        // Anzahl der Einträge aus den Mockup-Daten
        itemCount: mockBands.length,

        // Für jeden Eintrag wird eine Karte erstellt
        itemBuilder: (context, index) {
          final Band band = mockBands[index];

          return _BandCard(band: band);
        },
      ),
    );
  }
}

// Eigenes Widget für eine Band-Karte in der Liste
// Ausgelagert für bessere Lesbarkeit
class _BandCard extends StatelessWidget {
  final Band band;

  const _BandCard({required this.band});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Aussenabstand der Karte
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      // Rahmen mit abgerundeten Ecken
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        // Leichter Schatten für Tiefenwirkung
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // Tippen auf die Karte öffnet den Detailscreen
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Mit Navigator.push wird der Detailscreen auf den Stapel gelegt
          Navigator.push(
            context,
            MaterialPageRoute(
              // Der ausgewählte Band-Eintrag wird übergeben
              builder: (context) => BandDetailScreen(band: band),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Goldfarbenes Musik-Icon links
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF242F40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Color(0xFFCCA43B),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Bandname und Genre in der Mitte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bandname
                    Text(
                      band.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363636),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Genre
                    Text(
                      band.genre,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Herkunft und Gründungsjahr
                    Text(
                      '${band.origin} · seit ${band.founded}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),

              // Pfeil-Icon rechts als Hinweis auf Detailseite
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCA43B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
