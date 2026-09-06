// MaterialApp mit den Designgrundlagen und der Startseite.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation_screen.dart';
import 'app_colors.dart';
import 'app_messenger.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/database/data/database_repository.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/onboarding/presentation/welcome_screen.dart';

// Änderung (Feedback "UI-Fehlermeldungen aus Repository"): Das Repository zeigt Fehler nicht mehr selbst als SnackBar an, sondern legt den Fehlertext nur in repo.lastError ab.
// die UI-Anzeige passiert also nur noch hier, nicht mehr in der Datenschicht.

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Änderung (Datenzugehörigkeit): hört zusätzlich auf den Login-Status,
  // um repo.reset() aufzurufen, sobald sich niemand mehr angemeldet hat -
  // sonst würde bei einem zweiten Konto auf demselben Gerät zuerst kurz
  // noch die Datenbank des vorherigen Kontos aufscheinen.
  StreamSubscription<User?>? _authSub;

  // Änderung (Onboarding, Teil 6): null = wird noch geprüft, true = der
  // Welcome-Screen wurde auf diesem Gerät noch nie gesehen und muss vor
  // dem Login gezeigt werden, false = schon gesehen (siehe
  // onboarding_repository.dart, das den Wert per shared_preferences
  // dauerhaft auf dem Gerät speichert).
  bool? _showWelcome;

  @override
  void initState() {
    super.initState();
    repo.lastError.addListener(_onError);
    _authSub = authRepo.authStateChanges.listen((user) {
      if (user == null) repo.reset();
    });
    _loadWelcomeFlag();
  }

  Future<void> _loadWelcomeFlag() async {
    final bool seen = await onboardingRepo.hasSeenWelcome();
    if (mounted) setState(() => _showWelcome = !seen);
  }

  // Wird vom "Los geht's"-Button auf dem Welcome-Screen aufgerufen: merkt
  // dauerhaft, dass er gesehen wurde, und schaltet zum Login weiter.
  void _continueFromWelcome() {
    onboardingRepo.markWelcomeSeen();
    setState(() => _showWelcome = false);
  }

  @override
  void dispose() {
    repo.lastError.removeListener(_onError);
    _authSub?.cancel();
    super.dispose();
  }

  void _onError() {
    final String? text = repo.lastError.value;
    if (text == null) return;
    appMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
    // Zurücksetzen, damit dieselbe Meldung nicht durch einen Rebuild erneut ausgelöst wird.
    repo.lastError.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicDB',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appMessengerKey,

      // Globales Theme mit der definierten Farbpalette:
      // Mit coolors.co erstelltes Farbschema:
      // https://coolors.co/363636-242f40-cca43b-e5e5e5-ffffff

      theme: ThemeData(
        // Hauptfarbe
        primaryColor: AppColors.darkBlue,

        // App Hintergrund

        scaffoldBackgroundColor: AppColors.background,

        // AppBar Design

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // BottomNavigationBar Design
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkBlue,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.background,
        ),

        // Farbe für Datenkarten (weisse boxen)

        cardColor: AppColors.white,

        // Der runde Plus-Button. Steht hier im Theme, damit ihn nicht jeder Screen einzeln einfärben muss.

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBlue,
          shape: CircleBorder(),
        ),

        // Farbschema Allg.

        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.darkBlue,
          secondary: AppColors.gold,
        ),
      ),

      // Änderung (Onboarding): ganz zuvorderst steht die Prüfung, ob der
      // Welcome-Screen auf diesem Gerät schon gesehen wurde. Erst danach
      // kommt das Auth-Gate (Änderung Authentifizierung): Es hört auf den
      // Login-Status von Firebase Auth und zeigt den Login-Screen, solange
      // niemand eingeloggt ist - erst danach kommt wie bisher die
      // Datenbank-Ladeseite.
      home: _showWelcome == null
          ? const _LoadingScreen()
          : _showWelcome!
              ? WelcomeScreen(onContinue: _continueFromWelcome)
              : StreamBuilder<User?>(
                  stream: authRepo.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingScreen();
                    }
                    if (snapshot.data == null) {
                      return const LoginScreen();
                    }
                    return _StartupScreen(uid: snapshot.data!.uid);
                  },
                ),
    );
  }
}


// Read: Erstes Laden der Datenbank aus Firestore 
// Holt beim Start alle Sammlungen aus Firestore. _StartupScreen wartet darauf und zeigt einen ladescreen wen das länger dauert.
// Fehlermeldung bei laden Fehlern. Beides konnte nur mit AI getriebenen Tests nachgewiesen werden bisher.

class _StartupScreen extends StatefulWidget {
  // Änderung (Datenzugehörigkeit): load() muss wissen, wer eingeloggt ist,
  // um die richtigen (privaten) Daten zu laden.
  final String uid;

  const _StartupScreen({required this.uid});

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  late final Future<void> _laden = DatabaseRepository.instance.load(widget.uid);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _laden,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // FutureBuilder meldet einen fehlgeschlagenen Ladevorgang auch als "done" - ohne diese Prüfung würde die App bei einem Fehler einfach mit leeren Daten weiterlaufen, ohne Meldung.
          // Dieses Element ist durch eine "Anmerkung" von Claude enstanden als ich das Fehlerhandling testen wollte.
          if (snapshot.hasError) {
            return const _LoadErrorScreen();
          }
          return const NavigationScreen();
        }
        return const _LoadingScreen();
      },
    );
  }
}

// Einfache, zum Design passende Ladeanzeige

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_music, color: AppColors.gold, size: 64),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.gold),
            SizedBox(height: 20),
            Text(
              'MusicDB wird geladen …',
              style: TextStyle(color: AppColors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// Wird angezeigt, wenn die Datenbank nicht geladen werden konnte. Verhindert, dass die App unbemerkt mit leeren Daten weiterläuft.

class _LoadErrorScreen extends StatelessWidget {
  const _LoadErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: AppColors.gold, size: 64),
              SizedBox(height: 24),
              Text(
                'Die Datenbank konnte nicht geladen werden.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bitte Internetverbindung prüfen und die App neu starten.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
