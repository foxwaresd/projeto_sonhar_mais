import 'package:flutter/material.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? user;

  bool isLoading = false;

  AuthProvider() {
    _authService.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      user = await _authService.signInWithEmail(email, password);
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}
