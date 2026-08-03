import '../common/geo_location.dart';
import '../enums/order_status.dart';
import '../enums/order_type.dart';
import '../enums/payment_method.dart';
import '../enums/payment_status.dart';

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
    this.orderType = OrderType.instant,
    this.scheduledFor,
    this.scheduledActivatedAt,
    this.customerPhone,
    this.branchName,
    this.note,
    this.paymentStatus = PaymentStatus.pending,
    this.supervisorId,
    this.supervisorName,
    this.riderId,
    this.riderName,
    this.estimatedArrivalAt,
    this.supervisorNotifiedAt,
    this.assignedAt,
    this.outForDeliveryAt,
    this.riderArrivedAt,
    this.deliveredAt,
    this.failedAt,
    this.failureReason,
    this.adminNotes,
    this.adminActionById,
    this.adminActionByName,
    this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.deliveryLocation,
    this.isCustomDeliveryLocation = false,
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
      paymentStatus: PaymentStatus.fromString(
        json['paymentStatus'] as String? ?? 'pending',
      ),
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      orderType: OrderType.fromString(
        json['orderType'] as String? ?? 'instant',
      ),
      scheduledFor: json['scheduledFor']?.toString(),
      scheduledActivatedAt: json['scheduledActivatedAt']?.toString(),
      supervisorId: json['supervisorId'] as String?,
      supervisorName: json['supervisorName'] as String?,
      riderId: json['riderId'] as String?,
      riderName: json['riderName'] as String?,
      estimatedArrivalAt: json['estimatedArrivalAt']?.toString(),
      supervisorNotifiedAt: json['supervisorNotifiedAt']?.toString(),
      assignedAt: json['assignedAt']?.toString(),
      outForDeliveryAt: json['outForDeliveryAt']?.toString(),
      riderArrivedAt: json['riderArrivedAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      failedAt: json['failedAt']?.toString(),
      failureReason: json['failureReason'] as String?,
      adminNotes: json['adminNotes'] as String?,
      adminActionById: json['adminActionById'] as String?,
      adminActionByName: json['adminActionByName'] as String?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryLocation: json['deliveryLocation'] is Map<String, dynamic>
          ? GeoLocation.fromJson(
              json['deliveryLocation'] as Map<String, dynamic>,
            )
          : null,
      isCustomDeliveryLocation:
          json['isCustomDeliveryLocation'] as bool? ?? false,
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
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final OrderType orderType;
  final String? scheduledFor;
  final String? scheduledActivatedAt;
  final String? supervisorId;
  final String? supervisorName;
  final String? riderId;
  final String? riderName;
  final String? estimatedArrivalAt;
  final String? supervisorNotifiedAt;
  final String? assignedAt;
  final String? outForDeliveryAt;
  final String? riderArrivedAt;
  final String? deliveredAt;
  final String? failedAt;
  final String? failureReason;
  final String? adminNotes;
  final String? adminActionById;
  final String? adminActionByName;
  final String? createdAt;
  final String? updatedAt;
  final String? deliveryAddress;
  final GeoLocation? deliveryLocation;
  final bool isCustomDeliveryLocation;

  DateTime? get scheduledForDate => _parse(scheduledFor);
  DateTime? get scheduledActivatedAtDate => _parse(scheduledActivatedAt);

  bool get isScheduledOrder =>
      orderType == OrderType.scheduled || status == OrderStatus.scheduled;

  /// Address shown in UI, with "(custom location)" when order-specific.
  String get deliveryAddressLabel {
    final address = deliveryAddress?.trim();
    if (address == null || address.isEmpty) {
      return isCustomDeliveryLocation ? '(custom location)' : '—';
    }
    if (isCustomDeliveryLocation) {
      return '$address (custom location)';
    }
    return address;
  }

  bool get isUnpaidCredit =>
      paymentMethod == PaymentMethod.credit &&
      paymentStatus.isUnpaid &&
      status != OrderStatus.cancelled &&
      status != OrderStatus.failed;

  /// Cancelled / failed orders stay unpaid and are not actionable in payments.
  bool get isCancelledUnpaid =>
      status == OrderStatus.cancelled && paymentStatus.isUnpaid;

  bool get blocksPaymentActions =>
      status == OrderStatus.cancelled || status == OrderStatus.failed;

  /// COD is collected on delivery; credit stays pending until marked paid.
  PaymentStatus get effectivePaymentStatus {
    if (paymentMethod == PaymentMethod.cod &&
        status == OrderStatus.delivered) {
      return PaymentStatus.paid;
    }
    return paymentStatus;
  }

  DateTime? get createdAtDate => _parse(createdAt);
  DateTime? get assignedAtDate => _parse(assignedAt);
  DateTime? get outForDeliveryAtDate => _parse(outForDeliveryAt);
  DateTime? get riderArrivedAtDate => _parse(riderArrivedAt);
  DateTime? get deliveredAtDate => _parse(deliveredAt);
  DateTime? get failedAtDate => _parse(failedAt);

  /// Time from order placed until supervisor assigned a rider.
  Duration? get supervisorAssignDuration {
    final start = createdAtDate;
    final end = assignedAtDate;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  /// Time from rider assigned until delivery confirmed.
  Duration? get riderDeliveryDuration {
    final start = assignedAtDate;
    final end = deliveredAtDate ?? failedAtDate;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  /// Time from rider arrived until customer confirmed delivery.
  Duration? get customerConfirmDuration {
    final start = riderArrivedAtDate;
    final end = deliveredAtDate;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

  /// Total lifecycle time until delivered or failed.
  Duration? get totalOrderDuration {
    final start = createdAtDate;
    final end = deliveredAtDate ?? failedAtDate;
    if (start == null || end == null) return null;
    return end.difference(start);
  }

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
        'paymentStatus': paymentStatus.name,
        'status': status.name,
        'orderType': orderType.name,
        'scheduledFor': scheduledFor,
        'scheduledActivatedAt': scheduledActivatedAt,
        'supervisorId': supervisorId,
        'supervisorName': supervisorName,
        'riderId': riderId,
        'riderName': riderName,
        'estimatedArrivalAt': estimatedArrivalAt,
        'supervisorNotifiedAt': supervisorNotifiedAt,
        'assignedAt': assignedAt,
        'outForDeliveryAt': outForDeliveryAt,
        'riderArrivedAt': riderArrivedAt,
        'deliveredAt': deliveredAt,
        'failedAt': failedAt,
        'failureReason': failureReason,
        'adminNotes': adminNotes,
        'adminActionById': adminActionById,
        'adminActionByName': adminActionByName,
        'deliveryAddress': deliveryAddress,
        'isCustomDeliveryLocation': isCustomDeliveryLocation,
        if (deliveryLocation != null)
          'deliveryLocation': deliveryLocation!.toJson(),
      };

  DeliveryOrder copyWith({
    String? id,
    OrderStatus? status,
    OrderType? orderType,
    String? scheduledFor,
    String? scheduledActivatedAt,
    PaymentStatus? paymentStatus,
    String? supervisorId,
    String? supervisorName,
    String? riderId,
    String? riderName,
    String? estimatedArrivalAt,
    String? supervisorNotifiedAt,
    String? assignedAt,
    String? outForDeliveryAt,
    String? riderArrivedAt,
    String? deliveredAt,
    String? failedAt,
    String? failureReason,
    String? adminNotes,
    String? adminActionById,
    String? adminActionByName,
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
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      scheduledActivatedAt: scheduledActivatedAt ?? this.scheduledActivatedAt,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorName: supervisorName ?? this.supervisorName,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      estimatedArrivalAt: estimatedArrivalAt ?? this.estimatedArrivalAt,
      supervisorNotifiedAt:
          supervisorNotifiedAt ?? this.supervisorNotifiedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      outForDeliveryAt: outForDeliveryAt ?? this.outForDeliveryAt,
      riderArrivedAt: riderArrivedAt ?? this.riderArrivedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
      adminNotes: adminNotes ?? this.adminNotes,
      adminActionById: adminActionById ?? this.adminActionById,
      adminActionByName: adminActionByName ?? this.adminActionByName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress,
      deliveryLocation: deliveryLocation,
      isCustomDeliveryLocation: isCustomDeliveryLocation,
    );
  }

  static DateTime? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

extension DurationFormat on Duration {
  String get shortLabel {
    final totalMinutes = inMinutes.abs();
    if (totalMinutes < 1) return '< 1m';
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours < 24) {
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
    }
    final days = hours ~/ 24;
    final remHours = hours % 24;
    return remHours == 0 ? '${days}d' : '${days}d ${remHours}h';
  }
}
