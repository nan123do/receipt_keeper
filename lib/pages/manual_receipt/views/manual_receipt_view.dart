// lib/pages/manual_receipt/views/manual_receipt_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/TextField/labeledtextfield.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/custom_popupmenubutton.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/components/custombottomsheet.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/components/mini_switch.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:receipt_keeper/pages/manual_receipt/controllers/manual_receipt_controller.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ManualReceiptView extends GetView<ManualReceiptController> {
  const ManualReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: CustomAppBar(
          title: controller.pageTitle,
          theme: controller.canShowEditActions ? 'normalIcon' : 'normal',
          widgetIcon: controller.canShowEditActions
              ? CustomPopupMenuButton(
                  paddingRight: 12,
                  menuItems: [
                    if (controller.canArchiveReceipt)
                      PopupMenuItem(
                        onTap: () {
                          Future.microtask(controller.archiveReceipt);
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.archive_outlined,
                              size: 18,
                              color: CareraTheme.gray80,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Arsipkan Struk'),
                            ),
                          ],
                        ),
                      ),
                    if (controller.canDeleteReceipt)
                      PopupMenuItem(
                        onTap: () {
                          Future.microtask(controller.deleteReceipt);
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: CareraTheme.red,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Hapus Struk',
                                style: TextStyle(
                                  color: CareraTheme.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : null,
        ),
        body: controller.isLoading.value
            ? const LoadingPage()
            : SafeArea(
                child: Form(
                  key: controller.formKey,
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
                                if (controller.hasDraftImage) ...[
                                  _buildImageSection(),
                                  16.gap,
                                ],
                                _buildMainSection(context),
                                16.gap,
                                _buildItemSection(),
                                16.gap,
                                _buildAdditionalSection(),
                              ],
                            ),
                          ),
                        ),
                        16.gap,
                        _buildBottomTotalBar(),
                        12.gap,
                        ButtonFull(
                          middleText: controller.submitButtonText,
                          readOnly: controller.isLoading.value,
                          ontap: controller.submitForm,
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
                  controller.infoTitle,
                  style: AxataTextStyle.textLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
                6.gap,
                Text(
                  controller.infoDescription,
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

  Widget _buildImageSection() {
    final imagePath = controller.normalizedDraftImagePath;
    if (imagePath == null) {
      return const SizedBox.shrink();
    }

    final imageFile = File(imagePath);

    return _buildSectionCard(
      title: 'Foto Struk',
      description: 'Foto struk ini akan ikut tersimpan bersama draft struk.',
      children: [
        if (imageFile.existsSync())
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
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
              title: 'Foto struk tidak ditemukan',
              message: 'Silakan ulangi scan bila gambar sudah tidak tersedia.',
            ),
          ),
        if (controller.draftImageSourceLabel != null) ...[
          12.gap,
          _buildBadge(
            icon: Icons.photo_camera_back_outlined,
            text: controller.draftImageSourceLabel!,
            backgroundColor: CareraTheme.turquoise30,
            iconColor: CareraTheme.mainColor,
            textColor: CareraTheme.gray90,
          ),
        ],
      ],
    );
  }

  Widget _buildMainSection(BuildContext context) {
    return _buildSectionCard(
      title: 'Informasi Utama',
      description: 'Isi data dasar struk sebelum menambahkan item belanja.',
      children: [
        GestureDetector(
          onTap: () => controller.openPurchaseDatePicker(context),
          child: AbsorbPointer(
            child: LabeledTextField(
              label: 'Tanggal Beli',
              hintText: 'Pilih tanggal beli',
              controller: controller.purchaseDateC,
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: CareraTheme.gray60,
              ),
            ),
          ),
        ),
        14.gap,
        LabeledTextField(
          label: 'Nama Toko',
          hintText: 'Isi nama toko bila ada',
          controller: controller.storeNameC,
          prefixIcon: const Icon(
            Icons.storefront_outlined,
            color: CareraTheme.gray60,
          ),
        ),
      ],
    );
  }

  Widget _buildItemSection() {
    return _buildSectionCard(
      title: 'Daftar Item',
      description:
          'Tambahkan barang dari struk. Garansi ditandai per item agar lebih jelas.',
      children: [
        ButtonFull(
          middleText: 'Tambah Item',
          icon: Icons.add_rounded,
          colorOpposite: true,
          bgColor: CareraTheme.mainColor,
          ontap: _openAddItemBottomSheet,
        ),
        14.gap,
        if (controller.draftItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: CareraTheme.gray5,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CareraTheme.gray20),
            ),
            child: const EmptyState(
              useExpanded: false,
              icon: Icons.shopping_bag_outlined,
              title: 'Belum ada item',
              message:
                  'Tambahkan item terlebih dahulu agar total belanja dihitung otomatis.',
            ),
          )
        else
          Column(
            children: List.generate(
              controller.draftItems.length,
              (index) {
                final item = controller.draftItems[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == controller.draftItems.length - 1 ? 0 : 12,
                  ),
                  child: _buildItemCard(
                    item: item,
                    index: index,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard({
    required ManualReceiptItemDraft item,
    required int index,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
                      item.itemName,
                      style: AxataTextStyle.textBase.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CareraTheme.black,
                      ),
                    ),
                    6.gap,
                    Text(
                      '${controller.formatDraftItemQty(item.qty)} x ${controller.formatDraftItemPrice(item.unitPrice)}',
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.gray70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              10.wGap,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatHelper.formatRupiah(item.subtotal),
                    style: AxataTextStyle.textBase.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CareraTheme.black,
                    ),
                  ),
                  8.gap,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconAction(
                        icon: Icons.edit_outlined,
                        color: CareraTheme.mainColor,
                        onTap: () => _openEditItemBottomSheet(
                          item: item,
                          index: index,
                        ),
                      ),
                      8.wGap,
                      _buildIconAction(
                        icon: Icons.delete_outline,
                        color: CareraTheme.red,
                        onTap: () => controller.removeDraftItem(index),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if ((item.note ?? '').trim().isNotEmpty) ...[
            10.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: CareraTheme.gray5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.note!.trim(),
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                ),
              ),
            ),
          ],
          10.gap,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                icon: Icons.shopping_bag_outlined,
                text: '${controller.formatDraftItemQty(item.qty)} item',
                backgroundColor: CareraTheme.gray5,
                iconColor: CareraTheme.gray70,
                textColor: CareraTheme.gray80,
              ),
              _buildBadge(
                icon: item.hasWarranty
                    ? Icons.verified_outlined
                    : Icons.shield_outlined,
                text: controller.formatDraftItemWarranty(item),
                backgroundColor: item.hasWarranty
                    ? CareraTheme.turquoise30
                    : CareraTheme.gray5,
                iconColor: item.hasWarranty
                    ? CareraTheme.mainColor
                    : CareraTheme.gray70,
                textColor:
                    item.hasWarranty ? CareraTheme.gray90 : CareraTheme.gray80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTotalBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Belanja',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                4.gap,
                Text(
                  controller.hasDraftItems
                      ? '${controller.draftItems.length} item • ${controller.warrantyItemCount} bergaransi'
                      : 'Belum ada item',
                  style: AxataTextStyle.textXs.copyWith(
                    color: CareraTheme.gray60,
                  ),
                ),
              ],
            ),
          ),
          12.wGap,
          Text(
            AppFormatHelper.formatRupiah(controller.itemsTotal),
            style: AxataTextStyle.textLg.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSection() {
    return _buildSectionCard(
      title: 'Catatan',
      description:
          'Opsional. Gunakan bila ada informasi tambahan yang ingin disimpan.',
      children: [
        LabeledTextField(
          label: 'Catatan',
          hintText: 'Tambah catatan bila perlu',
          controller: controller.noteC,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
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
              height: 1.4,
            ),
          ),
          14.gap,
          ...children,
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
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
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

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
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
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  Future<void> _openAddItemBottomSheet() async {
    final item = await _showItemBottomSheet();
    if (item == null) {
      return;
    }

    controller.addDraftItem(item);
  }

  Future<void> _openEditItemBottomSheet({
    required ManualReceiptItemDraft item,
    required int index,
  }) async {
    final updatedItem = await _showItemBottomSheet(initialItem: item);
    if (updatedItem == null) {
      return;
    }

    controller.updateDraftItem(index, updatedItem);
  }

  Future<ManualReceiptItemDraft?> _showItemBottomSheet({
    ManualReceiptItemDraft? initialItem,
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
    final warrantyMonthsC = TextEditingController(
      text: (initialItem?.warrantyMonths ?? 12).toString(),
    );

    bool hasWarranty = initialItem?.hasWarranty ?? false;

    final result = await CustomBottomSheet.showDynamic<ManualReceiptItemDraft>(
      title: initialItem == null ? 'Tambah Item' : 'Edit Item',
      primaryText: initialItem == null ? 'Simpan Item' : 'Simpan Perubahan',
      body: StatefulBuilder(
        builder: (context, setState) {
          return Form(
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
                          final qty =
                              NumberHelper.toDoubleCurrency(value ?? '');
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
                        hintText: '0',
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CareraTheme.gray5,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CareraTheme.gray20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Produk Bergaransi',
                              style: AxataTextStyle.textBase.copyWith(
                                fontWeight: FontWeight.w700,
                                color: CareraTheme.black,
                              ),
                            ),
                            4.gap,
                            Text(
                              'Aktifkan bila produk ini punya masa garansi.',
                              style: AxataTextStyle.textSm.copyWith(
                                color: CareraTheme.gray70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.wGap,
                      MiniSwitch(
                        value: hasWarranty,
                        onChanged: (value) {
                          setState(() {
                            hasWarranty = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (hasWarranty) ...[
                  14.gap,
                  LabeledTextField(
                    label: 'Durasi Garansi (Bulan)',
                    hintText: '12',
                    controller: warrantyMonthsC,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (!hasWarranty) {
                        return null;
                      }

                      final months =
                          NumberHelper.toDoubleCurrency(value ?? '').toInt();
                      if (months <= 0) {
                        return 'Durasi garansi harus lebih dari 0.';
                      }

                      return null;
                    },
                  ),
                ],
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
          );
        },
      ),
      onSave: () async {
        final isValid = formKey.currentState?.validate() ?? false;
        if (!isValid) {
          return null;
        }

        final itemName = itemNameC.text.trim();
        final qty = NumberHelper.toDoubleCurrency(qtyC.text);
        final unitPrice = NumberHelper.toDoubleCurrency(unitPriceC.text);
        final warrantyMonths = hasWarranty
            ? NumberHelper.toDoubleCurrency(warrantyMonthsC.text).toInt()
            : 12;

        if (itemName.isEmpty || qty <= 0 || unitPrice <= 0) {
          CustomToast.errorToast(
            'Data item belum lengkap',
            'Nama produk, jumlah, dan harga wajib diisi dengan benar.',
          );
          return null;
        }

        if (hasWarranty && warrantyMonths <= 0) {
          CustomToast.errorToast(
            'Durasi garansi belum valid',
            'Durasi garansi harus lebih dari 0 bulan.',
          );
          return null;
        }

        return ManualReceiptItemDraft(
          itemName: itemName,
          qty: qty,
          unitPrice: unitPrice,
          note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
          hasWarranty: hasWarranty,
          warrantyMonths: warrantyMonths,
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      itemNameC.dispose();
      qtyC.dispose();
      unitPriceC.dispose();
      noteC.dispose();
      warrantyMonthsC.dispose();
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
