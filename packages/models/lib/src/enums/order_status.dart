enum OrderStatus {
  pending,
  confirmed,
  assigned,
  outForDelivery,
  delivered,
  cancelled,
  failed;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
