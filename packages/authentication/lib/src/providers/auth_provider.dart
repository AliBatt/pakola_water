import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:models/models.dart';
import 'package:repositories/repositories.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  suspended,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<String?>? _authSubscription;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _authSubscription = _authRepository.watchAuthState().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(String? userId) async {
    if (userId == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.getCurrentUser();

    switch (result) {
      case Success<AppUser?>(:final value):
        _user = value;
        if (value == null) {
          _status = AuthStatus.unauthenticated;
        } else if (value.status == UserStatus.suspended) {
          _status = AuthStatus.suspended;
        } else {
          _status = AuthStatus.authenticated;
        }
      case FailureResult<AppUser?>(:final failure):
        _errorMessage = failure.message;
        _status = AuthStatus.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );

    return switch (result) {
      Success<void>() => () {
          _isLoading = false;
          notifyListeners();
          return true;
        }(),
      FailureResult<void>(:final failure) => () {
          _errorMessage = failure.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }(),
    };
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
