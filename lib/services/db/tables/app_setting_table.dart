// lib/services/db/tables/app_setting_table.dart
class AppSettingTable {
  static const String tableName = 'app_setting';

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS app_setting (
  setting_key TEXT PRIMARY KEY,
  setting_value TEXT NOT NULL DEFAULT '',
  description TEXT,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
''';

  static const List<String> indexes = [];
}
