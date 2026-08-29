// Einstiegspunkt der App.
// Verbindet mit Firebase, danach startet die App sofort. Das Laden der Datenbank aus Firestore übernimmt App selbst und zeigt währenddessen eine eigene Ladeanzeige 

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}
