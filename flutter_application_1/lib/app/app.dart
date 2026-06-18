// Hier liegt die MaterialApp mit dem globalen Theme und der Startseite.

import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicDB',
      debugShowCheckedModeBanner: false,

      // Globales Theme mit der definierten Farbpalette:
      // Mit coolors.co erstelltes Farbschema: https://coolors.co/363636-242f40-cca43b-e5e5e5-ffffff
     
      theme: ThemeData(
        // Hauptfarbe
        primaryColor: const Color(0xFF242F40),

        // App Hintergrund
        scaffoldBackgroundColor: const Color(0xFFE5E5E5),

        // AppBar Design
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242F40),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // BottomNavigationBar Design
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF242F40),
          selectedItemColor: Color(0xFFCCA43B),
          unselectedItemColor: Color(0xFFE5E5E5),
        ),

        // Farbe für Datenkarten (weisse boxen)
        cardColor: const Color(0xFFFFFFFF),

        // Farbschema Allg.
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF242F40),
          secondary: const Color(0xFFCCA43B),
        ),
      ),

      // Startseite ist der NavigationScreen
      home: const NavigationScreen(),
    );
  }
}
