// lib/utils/app_format_helper.dart
import 'package:intl/intl.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';

enum WarrantyStatusType {
  active,
  expiringSoon,
  expired,
}

class AppFormatHelper {
  AppFormatHelper._();

  static const String _localeId = 'id_ID';

  static String formatDate(
    DateTime? value, {
    String pattern = 'dd MMM yyyy',
  }) {
    if (value == null) {
      return '-';
    }

    return DateFormat(pattern, _localeId).format(value);
  }

  static String formatDateTime(
    DateTime? value, {
    String pattern = 'dd MMM yyyy HH:mm',
  }) {
    if (value == null) {
      return '-';
    }

    return DateFormat(pattern, _localeId).format(value);
  }

  static String formatRupiah(
    num? value, {
    bool withSymbol = true,
    int maxFraction = 0,
    int minFraction = 0,
  }) {
    return NumberHelper.toCurrencyString(
      value ?? 0,
      template: withSymbol ? 'Rp 0' : '',
      maxFraction: maxFraction,
      minFraction: minFraction,
    );
  }

  static WarrantyStatusType getWarrantyStatusType(int daysLeft) {
    if (daysLeft <= 0) {
      return WarrantyStatusType.expired;
    }

    if (daysLeft <= 7) {
      return WarrantyStatusType.expiringSoon;
    }

    return WarrantyStatusType.active;
  }

  static String formatWarrantyStatus(int daysLeft) {
    final status = getWarrantyStatusType(daysLeft);

    switch (status) {
      case WarrantyStatusType.active:
        return 'Aktif';
      case WarrantyStatusType.expiringSoon:
        return 'Hampir habis';
      case WarrantyStatusType.expired:
        return 'Sudah habis';
    }
  }

  static String formatWarrantyDaysLeft(int daysLeft) {
    if (daysLeft <= 0) {
      return 'Sudah habis';
    }

    if (daysLeft == 1) {
      return '1 hari lagi';
    }

    return '$daysLeft hari lagi';
  }
}
