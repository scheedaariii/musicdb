// band_detail_screen.dart
// Zeigt die Detailinformationen einer ausgewählten Band an.
// Der Band-Eintrag wird über den Konstruktor übergeben.

import 'package:flutter/material.dart';
import '../domain/band.dart';

class BandDetailScreen extends StatelessWidget {
  // Die ausgewählte Band wird beim Öffnen des Screens übergeben
  final Band band;

  const BandDetailScreen({
    super.key,
    required this.band,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar zeigt den Bandnamen als Titel
      appBar: AppBar(
        title: Text(band.title),
        // Inkl. Zurückpfeil
      ),

      // Scrollbarer Body um längere  Listen azuzeigen. Aktuel sind zuwenig Inhalte verfügbar für  scrolling
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mit Icon und Bandname
            _buildHeader(band),

            const SizedBox(height: 20),

            // Info-Feld 
            _buildInfoRow(
              icon: Icons.album,
              label: 'Genre',
              value: band.genre,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.place,
              label: 'Herkunft',
              value: band.origin,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Gegründet',
              value: band.founded,
            ),

            const SizedBox(height: 24),

          
            const Text(
              'Über die Band',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF242F40),
              ),
            ),

            const SizedBox(height: 8),

            // Trennlinie 
            Container(
              height: 2,
              width: 40,
              color: const Color(0xFFCCA43B),
            ),

            const SizedBox(height: 12),

            // Beschreibungstext der Band
            Text(
              band.description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF363636),
                height: 1.6, 
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Header-Bereich mit grossem Icon und Bandname
  Widget _buildHeader(Band band) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF242F40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFCCA43B).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note,
              color: Color(0xFFCCA43B),
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Bandname
          Text(
            band.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Genre als Untertitel
          Text(
            band.genre,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCCA43B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Info-Zeilen-Widget 
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            icon,
            color: const Color(0xFFCCA43B),
            size: 22,
          ),

          const SizedBox(width: 12),

          // Bezeichnung
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Wert
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF363636),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
