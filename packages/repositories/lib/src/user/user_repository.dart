import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class UserRepository {
  Future<Result<AppUser?>> getCurrentUser();
  Future<Result<List<AppUser>>> listByRole(AppRole role);
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
}
