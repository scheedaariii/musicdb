// MaterialApp mit den Designgrundlagen und der Startseite.

import 'package:flutter/material.dart';
import 'navigation_screen.dart';
import 'app_colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicDB',
      debugShowCheckedModeBanner: false,

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

      // Startseite ist der NavigationScreen
      home: const NavigationScreen(),
    );
  }
}
