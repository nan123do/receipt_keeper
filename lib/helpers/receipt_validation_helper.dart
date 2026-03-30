// lib/helpers/receipt_validation_helper.dart
import 'package:receipt_keeper/helpers/receipt_field_helper.dart';
import 'package:receipt_keeper/models/receipt.dart';

class ReceiptValidationHelper {
  ReceiptValidationHelper._();

  static String? validate(Receipt receipt) {
    final purchaseDateMessage = validatePurchaseDate(receipt.purchaseDate);
    if (purchaseDateMessage != null) {
      return purchaseDateMessage;
    }

    final totalAmountMessage = validateTotalAmount(receipt.totalAmount);
    if (totalAmountMessage != null) {
      return totalAmountMessage;
    }

    return null;
  }

  static bool isValid(Receipt receipt) {
    return validate(receipt) == null;
  }

  static bool hasCoreFields(Receipt receipt) {
    return ReceiptFieldHelper.hasCoreFields(receipt);
  }

  static String? validatePurchaseDate(DateTime? purchaseDate) {
    if (purchaseDate == null) {
      return 'Tanggal beli wajib diisi.';
    }

    return null;
  }

  static String? validateTotalAmount(num? totalAmount) {
    if (totalAmount == null) {
      return 'Total belanja wajib diisi.';
    }

    if (totalAmount <= 0) {
      return 'Total belanja harus lebih dari 0.';
    }

    return null;
  }

  static String? validateStoreName(String? storeName) {
    if (storeName == null) {
      return null;
    }

    if (storeName.trim().isEmpty) {
      return null;
    }

    return null;
  }

  static String? validateNote(String? note) {
    if (note == null) {
      return null;
    }

    if (note.trim().isEmpty) {
      return null;
    }

    return null;
  }
}
