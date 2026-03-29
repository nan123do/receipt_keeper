// lib/models/receipt.dart
class Receipt {
  final int? id;
  final String? storeName;
  final DateTime purchaseDate;
  final double totalAmount;
  final String? imagePath;
  final String? note;
  final String? rawOcrText;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Receipt({
    this.id,
    this.storeName,
    required this.purchaseDate,
    required this.totalAmount,
    this.imagePath,
    this.note,
    this.rawOcrText,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  Receipt copyWith({
    int? id,
    String? storeName,
    DateTime? purchaseDate,
    double? totalAmount,
    String? imagePath,
    String? note,
    String? rawOcrText,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      totalAmount: totalAmount ?? this.totalAmount,
      imagePath: imagePath ?? this.imagePath,
      note: note ?? this.note,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: _toInt(map['id']),
      storeName: _toNullableString(map['store_name']),
      purchaseDate: _toDateTime(map['purchase_date']) ?? DateTime.now(),
      totalAmount: _toDouble(map['total_amount']),
      imagePath: _toNullableString(map['image_path']),
      note: _toNullableString(map['note']),
      rawOcrText: _toNullableString(map['raw_ocr_text']),
      isArchived: _toBool(map['is_archived']),
      createdAt: _toDateTime(map['created_at']),
      updatedAt: _toDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_name': storeName,
      'purchase_date': purchaseDate.toIso8601String(),
      'total_amount': totalAmount,
      'image_path': imagePath,
      'note': note,
      'raw_ocr_text': rawOcrText,
      'is_archived': isArchived ? 1 : 0,
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
