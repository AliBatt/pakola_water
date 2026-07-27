enum OrderMessageType {
  customerMessage,
  review,
  staffMessage;

  static OrderMessageType fromString(String value) {
    return OrderMessageType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => OrderMessageType.customerMessage,
    );
  }

  String get label {
    switch (this) {
      case OrderMessageType.customerMessage:
        return 'Customer message';
      case OrderMessageType.review:
        return 'Review';
      case OrderMessageType.staffMessage:
        return 'Staff message';
    }
  }
}
