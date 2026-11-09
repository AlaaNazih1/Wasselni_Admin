import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthRepository {
  final FirebaseAuth _firebaseAuth;

  AdminAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
Future<void> bootstrapAdmin() async {
    final callable = FirebaseFunctions.instance.httpsCallable('bootstrapAdmin');

    await callable.call();
  }
  Future<bool> isAdmin() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) return false;

    final idTokenResult = await user.getIdTokenResult(true);

    return idTokenResult.claims?['admin'] == true;
  }
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser => _firebaseAuth.currentUser;
}
