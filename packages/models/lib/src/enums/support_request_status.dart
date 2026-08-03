enum SupportRequestStatus {
  open,
  inProgress,
  completed,
  rejected,
  closed;

  static SupportRequestStatus fromString(String value) {
    return SupportRequestStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SupportRequestStatus.open,
    );
  }

  bool get isOpen =>
      this == SupportRequestStatus.open ||
      this == SupportRequestStatus.inProgress;

  bool get isTerminal =>
      this == SupportRequestStatus.completed ||
      this == SupportRequestStatus.rejected ||
      this == SupportRequestStatus.closed;

  String get label {
    switch (this) {
      case SupportRequestStatus.open:
        return 'Open';
      case SupportRequestStatus.inProgress:
        return 'In progress';
      case SupportRequestStatus.completed:
        return 'Completed';
      case SupportRequestStatus.rejected:
        return 'Rejected';
      case SupportRequestStatus.closed:
        return 'Closed';
    }
  }
}
