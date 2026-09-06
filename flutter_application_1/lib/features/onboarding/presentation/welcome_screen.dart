// welcome_screen.dart
// Wird nur beim allerersten Start der App gezeigt (siehe app.dart und
// onboarding_repository.dart). Erklärt kurz, was die App macht, bevor es
// zum Login geht.

import 'package:flutter/material.dart';

import '../../database/presentation/database_widgets.dart';
import '../../database/presentation/form_widgets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const DetailHeader(
                icon: Icons.library_music,
                title: 'Willkommen bei MusicDB',
                subtitle: 'Deine persönliche Musik-Datenbank',
              ),

              const SizedBox(height: 20),

              const TextCard(
                text:
                    'Erfasse Bands, Musiker, Alben, Songs, Genres und Rollen '
                    'und verknüpfe sie miteinander. Deine Datenbank ist '
                    'privat - nur du siehst deine Einträge.',
              ),

              const Spacer(),

              SaveButton(
                onPressed: onContinue,
                label: 'Los geht\'s',
                icon: Icons.arrow_forward,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
