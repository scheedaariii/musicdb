// profile_screen.dart
// Der Profil-Bereich der App.
// Zeigt ein einfaches Benutzerprofil als Platzhalter an.

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar mit Titel
      appBar: AppBar(
        title: const Text('Profil'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil-Header mit Avatar und Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF242F40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Avatar-Kreis mit Initialen
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCA43B),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'TF',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Benutzername
                  const Text(
                    'Thomas Frei',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Kurzbeschreibung
                  const Text(
                    'Leidenschaftlicher Musikfan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCCA43B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistiken
            Row(
              children: [
                // Anzahl Bands
                Expanded(
                  child: _buildStatCard(
                    label: 'Bands',
                    value: '6',
                    icon: Icons.library_music,
                  ),
                ),
                const SizedBox(width: 12),
                // Lieblings-Genre
                Expanded(
                  child: _buildStatCard(
                    label: 'Genres',
                    value: '5',
                    icon: Icons.queue_music,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profil-Informationen
            _buildProfileItem(
              icon: Icons.music_note,
              label: 'Lieblingsgenre',
              value: 'Heavy Metal',
            ),

            const SizedBox(height: 10),

            _buildProfileItem(
              icon: Icons.place,
              label: 'Standort',
              value: 'Zürich, Schweiz',
            ),

            const SizedBox(height: 10),

            _buildProfileItem(
              icon: Icons.cake,
              label: 'Mitglied seit',
              value: '2025',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Statistik-Karte für die Profilstatistiken
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFCCA43B),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF242F40),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  // Einzelne Profilzeile mit Icon, Label und Wert
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
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

          const SizedBox(width: 14),

          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),

          const Spacer(),

          // Wert
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF363636),
            ),
          ),
        ],
      ),
    );
  }
}
