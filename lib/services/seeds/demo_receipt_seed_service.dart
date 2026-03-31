// lib/services/seeds/demo_receipt_seed_service.dart
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_item_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

class DemoReceiptSeedService {
  final AppSettingDaoService _appSettingDaoService = AppSettingDaoService();
  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final ReceiptItemDaoService _receiptItemDaoService = ReceiptItemDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  void ensureSeeded() {
    final isSeeded = _appSettingDaoService.getBoolValue(
      AppSettingKeys.exampleDataSeeded,
      defaultValue: false,
    );

    if (isSeeded) {
      return;
    }

    final totalReceipt = _receiptDaoService.countAll(includeArchived: true);
    if (totalReceipt > 0) {
      _markAsSeeded();
      return;
    }

    final purchaseDate = DateTime.now().subtract(
      const Duration(days: 2, hours: 3),
    );

    final receiptId = _receiptDaoService.insert(
      Receipt(
        storeName: 'Electronic City',
        purchaseDate: purchaseDate,
        totalAmount: 417000,
        note:
            'Data contoh bawaan aplikasi. Anda bisa edit atau hapus kapan saja.',
        rawOcrText: '''
ELECTRONIC CITY
Tanggal: ${purchaseDate.toIso8601String()}
Rice Cooker Miyako 1 x 349000
Piring Keramik 2 x 25000
Sabun Cuci Piring 1 x 18000
TOTAL 417000
''',
      ),
    );

    final riceCookerItemId = _receiptItemDaoService.insert(
      ReceiptItem(
        receiptId: receiptId,
        itemName: 'Rice Cooker Miyako 1.8L',
        qty: 1,
        unitPrice: 349000,
        subtotal: 349000,
      ),
    );

    _receiptItemDaoService.insert(
      ReceiptItem(
        receiptId: receiptId,
        itemName: 'Piring Keramik',
        qty: 2,
        unitPrice: 25000,
        subtotal: 50000,
      ),
    );

    _receiptItemDaoService.insert(
      ReceiptItem(
        receiptId: receiptId,
        itemName: 'Sabun Cuci Piring',
        qty: 1,
        unitPrice: 18000,
        subtotal: 18000,
      ),
    );

    _warrantyDaoService.insert(
      Warranty(
        receiptId: receiptId,
        receiptItemId: riceCookerItemId,
        productName: 'Rice Cooker Miyako 1.8L',
        purchaseDate: purchaseDate,
        warrantyMonths: 12,
        isReminderEnabled: false,
      ),
    );

    _appSettingDaoService.setValue(
      AppSettingKeys.exampleReceiptId,
      receiptId.toString(),
      description: 'Id receipt contoh bawaan aplikasi',
    );

    _markAsSeeded();
  }

  void _markAsSeeded() {
    _appSettingDaoService.setValue(
      AppSettingKeys.exampleDataSeeded,
      '1',
      description: 'Contoh data bawaan aplikasi sudah dibuat',
    );
  }
}
