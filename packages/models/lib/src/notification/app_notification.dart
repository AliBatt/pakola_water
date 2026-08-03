class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdById,
    required this.createdByRole,
    this.createdByName,
    this.read = false,
    this.type = 'general',
    this.orderId,
    this.requestId,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdById: json['createdById'] as String? ?? '',
      createdByRole: json['createdByRole'] as String? ?? 'admin',
      createdByName: json['createdByName'] as String?,
      read: json['read'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
      orderId: json['orderId'] as String?,
      requestId: json['requestId'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String body;
  final String createdById;
  final String createdByRole;
  final String? createdByName;
  final bool read;
  final String type;
  final String? orderId;
  final String? requestId;
  final String? createdAt;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'body': body,
        'createdById': createdById,
        'createdByRole': createdByRole,
        'createdByName': createdByName,
        'read': read,
        'type': type,
        'orderId': orderId,
        'requestId': requestId,
      };

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      createdById: createdById,
      createdByRole: createdByRole,
      createdByName: createdByName,
      read: read ?? this.read,
      type: type,
      orderId: orderId,
      requestId: requestId,
      createdAt: createdAt,
    );
  }
}
