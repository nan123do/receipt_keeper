// lib/helpers/premium_gate_prompt_helper.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Dialog/restore_confirm_dialog.dart';
import 'package:receipt_keeper/routes/app_pages.dart';

class PremiumGatePromptHelper {
  PremiumGatePromptHelper._();

  static Future<void> showReceiptLimitReached({
    required int freeLimit,
  }) async {
    final shouldOpenPremium = await Get.dialog<bool>(
      RestoreConfirmDialog(
        title: 'Kuota Struk Gratis Habis',
        message: 'Paket gratis bisa menyimpan hingga $freeLimit struk.',
        description:
            'Upgrade ke Premium agar Anda bisa menambah struk baru tanpa terhalang kuota gratis.',
        actionText: 'Lihat Premium',
        icon: Icons.workspace_premium_outlined,
      ),
    );

    if (shouldOpenPremium == true) {
      await Get.toNamed(Routes.PREMIUM);
    }
  }

  static Future<void> showOcrLimitReached({
    required int freeLimit,
  }) async {
    final shouldOpenPremium = await Get.dialog<bool>(
      RestoreConfirmDialog(
        title: 'Kuota OCR Gratis Habis',
        message:
            'OCR otomatis gratis bisa dipakai hingga $freeLimit kali per bulan.',
        description:
            'Upgrade ke Premium agar Anda bisa scan OCR lebih leluasa tanpa kehabisan kuota.',
        actionText: 'Lihat Premium',
        icon: Icons.document_scanner_outlined,
      ),
    );

    if (shouldOpenPremium == true) {
      await Get.toNamed(Routes.PREMIUM);
    }
  }

  static Future<void> showNotificationPremiumOnly() async {
    final shouldOpenPremium = await Get.dialog<bool>(
      const RestoreConfirmDialog(
        title: 'Fitur Premium',
        message: 'Pengingat garansi hanya tersedia di paket Premium.',
        description:
            'Upgrade ke Premium agar Anda bisa menyalakan pengingat per produk dan tidak telat klaim.',
        actionText: 'Lihat Premium',
        icon: Icons.notifications_active_outlined,
      ),
    );

    if (shouldOpenPremium == true) {
      await Get.toNamed(Routes.PREMIUM);
    }
  }

  static Future<bool> confirmFreeExportContinuation() async {
    final result = await Get.dialog<bool>(
      const RestoreConfirmDialog(
        title: 'Export Lebih Praktis di Premium',
        message:
            'Mode gratis masih bisa export PDF, tetapi Premium lebih nyaman untuk kebutuhan rutin.',
        description:
            'Tekan Lanjut Export untuk tetap membuat PDF sekarang, atau pilih Batal bila ingin lihat paket Premium dulu.',
        actionText: 'Lanjut Export',
        icon: Icons.picture_as_pdf_outlined,
      ),
    );

    return result == true;
  }
}
