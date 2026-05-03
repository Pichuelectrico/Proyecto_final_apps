import 'package:firebase_auth/firebase_auth.dart';

class AuthServicio {
  final FirebaseAuth _auth;

  AuthServicio({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  Future<User> register({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user!;
  }

  Future<void> logout() => _auth.signOut();
}
