// lib/pages/receipt_detail/views/receipt_detail_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/TextField/labeledtextfield.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/components/custombottomsheet.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/label_value_row.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/pages/receipt_detail/controllers/receipt_detail_controller.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ReceiptDetailView extends GetView<ReceiptDetailController> {
  const ReceiptDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }

          controller.backToPreviousPage();
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: controller.pageTitle,
            theme: 'normal',
            onBack: controller.backToPreviousPage,
          ),
          body: controller.isLoading.value
              ? const LoadingPage()
              : SafeArea(
                  child: Padding(
                    padding: CareraTheme.paddingScaffold,
                    child: controller.hasReceipt
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildHeroCard(),
                                      16.gap,
                                      _buildReceiptImageSection(),
                                      16.gap,
                                      _buildReceiptInfoSection(),
                                      16.gap,
                                      _buildItemSection(),
                                      16.gap,
                                      _buildReceiptActionSection(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              EmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: 'Detail struk tidak ditemukan',
                                message:
                                    'Data struk ini belum tersedia atau sudah dihapus.',
                              ),
                            ],
                          ),
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
              Icons.receipt_long_outlined,
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
                  controller.storeNameLabel,
                  style: AxataTextStyle.textLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
                6.gap,
                Text(
                  controller.purchaseDateLabel,
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                    height: 1.4,
                  ),
                ),
                12.gap,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(
                      icon: Icons.shopping_bag_outlined,
                      text: '${controller.itemCount} item',
                      backgroundColor: CareraTheme.gray5,
                      iconColor: CareraTheme.gray70,
                      textColor: CareraTheme.gray80,
                    ),
                    _buildBadge(
                      icon: Icons.verified_outlined,
                      text: '${controller.warrantyCount} garansi',
                      backgroundColor: controller.hasWarranties
                          ? CareraTheme.turquoise30
                          : CareraTheme.gray5,
                      iconColor: controller.hasWarranties
                          ? CareraTheme.mainColor
                          : CareraTheme.gray70,
                      textColor: controller.hasWarranties
                          ? CareraTheme.gray90
                          : CareraTheme.gray80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImageSection() {
    final imagePath = controller.imagePath;

    return _buildSectionCard(
      title: 'Foto Struk Original',
      child: imagePath == null
          ? _buildImagePlaceholder(
              title: 'Foto struk belum tersedia',
              message: 'Belum ada gambar struk yang tersimpan.',
            )
          : _buildImageContent(imagePath),
    );
  }

  Widget _buildImageContent(String imagePath) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      return _buildImagePlaceholder(
        title: 'File gambar tidak ditemukan',
        message: 'Path gambar tersimpan, tetapi file aslinya sudah tidak ada.',
      );
    }

    return GestureDetector(
      onTap: () => _openImagePreview(file),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Image.file(
              file,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tap untuk perbesar',
                  style: AxataTextStyle.textXs.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePreview(File file) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.file(file),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptInfoSection() {
    return _buildSectionCard(
      title: 'Informasi Struk',
      child: Column(
        children: [
          LabelValueRow.text(
            'Nama Toko',
            controller.storeNameLabel,
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray90,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildDivider(),
          LabelValueRow.text(
            'Tanggal Beli',
            controller.purchaseDateLabel,
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray90,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildDivider(),
          LabelValueRow(
            'Total Belanja',
            Text(
              controller.totalAmountLabel,
              style: AxataTextStyle.textBase.copyWith(
                color: CareraTheme.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray90,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildDivider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catatan',
                style: AxataTextStyle.textBase.copyWith(
                  color: CareraTheme.gray90,
                  fontWeight: FontWeight.w500,
                ),
              ),
              12.wGap,
              Expanded(
                child: Text(
                  controller.noteLabel,
                  textAlign: TextAlign.right,
                  style: AxataTextStyle.textBase.copyWith(
                    color: CareraTheme.gray90,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemSection() {
    return _buildSectionCard(
      title: 'Daftar Item',
      trailing: Text(
        controller.hasItems ? '${controller.itemCount} item' : 'Belum ada item',
        style: AxataTextStyle.textSm.copyWith(
          color: CareraTheme.gray70,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ButtonFull(
            middleText: controller.addItemButtonText,
            icon: Icons.add_rounded,
            colorOpposite: true,
            bgColor: CareraTheme.mainColor,
            readOnly: !controller.canManageItems,
            ontap: controller.canManageItems ? _openAddItemBottomSheet : null,
          ),
          14.gap,
          if (!controller.hasItems)
            const EmptyState(
              useExpanded: false,
              icon: Icons.shopping_bag_outlined,
              title: 'Belum ada item',
              message:
                  'Tambahkan item terlebih dahulu agar isi struk lebih lengkap.',
            )
          else
            Column(
              children: [
                ListView.separated(
                  itemCount: controller.itemList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = controller.itemList[index];
                    return _buildItemTile(item);
                  },
                ),
                16.gap,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: CareraTheme.gray5,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CareraTheme.gray20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total dari item',
                          style: AxataTextStyle.textSm.copyWith(
                            color: CareraTheme.gray70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        controller.itemSubtotalLabel,
                        style: AxataTextStyle.textBase.copyWith(
                          color: CareraTheme.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptActionSection() {
    return _buildSectionCard(
      title: 'Aksi Struk',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: CareraTheme.mainColor,
                  onTap: controller.canUseReceiptActions
                      ? controller.openEditReceipt
                      : null,
                ),
              ),
              12.wGap,
              Expanded(
                child: _buildActionButton(
                  icon: Icons.ios_share_outlined,
                  label: 'Export',
                  color: CareraTheme.turquoise80,
                  onTap: controller.canUseReceiptActions
                      ? controller.exportReceipt
                      : null,
                ),
              ),
            ],
          ),
          12.gap,
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Hapus Struk',
            color: CareraTheme.red,
            onTap: controller.canUseReceiptActions
                ? controller.deleteReceipt
                : null,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ReceiptItem item) {
    final note = item.note?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.itemName,
                style: AxataTextStyle.textBase.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.black,
                ),
              ),
            ),
            12.wGap,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconAction(
                  icon: Icons.edit_outlined,
                  color: CareraTheme.mainColor,
                  onTap: controller.canManageItems
                      ? () => _openEditItemBottomSheet(item: item)
                      : null,
                ),
                8.wGap,
                _buildIconAction(
                  icon: Icons.delete_outline,
                  color: CareraTheme.red,
                  onTap: controller.canManageItems
                      ? () => controller.removeManualItem(item)
                      : null,
                ),
              ],
            ),
          ],
        ),
        if (note != null && note.isNotEmpty) ...[
          4.gap,
          Text(
            note,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.4,
            ),
          ),
        ],
        10.gap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${controller.formatItemQty(item.qty)} x ${controller.formatItemPrice(item.unitPrice)}',
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            12.wGap,
            Text(
              AppFormatHelper.formatRupiah(item.subtotal),
              style: AxataTextStyle.textBase.copyWith(
                color: CareraTheme.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder({
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: CareraTheme.gray60,
            size: 34,
          ),
          10.gap,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AxataTextStyle.textBaseBold.copyWith(
              color: CareraTheme.black,
            ),
          ),
          6.gap,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray60,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          14.gap,
          child,
        ],
      ),
    );
  }

  Widget _buildBadge({
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
            size: 15,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isFullWidth = false,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: onTap == null
                ? CareraTheme.gray10
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: onTap == null ? CareraTheme.gray20 : color,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: onTap == null ? CareraTheme.gray50 : color,
              ),
              8.wGap,
              Text(
                label,
                style: AxataTextStyle.textBase.copyWith(
                  color: onTap == null ? CareraTheme.gray50 : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: onTap == null
                ? CareraTheme.gray10
                : color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? CareraTheme.gray50 : color,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        color: CareraTheme.gray20,
      ),
    );
  }

  Future<void> _openAddItemBottomSheet() async {
    final result = await _showItemBottomSheet();
    if (result == null) {
      return;
    }

    await controller.addManualItem(
      itemName: result.itemName,
      qty: result.qty,
      unitPrice: result.unitPrice,
      note: result.note,
    );
  }

  Future<void> _openEditItemBottomSheet({
    required ReceiptItem item,
  }) async {
    final result = await _showItemBottomSheet(initialItem: item);
    if (result == null) {
      return;
    }

    await controller.updateManualItem(
      sourceItem: item,
      itemName: result.itemName,
      qty: result.qty,
      unitPrice: result.unitPrice,
      note: result.note,
    );
  }

  Future<_ReceiptItemFormValue?> _showItemBottomSheet({
    ReceiptItem? initialItem,
  }) async {
    final formKey = GlobalKey<FormState>();
    final itemNameC = TextEditingController(text: initialItem?.itemName ?? '');
    final qtyC = TextEditingController(
      text: _formatInputNumber(initialItem?.qty ?? 1),
    );
    final unitPriceC = TextEditingController(
      text: _formatInputNumber(initialItem?.unitPrice ?? 0),
    );
    final noteC = TextEditingController(text: initialItem?.note ?? '');

    final result = await CustomBottomSheet.showDynamic<_ReceiptItemFormValue>(
      title: initialItem == null ? 'Tambah Item' : 'Edit Item',
      primaryText: initialItem == null ? 'Simpan Item' : 'Simpan Perubahan',
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledTextField(
              label: 'Nama Produk',
              hintText: 'Contoh: Kipas Angin Sekai',
              controller: itemNameC,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Nama produk wajib diisi.';
                }

                return null;
              },
            ),
            14.gap,
            Row(
              children: [
                Expanded(
                  child: LabeledTextField(
                    label: 'Jumlah',
                    hintText: '1',
                    controller: qtyC,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final qty = NumberHelper.toDoubleCurrency(value ?? '');
                      if (qty <= 0) {
                        return 'Jumlah harus lebih dari 0.';
                      }

                      return null;
                    },
                  ),
                ),
                12.wGap,
                Expanded(
                  child: LabeledTextField(
                    label: 'Harga',
                    hintText: 'Rp 0',
                    controller: unitPriceC,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final unitPrice =
                          NumberHelper.toDoubleCurrency(value ?? '');
                      if (unitPrice <= 0) {
                        return 'Harga harus lebih dari 0.';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            14.gap,
            LabeledTextField(
              label: 'Catatan',
              hintText: 'Opsional',
              controller: noteC,
              maxLines: 3,
            ),
            12.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CareraTheme.turquoise20,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CareraTheme.turquoise50),
              ),
              child: Text(
                'Subtotal akan dihitung otomatis dari jumlah x harga.',
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray80,
                ),
              ),
            ),
          ],
        ),
      ),
      onSave: () async {
        final isValid = formKey.currentState?.validate() ?? false;
        if (!isValid) {
          return null;
        }

        final itemName = itemNameC.text.trim();
        final qty = NumberHelper.toDoubleCurrency(qtyC.text);
        final unitPrice = NumberHelper.toDoubleCurrency(unitPriceC.text);

        if (itemName.isEmpty || qty <= 0 || unitPrice <= 0) {
          CustomToast.errorToast(
            'Data item belum lengkap',
            'Nama produk, jumlah, dan harga wajib diisi dengan benar.',
          );
          return null;
        }

        return _ReceiptItemFormValue(
          itemName: itemName,
          qty: qty,
          unitPrice: unitPrice,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      itemNameC.dispose();
      qtyC.dispose();
      unitPriceC.dispose();
      noteC.dispose();
    });

    return result;
  }

  String _formatInputNumber(double value) {
    final isWholeNumber = value == value.truncateToDouble();
    return NumberHelper.toCurrencyString(
      value,
      maxFraction: isWholeNumber ? 0 : 2,
      minFraction: 0,
    );
  }
}

class _ReceiptItemFormValue {
  final String itemName;
  final double qty;
  final double unitPrice;
  final String? note;

  const _ReceiptItemFormValue({
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    this.note,
  });
}
