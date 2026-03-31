// lib/components/Filter/date_filter.dart
import 'package:intl/intl.dart';

enum DateFilterPreset {
  all,
  today,
  last7Days,
  last30Days,
  customDate,
  customMonth,
  customYear,
}

class DateFilterValue {
  final DateFilterPreset preset;
  final DateTime start;
  final DateTime end;

  const DateFilterValue({
    required this.preset,
    required this.start,
    required this.end,
  });

  factory DateFilterValue.all() {
    final now = DateTime.now();
    return DateFilterValue(
      preset: DateFilterPreset.all,
      start: DateTime(2000, 1, 1),
      end: _endOfDay(now),
    );
  }

  factory DateFilterValue.today() {
    final now = DateTime.now();
    final start = _startOfDay(now);
    final end = _endOfDay(now);
    return DateFilterValue(
      preset: DateFilterPreset.today,
      start: start,
      end: end,
    );
  }

  factory DateFilterValue.last7Days() {
    final now = DateTime.now();
    final end = _endOfDay(now);
    final startDate = end.subtract(const Duration(days: 6));
    final start = _startOfDay(startDate);
    return DateFilterValue(
      preset: DateFilterPreset.last7Days,
      start: start,
      end: end,
    );
  }

  factory DateFilterValue.last30Days() {
    final now = DateTime.now();
    final end = _endOfDay(now);
    final startDate = end.subtract(const Duration(days: 29));
    final start = _startOfDay(startDate);
    return DateFilterValue(
      preset: DateFilterPreset.last30Days,
      start: start,
      end: end,
    );
  }

  factory DateFilterValue.customDateRange(DateTime start, DateTime end) {
    var s = _startOfDay(start);
    var e = _endOfDay(end);

    if (e.isBefore(s)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    return DateFilterValue(
      preset: DateFilterPreset.customDate,
      start: s,
      end: e,
    );
  }

  factory DateFilterValue.customMonthRange(DateTime start, DateTime end) {
    var s = _startOfMonth(start);
    var e = _endOfMonth(end);

    if (e.isBefore(s)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    return DateFilterValue(
      preset: DateFilterPreset.customMonth,
      start: s,
      end: e,
    );
  }

  factory DateFilterValue.customYearRange(DateTime start, DateTime end) {
    var s = _startOfYear(start);
    var e = _endOfYear(end);

    if (e.isBefore(s)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    return DateFilterValue(
      preset: DateFilterPreset.customYear,
      start: s,
      end: e,
    );
  }

  DateFilterValue copyWith({
    DateFilterPreset? preset,
    DateTime? start,
    DateTime? end,
  }) {
    return DateFilterValue(
      preset: preset ?? this.preset,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  String get label {
    final dfDay = DateFormat('dd MMM yyyy', 'id_ID');

    switch (preset) {
      case DateFilterPreset.all:
        return 'Semua tanggal';
      case DateFilterPreset.today:
        return 'Hari ini';
      case DateFilterPreset.last7Days:
        return '7 hari terakhir';
      case DateFilterPreset.last30Days:
        return '30 hari terakhir';
      case DateFilterPreset.customDate:
        return '${dfDay.format(start)} - ${dfDay.format(end)}';
      case DateFilterPreset.customMonth:
        final dfMonth = DateFormat('MMM yyyy', 'id_ID');
        return '${dfMonth.format(start)} - ${dfMonth.format(end)}';
      case DateFilterPreset.customYear:
        final dfYear = DateFormat('yyyy', 'id_ID');
        return '${dfYear.format(start)} - ${dfYear.format(end)}';
    }
  }
}

DateTime _startOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 0, 0, 0, 0);

DateTime _endOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

DateTime _startOfMonth(DateTime dt) =>
    DateTime(dt.year, dt.month, 1, 0, 0, 0, 0);

DateTime _endOfMonth(DateTime dt) =>
    DateTime(dt.year, dt.month + 1, 0, 23, 59, 59, 999);

DateTime _startOfYear(DateTime dt) => DateTime(dt.year, 1, 1, 0, 0, 0, 0);

DateTime _endOfYear(DateTime dt) => DateTime(dt.year, 12, 31, 23, 59, 59, 999);
