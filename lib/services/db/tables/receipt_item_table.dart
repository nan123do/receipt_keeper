// lib/services/db/tables/receipt_item_table.dart
class ReceiptItemTable {
  static const String tableName = 'receipt_item';

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS receipt_item (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receipt_id INTEGER NOT NULL,
  item_name TEXT NOT NULL,
  qty REAL NOT NULL DEFAULT 1,
  unit_price REAL NOT NULL DEFAULT 0,
  subtotal REAL NOT NULL DEFAULT 0,
  note TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (receipt_id) REFERENCES receipt(id) ON DELETE CASCADE
);
''';

  static const List<String> indexes = [
    '''
CREATE INDEX IF NOT EXISTS idx_receipt_item_receipt_id
ON receipt_item(receipt_id);
''',
  ];
}
