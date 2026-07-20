import 'package:json_annotation/json_annotation.dart';

import '../enums/app_role.dart';
import '../enums/user_status.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    this.phone,
    this.address,
    this.notes,
    this.cnic,
    this.experience,
    this.vehiclePlate,
    this.branchIds = const [],
    this.primaryBranchId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  final String id;
  final String email;
  final String displayName;
  final String? phone;
  final String? address;
  final String? notes;
  final String? cnic;
  final String? experience;
  final String? vehiclePlate;
  @JsonKey(unknownEnumValue: AppRole.customer)
  final AppRole role;
  @JsonKey(unknownEnumValue: UserStatus.pending)
  final UserStatus status;
  final List<String> branchIds;
  final String? primaryBranchId;

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    String? address,
    String? notes,
    String? cnic,
    String? experience,
    String? vehiclePlate,
    AppRole? role,
    UserStatus? status,
    List<String>? branchIds,
    String? primaryBranchId,
    bool clearPrimaryBranch = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      cnic: cnic ?? this.cnic,
      experience: experience ?? this.experience,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      role: role ?? this.role,
      status: status ?? this.status,
      branchIds: branchIds ?? this.branchIds,
      primaryBranchId: clearPrimaryBranch
          ? null
          : (primaryBranchId ?? this.primaryBranchId),
    );
  }
}
