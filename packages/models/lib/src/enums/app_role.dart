enum AppRole {
  customer,
  driver,
  supervisor,
  admin;

  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => AppRole.customer,
    );
  }
}
