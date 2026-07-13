enum UserStatus {
  active,
  suspended,
  pending;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => UserStatus.pending,
    );
  }
}
