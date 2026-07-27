import '../enums/order_message_type.dart';

class OrderMessage {
  const OrderMessage({
    required this.id,
    required this.orderId,
    required this.message,
    required this.type,
    required this.createdById,
    required this.createdByName,
    required this.createdByRole,
    this.createdAt,
  });

  factory OrderMessage.fromJson(Map<String, dynamic> json) {
    return OrderMessage(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: OrderMessageType.fromString(
        json['type'] as String? ?? 'customerMessage',
      ),
      createdById: json['createdById'] as String? ?? '',
      createdByName: json['createdByName'] as String? ?? '',
      createdByRole: json['createdByRole'] as String? ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }

  final String id;
  final String orderId;
  final String message;
  final OrderMessageType type;
  final String createdById;
  final String createdByName;
  final String createdByRole;
  final String? createdAt;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'message': message,
        'type': type.name,
        'createdById': createdById,
        'createdByName': createdByName,
        'createdByRole': createdByRole,
      };
}
