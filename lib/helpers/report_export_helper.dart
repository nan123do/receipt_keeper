// lib/helpers/report_export_helper.dart

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:receipt_keeper/components/Filter/date_filter.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:share_plus/share_plus.dart';

class ReportExportHelper {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  static String formatPeriode(DateFilterValue value) {
    return '${_dateFormat.format(value.start)} - ${_dateFormat.format(value.end)}';
  }

  static String formatTanggal(DateTime value) {
    return _dateFormat.format(value);
  }

  static String formatRupiah(num value) {
    return NumberHelper.toCurrencyString(
      value,
      template: 'Rp 0',
      maxFraction: 0,
    );
  }

  static Future<void> shareFile(
    File file, {
    required String subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
        text: subject,
      ),
    );
  }
}
