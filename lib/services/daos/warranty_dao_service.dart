// lib/services/daos/warranty_dao_service.dart

import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/services/db/app_db_service.dart';

class WarrantyDaoService {
  Warranty? getById(int id) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM warranty
      WHERE id = ?
      LIMIT 1
      ''',
      [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    return Warranty.fromMap(Map<String, dynamic>.from(rows.first));
  }

  List<Warranty> getAll({
    int? receiptId,
    bool? isReminderEnabled,
  }) {
    final where = <String>[];
    final args = <Object?>[];

    if (receiptId != null) {
      where.add('receipt_id = ?');
      args.add(receiptId);
    }

    if (isReminderEnabled != null) {
      where.add('is_reminder_enabled = ?');
      args.add(isReminderEnabled ? 1 : 0);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM warranty
      $whereClause
      ORDER BY purchase_date DESC, id DESC
      ''',
      args,
    );

    return rows
        .map((row) => Warranty.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  List<Warranty> getByReceiptId(int receiptId) {
    return getAll(receiptId: receiptId);
  }

  int countByReceiptId(int receiptId) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT COUNT(*) AS total
      FROM warranty
      WHERE receipt_id = ?
      ''',
      [receiptId],
    );

    if (rows.isEmpty) {
      return 0;
    }

    final total = rows.first['total'];
    if (total is int) {
      return total;
    }

    return int.tryParse(total.toString()) ?? 0;
  }

  int insert(Warranty warranty) {
    final now = DateTime.now().toIso8601String();

    AppDbService.to.db.execute(
      '''
      INSERT INTO warranty (
        receipt_id,
        receipt_item_id,
        product_name,
        purchase_date,
        warranty_months,
        is_reminder_enabled,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        warranty.receiptId,
        warranty.receiptItemId,
        warranty.productName,
        warranty.purchaseDate.toIso8601String(),
        warranty.warrantyMonths,
        warranty.isReminderEnabled ? 1 : 0,
        now,
        now,
      ],
    );

    return AppDbService.to.db.lastInsertRowId;
  }

  void update(Warranty warranty) {
    if (warranty.id == null) {
      throw Exception('Id garansi tidak valid.');
    }

    AppDbService.to.db.execute(
      '''
      UPDATE warranty
      SET
        receipt_id = ?,
        receipt_item_id = ?,
        product_name = ?,
        purchase_date = ?,
        warranty_months = ?,
        is_reminder_enabled = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        warranty.receiptId,
        warranty.receiptItemId,
        warranty.productName,
        warranty.purchaseDate.toIso8601String(),
        warranty.warrantyMonths,
        warranty.isReminderEnabled ? 1 : 0,
        DateTime.now().toIso8601String(),
        warranty.id,
      ],
    );
  }

  void updateReminderEnabled(
    int id,
    bool isReminderEnabled,
  ) {
    AppDbService.to.db.execute(
      '''
      UPDATE warranty
      SET
        is_reminder_enabled = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        isReminderEnabled ? 1 : 0,
        DateTime.now().toIso8601String(),
        id,
      ],
    );
  }

  void delete(int id) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM warranty
      WHERE id = ?
      ''',
      [id],
    );
  }

  void deleteByReceiptId(int receiptId) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM warranty
      WHERE receipt_id = ?
      ''',
      [receiptId],
    );
  }
}
