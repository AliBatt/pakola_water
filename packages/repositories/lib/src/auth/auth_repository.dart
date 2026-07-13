import 'package:core/core.dart';
import 'package:services/services.dart';

abstract class AuthRepository {
  Stream<String?> watchAuthState();
  Future<Result<void>> signIn({required String email, required String password});
  Future<Result<void>> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  @override
  Stream<String?> watchAuthState() => _authService.authStateChanges;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }

  @override
  Future<Result<void>> signOut() => _authService.signOut();
}
