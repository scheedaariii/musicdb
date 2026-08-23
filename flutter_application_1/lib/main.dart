// Einstiegspunkt der App.
// Verbindet mit Firebase und lädt die Datenbank aus Firestore, bevor die
// eigentliche App startet. Bis dahin bleibt der native Splash-Screen sichtbar.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'features/database/data/database_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseRepository.instance.load();
  runApp(const App());
}
