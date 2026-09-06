// onboarding_repository.dart
// Merkt sich auf dem Gerät (nicht in Firebase), ob der Welcome-Screen
// schon gezeigt wurde - mit shared_preferences, das genau für solche
// kleinen, geräte-lokalen Einstellungen gedacht ist. Gleich aufgebaut wie
// die anderen Repositories (auth_repository.dart, database_repository.dart).

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  OnboardingRepository._();

  static final OnboardingRepository instance = OnboardingRepository._();

  static const String _seenWelcomeKey = 'hasSeenWelcome';

  Future<bool> hasSeenWelcome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenWelcomeKey) ?? false;
  }

  Future<void> markWelcomeSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenWelcomeKey, true);
  }
}

final OnboardingRepository onboardingRepo = OnboardingRepository.instance;
