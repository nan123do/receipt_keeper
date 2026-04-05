// lib/services/backup/local_backup_service.dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:receipt_keeper/services/db/app_db_service.dart';

class LocalBackupService {
  LocalBackupService({
    AppDbService? appDbService,
  }) : _appDbService = appDbService ?? AppDbService.to;

  final AppDbService _appDbService;

  static const String backupFolderName = 'backups';
  static const String backupFilePrefix = 'receipt_keeper_backup';

  Future<File> createLocalBackup() async {
    final backupDirectory = await _ensureBackupDirectory();
    final targetFile = File(
      p.join(
        backupDirectory.path,
        '${backupFilePrefix}_${_buildTimestamp(DateTime.now())}.sqlite',
      ),
    );

    await _appDbService.closeConnection();

    try {
      final dbFile = await _appDbService.ensureDbFile();
      await dbFile.copy(targetFile.path);
      return targetFile;
    } finally {
      await _appDbService.init();
    }
  }

  Future<List<File>> getLocalBackups({
    int limit = 10,
  }) async {
    final backupDirectory = await _ensureBackupDirectory();
    final entities = backupDirectory.listSync();

    final files = entities
        .whereType<File>()
        .where(
          (file) =>
              p.extension(file.path).toLowerCase() == '.sqlite' &&
              p.basename(file.path).startsWith('${backupFilePrefix}_'),
        )
        .toList()
      ..sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

    if (limit <= 0 || files.length <= limit) {
      return files;
    }

    return files.take(limit).toList();
  }

  Future<File?> getLatestLocalBackup() async {
    final backups = await getLocalBackups(limit: 1);
    if (backups.isEmpty) {
      return null;
    }

    return backups.first;
  }

  Future<void> restoreFromBackup(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('File backup tidak ditemukan');
    }

    await _appDbService.closeConnection();

    try {
      final dbFile = await _appDbService.ensureDbFile();

      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      await backupFile.copy(dbFile.path);
    } finally {
      await _appDbService.init();
    }
  }

  Future<Directory> _ensureBackupDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory(
      p.join(documentsDirectory.path, backupFolderName),
    );

    if (!await backupDirectory.exists()) {
      await backupDirectory.create(recursive: true);
    }

    return backupDirectory;
  }

  String _buildTimestamp(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');

    return '$year$month${day}_$hour$minute$second';
  }
}
