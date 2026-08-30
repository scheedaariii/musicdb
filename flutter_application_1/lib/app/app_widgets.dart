// Bausteine, die in der ganzen App vorkommen 
// Vorher war das Aussehen der weissen Karten in sieben Dateien einzeln ausgeschrieben.

import 'package:flutter/material.dart';
import 'app_colors.dart';

// Das gemeinsame Aussehen aller weissen Karten. Nur die Ecken-Rundung unterscheidet sich je nach Grösse der Karte.
BoxDecoration appCardDecoration({double radius = 10}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}

// Weisse Karte mit reinem Fliesstext, z.B. der Hinweistext über einer Liste.
class TextCard extends StatelessWidget {
  final String text;

  const TextCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(radius: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }
}

// Weisse Karte mit Titel und Text, der Titel bekommt einen goldenen Balken. Wird auf dem Info-Screen und den drei Screens aus dem Drawer verwendet.
class SectionCard extends StatelessWidget {
  final String title;
  final String content;

  const SectionCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titelzeile mit goldenem Akzentbalken
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 10),

              // Expanded, damit auch lange Titel umbrechen statt überzulaufen
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Inhalt
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
