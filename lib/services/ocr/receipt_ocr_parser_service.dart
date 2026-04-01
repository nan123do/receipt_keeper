// lib/services/ocr/receipt_ocr_parser_service.dart
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:receipt_keeper/models/ocr_parsed_receipt_model.dart';

class ReceiptOcrParserService {
  const ReceiptOcrParserService();

  static const Map<String, String> _knownStores = {
    'indomaret': 'Indomaret',
    'alfamart': 'Alfamart',
    'superindo': 'Superindo',
    'hypermart': 'Hypermart',
    'transmart': 'Transmart',
    'tokopedia': 'Tokopedia',
    'shopee': 'Shopee',
    'lazada': 'Lazada',
    'blibli': 'Blibli',
  };

  static const Map<String, int> _monthMap = {
    'jan': 1,
    'januari': 1,
    'january': 1,
    'feb': 2,
    'februari': 2,
    'february': 2,
    'mar': 3,
    'maret': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'mei': 5,
    'may': 5,
    'jun': 6,
    'juni': 6,
    'june': 6,
    'jul': 7,
    'juli': 7,
    'july': 7,
    'agu': 8,
    'agt': 8,
    'ags': 8,
    'agustus': 8,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'okt': 10,
    'oktober': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'des': 12,
    'desember': 12,
    'december': 12,
  };

  OcrParsedReceiptModel parse(String rawText) {
    final normalizedText = rawText.trim();
    if (normalizedText.isEmpty) {
      return const OcrParsedReceiptModel();
    }

    final lines = normalizedText
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return OcrParsedReceiptModel(
      storeName: _parseStoreName(lines),
      purchaseDate: _parsePurchaseDate(lines),
      totalAmount: _parseTotalAmount(lines),
      items: _parseItems(lines),
    );
  }

  String? _parseStoreName(List<String> lines) {
    for (final line in lines.take(8)) {
      final lower = line.toLowerCase();

      for (final entry in _knownStores.entries) {
        if (lower.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    for (final line in lines.take(3)) {
      final cleaned = line.replaceAll(RegExp(r'[^A-Za-z0-9 .,&-]'), '').trim();

      if (cleaned.length >= 3 && cleaned.length <= 40) {
        return cleaned;
      }
    }

    return null;
  }

  DateTime? _parsePurchaseDate(List<String> lines) {
    for (final line in lines.take(15)) {
      final numeric = _parseNumericDate(line);
      if (numeric != null) {
        return numeric;
      }

      final textMonth = _parseTextMonthDate(line);
      if (textMonth != null) {
        return textMonth;
      }
    }

    return null;
  }

  DateTime? _parseNumericDate(String text) {
    final match = RegExp(
      r'(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})',
    ).firstMatch(text);

    if (match == null) {
      return null;
    }

    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final yearRaw = int.tryParse(match.group(3) ?? '');

    if (day == null || month == null || yearRaw == null) {
      return null;
    }

    final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;

    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    return DateTime(year, month, day);
  }

  DateTime? _parseTextMonthDate(String text) {
    final match = RegExp(
      r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{2,4})',
      caseSensitive: false,
    ).firstMatch(text);

    if (match == null) {
      return null;
    }

    final day = int.tryParse(match.group(1) ?? '');
    final monthText = (match.group(2) ?? '').toLowerCase();
    final yearRaw = int.tryParse(match.group(3) ?? '');

    if (day == null || yearRaw == null) {
      return null;
    }

    final month = _monthMap[monthText];
    if (month == null) {
      return null;
    }

    final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;

    return DateTime(year, month, day);
  }

  double? _parseTotalAmount(List<String> lines) {
    const keywords = [
      'grand total',
      'total belanja',
      'total bayar',
      'total',
      'jumlah',
      'amount',
      'subtotal',
    ];

    for (final keyword in keywords) {
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (!lower.contains(keyword)) {
          continue;
        }

        final amount = _extractLargestAmount(line);
        if (amount > 0) {
          return amount;
        }
      }
    }

    double maxAmount = 0;
    for (final line in lines) {
      final amount = _extractLargestAmount(line);
      if (amount > maxAmount) {
        maxAmount = amount;
      }
    }

    return maxAmount > 0 ? maxAmount : null;
  }

  double _extractLargestAmount(String text) {
    final matches = RegExp(
      r'((?:rp)?\s?[\d.,]{3,})',
      caseSensitive: false,
    ).allMatches(text);

    double maxValue = 0;
    for (final match in matches) {
      final value = NumberHelper.toDoubleCurrency(match.group(0) ?? '');
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return maxValue;
  }

  List<OcrParsedItemModel> _parseItems(List<String> lines) {
    final items = <OcrParsedItemModel>[];

    for (final line in lines) {
      if (_shouldSkipItemLine(line)) {
        continue;
      }

      final parsed = _parseItemLine(line);
      if (parsed == null) {
        continue;
      }

      items.add(parsed);

      if (items.length >= 20) {
        break;
      }
    }

    return items;
  }

  bool _shouldSkipItemLine(String line) {
    final lower = line.toLowerCase();

    const blockedWords = [
      'total',
      'subtotal',
      'grand total',
      'cash',
      'tunai',
      'kembalian',
      'change',
      'ppn',
      'tax',
      'diskon',
      'discount',
      'promo',
      'member',
      'terima kasih',
      'thank you',
      'debit',
      'kredit',
      'no.',
      'invoice',
      'tanggal',
      'date',
      'jam',
      'waktu',
      'qty',
    ];

    if (blockedWords.any(lower.contains)) {
      return true;
    }

    final digitCount = RegExp(r'\d').allMatches(line).length;
    if (digitCount < 3) {
      return true;
    }

    return false;
  }

  OcrParsedItemModel? _parseItemLine(String line) {
    final qtyPriceMatch = RegExp(
      r'^(.*?)(\d+(?:[.,]\d+)?)\s*[xX]\s*((?:rp)?\s?[\d.,]+)$',
      caseSensitive: false,
    ).firstMatch(line);

    if (qtyPriceMatch != null) {
      final itemName = qtyPriceMatch.group(1)?.trim() ?? '';
      final qty = NumberHelper.toDoubleCurrency(qtyPriceMatch.group(2) ?? '');
      final unitPrice = NumberHelper.toDoubleCurrency(
        qtyPriceMatch.group(3) ?? '',
      );

      if (itemName.isEmpty || qty <= 0 || unitPrice <= 0) {
        return null;
      }

      return OcrParsedItemModel(
        itemName: itemName,
        qty: qty,
        unitPrice: unitPrice,
        subtotal: qty * unitPrice,
      );
    }

    final trailingPriceMatch = RegExp(
      r'^(.*?)(?:\s{1,}|\.{2,})((?:rp)?\s?[\d.,]{3,})$',
      caseSensitive: false,
    ).firstMatch(line);

    if (trailingPriceMatch != null) {
      final itemName = trailingPriceMatch.group(1)?.trim() ?? '';
      final subtotal = NumberHelper.toDoubleCurrency(
        trailingPriceMatch.group(2) ?? '',
      );

      if (itemName.isEmpty || subtotal <= 0) {
        return null;
      }

      return OcrParsedItemModel(
        itemName: itemName,
        qty: 1,
        unitPrice: subtotal,
        subtotal: subtotal,
      );
    }

    return null;
  }
}
