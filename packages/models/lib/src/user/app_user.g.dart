// GENERATED CODE - run `dart run build_runner build` in packages/models
// ignore_for_file: type=lint

part of 'app_user.dart';

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      phone: json['phone'] as String?,
      role: $enumDecodeNullable(_$AppRoleEnumMap, json['role']) ??
          AppRole.customer,
      status: $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
          UserStatus.pending,
      branchIds: (json['branchIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      primaryBranchId: json['primaryBranchId'] as String?,
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'phone': instance.phone,
      'role': _$AppRoleEnumMap[instance.role]!,
      'status': _$UserStatusEnumMap[instance.status]!,
      'branchIds': instance.branchIds,
      'primaryBranchId': instance.primaryBranchId,
    };

const _$AppRoleEnumMap = {
  AppRole.customer: 'customer',
  AppRole.driver: 'driver',
  AppRole.supervisor: 'supervisor',
  AppRole.admin: 'admin',
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.suspended: 'suspended',
  UserStatus.pending: 'pending',
};

T? $enumDecodeNullable<T extends Enum>(
  Map<T, String> enumMap,
  Object? source,
) {
  if (source == null) return null;
  return enumMap.entries
      .singleWhere(
        (entry) => entry.value == source,
        orElse: () => throw ArgumentError('Unknown enum value: $source'),
      )
      .key;
}
