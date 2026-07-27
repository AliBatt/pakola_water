import 'package:intl/intl.dart';

/// Shared date/time display helpers used across all Pakola Waters apps.
class DateTimeFormatter {
  const DateTimeFormatter._();

  static const String empty = '—';

  static final DateFormat _dateTime = DateFormat('dd MMM, hh:mm a');
  static final DateFormat _dateTimeLong = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateShort = DateFormat('dd MMM');
  static final DateFormat _time = DateFormat('hh:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static DateTime? parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Default UI timestamp: `27 Jul, 04:15 PM`
  static String format(String? value) {
    final dt = parse(value)?.toLocal();
    if (dt == null) return empty;
    return _dateTime.format(dt);
  }

  /// Longer UI timestamp: `27 Jul 2026, 04:15 PM`
  static String formatLong(String? value) {
    final dt = parse(value)?.toLocal();
    if (dt == null) return empty;
    return _dateTimeLong.format(dt);
  }

  static String formatDateTime(DateTime value) {
    return _dateTime.format(value.toLocal());
  }

  static String formatDateTimeLong(DateTime value) {
    return _dateTimeLong.format(value.toLocal());
  }

  /// Date only: `27 Jul 2026`
  static String formatDate(Object? value) {
    final dt = _asDateTime(value)?.toLocal();
    if (dt == null) return empty;
    return _date.format(dt);
  }

  /// Short date: `27 Jul`
  static String formatDateShort(Object? value) {
    final dt = _asDateTime(value)?.toLocal();
    if (dt == null) return empty;
    return _dateShort.format(dt);
  }

  /// Time only: `04:15 PM`
  static String formatTime(Object? value) {
    final dt = _asDateTime(value)?.toLocal();
    if (dt == null) return empty;
    return _time.format(dt);
  }

  /// ISO date: `2026-07-27`
  static String formatIsoDate(DateTime value) {
    return _isoDate.format(value.toLocal());
  }

  /// Date range: `20 Jul – 27 Jul 2026`
  static String formatRange(DateTime start, DateTime end) {
    final localStart = start.toLocal();
    final localEnd = end.toLocal();
    if (localStart.year == localEnd.year &&
        localStart.month == localEnd.month &&
        localStart.day == localEnd.day) {
      return _date.format(localEnd);
    }
    return '${_dateShort.format(localStart)} – ${_date.format(localEnd)}';
  }

  static DateTime? _asDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return parse(value);
    return null;
  }
}

/// Backwards-compatible alias for older call sites.
class DateFormatter {
  const DateFormatter._();

  static String formatDate(DateTime date) => DateTimeFormatter.formatIsoDate(date);
}
