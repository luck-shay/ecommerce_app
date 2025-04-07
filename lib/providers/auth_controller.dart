import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

// Provider to expose the authentication state changes
final authControllerProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider to expose the AuthController instance
final authControllerInstanceProvider = Provider<AuthController>((ref) {
  return AuthController(FirebaseAuth.instance);
});

// Class to hold the authentication state (loading, error message)
@immutable // Good practice for state classes
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    // Setting errorMessage to null clears the previous error
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // If null is passed, it becomes null
    );
  }
}

class AuthController {
  final FirebaseAuth _auth;

  AuthController(this._auth);

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
