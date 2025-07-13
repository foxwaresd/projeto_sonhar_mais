import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream para escutar mudanças no estado de autenticação.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Método de login com email e senha.
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Método para envio de email para resetar senha.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Método de logout.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Pega o usuário logado atualmente.
  User? get currentUser => _firebaseAuth.currentUser;
}
