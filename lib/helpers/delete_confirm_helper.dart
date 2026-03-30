// lib/helpers/delete_confirm_helper.dart
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Dialog/delete_confirm_dialog.dart';

class DeleteConfirmHelper {
  DeleteConfirmHelper._();

  static Future<bool> show({
    String title = 'Hapus Data',
    String message = 'Apakah Anda yakin menghapus data ini?',
    String? description,
    bool barrierDismissible = true,
  }) async {
    final result = await Get.dialog<bool>(
      DeleteConfirmDialog(
        title: title,
        message: message,
        description: description,
      ),
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }

  static Future<void> showAndExecute({
    String title = 'Hapus Data',
    String message = 'Apakah Anda yakin menghapus data ini?',
    String? description,
    bool barrierDismissible = true,
    required Future<void> Function() onConfirm,
  }) async {
    final isConfirmed = await show(
      title: title,
      message: message,
      description: description,
      barrierDismissible: barrierDismissible,
    );

    if (isConfirmed == false) {
      return;
    }

    await onConfirm();
  }
}
