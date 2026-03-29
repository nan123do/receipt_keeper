// lib/services/db/tables/warranty_table.dart
class WarrantyTable {
  static const String tableName = 'warranty';

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS warranty (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receipt_id INTEGER NOT NULL,
  receipt_item_id INTEGER,
  product_name TEXT NOT NULL,
  purchase_date TEXT NOT NULL,
  warranty_months INTEGER NOT NULL DEFAULT 12,
  is_reminder_enabled INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (receipt_id) REFERENCES receipt(id) ON DELETE CASCADE,
  FOREIGN KEY (receipt_item_id) REFERENCES receipt_item(id) ON DELETE SET NULL
);
''';

  static const List<String> indexes = [
    '''
CREATE INDEX IF NOT EXISTS idx_warranty_receipt_id
ON warranty(receipt_id);
''',
    '''
CREATE INDEX IF NOT EXISTS idx_warranty_receipt_item_id
ON warranty(receipt_item_id);
''',
    '''
CREATE INDEX IF NOT EXISTS idx_warranty_purchase_date
ON warranty(purchase_date DESC);
''',
  ];
}
