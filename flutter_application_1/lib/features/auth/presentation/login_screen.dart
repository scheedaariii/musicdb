// login_screen.dart
// Wird gezeigt, solange niemand eingeloggt ist (siehe app.dart). Erst nach
// erfolgreichem Login wird die eigentliche App (NavigationScreen) sichtbar.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_errors.dart';
import '../data/auth_repository.dart';
import 'register_screen.dart';
import '../../database/presentation/database_widgets.dart';
import '../../database/presentation/form_widgets.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Verhindert einen zweiten Login-Versuch, während der erste noch läuft
  // (gleiches Muster wie _saving beim Speichern in der Datenbank).
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_submitting) return;

    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      showAppMessage(context, 'Bitte E-Mail und Passwort eingeben!');
      return;
    }

    setState(() => _submitting = true);
    try {
      await authRepo.signIn(
        email: _email.text,
        password: _password.text,
      );
      // Kein Navigator.push nötig: app.dart hört selbst auf den Login-Status
      // und wechselt automatisch zur App, sobald der Login erfolgreich war.
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      showAppMessage(
        context,
        'Bitte zuerst die E-Mail-Adresse oben eingeben.',
      );
      return;
    }
    try {
      await authRepo.sendPasswordReset(_email.text);
      if (mounted) {
        showAppMessage(
          context,
          'Wir haben einen Link zum Zurücksetzen des Passworts an '
          '${_email.text.trim()} geschickt.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, authErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const DetailHeader(
                icon: Icons.library_music,
                title: 'MusicDB',
                subtitle: 'Willkommen zurück',
              ),

              const SizedBox(height: 24),

              FormTextField(label: 'E-Mail', controller: _email),

              const SizedBox(height: 16),

              PasswordField(controller: _password, label: 'Passwort'),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(color: AppColors.darkBlue),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SaveButton(
                onPressed: _submitting ? null : _login,
                label: 'Anmelden',
                icon: Icons.login,
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Registrieren',
                    style: TextStyle(color: AppColors.darkBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
