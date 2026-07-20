enum ProductCategory {
  water,
  dispenser,
  accessory,
  other;

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ProductCategory.other,
    );
  }

  String get label {
    switch (this) {
      case ProductCategory.water:
        return 'Water';
      case ProductCategory.dispenser:
        return 'Dispenser';
      case ProductCategory.accessory:
        return 'Accessory';
      case ProductCategory.other:
        return 'Other';
    }
  }
}
