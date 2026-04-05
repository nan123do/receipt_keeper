// lib/services/receipt/receipt_image_storage_service.dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptImageStorageService {
  static const String _folderName = 'receipt_images';

  Future<String?> persistImagePath(String? sourcePath) async {
    final normalizedPath = sourcePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return null;
    }

    final sourceFile = File(normalizedPath);
    if (!await sourceFile.exists()) {
      return null;
    }

    if (await isManagedImagePath(normalizedPath)) {
      return normalizedPath;
    }

    final targetDirectory = await _ensureDirectory();
    final extension = _resolveExtension(normalizedPath);
    final fileName =
        'receipt_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = p.join(targetDirectory.path, fileName);

    final copiedFile = await sourceFile.copy(targetPath);
    return copiedFile.path;
  }

  Future<void> deleteManagedImage(String? imagePath) async {
    final normalizedPath = imagePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return;
    }

    if (!await isManagedImagePath(normalizedPath)) {
      return;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      return;
    }

    await file.delete();
  }

  Future<bool> isManagedImagePath(String? imagePath) async {
    final normalizedPath = imagePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return false;
    }

    final targetDirectory = await _ensureDirectory();
    final normalizedFolderPath = p.normalize(targetDirectory.path);
    final normalizedImagePath = p.normalize(normalizedPath);

    return p.isWithin(normalizedFolderPath, normalizedImagePath) ||
        normalizedFolderPath == p.dirname(normalizedImagePath);
  }

  Future<Directory> _ensureDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(
      p.join(appDirectory.path, _folderName),
    );

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    return targetDirectory;
  }

  String _resolveExtension(String path) {
    final extension = p.extension(path).trim().toLowerCase();
    if (extension.isEmpty) {
      return '.jpg';
    }

    return extension;
  }
}
