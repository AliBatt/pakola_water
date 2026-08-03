enum OrderType {
  instant,
  scheduled;

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => OrderType.instant,
    );
  }

  String get label {
    switch (this) {
      case OrderType.instant:
        return 'Instant';
      case OrderType.scheduled:
        return 'Scheduled';
    }
  }
}
