// lib/helpers/receipt_field_helper.dart
import 'package:receipt_keeper/models/receipt.dart';

class ReceiptFieldHelper {
  ReceiptFieldHelper._();

  static const List<String> coreFields = [
    'purchaseDate',
    'totalAmount',
  ];

  static const List<String> optionalFields = [
    'storeName',
    'imagePath',
    'note',
    'rawOcrText',
  ];

  static const List<String> systemFields = [
    'id',
    'isArchived',
    'createdAt',
    'updatedAt',
  ];

  static bool isCoreField(String fieldName) {
    return coreFields.contains(fieldName);
  }

  static bool isOptionalField(String fieldName) {
    return optionalFields.contains(fieldName);
  }

  static bool isSystemField(String fieldName) {
    return systemFields.contains(fieldName);
  }

  static Map<String, dynamic> coreFieldMap(Receipt receipt) {
    return {
      'purchaseDate': receipt.purchaseDate,
      'totalAmount': receipt.totalAmount,
    };
  }

  static Map<String, dynamic> optionalFieldMap(Receipt receipt) {
    return {
      'storeName': receipt.storeName,
      'imagePath': receipt.imagePath,
      'note': receipt.note,
      'rawOcrText': receipt.rawOcrText,
    };
  }

  static Map<String, dynamic> systemFieldMap(Receipt receipt) {
    return {
      'id': receipt.id,
      'isArchived': receipt.isArchived,
      'createdAt': receipt.createdAt,
      'updatedAt': receipt.updatedAt,
    };
  }

  static bool hasCoreFields(Receipt receipt) {
    return receipt.totalAmount > 0;
  }

  static bool hasOptionalValue(Receipt receipt) {
    return _hasText(receipt.storeName) ||
        _hasText(receipt.imagePath) ||
        _hasText(receipt.note) ||
        _hasText(receipt.rawOcrText);
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
