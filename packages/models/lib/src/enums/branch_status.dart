enum BranchStatus {
  active,
  inactive;

  static BranchStatus fromString(String value) {
    return BranchStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BranchStatus.inactive,
    );
  }
}
