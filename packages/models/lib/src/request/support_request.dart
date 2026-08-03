import '../enums/app_role.dart';
import '../enums/support_request_status.dart';

class SupportRequest {
  const SupportRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdByName,
    required this.createdByRole,
    this.status = SupportRequestStatus.open,
    this.imageUrl,
    this.lastReplyAt,
    this.lastReplyPreview,
    this.lastReplyByRole,
    this.adminUnread = false,
    this.requesterUnread = false,
    this.closedAt,
    this.closedById,
    this.closedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportRequest.fromJson(Map<String, dynamic> json) {
    return SupportRequest(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdById: json['createdById'] as String? ?? '',
      createdByName: json['createdByName'] as String? ?? '',
      createdByRole: AppRole.fromString(
        json['createdByRole'] as String? ?? 'customer',
      ),
      status: SupportRequestStatus.fromString(
        json['status'] as String? ?? 'open',
      ),
      imageUrl: json['imageUrl'] as String?,
      lastReplyAt: json['lastReplyAt']?.toString(),
      lastReplyPreview: json['lastReplyPreview'] as String?,
      lastReplyByRole: json['lastReplyByRole'] as String?,
      adminUnread: json['adminUnread'] as bool? ?? false,
      requesterUnread: json['requesterUnread'] as bool? ?? false,
      closedAt: json['closedAt']?.toString(),
      closedById: json['closedById'] as String?,
      closedByName: json['closedByName'] as String?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  final String id;
  final String title;
  final String description;
  final String createdById;
  final String createdByName;
  final AppRole createdByRole;
  final SupportRequestStatus status;
  final String? imageUrl;
  final String? lastReplyAt;
  final String? lastReplyPreview;
  final String? lastReplyByRole;
  final bool adminUnread;
  final bool requesterUnread;
  final String? closedAt;
  final String? closedById;
  final String? closedByName;
  final String? createdAt;
  final String? updatedAt;

  String get roleLabel {
    switch (createdByRole) {
      case AppRole.customer:
        return 'Customer';
      case AppRole.driver:
        return 'Rider';
      case AppRole.supervisor:
        return 'Supervisor';
      case AppRole.admin:
        return 'Admin';
    }
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'createdById': createdById,
        'createdByName': createdByName,
        'createdByRole': createdByRole.name,
        'status': status.name,
        'imageUrl': imageUrl,
        'lastReplyAt': lastReplyAt,
        'lastReplyPreview': lastReplyPreview,
        'lastReplyByRole': lastReplyByRole,
        'adminUnread': adminUnread,
        'requesterUnread': requesterUnread,
        'closedAt': closedAt,
        'closedById': closedById,
        'closedByName': closedByName,
      };

  SupportRequest copyWith({
    String? id,
    SupportRequestStatus? status,
    bool? adminUnread,
    bool? requesterUnread,
    String? lastReplyAt,
    String? lastReplyPreview,
    String? lastReplyByRole,
    String? updatedAt,
  }) {
    return SupportRequest(
      id: id ?? this.id,
      title: title,
      description: description,
      createdById: createdById,
      createdByName: createdByName,
      createdByRole: createdByRole,
      status: status ?? this.status,
      imageUrl: imageUrl,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      lastReplyPreview: lastReplyPreview ?? this.lastReplyPreview,
      lastReplyByRole: lastReplyByRole ?? this.lastReplyByRole,
      adminUnread: adminUnread ?? this.adminUnread,
      requesterUnread: requesterUnread ?? this.requesterUnread,
      closedAt: closedAt,
      closedById: closedById,
      closedByName: closedByName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
