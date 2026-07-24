enum OrderStatus {
  pending,
  supervisorNotified,
  assigned,
  outForDelivery,
  riderArrived,
  delivered,
  cancelled,
  failed;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  bool get isActive =>
      this != OrderStatus.delivered &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.failed;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.supervisorNotified:
        return 'Supervisor notified';
      case OrderStatus.assigned:
        return 'Rider assigned';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.riderArrived:
        return 'Rider arrived';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }
}
