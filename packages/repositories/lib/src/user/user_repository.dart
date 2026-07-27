import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class UserRepository {
  Future<Result<AppUser?>> getCurrentUser();
  Future<Result<List<AppUser>>> listByRole(AppRole role);
  Future<Result<AppUser>> createSelfProfile({
    required String email,
    required String displayName,
    required String phone,
    required String address,
    required GeoLocation location,
    required String primaryBranchId,
    List<String> branchIds = const [],
  });
  Future<Result<CreateUserAccountResult>> createUser({
    required String displayName,
    required String phone,
    required AppRole role,
    required UserStatus status,
    String? email,
    String? address,
    String? notes,
    String? cnic,
    String? experience,
    String? vehiclePlate,
    String? primaryBranchId,
    List<String> branchIds = const [],
    String? password,
  });
  Future<Result<AppUser>> updateUser(AppUser user);
  Future<Result<void>> deleteUser(String userId);
  Future<Result<void>> registerFcmToken({
    required String userId,
    required String token,
  });
  Future<Result<void>> unregisterFcmToken({
    required String userId,
    required String token,
  });
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._userService);

  final UserService _userService;

  @override
  Future<Result<AppUser?>> getCurrentUser() {
    return _userService.getCurrentUserProfile();
  }

  @override
  Future<Result<List<AppUser>>> listByRole(AppRole role) {
    return _userService.listByRole(role);
  }

  @override
  Future<Result<AppUser>> createSelfProfile({
    required String email,
    required String displayName,
    required String phone,
    required String address,
    required GeoLocation location,
    required String primaryBranchId,
    List<String> branchIds = const [],
  }) {
    return _userService.createSelfProfile(
      email: email,
      displayName: displayName,
      phone: phone,
      address: address,
      location: location,
      primaryBranchId: primaryBranchId,
      branchIds: branchIds,
    );
  }

  @override
  Future<Result<CreateUserAccountResult>> createUser({
    required String displayName,
    required String phone,
    required AppRole role,
    required UserStatus status,
    String? email,
    String? address,
    String? notes,
    String? cnic,
    String? experience,
    String? vehiclePlate,
    String? primaryBranchId,
    List<String> branchIds = const [],
    String? password,
  }) {
    return _userService.createUserProfile(
      displayName: displayName,
      phone: phone,
      role: role,
      status: status,
      email: email,
      address: address,
      notes: notes,
      cnic: cnic,
      experience: experience,
      vehiclePlate: vehiclePlate,
      primaryBranchId: primaryBranchId,
      branchIds: branchIds,
      password: password,
    );
  }

  @override
  Future<Result<AppUser>> updateUser(AppUser user) {
    return _userService.updateUserProfile(user);
  }

  @override
  Future<Result<void>> deleteUser(String userId) {
    return _userService.deleteUserProfile(userId);
  }

  @override
  Future<Result<void>> registerFcmToken({
    required String userId,
    required String token,
  }) {
    return _userService.registerFcmToken(userId: userId, token: token);
  }

  @override
  Future<Result<void>> unregisterFcmToken({
    required String userId,
    required String token,
  }) {
    return _userService.unregisterFcmToken(userId: userId, token: token);
  }
}
