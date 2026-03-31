import 'package:intl/intl.dart';
import 'package:receipt_keeper/components/Filter/date_filter.dart';

/// Data mentah: 1 baris = 1 transaksi (tanggal + nilai)
class ChartDateValue {
  final DateTime date;
  final double value;

  ChartDateValue({
    required this.date,
    required this.value,
  });
}

/// Data siap pakai untuk grafik: label sumbu X + total nilai
class ReportChartPoint {
  final String label;
  final double total;

  ReportChartPoint({
    required this.label,
    required this.total,
  });
}

/// Helper untuk membentuk data grafik berdasarkan jenis DateFilterPreset.
class ReportChartHelper {
  static List<ReportChartPoint> buildPoints(
    List<ChartDateValue> source,
    DateFilterValue filter,
  ) {
    switch (filter.preset) {
      case DateFilterPreset.all:
      case DateFilterPreset.today:
      case DateFilterPreset.last30Days:
      case DateFilterPreset.customDate:
        // Harian → per tanggal
        return _groupPerDate(source, filter);

      case DateFilterPreset.last7Days:
        // 7 hari terakhir → urutan tanggal (paling kanan = hari ini)
        return _groupLast7DaysDaily(source, filter);

      case DateFilterPreset.customMonth:
        // Bulanan → nama bulan
        return _groupPerMonth(source, filter);

      case DateFilterPreset.customYear:
        // Tahunan → tahun
        return _groupPerYear(source, filter);
    }
  }

  /// 7 hari terakhir, urut tanggal dari start..end
  /// label = nama hari (Sen, Sel, Rab, dst)
  static List<ReportChartPoint> _groupLast7DaysDaily(
    List<ChartDateValue> source,
    DateFilterValue filter,
  ) {
    final Map<DateTime, double> totalsByDate = {};

    for (final item in source) {
      final dt = item.date;
      if (dt.isBefore(filter.start) || dt.isAfter(filter.end)) continue;

      final key = DateTime(dt.year, dt.month, dt.day);
      totalsByDate[key] = (totalsByDate[key] ?? 0) + item.value;
    }

    const weekdayLabels = <int, String>{
      1: 'Sen',
      2: 'Sel',
      3: 'Rab',
      4: 'Kam',
      5: 'Jum',
      6: 'Sab',
      7: 'Min',
    };

    final List<ReportChartPoint> points = [];

    DateTime cursor = DateTime(
      filter.start.year,
      filter.start.month,
      filter.start.day,
    );

    while (!cursor.isAfter(filter.end)) {
      final key = DateTime(cursor.year, cursor.month, cursor.day);
      final total = totalsByDate[key] ?? 0;
      final label = weekdayLabels[cursor.weekday] ?? cursor.weekday.toString();

      points.add(
        ReportChartPoint(
          label: label,
          total: total,
        ),
      );

      cursor = cursor.add(const Duration(days: 1));
    }

    return points;
  }

  /// Group per tanggal untuk preset harian:
  /// today, last30Days, customDate
  static List<ReportChartPoint> _groupPerDate(
    List<ChartDateValue> source,
    DateFilterValue filter,
  ) {
    final Map<DateTime, double> totalsByDate = {};

    for (final item in source) {
      final dt = item.date;
      if (dt.isBefore(filter.start) || dt.isAfter(filter.end)) continue;

      final key = DateTime(dt.year, dt.month, dt.day);
      totalsByDate[key] = (totalsByDate[key] ?? 0) + item.value;
    }

    final List<ReportChartPoint> points = [];

    final bool sameMonth = filter.start.year == filter.end.year &&
        filter.start.month == filter.end.month;

    final DateFormat dayFormat =
        sameMonth ? DateFormat('d', 'id_ID') : DateFormat('d/M', 'id_ID');

    DateTime cursor = DateTime(
      filter.start.year,
      filter.start.month,
      filter.start.day,
    );

    while (!cursor.isAfter(filter.end)) {
      final key = DateTime(cursor.year, cursor.month, cursor.day);
      final total = totalsByDate[key] ?? 0;

      points.add(
        ReportChartPoint(
          label: dayFormat.format(cursor),
          total: total,
        ),
      );

      cursor = cursor.add(const Duration(days: 1));
    }

    return points;
  }

  /// Group per bulan untuk preset customMonth
  static List<ReportChartPoint> _groupPerMonth(
    List<ChartDateValue> source,
    DateFilterValue filter,
  ) {
    final Map<String, double> totalsByMonthKey = {};

    for (final item in source) {
      final dt = item.date;
      if (dt.isBefore(filter.start) || dt.isAfter(filter.end)) continue;

      final key = '${dt.year}-${dt.month}';
      totalsByMonthKey[key] = (totalsByMonthKey[key] ?? 0) + item.value;
    }

    final List<ReportChartPoint> points = [];

    final DateTime startMonth = DateTime(filter.start.year, filter.start.month);
    final DateTime endMonth = DateTime(filter.end.year, filter.end.month);

    final bool sameYear = filter.start.year == filter.end.year;
    final DateFormat monthFormat =
        sameYear ? DateFormat('MMM', 'id_ID') : DateFormat('MMM yy', 'id_ID');

    DateTime cursor = startMonth;

    while (!cursor.isAfter(endMonth)) {
      final key = '${cursor.year}-${cursor.month}';
      final total = totalsByMonthKey[key] ?? 0;

      points.add(
        ReportChartPoint(
          label: monthFormat.format(cursor),
          total: total,
        ),
      );

      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    return points;
  }

  /// Group per tahun untuk preset customYear
  static List<ReportChartPoint> _groupPerYear(
    List<ChartDateValue> source,
    DateFilterValue filter,
  ) {
    final Map<int, double> totalsByYear = {};

    for (final item in source) {
      final dt = item.date;
      if (dt.isBefore(filter.start) || dt.isAfter(filter.end)) continue;

      final year = dt.year;
      totalsByYear[year] = (totalsByYear[year] ?? 0) + item.value;
    }

    final List<ReportChartPoint> points = [];

    for (int year = filter.start.year; year <= filter.end.year; year++) {
      points.add(
        ReportChartPoint(
          label: year.toString(),
          total: totalsByYear[year] ?? 0,
        ),
      );
    }

    return points;
  }
}
