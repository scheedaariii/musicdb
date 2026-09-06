// register_screen.dart
// Konto-Erstellung: Username, E-Mail und Passwort. Der Username wird nicht
// von Firebase Auth selbst verwaltet (das kennt nur E-Mails), sondern über
// eine eigene Firestore-Collection in auth_repository.dart geprüft und
// gespeichert.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_errors.dart';
import '../data/auth_repository.dart';
import '../../database/presentation/database_widgets.dart';
import '../../database/presentation/form_widgets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  // Einfache Prüfung auf eine plausible E-Mail-Form, bevor überhaupt zu
  // Firebase geschickt wird - gleiches Prinzip wie die Pflichtfeld-Prüfung
  // beim Erfassen neuer Datenbank-Einträge (add_data_screen.dart).
  bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _register() async {
    if (_submitting) return;

    final String username = _username.text.trim();
    final String email = _email.text.trim();

    if (username.isEmpty || email.isEmpty || _password.text.isEmpty) {
      showAppMessage(context, 'Bitte alle Felder ausfüllen!');
      return;
    }
    if (!_looksLikeEmail(email)) {
      showAppMessage(context, 'Bitte eine gültige E-Mail-Adresse angeben!');
      return;
    }
    if (_password.text.length < 6) {
      showAppMessage(context, 'Das Passwort muss mindestens 6 Zeichen haben!');
      return;
    }
    if (_password.text != _passwordConfirm.text) {
      showAppMessage(context, 'Die Passwörter stimmen nicht überein!');
      return;
    }

    setState(() => _submitting = true);
    try {
      // Eindeutigkeit des Usernames wird vorher geprüft und mit derselben
      // Meldung wie überall sonst in der App blockiert (siehe
      // add_data_screen.dart, _isUnique) - Firebase selbst kennt nur die
      // Eindeutigkeit der E-Mail (email-already-in-use weiter unten).
      if (await authRepo.isUsernameTaken(username)) {
        if (mounted) {
          showAppMessage(context, 'Dieser Username ist bereits vergeben!');
        }
        return;
      }

      await authRepo.register(
        username: username,
        email: email,
        password: _password.text,
      );
      // Änderung: Dieser Screen liegt per Navigator.push über dem
      // Login-Screen. Die Registrierung meldet zwar sofort an (Firebase-
      // Standardverhalten) und app.dart wechselt dadurch im Hintergrund
      // schon zur eigentlichen App - sichtbar blieb bisher aber trotzdem
      // dieser Screen, weil er ja weiterhin oben auf dem Navigator-Stack
      // lag. Darum jetzt zurück zur Wurzel, damit die eigentliche App
      // (bzw. der jetzt passende Screen aus app.dart) auch angezeigt wird.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DetailHeader(
                icon: Icons.person_add_alt_1,
                title: 'Konto erstellen',
                subtitle: 'Registriere dich bei MusicDB',
              ),

              const SizedBox(height: 24),

              FormTextField(
                label: 'Username',
                required: true,
                controller: _username,
              ),

              const SizedBox(height: 16),

              FormTextField(
                label: 'E-Mail',
                required: true,
                controller: _email,
              ),

              const SizedBox(height: 16),

              PasswordField(controller: _password, label: 'Passwort'),

              const SizedBox(height: 16),

              PasswordField(
                controller: _passwordConfirm,
                label: 'Passwort bestätigen',
              ),

              const SizedBox(height: 24),

              SaveButton(
                onPressed: _submitting ? null : _register,
                label: 'Registrieren',
                icon: Icons.person_add_alt_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
