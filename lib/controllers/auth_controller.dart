import 'dart:async';

import 'package:demo/exceptions/custom_exception.dart';
import 'package:demo/repositorys/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController>((ref) {
  return AuthController(ref.read)..appStarted();
});
final loginExceptionProvider = StateProvider<CustomException?>((_) => null);

class AuthController extends StateNotifier<User?> {
  final Reader _read;
  StreamSubscription<User?>? _authStateChangesSubscription;
  AuthController(this._read) : super(null) {
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription = _read(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }
  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  void appStarted() async {
    _read(authRepositoryProvider).getCurrentUser();
    // if (user == null) {
    //   await _read(authRepositoryProvider).signInAnounmously();
    // }
  }

  void signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email, password: password);
    } on CustomException catch (e) {
      _read(loginExceptionProvider).state = e;
    }
  }

  void signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      _read(authRepositoryProvider)
          .signUpwithEmailAndPassword(email: email, password: password);
    } on CustomException catch (e) {
      _read(loginExceptionProvider).state = e;
    }
  }

  void signOut() async {
    await _read(authRepositoryProvider).signOut();
  }
}
