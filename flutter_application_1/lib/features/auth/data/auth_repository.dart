// Zuständig für Login, Registrieren, Abmelden und die Profilverwaltung
// Firebase Auth kennt von sich aus nur E-Mail-Adressen (Eindeutigkeit wird dort automatisch geprüft). Einen Username kennt Firebase Auth nicht.
// Nach bestpractise und Beispielen gebaut. Ecken und Kanten mit AI gerade gezogen.
// es existiert aktuell keine Email Infrastruktur - Es werden also keine Mails für reset etc. verschickt! Code ist beispielhaft nach Firebase standard eingefügt.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProfile {
  final String username;

  const AuthProfile({required this.username});

  factory AuthProfile.fromMap(Map<String, dynamic> data) =>
      AuthProfile(username: data['username'] as String? ?? '');

  Map<String, dynamic> toMap(String username) => {
    'username': username,
    // Kleingeschriebene Kopie nur für den Eindeutigkeits-Vergleich, damit "Max" und "max" als derselbe Username gelten.
    'usernameLower': username.toLowerCase(),
  };
}

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Meldet jede Änderung des Login-Status. app.dart entscheidet danach, ob der Login-Screen oder die eigentliche App gezeigt wird.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Prüft, ob ein Username schon vergeben ist. Wird sowohl beim Registrieren als auch beim Bearbeiten des eigenen Profils verwendet.
  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> treffer = await _db
        .collection('users')
        .where('usernameLower', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    return treffer.docs.isNotEmpty;
  }

  // Legt ein neues Konto an und danach das passende Profil-Dokument mit dem gewählten Username.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set(AuthProfile(username: username.trim()).toMap(username.trim()));
  }

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  // PW Reset (keine mail infra dahinter aktuell)
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Live Aktualisierung von Änderungen im Usernamen
  Stream<AuthProfile?> get currentProfile {
    final User? user = currentUser;
    if (user == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? AuthProfile.fromMap(doc.data()!) : null);
  }

  Future<void> updateUsername(String newUsername) {
    final User user = currentUser!;
    return _db
        .collection('users')
        .doc(user.uid)
        .update(
          AuthProfile(username: newUsername.trim()).toMap(newUsername.trim()),
        );
  }

  // Ändert die E-Mail-Adresse. Firebase verlangt aus Sicherheitsgründen eine Bestätigung über einen Link an die neue Adresse (AI Input)
  Future<void> updateEmail(String newEmail) {
    final User user = currentUser!;
    return user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  // Bestätigt das aktuelle Passwort nochmals. (AI Input)
  Future<void> reauthenticate(String password) {
    final User user = currentUser!;
    final AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    return user.reauthenticateWithCredential(credential);
  }
}

final AuthRepository authRepo = AuthRepository.instance;
