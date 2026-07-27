enum PaymentStatus {
  pending,
  paid;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Unpaid';
      case PaymentStatus.paid:
        return 'Paid';
    }
  }

  bool get isPaid => this == PaymentStatus.paid;
  bool get isUnpaid => this == PaymentStatus.pending;
}
