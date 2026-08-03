class SupportRequestReply {
  const SupportRequestReply({
    required this.id,
    required this.requestId,
    required this.message,
    required this.createdById,
    required this.createdByName,
    required this.createdByRole,
    this.createdAt,
  });

  factory SupportRequestReply.fromJson(Map<String, dynamic> json) {
    return SupportRequestReply(
      id: json['id'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdById: json['createdById'] as String? ?? '',
      createdByName: json['createdByName'] as String? ?? '',
      createdByRole: json['createdByRole'] as String? ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }

  final String id;
  final String requestId;
  final String message;
  final String createdById;
  final String createdByName;
  final String createdByRole;
  final String? createdAt;

  bool get isFromAdmin => createdByRole == 'admin';

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'message': message,
        'createdById': createdById,
        'createdByName': createdByName,
        'createdByRole': createdByRole,
      };
}
