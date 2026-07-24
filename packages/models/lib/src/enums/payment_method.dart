enum PaymentMethod {
  cod,
  credit;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == value,
      orElse: () => PaymentMethod.cod,
    );
  }

  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on delivery';
      case PaymentMethod.credit:
        return 'Credit';
    }
  }
}
