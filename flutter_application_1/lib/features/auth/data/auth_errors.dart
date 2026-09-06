// auth_errors.dart
// Übersetzt die Fehler-Codes von Firebase Auth in verständliche, deutsche
// Meldungen. Ohne das würde z.B. "wrong-password" oder "email-already-in-use"
// unübersetzt in einem Dialog auftauchen.

import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Diese E-Mail-Adresse wird bereits von einem anderen Konto verwendet.';
    case 'invalid-email':
      return 'Ungültige E-Mail-Adresse.';
    case 'weak-password':
      return 'Das Passwort ist zu schwach (mindestens 6 Zeichen).';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-Mail oder Passwort ist falsch.';
    case 'user-disabled':
      return 'Dieses Konto wurde deaktiviert.';
    case 'too-many-requests':
      return 'Zu viele Versuche. Bitte später erneut versuchen.';
    case 'network-request-failed':
      return 'Keine Internetverbindung. Bitte prüfen und erneut versuchen.';
    case 'requires-recent-login':
      return 'Diese Änderung erfordert eine kürzliche Anmeldung. Bitte aus- und wieder einloggen und erneut versuchen.';
    default:
      return 'Ein unbekannter Fehler ist aufgetreten (${e.code}).';
  }
}
