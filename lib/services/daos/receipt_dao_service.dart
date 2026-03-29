// lib/services/daos/receipt_dao_service.dart
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/services/db/app_db_service.dart';

class ReceiptDaoService {
  Receipt? getById(int id) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM receipt
      WHERE id = ?
      LIMIT 1
      ''',
      [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    return Receipt.fromMap(Map<String, dynamic>.from(rows.first));
  }

  List<Receipt> getAll({
    String search = '',
    bool? isArchived,
    bool latestFirst = true,
  }) {
    final where = <String>[];
    final args = <Object?>[];

    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      where.add(
        '''
        (
          LOWER(COALESCE(store_name, '')) LIKE ?
          OR LOWER(COALESCE(note, '')) LIKE ?
          OR LOWER(COALESCE(raw_ocr_text, '')) LIKE ?
        )
        ''',
      );

      final like = '%$q%';
      args.addAll([like, like, like]);
    }

    if (isArchived != null) {
      where.add('is_archived = ?');
      args.add(isArchived ? 1 : 0);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final orderBy = latestFirst ? 'DESC' : 'ASC';

    final rows = AppDbService.to.db.select(
      '''
      SELECT *
      FROM receipt
      $whereClause
      ORDER BY purchase_date $orderBy, id DESC
      ''',
      args,
    );

    return rows
        .map((row) => Receipt.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  int insert(Receipt receipt) {
    final now = DateTime.now().toIso8601String();

    AppDbService.to.db.execute(
      '''
      INSERT INTO receipt (
        store_name,
        purchase_date,
        total_amount,
        image_path,
        note,
        raw_ocr_text,
        is_archived,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        receipt.storeName,
        receipt.purchaseDate.toIso8601String(),
        receipt.totalAmount,
        receipt.imagePath,
        receipt.note,
        receipt.rawOcrText,
        receipt.isArchived ? 1 : 0,
        now,
        now,
      ],
    );

    return AppDbService.to.db.lastInsertRowId;
  }

  void update(Receipt receipt) {
    if (receipt.id == null) {
      throw Exception('Id receipt tidak valid.');
    }

    AppDbService.to.db.execute(
      '''
      UPDATE receipt
      SET
        store_name = ?,
        purchase_date = ?,
        total_amount = ?,
        image_path = ?,
        note = ?,
        raw_ocr_text = ?,
        is_archived = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        receipt.storeName,
        receipt.purchaseDate.toIso8601String(),
        receipt.totalAmount,
        receipt.imagePath,
        receipt.note,
        receipt.rawOcrText,
        receipt.isArchived ? 1 : 0,
        DateTime.now().toIso8601String(),
        receipt.id,
      ],
    );
  }

  void delete(int id) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM receipt
      WHERE id = ?
      ''',
      [id],
    );
  }

  void setArchived(
    int id, {
    required bool isArchived,
  }) {
    AppDbService.to.db.execute(
      '''
      UPDATE receipt
      SET
        is_archived = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        isArchived ? 1 : 0,
        DateTime.now().toIso8601String(),
        id,
      ],
    );
  }

  int countAll({
    bool includeArchived = true,
  }) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT COUNT(*) AS total
      FROM receipt
      ${includeArchived ? '' : 'WHERE is_archived = 0'}
      ''',
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
}
