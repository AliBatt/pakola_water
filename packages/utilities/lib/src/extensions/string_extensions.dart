extension StringExtensions on String {
  bool get isNullOrEmpty => trim().isEmpty;

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
