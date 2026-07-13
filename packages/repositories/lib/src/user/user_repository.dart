import 'package:core/core.dart';
import 'package:models/models.dart';
import 'package:services/services.dart';

abstract class UserRepository {
  Future<Result<AppUser?>> getCurrentUser();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._userService);

  final UserService _userService;

  @override
  Future<Result<AppUser?>> getCurrentUser() {
    return _userService.getCurrentUserProfile();
  }
}
