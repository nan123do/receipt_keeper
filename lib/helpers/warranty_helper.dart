// lib/helpers/warranty_helper.dart
class WarrantyHelper {
  WarrantyHelper._();

  static DateTime calculateExpiryDate({
    required DateTime purchaseDate,
    required int warrantyMonths,
  }) {
    final normalizedPurchaseDate = normalizeDate(purchaseDate);
    final safeWarrantyMonths = warrantyMonths < 0 ? 0 : warrantyMonths;

    final totalMonths =
        (normalizedPurchaseDate.year * 12) +
        normalizedPurchaseDate.month -
        1 +
        safeWarrantyMonths;

    final targetYear = totalMonths ~/ 12;
    final targetMonth = (totalMonths % 12) + 1;
    final lastDayOfTargetMonth = _getLastDayOfMonth(targetYear, targetMonth);
    final targetDay = normalizedPurchaseDate.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : normalizedPurchaseDate.day;

    return DateTime(targetYear, targetMonth, targetDay);
  }

  static int calculateDaysLeft({
    required DateTime expiryDate,
    DateTime? currentDate,
  }) {
    final normalizedCurrentDate = normalizeDate(currentDate ?? DateTime.now());
    final normalizedExpiryDate = normalizeDate(expiryDate);

    return normalizedExpiryDate.difference(normalizedCurrentDate).inDays;
  }

  static int calculateDaysLeftFromPurchaseDate({
    required DateTime purchaseDate,
    required int warrantyMonths,
    DateTime? currentDate,
  }) {
    final expiryDate = calculateExpiryDate(
      purchaseDate: purchaseDate,
      warrantyMonths: warrantyMonths,
    );

    return calculateDaysLeft(
      expiryDate: expiryDate,
      currentDate: currentDate,
    );
  }

  static DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int _getLastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}