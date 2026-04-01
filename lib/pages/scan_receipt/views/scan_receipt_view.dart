// lib/pages/scan_receipt/views/scan_receipt_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/pages/scan_receipt/controllers/scan_receipt_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ScanReceiptView extends GetView<ScanReceiptController> {
  const ScanReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Scan Struk',
          theme: 'normal',
        ),
        body: SafeArea(
          child: Padding(
            padding: CareraTheme.paddingScaffold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(),
                        16.gap,
                        _buildActionSection(),
                        if (controller.isLoading.value) ...[
                          16.gap,
                          _buildLoadingCard(),
                        ],
                        16.gap,
                        _buildPreviewSection(),
                        16.gap,
                        _buildOcrResultSection(),
                      ],
                    ),
                  ),
                ),
                16.gap,
                if (controller.hasSelectedImage && controller.isOcrFailed) ...[
                  ButtonFull(
                    middleText: 'Coba Baca OCR Lagi',
                    icon: Icons.refresh_rounded,
                    colorOpposite: true,
                    bgColor: CareraTheme.mainColor,
                    ontap: controller.retryOcr,
                  ),
                  12.gap,
                ],
                if (controller.hasSelectedImage) ...[
                  ButtonFull(
                    middleText: 'Ulangi Scan',
                    icon: Icons.photo_camera_back_rounded,
                    colorOpposite: true,
                    bgColor: CareraTheme.mainColor,
                    ontap: controller.retryScan,
                  ),
                  12.gap,
                ],
                ButtonFull(
                  middleText: controller.continueButtonText,
                  icon: controller.hasOcrText
                      ? Icons.arrow_forward_rounded
                      : Icons.edit_note_rounded,
                  readOnly: !controller.canContinue,
                  ontap: controller.canContinue
                      ? () => controller.continueToDraft()
                      : null,
                ),
                8.gap,
                Text(
                  controller.continueHelperText,
                  style: AxataTextStyle.textXs.copyWith(
                    color: CareraTheme.gray60,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CareraTheme.turquoise20,
            CareraTheme.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CareraTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CareraTheme.turquoise50),
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              color: CareraTheme.mainColor,
              size: 22,
            ),
          ),
          12.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambil foto struk',
                  style: AxataTextStyle.textLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
                6.gap,
                Text(
                  'Pilih dari kamera atau galeri, lalu lanjutkan ke draft struk untuk cek hasilnya.',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        _buildActionTile(
          title: 'Ambil dari kamera',
          description: 'Cocok jika struk masih ada di tangan Anda.',
          icon: Icons.camera_alt_outlined,
          iconBackground: CareraTheme.turquoise30,
          iconColor: CareraTheme.mainColor,
          onTap: controller.isLoading.value
              ? null
              : () => controller.pickFromCamera(),
        ),
        12.gap,
        _buildActionTile(
          title: 'Pilih dari galeri',
          description: 'Gunakan foto struk yang sudah tersimpan.',
          icon: Icons.photo_library_outlined,
          iconBackground: CareraTheme.orange20,
          iconColor: CareraTheme.orange100,
          onTap: controller.isLoading.value
              ? null
              : () => controller.pickFromGallery(),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CareraTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CareraTheme.gray20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              12.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AxataTextStyle.textBase.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CareraTheme.black,
                      ),
                    ),
                    4.gap,
                    Text(
                      description,
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.gray70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              12.wGap,
              const Icon(
                Icons.chevron_right_rounded,
                color: CareraTheme.gray60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: CareraTheme.mainColor,
            ),
          ),
          12.wGap,
          Expanded(
            child: Text(
              'Sedang menyiapkan gambar struk...',
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray80,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.previewTitle,
                      style: AxataTextStyle.textBase.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CareraTheme.black,
                      ),
                    ),
                    4.gap,
                    Text(
                      controller.previewDescription,
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.gray70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.hasSelectedImage) ...[
                12.wGap,
                _buildSourceBadge(),
              ],
            ],
          ),
          14.gap,
          _buildPreviewBody(),
        ],
      ),
    );
  }

  Widget _buildOcrResultSection() {
    final hasImage = controller.hasSelectedImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Deteksi OCR',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          4.gap,
          Text(
            controller.isProcessingOcr.value
                ? 'Sistem sedang membaca teks dari struk Anda.'
                : controller.hasOcrText
                    ? 'Cek hasil bacaan awal sebelum lanjut ke draft.'
                    : hasImage
                        ? 'OCR belum menemukan teks yang cukup jelas. Anda tetap bisa lanjut dan isi manual.'
                        : 'Hasil OCR akan tampil setelah Anda memilih gambar struk.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.4,
            ),
          ),
          14.gap,
          if (!hasImage)
            _buildOcrEmptyCard(
              icon: Icons.text_snippet_outlined,
              title: 'Belum ada hasil OCR',
              message:
                  'Silakan ambil foto atau pilih gambar struk terlebih dahulu.',
            )
          else if (controller.isProcessingOcr.value)
            _buildOcrLoadingCard()
          else if (controller.hasOcrText)
            _buildOcrSuccessCard()
          else
            _buildOcrEmptyCard(
              icon: Icons.warning_amber_rounded,
              title: 'Teks belum terbaca jelas',
              message: controller.ocrErrorMessage.value ??
                  'Anda tetap bisa lanjut ke draft dan isi data secara manual.',
            ),
          if (controller.isOcrFailed) ...[
            12.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CareraTheme.orange20,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CareraTheme.orange50),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: CareraTheme.orange100,
                  ),
                  10.wGap,
                  Expanded(
                    child: Text(
                      'Hasil OCR belum cukup jelas. Anda bisa coba baca ulang OCR atau lanjut isi draft secara manual.',
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.gray80,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOcrLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: CareraTheme.mainColor,
            ),
          ),
          12.wGap,
          Expanded(
            child: Text(
              'Sedang membaca teks struk...',
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray80,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrSuccessCard() {
    final lines = controller.ocrResult.value.lines;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.turquoise10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.turquoise40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoBadge(
                icon: Icons.check_circle_outline_rounded,
                text: '${lines.length} baris terbaca',
                backgroundColor: CareraTheme.white,
                iconColor: CareraTheme.mainColor,
                textColor: CareraTheme.gray90,
              ),
              _buildInfoBadge(
                icon: Icons.edit_note_rounded,
                text: 'Tetap bisa diedit',
                backgroundColor: CareraTheme.white,
                iconColor: CareraTheme.orange100,
                textColor: CareraTheme.gray90,
              ),
            ],
          ),
          12.gap,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CareraTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CareraTheme.gray20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.take(6).map((line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $line',
                    style: AxataTextStyle.textSm.copyWith(
                      color: CareraTheme.gray80,
                      height: 1.35,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (lines.length > 6) ...[
            10.gap,
            Text(
              '+${lines.length - 6} baris lain akan dicek lagi di halaman draft.',
              style: AxataTextStyle.textXs.copyWith(
                color: CareraTheme.gray70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOcrEmptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: CareraTheme.gray60,
          ),
          10.gap,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          6.gap,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          6.wGap,
          Text(
            text,
            style: AxataTextStyle.textXs.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CareraTheme.turquoise30,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 14,
            color: CareraTheme.mainColor,
          ),
          6.wGap,
          Text(
            controller.sourceLabel,
            style: AxataTextStyle.textXs.copyWith(
              color: CareraTheme.gray90,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody() {
    if (!controller.hasSelectedImage) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: CareraTheme.gray5,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CareraTheme.gray20),
        ),
        child: const EmptyState(
          useExpanded: false,
          icon: Icons.image_search_outlined,
          title: 'Preview belum tersedia',
          message: 'Belum ada foto struk yang dipilih.',
        ),
      );
    }

    final imagePath = controller.selectedImagePath.value!;
    final imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: CareraTheme.gray5,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CareraTheme.gray20),
        ),
        child: const EmptyState(
          useExpanded: false,
          icon: Icons.broken_image_outlined,
          title: 'File gambar tidak ditemukan',
          message: 'Silakan ulangi scan atau pilih gambar lagi.',
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        decoration: BoxDecoration(
          color: CareraTheme.gray5,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Image.file(
          imageFile,
          width: double.infinity,
          height: 360,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
