import 'package:intl/intl.dart';

class NumberHelper {
  static var currency = NumberFormat("#,##0", "en_US");

  /// format -> String  (deteksi symbol + locale otomatis)
  /// - maxFraction = batas digit desimal (opsional)
  /// - minFraction = digit desimal minimal (dipaksa)
  static String toCurrencyString(
    num value, {
    // <- ganti dari double ke num
    String template = '',
    int maxFraction = 2,
    int minFraction = 0,
  }) {
    final symbol = _detectSymbol(template);

    final locale = template.trim().isEmpty
        ? (Intl.defaultLocale ?? 'en_US')
        : _detectLocale(template);

    final pattern = _buildPattern(
      maxFraction: maxFraction,
      minFraction: minFraction,
    );

    final fmt = NumberFormat(pattern, locale);
    return '$symbol${fmt.format(value)}';
  }

  static String _buildPattern({
    required int maxFraction,
    required int minFraction,
  }) {
    if (maxFraction <= 0) return '#,##0';

    if (minFraction < 0) minFraction = 0;
    if (minFraction > maxFraction) minFraction = maxFraction;

    // 0 = wajib, # = opsional
    final zeros = '0' * minFraction;
    final hashes = '#' * (maxFraction - minFraction);

    return '#,##0.$zeros$hashes';
  }

  /// ambil prefix non-digit (“Rp ”, “$”, “€ ” …)
  static String _detectSymbol(String s) =>
      RegExp(r'^[^\d\-]+').firstMatch(s.trim())?.group(0) ?? '';

  /// tebak locale berdasar pemisah desimal
  static String _detectLocale(String s) {
    final lastDot = s.lastIndexOf('.');
    final lastComma = s.lastIndexOf(',');
    if (lastDot != -1 && lastComma != -1) {
      return lastComma > lastDot ? 'id_ID' : 'en_US';
    } else if (lastComma != -1) {
      return (s.length - lastComma - 1) <= 2 ? 'id_ID' : 'en_US';
    } else if (lastDot != -1) {
      return (s.length - lastDot - 1) <= 2 ? 'en_US' : 'id_ID';
    }
    return 'en_US';
  }

  /// Mengubah string mata-uang apa pun menjadi double tanpa error.
  static double toDoubleCurrency(String text) {
    if (text.trim().isEmpty) return 0;

    String cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9,.\-]'), '');

    final int lastDot = cleaned.lastIndexOf('.');
    final int lastComma = cleaned.lastIndexOf(',');

    String normalized;

    if (lastDot != -1 && lastComma != -1) {
      final bool commaIsDecimal = lastComma > lastDot;
      normalized = cleaned
          .replaceAll(commaIsDecimal ? '.' : ',', '')
          .replaceFirst(commaIsDecimal ? ',' : '.', '.');
    } else if (lastComma != -1) {
      final bool commaIsDecimal = cleaned.length - lastComma - 1 <= 2;
      normalized = commaIsDecimal
          ? cleaned.replaceFirst(',', '.')
          : cleaned.replaceAll(',', '');
    } else if (lastDot != -1) {
      final bool dotIsDecimal = cleaned.length - lastDot - 1 <= 2;
      normalized = dotIsDecimal ? cleaned : cleaned.replaceAll('.', '');
    } else {
      normalized = cleaned;
    }

    return double.tryParse(normalized) ?? 0;
  }

  static dynamic normalizeValue(dynamic value) {
    if (value is double) {
      return value % 1 == 0 ? value.toInt() : value;
    }
    if (value is List) {
      return value.map(normalizeValue).toList();
    }
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, normalizeValue(v)));
    }
    return value;
  }
}
