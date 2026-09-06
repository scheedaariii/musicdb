// auth_repository.dart
// Zuständig für Login, Registrieren, Abmelden und die Profilverwaltung
// (Username) über Firebase Auth. Gleich aufgebaut wie das repo-Singleton in
// database_repository.dart: eine einzige Instanz, über die die ganze App
// auf denselben Login-Status zugreift.
//
// Firebase Auth kennt von sich aus nur E-Mail-Adressen (Eindeutigkeit wird
// dort automatisch geprüft). Einen Username kennt Firebase Auth nicht -
// dafür gibt es die eigene Firestore-Collection "users" (ein Dokument pro
// Nutzer, Dokument-ID = die Firebase-UID), über die auch die
// Username-Eindeutigkeit selbst geprüft wird.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProfile {
  final String username;

  const AuthProfile({required this.username});

  factory AuthProfile.fromMap(Map<String, dynamic> data) =>
      AuthProfile(username: data['username'] as String? ?? '');

  Map<String, dynamic> toMap(String username) => {
        'username': username,
        // Kleingeschriebene Kopie nur für den Eindeutigkeits-Vergleich,
        // damit "Max" und "max" als derselbe Username gelten.
        'usernameLower': username.toLowerCase(),
      };
}

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Meldet jede Änderung des Login-Status. app.dart entscheidet danach, ob
  // der Login-Screen oder die eigentliche App gezeigt wird.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Prüft, ob ein Username schon vergeben ist. Wird sowohl beim
  // Registrieren als auch beim Bearbeiten des eigenen Profils gebraucht.
  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> treffer = await _db
        .collection('users')
        .where('usernameLower', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    return treffer.docs.isNotEmpty;
  }

  // Legt ein neues Konto an und danach das passende Profil-Dokument mit dem
  // gewählten Username.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
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

  // Löst Firebases eigenen "Passwort zurücksetzen"-Ablauf aus: die Nutzerin/
  // der Nutzer bekommt einen Link per E-Mail zugeschickt.
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Liefert das Profil-Dokument des eingeloggten Nutzers, live - damit der
  // Profil-Screen den Username sofort aktualisiert zeigt, sobald er
  // geändert wurde.
  Stream<AuthProfile?> get currentProfile {
    final User? user = currentUser;
    if (user == null) return Stream.value(null);
    return _db.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.exists ? AuthProfile.fromMap(doc.data()!) : null,
        );
  }

  Future<void> updateUsername(String newUsername) {
    final User user = currentUser!;
    return _db
        .collection('users')
        .doc(user.uid)
        .update(AuthProfile(username: newUsername.trim())
            .toMap(newUsername.trim()));
  }

  // Ändert die E-Mail-Adresse. Firebase verlangt aus Sicherheitsgründen eine
  // Bestätigung über einen Link an die neue Adresse - die Änderung ist also
  // nicht sofort wirksam, sondern erst nach dem Klick auf diesen Link.
  Future<void> updateEmail(String newEmail) {
    final User user = currentUser!;
    return user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  // Bestätigt das aktuelle Passwort nochmals. Wird gebraucht, wenn Firebase
  // eine sensible Änderung (z.B. updateEmail) wegen "requires-recent-login"
  // ablehnt, weil der letzte Login schon zu lange her ist.
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
