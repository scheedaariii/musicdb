// Globaler ScaffoldMessenger-Key. Erlaubt es, SnackBars auch von Stellen ohne eigenen BuildContext anzuzeigen, z.B. wenn ein Firestore-Schreibvorgang im
// Hintergrund fehlschlägt - Eine Best practise die ich online gefunden hab und mit der Hilfe von AI Umgesetzt.

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
