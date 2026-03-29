// lib/services/daos/receipt_item_dao_service.dart
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/services/db/app_db_service.dart';

class ReceiptItemDaoService {
  ReceiptItem? getById(int id) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM receipt_item
      WHERE id = ?
      LIMIT 1
      ''',
      [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    return ReceiptItem.fromMap(Map<String, dynamic>.from(rows.first));
  }

  List<ReceiptItem> getByReceiptId(int receiptId) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM receipt_item
      WHERE receipt_id = ?
      ORDER BY id ASC
      ''',
      [receiptId],
    );

    return rows
        .map((row) => ReceiptItem.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  int insert(ReceiptItem item) {
    final now = DateTime.now().toIso8601String();

    AppDbService.to.db.execute(
      '''
      INSERT INTO receipt_item (
        receipt_id,
        item_name,
        qty,
        unit_price,
        subtotal,
        note,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        item.receiptId,
        item.itemName,
        item.qty,
        item.unitPrice,
        item.subtotal,
        item.note,
        now,
        now,
      ],
    );

    return AppDbService.to.db.lastInsertRowId;
  }

  void insertMany(List<ReceiptItem> items) {
    if (items.isEmpty) {
      return;
    }

    AppDbService.to.db.execute('BEGIN;');

    try {
      for (final item in items) {
        insert(item);
      }

      AppDbService.to.db.execute('COMMIT;');
    } catch (_) {
      AppDbService.to.db.execute('ROLLBACK;');
      rethrow;
    }
  }

  void update(ReceiptItem item) {
    if (item.id == null) {
      throw Exception('Id item receipt tidak valid.');
    }

    AppDbService.to.db.execute(
      '''
      UPDATE receipt_item
      SET
        item_name = ?,
        qty = ?,
        unit_price = ?,
        subtotal = ?,
        note = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        item.itemName,
        item.qty,
        item.unitPrice,
        item.subtotal,
        item.note,
        DateTime.now().toIso8601String(),
        item.id,
      ],
    );
  }

  void delete(int id) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM receipt_item
      WHERE id = ?
      ''',
      [id],
    );
  }

  void deleteByReceiptId(int receiptId) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM receipt_item
      WHERE receipt_id = ?
      ''',
      [receiptId],
    );
  }
}
