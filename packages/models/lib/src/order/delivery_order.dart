import '../common/geo_location.dart';
import '../enums/order_status.dart';
import '../enums/payment_method.dart';

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.branchId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.paymentMethod,
    required this.status,
    this.customerPhone,
    this.branchName,
    this.note,
    this.paymentStatus = 'pending',
    this.supervisorId,
    this.riderId,
    this.riderName,
    this.estimatedArrivalAt,
    this.supervisorNotifiedAt,
    this.assignedAt,
    this.riderArrivedAt,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.deliveryLocation,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String?,
      branchId: json['branchId'] as String? ?? '',
      branchName: json['branchName'] as String?,
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
      paymentMethod: PaymentMethod.fromString(
        json['paymentMethod'] as String? ?? 'cod',
      ),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      supervisorId: json['supervisorId'] as String?,
      riderId: json['riderId'] as String?,
      riderName: json['riderName'] as String?,
      estimatedArrivalAt: json['estimatedArrivalAt']?.toString(),
      supervisorNotifiedAt: json['supervisorNotifiedAt']?.toString(),
      assignedAt: json['assignedAt']?.toString(),
      riderArrivedAt: json['riderArrivedAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryLocation: json['deliveryLocation'] is Map<String, dynamic>
          ? GeoLocation.fromJson(
              json['deliveryLocation'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String branchId;
  final String? branchName;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String? note;
  final PaymentMethod paymentMethod;
  final String paymentStatus;
  final OrderStatus status;
  final String? supervisorId;
  final String? riderId;
  final String? riderName;
  final String? estimatedArrivalAt;
  final String? supervisorNotifiedAt;
  final String? assignedAt;
  final String? riderArrivedAt;
  final String? deliveredAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deliveryAddress;
  final GeoLocation? deliveryLocation;

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'branchId': branchId,
        'branchName': branchName,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
        'note': note,
        'paymentMethod': paymentMethod.name,
        'paymentStatus': paymentStatus,
        'status': status.name,
        'supervisorId': supervisorId,
        'riderId': riderId,
        'riderName': riderName,
        'estimatedArrivalAt': estimatedArrivalAt,
        'supervisorNotifiedAt': supervisorNotifiedAt,
        'assignedAt': assignedAt,
        'riderArrivedAt': riderArrivedAt,
        'deliveredAt': deliveredAt,
        'deliveryAddress': deliveryAddress,
        if (deliveryLocation != null)
          'deliveryLocation': deliveryLocation!.toJson(),
      };

  DeliveryOrder copyWith({
    String? id,
    OrderStatus? status,
    String? riderId,
    String? riderName,
    String? estimatedArrivalAt,
    String? deliveredAt,
    String? updatedAt,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      branchId: branchId,
      branchName: branchName,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      note: note,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status ?? this.status,
      supervisorId: supervisorId,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      estimatedArrivalAt: estimatedArrivalAt ?? this.estimatedArrivalAt,
      supervisorNotifiedAt: supervisorNotifiedAt,
      assignedAt: assignedAt,
      riderArrivedAt: riderArrivedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress,
      deliveryLocation: deliveryLocation,
    );
  }
}
