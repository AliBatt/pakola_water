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
  bool _isSigningUp = false;
  StreamSubscription<String?>? _authSubscription;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _authSubscription = _authRepository.watchAuthState().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(String? userId) async {
    if (_isSigningUp) return;

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
          // Auth exists but profile not written yet (mid-signup).
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

  /// Creates Auth account + Firestore customer profile, then refreshes session.
  Future<bool> signUpCustomer({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String address,
    required GeoLocation location,
    required String primaryBranchId,
  }) async {
    _isLoading = true;
    _isSigningUp = true;
    _errorMessage = null;
    notifyListeners();

    final authResult = await _authRepository.signUp(
      email: email,
      password: password,
    );

    switch (authResult) {
      case FailureResult<void>(:final failure):
        _errorMessage = failure.message;
        _isLoading = false;
        _isSigningUp = false;
        notifyListeners();
        return false;
      case Success<void>():
        break;
    }

    final profileResult = await _userRepository.createSelfProfile(
      email: email,
      displayName: displayName,
      phone: phone,
      address: address,
      location: location,
      primaryBranchId: primaryBranchId,
      branchIds: [primaryBranchId],
    );

    _isSigningUp = false;

    return switch (profileResult) {
      Success<AppUser>(:final value) => () {
          _user = value;
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        }(),
      FailureResult<AppUser>(:final failure) => () {
          _errorMessage = failure.message;
          _isLoading = false;
          notifyListeners();
          return false;
        }(),
    };
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.sendPasswordResetEmail(email);

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

  Future<void> refreshProfile() => _loadUserProfile();

  /// Deletes Firestore profile then Firebase Auth user.
  Future<bool> deleteAccount() async {
    final userId = _user?.id;
    if (userId == null) {
      _errorMessage = 'Not signed in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final profileResult = await _userRepository.deleteUser(userId);
    if (profileResult case FailureResult(:final failure)) {
      _errorMessage = failure.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final authResult = await _authRepository.deleteAccount();
    return switch (authResult) {
      Success<void>() => () {
          _user = null;
          _status = AuthStatus.unauthenticated;
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
