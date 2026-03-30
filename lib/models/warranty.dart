// lib/models/warranty.dart
import 'package:receipt_keeper/helpers/warranty_helper.dart';

class Warranty {
  final int? id;
  final int receiptId;
  final int? receiptItemId;
  final String productName;
  final DateTime purchaseDate;
  final int warrantyMonths;
  final bool isReminderEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Warranty({
    this.id,
    required this.receiptId,
    this.receiptItemId,
    required this.productName,
    required this.purchaseDate,
    this.warrantyMonths = 12,
    this.isReminderEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  DateTime get normalizedPurchaseDate {
    return WarrantyHelper.normalizeDate(purchaseDate);
  }

  DateTime get expiryDate {
    return WarrantyHelper.calculateExpiryDate(
      purchaseDate: purchaseDate,
      warrantyMonths: warrantyMonths,
    );
  }

  int get daysLeft {
    return WarrantyHelper.calculateDaysLeft(
      expiryDate: expiryDate,
    );
  }

  bool get isExpired {
    return daysLeft <= 0;
  }

  bool get isExpiringSoon {
    return daysLeft > 0 && daysLeft <= 7;
  }

  bool get isActive {
    return daysLeft > 7;
  }

  Warranty copyWith({
    int? id,
    int? receiptId,
    int? receiptItemId,
    String? productName,
    DateTime? purchaseDate,
    int? warrantyMonths,
    bool? isReminderEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warranty(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      receiptItemId: receiptItemId ?? this.receiptItemId,
      productName: productName ?? this.productName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Warranty.fromMap(Map<String, dynamic> map) {
    return Warranty(
      id: _toInt(map['id']),
      receiptId: _toInt(map['receipt_id']) ?? 0,
      receiptItemId: _toInt(map['receipt_item_id']),
      productName: _toNullableString(map['product_name']) ?? '',
      purchaseDate: _toDateTime(map['purchase_date']) ?? DateTime.now(),
      warrantyMonths: _toInt(map['warranty_months']) ?? 12,
      isReminderEnabled: _toBool(map['is_reminder_enabled']),
      createdAt: _toDateTime(map['created_at']),
      updatedAt: _toDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'receipt_item_id': receiptItemId,
      'product_name': productName,
      'purchase_date': purchaseDate.toIso8601String(),
      'warranty_months': warrantyMonths,
      'is_reminder_enabled': isReminderEnabled ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    final str = value.toString().toLowerCase();
    return str == '1' || str == 'true';
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();
    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
