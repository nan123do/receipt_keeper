// lib/services/db/app_db_service.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:receipt_keeper/services/db/tables/app_setting_table.dart';
import 'package:receipt_keeper/services/db/tables/receipt_item_table.dart';
import 'package:receipt_keeper/services/db/tables/receipt_table.dart';
import 'package:receipt_keeper/services/db/tables/warranty_table.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

class AppDbService extends GetxService {
  static AppDbService get to => Get.find<AppDbService>();

  static const String dbName = 'receipt_keeper.sqlite';
  static const int schemaVersion = 1;

  final RxBool isReady = false.obs;

  late final String dbPath;
  late final File dbFile;
  late final sqlite.Database db;

  Future<AppDbService> init() async {
    final directory = await getApplicationDocumentsDirectory();

    dbPath = p.join(directory.path, dbName);
    dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      await dbFile.create(recursive: true);
    }

    db = sqlite.sqlite3.open(dbPath);
    db.execute('PRAGMA foreign_keys = ON;');

    _migrate();

    isReady.value = true;
    return this;
  }

  void _migrate() {
    final result = db.select('PRAGMA user_version;');
    final currentVersion =
        result.isNotEmpty ? (result.first['user_version'] as int? ?? 0) : 0;

    if (currentVersion >= schemaVersion) {
      return;
    }

    db.execute('BEGIN;');

    try {
      _createTables();
      db.execute('PRAGMA user_version = $schemaVersion;');
      db.execute('COMMIT;');
    } catch (_) {
      db.execute('ROLLBACK;');
      rethrow;
    }
  }

  void _createTables() {
    final statements = <String>[
      ReceiptTable.createTable,
      ...ReceiptTable.indexes,
      ReceiptItemTable.createTable,
      ...ReceiptItemTable.indexes,
      WarrantyTable.createTable,
      ...WarrantyTable.indexes,
      AppSettingTable.createTable,
      ...AppSettingTable.indexes,
    ];

    for (final statement in statements) {
      db.execute(statement);
    }
  }

  Future<void> closeConnection() async {
    if (!isReady.value) {
      return;
    }

    db.dispose();
    isReady.value = false;
  }

  Future<void> deleteDatabaseFile() async {
    await closeConnection();

    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }
}
