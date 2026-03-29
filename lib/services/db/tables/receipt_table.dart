// lib/services/db/tables/receipt_table.dart
class ReceiptTable {
  static const String tableName = 'receipt';

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS receipt (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  store_name TEXT,
  purchase_date TEXT NOT NULL,
  total_amount REAL NOT NULL DEFAULT 0,
  image_path TEXT,
  note TEXT,
  raw_ocr_text TEXT,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
''';

  static const List<String> indexes = [
    '''
CREATE INDEX IF NOT EXISTS idx_receipt_purchase_date
ON receipt(purchase_date DESC);
''',
    '''
CREATE INDEX IF NOT EXISTS idx_receipt_is_archived
ON receipt(is_archived);
''',
  ];
}
