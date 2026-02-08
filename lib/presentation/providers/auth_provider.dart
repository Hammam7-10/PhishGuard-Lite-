import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Student-friendly auth:
/// - Prefer Firebase Auth if initialization works.
/// - Also store last logged-in email locally so the app doesn't feel "logged out"
///   if user opens it again (useful for demo/testing).
class AuthProvider extends ChangeNotifier {
  static const _kLastEmail = 'lastEmail';

  bool firebaseReady = false;
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> bootstrap() async {
    try {
      await Firebase.initializeApp();
      firebaseReady = true;
      _user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      firebaseReady = false;
      _user = null;
    }

    // Local hint (does not bypass Firebase security; just UX helper)
    // If Firebase is ready and user is null, we still show Login screen.
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (!firebaseReady) {
      throw Exception('Firebase not ready. Check configuration.');
    }
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _user = cred.user;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastEmail, email.trim());
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    if (!firebaseReady) {
      throw Exception('Firebase not ready. Check configuration.');
    }
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _user = cred.user;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastEmail, email.trim());
    notifyListeners();
  }

  Future<void> logout() async {
    if (firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
    _user = null;
    notifyListeners();
  }

  Future<String?> getLastEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLastEmail);
  }
}
