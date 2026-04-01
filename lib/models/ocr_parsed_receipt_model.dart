// lib/pages/scan_receipt/models/ocr_parsed_receipt_model.dart

class OcrParsedItemModel {
  final String itemName;
  final double qty;
  final double unitPrice;
  final double subtotal;

  const OcrParsedItemModel({
    required this.itemName,
    this.qty = 1,
    this.unitPrice = 0,
    this.subtotal = 0,
  });
}

class OcrParsedReceiptModel {
  final String? storeName;
  final DateTime? purchaseDate;
  final double? totalAmount;
  final List<OcrParsedItemModel> items;

  const OcrParsedReceiptModel({
    this.storeName,
    this.purchaseDate,
    this.totalAmount,
    this.items = const [],
  });

  bool get hasStoreName => (storeName ?? '').trim().isNotEmpty;
  bool get hasPurchaseDate => purchaseDate != null;
  bool get hasTotalAmount => (totalAmount ?? 0) > 0;
  bool get hasItems => items.isNotEmpty;

  bool get hasAnyValue =>
      hasStoreName || hasPurchaseDate || hasTotalAmount || hasItems;
}
