import '../common/geo_location.dart';
import '../enums/branch_status.dart';

class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.location,
    this.supervisorId,
    this.riderIds = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    GeoLocation? location;
    if (locationJson is Map<String, dynamic>) {
      location = GeoLocation.fromJson(locationJson);
    } else if (json['address'] is Map<String, dynamic>) {
      final address = json['address'] as Map<String, dynamic>;
      if (address['lat'] != null || address['lng'] != null) {
        location = GeoLocation.fromJson(address);
      }
    }

    return Branch(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: BranchStatus.fromString(json['status'] as String? ?? 'inactive'),
      address: json['address'] is String
          ? json['address'] as String
          : (json['address'] is Map
              ? (json['address'] as Map)['street'] as String?
              : null),
      city: json['city'] as String? ??
          (json['address'] is Map
              ? (json['address'] as Map)['city'] as String?
              : null),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      location: location,
      supervisorId:
          json['supervisorId'] as String? ?? json['managerId'] as String?,
      riderIds: (json['riderIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  final String id;
  final String name;
  final String code;
  final BranchStatus status;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final GeoLocation? location;
  final String? supervisorId;
  final List<String> riderIds;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'status': status.name,
        'address': address,
        'city': city,
        'phone': phone,
        'email': email,
        'location': location?.toJson(),
        'supervisorId': supervisorId,
        'managerId': supervisorId,
        'riderIds': riderIds,
        'notes': notes,
      };

  Branch copyWith({
    String? id,
    String? name,
    String? code,
    BranchStatus? status,
    String? address,
    String? city,
    String? phone,
    String? email,
    GeoLocation? location,
    String? supervisorId,
    List<String>? riderIds,
    String? notes,
    bool clearSupervisor = false,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      supervisorId:
          clearSupervisor ? null : (supervisorId ?? this.supervisorId),
      riderIds: riderIds ?? this.riderIds,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
