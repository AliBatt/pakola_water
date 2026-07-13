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
    this.branchIds = const [],
    this.primaryBranchId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  final String id;
  final String email;
  final String displayName;
  final String? phone;
  @JsonKey(unknownEnumValue: AppRole.customer)
  final AppRole role;
  @JsonKey(unknownEnumValue: UserStatus.pending)
  final UserStatus status;
  final List<String> branchIds;
  final String? primaryBranchId;

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
