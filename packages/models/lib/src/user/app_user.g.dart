// GENERATED CODE - manually maintained alongside app_user.dart
// ignore_for_file: type=lint

part of 'app_user.dart';

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] is Map<String, dynamic>
          ? GeoLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      cnic: json['cnic'] as String?,
      experience: json['experience'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
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
      'address': instance.address,
      if (instance.location != null) 'location': instance.location!.toJson(),
      'notes': instance.notes,
      'cnic': instance.cnic,
      'experience': instance.experience,
      'vehiclePlate': instance.vehiclePlate,
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
  UserStatus.inactive: 'inactive',
  UserStatus.suspended: 'suspended',
  UserStatus.pending: 'pending',
};

T? $enumDecodeNullable<T extends Enum>(
  Map<T, String> enumMap,
  Object? source,
) {
  if (source == null) return null;
  for (final entry in enumMap.entries) {
    if (entry.value == source) return entry.key;
  }
  return null;
}
