// Der Profil-Bereich der App. 
// Änderung (Authentifizierung): vorher ein reiner Platzhalter mit fest eingetragenem Fantasie-Namen, jetzt der echte eingeloggte Nutzer.
// Edit Funktion analog zu den Kategorien.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../auth/data/auth_errors.dart';
import '../../auth/data/auth_repository.dart';
import '../../database/data/database_repository.dart';
import '../../database/domain/info_field.dart';
import '../../database/presentation/database_widgets.dart';
import '../../database/presentation/form_widgets.dart';
import '../../../app/app_drawer.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _dirty = false;
  bool _populating = false;
  bool _saving = false;

  // Editierbar sind nur Username und E-Mail (siehe Anforderung).
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _username.addListener(_markDirty);
    _email.addListener(_markDirty);
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_populating || _dirty) return;
    setState(() => _dirty = true);
  }

  void _startEditing(String currentUsername) {
    _populating = true;
    _username.text = currentUsername;
    _email.text = authRepo.currentUser?.email ?? '';
    _populating = false;
    setState(() {
      _editing = true;
      _dirty = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _dirty = false;
    });
  }

  // ---------- Speichern ----------

  Future<void> _save(String currentUsername) async {
    if (_saving) return;

    final String newUsername = _username.text.trim();
    final String newEmail = _email.text.trim();

    if (newUsername.isEmpty || newEmail.isEmpty) {
      showAppMessage(context, 'Username und E-Mail dürfen nicht leer sein!');
      return;
    }

    setState(() => _saving = true);
    try {
      // Username-Eindeutigkeit wird vorher geprüft und mit derselben Meldung wie überall sonst. Jedoch nur wenn er sich überhaupt geändert hat, sonst würde er ja immer schon "vergeben" sein.

      if (newUsername.toLowerCase() != currentUsername.toLowerCase()) {
        if (await authRepo.isUsernameTaken(newUsername)) {
          if (mounted) {
            showAppMessage(context, 'Dieser Username ist bereits vergeben!');
          }
          return;
        }
        await authRepo.updateUsername(newUsername);
      }

      final String currentEmail = authRepo.currentUser?.email ?? '';
      if (newEmail.toLowerCase() != currentEmail.toLowerCase()) {
        await _changeEmail(newEmail);
      }

      if (mounted) {
        setState(() {
          _editing = false;
          _dirty = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Ändert die E-Mail. Firebase verlangt dafür einen kürzlichen Login, ist der letzte Login schon zu lange her, verlangt Firebase eine erneute PW Eingabe.
  Future<void> _changeEmail(String newEmail) async {
    try {
      await authRepo.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;

      final String? password = await _askPassword();
      if (password == null || password.isEmpty) return;
      await authRepo.reauthenticate(password);
      await authRepo.updateEmail(newEmail);
    }

    if (mounted) {
      showAppMessage(
        context,
        'Wir haben einen Bestätigungslink an $newEmail geschickt. Die neue '
        'Adresse gilt erst, sobald du diesen Link angeklickt hast.',
      );
    }
  }

  // Fragt das aktuelle Passwort nochmals ab (für die erneute Anmeldung bei Firebase).
  Future<String?> _askPassword() {
    final TextEditingController password = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Passwort bestätigen'),
        content: PasswordField(
          controller: password,
          label: 'Aktuelles Passwort',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Abbrechen',
              style: TextStyle(color: AppColors.darkBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, password.text),
            child: const Text(
              'Bestätigen',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Passwort zurücksetzen / Abmelden ----------

  Future<void> _resetPassword() async {
    final String? email = authRepo.currentUser?.email;
    if (email == null) return;
    try {
      await authRepo.sendPasswordReset(email);
      if (mounted) {
        showAppMessage(
          context,
          'Wir haben einen Link zum Zurücksetzen des Passworts an $email '
          'geschickt.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) showAppMessage(context, authErrorMessage(e));
    }
  }

  Future<void> _logout() async {
    await authRepo.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Der Username wird sofort aktualisiert sobald er geändert wurde, damit die 
    // Bands-/Genres-Zähler unten beim Zurückkehren auf diesen Screen
    // zuverlässig den aktuellen Stand zeigen statt eines veralteten.
    return StreamBuilder<AuthProfile?>(
      stream: authRepo.currentProfile,
      builder: (context, snapshot) {
        final String username = snapshot.data?.username ?? '';
        final String email = authRepo.currentUser?.email ?? '';

        // Änderung: die vier Statistik-Karten (Bands/Genres-Anzahl) waren
        // doppelt mit der Database-Übersicht - stattdessen jetzt "Mitglied
        // seit" (kommt direkt von Firebase, kein neues Feld nötig) und
        // vier berechnete Kennzahlen aus den bestehenden Daten.
        final DateTime? mitgliedSeit = authRepo.currentUser?.metadata.creationTime;
        final List<InfoField> profilStatistiken = [
          InfoField(
            icon: Icons.calendar_today,
            label: 'Mitglied seit',
            value: mitgliedSeit != null ? _formatDate(mitgliedSeit) : '–',
          ),
          InfoField(
            icon: Icons.category_outlined,
            label: 'Genre mit den meisten Bands',
            value: repo.genreWithMostBands != null
                ? '${repo.genreWithMostBands!.title} (${repo.genreWithMostBandsCount})'
                : 'Noch keine Daten',
          ),
          InfoField(
            icon: Icons.queue_music,
            label: 'Genre mit den meisten Songs',
            value: repo.genreWithMostSongs != null
                ? '${repo.genreWithMostSongs!.title} (${repo.genreWithMostSongsCount})'
                : 'Noch keine Daten',
          ),
          InfoField(
            icon: Icons.library_music,
            label: 'Band mit den meisten Songs',
            value: repo.bandWithMostSongs != null
                ? '${repo.bandWithMostSongs!.title} (${repo.bandWithMostSongsCount})'
                : 'Noch keine Daten',
          ),
          InfoField(
            icon: Icons.album,
            label: 'Band mit den meisten Alben',
            value: repo.bandWithMostAlbums != null
                ? '${repo.bandWithMostAlbums!.title} (${repo.bandWithMostAlbumsCount})'
                : 'Noch keine Daten',
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
              if (_editing)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Abbrechen',
                  onPressed: _cancelEditing,
                )
              else
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Abmelden',
                  onPressed: _logout,
                ),
            ],
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil-Header mit Avatar und Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Profilbild: für alle Nutzer dasselbe Bild (das
                      // Launcher-Icon der App) statt der bisherigen
                      // Initialen - ein eigener Bild-Upload ist (noch)
                      // nicht vorgesehen.
                      // Etwas Padding statt BoxFit.cover, da das Icon sonst
                      // an den Rändern vom runden Zuschnitt abgeschnitten
                      // wird (das Icon füllt das Quadrat bis in die Ecken).
                      ClipOval(
                        child: Container(
                          width: 80,
                          height: 80,
                          color: AppColors.darkBlue,
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        username.isEmpty ? '…' : username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Statistiken
                for (final InfoField field in profilStatistiken) ...[
                  InfoBox(field: field),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 8),

                if (_editing) ...[
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _resetPassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Passwort zurücksetzen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: const BorderSide(color: AppColors.darkBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ],
            ),
          ),

          // Gleiches Prinzip wie in item_detail_screen.dart: Speichern nur sichtbar, wenn wirklich etwas geändert wurde.
          floatingActionButton: _editing
              ? (_dirty
                  ? FloatingActionButton.extended(
                      onPressed: _saving ? null : () => _save(username),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Speichern'),
                      shape: const StadiumBorder(),
                    )
                  : null)
              : FloatingActionButton.extended(
                  onPressed: () => _startEditing(username),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Bearbeiten'),
                  shape: const StadiumBorder(),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // Formatiert das Registrierungsdatum als "TT.MM.JJJJ".
  String _formatDate(DateTime date) {
    final String tag = date.day.toString().padLeft(2, '0');
    final String monat = date.month.toString().padLeft(2, '0');
    return '$tag.$monat.${date.year}';
  }
}
