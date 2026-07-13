import 'package:core/core.dart';
import 'package:firebase/firebase.dart';

abstract class AuthService {
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  Future<Result<void>> signIn({required String email, required String password});
  Future<Result<void>> signOut();
}

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._firebaseAuthService);

  final FirebaseAuthService _firebaseAuthService;

  @override
  Stream<String?> get authStateChanges =>
      _firebaseAuthService.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _firebaseAuthService.currentUser?.uid;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Success(null);
    } catch (error) {
      return FailureResult(AuthFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuthService.signOut();
      return const Success(null);
    } catch (error) {
      return FailureResult(AuthFailure(error.toString()));
    }
  }
}
