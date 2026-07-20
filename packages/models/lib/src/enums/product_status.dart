enum ProductStatus {
  active,
  inactive,
  discontinued;

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProductStatus.inactive,
    );
  }
}
