// lib/models/receipt_item.dart
class ReceiptItem {
  final int? id;
  final int receiptId;
  final String itemName;
  final double qty;
  final double unitPrice;
  final double subtotal;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReceiptItem({
    this.id,
    required this.receiptId,
    required this.itemName,
    this.qty = 1,
    this.unitPrice = 0,
    this.subtotal = 0,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  ReceiptItem copyWith({
    int? id,
    int? receiptId,
    String? itemName,
    double? qty,
    double? unitPrice,
    double? subtotal,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      id: _toInt(map['id']),
      receiptId: _toInt(map['receipt_id']) ?? 0,
      itemName: _toNullableString(map['item_name']) ?? '',
      qty: _toDouble(map['qty']),
      unitPrice: _toDouble(map['unit_price']),
      subtotal: _toDouble(map['subtotal']),
      note: _toNullableString(map['note']),
      createdAt: _toDateTime(map['created_at']),
      updatedAt: _toDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'item_name': itemName,
      'qty': qty,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'note': note,
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

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
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
