// app_messenger.dart
// Globaler ScaffoldMessenger-Key. Erlaubt es, SnackBars auch von Stellen ohne
// eigenen BuildContext anzuzeigen, z.B. wenn ein Firestore-Schreibvorgang im
// Hintergrund fehlschlägt (siehe DatabaseRepository._write).

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
