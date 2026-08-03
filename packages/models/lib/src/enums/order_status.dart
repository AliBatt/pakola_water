enum OrderStatus {
  /// Parked until [DeliveryOrder.scheduledFor]; not ongoing on home.
  scheduled,
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

  /// Ongoing delivery flow shown on customer home (excludes parked scheduled).
  bool get isActive =>
      this != OrderStatus.scheduled &&
      this != OrderStatus.delivered &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.failed;

  /// Occupies a customer slot (instant or scheduled) until terminal.
  bool get isOpen =>
      this != OrderStatus.delivered &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.failed;

  bool get isScheduledHold => this == OrderStatus.scheduled;

  bool get isRequested =>
      this == OrderStatus.pending || this == OrderStatus.supervisorNotified;

  bool get isCompleted =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.failed;

  bool get isInProgress =>
      this == OrderStatus.assigned ||
      this == OrderStatus.outForDelivery ||
      this == OrderStatus.riderArrived;

  /// Customer may cancel until the rider marks arrived (including scheduled).
  bool get canCustomerCancel =>
      this == OrderStatus.scheduled ||
      this == OrderStatus.pending ||
      this == OrderStatus.supervisorNotified ||
      this == OrderStatus.assigned ||
      this == OrderStatus.outForDelivery;

  String get label {
    switch (this) {
      case OrderStatus.scheduled:
        return 'Scheduled';
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
