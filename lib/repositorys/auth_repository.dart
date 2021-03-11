import 'package:demo/exceptions/custom_exception.dart';
import 'package:demo/providers/general_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseAuthRepository {
  Stream<User?> get authStateChanges;
  User? getCurrentUser();
  Future<void> signInAnounmously();
  Future<void> signOut();
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<void> signUpwithEmailAndPassword(
      {required String email, required String password});
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read);
});

class AuthRepository implements BaseAuthRepository {
  final Reader _read;
  const AuthRepository(this._read);
  @override
  Stream<User?> get authStateChanges =>
      _read(firebaseAuthProvider).authStateChanges();

  @override
  User? getCurrentUser() {
    try {
      return _read(firebaseAuthProvider).currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signInAnounmously() async {
    try {
      _read(firebaseAuthProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _read(firebaseAuthProvider).signOut();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) {
    try {
      return _read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> signUpwithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
