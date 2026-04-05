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

  String? _dbPath;
  File? _dbFile;
  sqlite.Database? _db;

  String get dbPath => _dbPath ?? '';
  File get dbFile => _dbFile!;
  sqlite.Database get db => _db!;

  Future<AppDbService> init() async {
    if (isReady.value && _db != null) {
      return this;
    }

    await _prepareDbFile();

    _db = sqlite.sqlite3.open(dbPath);
    _db!.execute('PRAGMA foreign_keys = ON;');

    _migrate();

    isReady.value = true;
    return this;
  }

  void _migrate() {
    final database = db;
    final result = database.select('PRAGMA user_version;');
    final currentVersion =
        result.isNotEmpty ? (result.first['user_version'] as int? ?? 0) : 0;

    if (currentVersion >= schemaVersion) {
      return;
    }

    database.execute('BEGIN;');

    try {
      _createTables();
      database.execute('PRAGMA user_version = $schemaVersion;');
      database.execute('COMMIT;');
    } catch (_) {
      database.execute('ROLLBACK;');
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

  Future<String> ensureDbPath() async {
    await _prepareDbFile();
    return dbPath;
  }

  Future<File> ensureDbFile() async {
    await _prepareDbFile();
    return dbFile;
  }

  Future<void> closeConnection() async {
    final database = _db;
    if (!isReady.value || database == null) {
      return;
    }

    database.dispose();
    _db = null;
    isReady.value = false;
  }

  Future<void> reopenConnection() async {
    await closeConnection();
    await init();
  }

  Future<void> deleteDatabaseFile() async {
    final file = await ensureDbFile();
    await closeConnection();

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _prepareDbFile() async {
    if (_dbPath != null && _dbFile != null) {
      if (!await _dbFile!.exists()) {
        await _dbFile!.create(recursive: true);
      }

      return;
    }

    final directory = await getApplicationDocumentsDirectory();

    _dbPath = p.join(directory.path, dbName);
    _dbFile = File(_dbPath!);

    if (!await _dbFile!.exists()) {
      await _dbFile!.create(recursive: true);
    }
  }
}
