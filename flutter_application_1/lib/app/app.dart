// MaterialApp mit den Designgrundlagen und der Startseite.

import 'package:flutter/material.dart';
import 'navigation_screen.dart';
import 'app_colors.dart';
import 'app_messenger.dart';
import '../features/database/data/database_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

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

        // Der runde Plus-Button. Steht hier im Theme, damit ihn nicht
        // jeder Screen einzeln einfärben muss.
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

      // Startseite wartet zuerst auf die Daten aus Firestore
      home: const _StartupScreen(),
    );
  }
}

// ================================================================
// Read: Erstes Laden der Datenbank aus Firestore
//
// DatabaseRepository.load() (siehe database_repository.dart) holt beim
// Start alle Sammlungen aus Firestore. _StartupScreen wartet darauf, statt
// dass main() das vorher übernahm - dort war während des Ladens nur der
// leere native Splash-Screen zu sehen. Jetzt zeigt die App währenddessen
// die eigene Ladeanzeige (_LoadingScreen) und bei einem Fehler eine
// verständliche Fehleranzeige (_LoadErrorScreen), statt entweder zu hängen
// oder unbemerkt mit leeren Daten weiterzulaufen.
// ================================================================
class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  late final Future<void> _laden = DatabaseRepository.instance.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _laden,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // FutureBuilder meldet einen fehlgeschlagenen Ladevorgang auch
          // als "done" - ohne diese Prüfung würde die App bei einem Fehler
          // (z.B. keine Internetverbindung) einfach mit leeren Daten
          // weiterlaufen, statt das kenntlich zu machen.
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

// Wird angezeigt, wenn die Datenbank nicht geladen werden konnte (z.B.
// keine Internetverbindung). Verhindert, dass die App unbemerkt mit
// leeren Daten weiterläuft.
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
