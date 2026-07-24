import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:models/models.dart';

import '../auth/auth_service.dart';

class CreateUserAccountResult {
  const CreateUserAccountResult({
    required this.user,
    required this.temporaryPassword,
    required this.generatedEmail,
  });

  final AppUser user;
  final String temporaryPassword;
  final bool generatedEmail;
}

abstract class UserService {
  Future<Result<AppUser?>> getCurrentUserProfile();
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
  Future<Result<CreateUserAccountResult>> createUserProfile({
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
  Future<Result<AppUser>> updateUserProfile(AppUser user);
  Future<Result<void>> deleteUserProfile(String userId);
}

class UserServiceImpl implements UserService {
  UserServiceImpl(
    this._firestoreService,
    this._authService, {
    FirebaseAuthAdminService? authAdminService,
  }) : _authAdminService = authAdminService ?? FirebaseAuthAdminService();

  final FirestoreService _firestoreService;
  final AuthService _authService;
  final FirebaseAuthAdminService _authAdminService;

  @override
  Future<Result<AppUser?>> getCurrentUserProfile() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return const Success(null);
    }

    try {
      final snapshot =
          await _firestoreService.doc(CollectionPaths.users, userId).get();

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

  @override
  Future<Result<List<AppUser>>> listByRole(AppRole role) async {
    try {
      final snapshot = await _firestoreService.queryWhere(
        CollectionPaths.users,
        field: 'role',
        isEqualTo: role.name,
      );

      final users = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return AppUser.fromJson(data);
      }).toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

      return Success(users);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
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
  }) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return const FailureResult(AuthFailure('Not signed in'));
    }

    try {
      final resolvedBranches =
          branchIds.isEmpty ? [primaryBranchId] : branchIds;
      final user = AppUser(
        id: userId,
        email: email.trim(),
        displayName: displayName.trim(),
        phone: phone.trim(),
        address: address.trim(),
        location: location,
        role: AppRole.customer,
        status: UserStatus.active,
        branchIds: resolvedBranches,
        primaryBranchId: primaryBranchId,
      );

      final data = user.toJson()
        ..remove('id')
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestoreService.setDoc(CollectionPaths.users, userId, data);
      return Success(user);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<CreateUserAccountResult>> createUserProfile({
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
  }) async {
    try {
      final normalizedPhone = phone.trim();
      final generatedEmail = email == null || email.trim().isEmpty;
      final resolvedEmail = generatedEmail
          ? _emailFromPhone(normalizedPhone, role)
          : email.trim();
      final temporaryPassword =
          (password == null || password.isEmpty) ? _defaultPassword : password;

      final credential = await _authAdminService.createUser(
        email: resolvedEmail,
        password: temporaryPassword,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const FailureResult(
          ServerFailure('Failed to create auth account'),
        );
      }

      final user = AppUser(
        id: uid,
        email: resolvedEmail,
        displayName: displayName.trim(),
        phone: normalizedPhone,
        address: address?.trim(),
        notes: notes?.trim(),
        cnic: cnic?.trim(),
        experience: experience?.trim(),
        vehiclePlate: vehiclePlate?.trim(),
        role: role,
        status: status,
        branchIds: branchIds,
        primaryBranchId: primaryBranchId ??
            (branchIds.isNotEmpty ? branchIds.first : null),
      );

      final data = user.toJson()
        ..remove('id')
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestoreService.setDoc(CollectionPaths.users, uid, data);

      return Success(
        CreateUserAccountResult(
          user: user,
          temporaryPassword: temporaryPassword,
          generatedEmail: generatedEmail,
        ),
      );
    } on FirebaseAuthException catch (error) {
      return FailureResult(
        ServerFailure(error.message ?? error.code, code: error.code),
      );
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<AppUser>> updateUserProfile(AppUser user) async {
    try {
      final data = user.toJson()
        ..remove('id')
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _firestoreService.setDoc(
        CollectionPaths.users,
        user.id,
        data,
        merge: true,
      );
      return Success(user);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUserProfile(String userId) async {
    try {
      await _firestoreService.deleteDoc(CollectionPaths.users, userId);
      return const Success(null);
    } catch (error) {
      return FailureResult(ServerFailure(error.toString()));
    }
  }

  static const String _defaultPassword = 'Welcome@123456';

  String _emailFromPhone(String phone, AppRole role) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '${role.name}_$digits@pakolawaters.app';
  }
}
