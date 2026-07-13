import '../auth/auth_service.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:models/models.dart';

abstract class UserService {
  Future<Result<AppUser?>> getCurrentUserProfile();
}

class UserServiceImpl implements UserService {
  UserServiceImpl(this._firestoreService, this._authService);

  final FirestoreService _firestoreService;
  final AuthService _authService;

  @override
  Future<Result<AppUser?>> getCurrentUserProfile() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return const Success(null);
    }

    try {
      final snapshot = await _firestoreService
          .doc(CollectionPaths.users, userId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        return const Success(null);
      }

      final data = Map<String, dynamic>.from(snapshot.data()!);
      data['id'] = snapshot.id;
      return Success(AppUser.fromJson(data));
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }
}
