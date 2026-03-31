// lib/pages/manual_receipt/controllers/manual_receipt_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/datehelper.dart';
import 'package:receipt_keeper/helpers/delete_confirm_helper.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:receipt_keeper/helpers/receipt_validation_helper.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_item_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';

class ManualReceiptItemDraft {
  final String itemName;
  final double qty;
  final double unitPrice;
  final String? note;
  final bool hasWarranty;
  final int warrantyMonths;

  const ManualReceiptItemDraft({
    required this.itemName,
    this.qty = 1,
    this.unitPrice = 0,
    this.note,
    this.hasWarranty = false,
    this.warrantyMonths = 12,
  });

  double get subtotal => qty * unitPrice;

  String? get normalizedNote {
    final value = note?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  ManualReceiptItemDraft copyWith({
    String? itemName,
    double? qty,
    double? unitPrice,
    String? note,
    bool? hasWarranty,
    int? warrantyMonths,
  }) {
    return ManualReceiptItemDraft(
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      note: note ?? this.note,
      hasWarranty: hasWarranty ?? this.hasWarranty,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
    );
  }
}

class ManualReceiptController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final ReceiptItemDaoService _receiptItemDaoService = ReceiptItemDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  final TextEditingController purchaseDateC = TextEditingController();
  final TextEditingController totalAmountC = TextEditingController();
  final TextEditingController noteC = TextEditingController();
  final TextEditingController storeNameC = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isFromScanFlow = false.obs;
  final RxnInt receiptId = RxnInt();
  final Rx<DateTime> selectedPurchaseDate = DateTime.now().obs;
  final RxList<ManualReceiptItemDraft> draftItems =
      <ManualReceiptItemDraft>[].obs;
  final RxnString draftImagePath = RxnString();
  final RxnString draftImageSource = RxnString();

  Receipt? loadedReceipt;

  DateTime get purchaseDate => selectedPurchaseDate.value;

  bool get hasDraftItems => draftItems.isNotEmpty;

  double get totalAmountValue => itemsTotal;

  double get itemsTotal {
    return draftItems.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  int get warrantyItemCount {
    return draftItems.where((item) => item.hasWarranty).length;
  }

  bool get canDeleteReceipt => isEditMode.value && receiptId.value != null;

  bool get canArchiveReceipt {
    if (!isEditMode.value) {
      return false;
    }

    if (receiptId.value == null) {
      return false;
    }

    return !(loadedReceipt?.isArchived ?? false);
  }

  bool get canShowEditActions => canDeleteReceipt || canArchiveReceipt;

  String get pageTitle =>
      isEditMode.value ? 'Edit Struk Manual' : 'Tambah Struk Manual';

  String get submitButtonText =>
      isEditMode.value ? 'Simpan Perubahan' : 'Simpan Struk';

  String get infoTitle =>
      isEditMode.value ? 'Edit struk manual' : 'Input struk manual';

  String get infoDescription {
    if (isEditMode.value) {
      return 'Silakan cek data utama, perbarui item, lalu simpan perubahan struk Anda.';
    }

    if (hasDraftImage) {
      return 'Foto struk sudah ditambahkan. Silakan cek data utama dan tambahkan item belanja.';
    }

    return 'Isi tanggal dan nama toko, lalu tambahkan item dari struk. Total akan dihitung otomatis.';
  }

  String? get noteValue {
    final value = noteC.text.trim();
    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  String? get storeNameValue {
    final value = storeNameC.text.trim();
    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  Receipt get draftReceipt {
    return Receipt(
      id: receiptId.value,
      storeName: storeNameValue,
      purchaseDate: purchaseDate,
      totalAmount: totalAmountValue,
      imagePath: normalizedDraftImagePath ?? loadedReceipt?.imagePath,
      note: noteValue,
      rawOcrText: loadedReceipt?.rawOcrText,
      isArchived: loadedReceipt?.isArchived ?? false,
      createdAt: loadedReceipt?.createdAt,
      updatedAt: loadedReceipt?.updatedAt,
    );
  }

  bool get hasDraftImage {
    final value = draftImagePath.value?.trim();
    return value != null && value.isNotEmpty;
  }

  String? get normalizedDraftImagePath {
    final value = draftImagePath.value?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  String? get draftImageSourceLabel {
    switch (draftImageSource.value) {
      case 'camera':
        return 'Dari kamera';
      case 'gallery':
        return 'Dari galeri';
      default:
        return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _setInitialValue();
    _handleArguments();
  }

  void _setInitialValue() {
    setPurchaseDate(DateTime.now());
    syncTotalAmountFromItems();
  }

  void _handleArguments() {
    final args = Get.arguments;

    if (args is! Map<String, dynamic>) {
      return;
    }

    isEditMode.value = args['isEditMode'] == true;
    isFromScanFlow.value = args['fromScanFlow'] == true;

    final rawReceiptId = args['receiptId'];
    if (rawReceiptId is int) {
      receiptId.value = rawReceiptId;
    } else if (rawReceiptId != null) {
      receiptId.value = int.tryParse(rawReceiptId.toString());
    }

    _applyScanDraftArguments(args);

    if (isEditMode.value) {
      loadReceiptForEdit();
    }
  }

  void _applyScanDraftArguments(Map<String, dynamic> args) {
    if (isEditMode.value) {
      return;
    }

    final rawImagePath = args['scanImagePath'];
    if (rawImagePath != null) {
      final imagePath = rawImagePath.toString().trim();
      if (imagePath.isNotEmpty) {
        draftImagePath.value = imagePath;
      }
    }

    final rawSource = args['scanSource'];
    if (rawSource != null) {
      final source = rawSource.toString().trim();
      if (source.isNotEmpty) {
        draftImageSource.value = source;
      }
    }
  }

  void loadReceiptForEdit() {
    if (isLoading.value) {
      return;
    }

    final id = receiptId.value;
    if (id == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk untuk edit tidak ditemukan.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final receipt = _receiptDaoService.getById(id);
      if (receipt == null) {
        CustomToast.errorToast(
          'Data tidak ditemukan',
          'Struk yang ingin Anda edit tidak ditemukan.',
        );
        return;
      }

      _applyReceiptToForm(receipt);
      _loadDraftItemsForEdit(id);
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memuat data',
        'Data struk belum bisa dimuat ke form edit.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyReceiptToForm(Receipt receipt) {
    loadedReceipt = receipt;
    receiptId.value = receipt.id;
    draftImagePath.value = receipt.imagePath;
    draftImageSource.value = null;

    setPurchaseDate(receipt.purchaseDate);
    totalAmountC.text = _formatEditableNumber(receipt.totalAmount);
    noteC.text = receipt.note ?? '';
    storeNameC.text = receipt.storeName ?? '';
  }

  void _loadDraftItemsForEdit(int id) {
    final items = _receiptItemDaoService.getByReceiptId(id);
    final warranties = _warrantyDaoService.getByReceiptId(id);

    draftItems.value = items.map((item) {
      Warranty? matchedWarranty;

      for (final warranty in warranties) {
        final sameItemId =
            warranty.receiptItemId != null && warranty.receiptItemId == item.id;
        final sameProductName = warranty.receiptItemId == null &&
            warranty.productName.trim().toLowerCase() ==
                item.itemName.trim().toLowerCase();

        if (sameItemId || sameProductName) {
          matchedWarranty = warranty;
          break;
        }
      }

      return ManualReceiptItemDraft(
        itemName: item.itemName,
        qty: item.qty,
        unitPrice: item.unitPrice,
        note: item.note,
        hasWarranty: matchedWarranty != null,
        warrantyMonths: matchedWarranty?.warrantyMonths ?? 12,
      );
    }).toList();

    if (draftItems.isNotEmpty) {
      syncTotalAmountFromItems();
    }
  }

  void setPurchaseDate(DateTime value) {
    final normalizedDate = DateTime(
      value.year,
      value.month,
      value.day,
    );

    selectedPurchaseDate.value = normalizedDate;
    purchaseDateC.text = AppFormatHelper.formatDate(
      normalizedDate,
      pattern: 'dd MMMM yyyy',
    );
  }

  void openPurchaseDatePicker(BuildContext context) {
    if (isLoading.value) {
      return;
    }

    DateHelper.listDatePickerV2(
      context,
      'dd MMMM yyyy',
      selectedPurchaseDate.value,
      purchaseDateC.text,
      (value, _) {
        setPurchaseDate(value);
      },
    );
  }

  String? validateTotalAmount(String? value) {
    return ReceiptValidationHelper.validateTotalAmount(totalAmountValue);
  }

  String? validateDraftItems() {
    if (draftItems.isEmpty) {
      return 'Tambahkan minimal 1 item terlebih dahulu.';
    }

    return null;
  }

  void addDraftItem(ManualReceiptItemDraft item) {
    draftItems.add(item);
    syncTotalAmountFromItems();
  }

  void updateDraftItem(int index, ManualReceiptItemDraft item) {
    if (index < 0 || index >= draftItems.length) {
      return;
    }

    draftItems[index] = item;
    draftItems.refresh();
    syncTotalAmountFromItems();
  }

  Future<void> removeDraftItem(int index) async {
    if (index < 0 || index >= draftItems.length) {
      return;
    }

    final isConfirmed = await DeleteConfirmHelper.show(
      title: 'Hapus Item',
      message: 'Apakah Anda yakin ingin menghapus item ini?',
      description: 'Item yang dihapus akan hilang dari draft struk.',
    );

    if (!isConfirmed) {
      return;
    }

    draftItems.removeAt(index);
    syncTotalAmountFromItems();
  }

  void syncTotalAmountFromItems() {
    totalAmountC.text = _formatEditableNumber(itemsTotal);
  }

  String formatDraftItemQty(double value) {
    final isWholeNumber = value == value.truncateToDouble();
    if (isWholeNumber) {
      return value.toInt().toString();
    }

    return NumberHelper.toCurrencyString(
      value,
      maxFraction: 2,
      minFraction: 0,
    );
  }

  String formatDraftItemPrice(double value) {
    return AppFormatHelper.formatRupiah(
      value,
      maxFraction: value == value.truncateToDouble() ? 0 : 2,
    );
  }

  String formatDraftItemWarranty(ManualReceiptItemDraft item) {
    if (!item.hasWarranty) {
      return 'Tanpa garansi';
    }

    return 'Garansi ${item.warrantyMonths} bulan';
  }

  String _formatEditableNumber(num value) {
    final normalizedValue = value.toDouble();
    final isWholeNumber = normalizedValue == normalizedValue.truncateToDouble();

    return NumberHelper.toCurrencyString(
      normalizedValue,
      maxFraction: isWholeNumber ? 0 : 2,
      minFraction: 0,
    );
  }

  Future<void> submitForm() async {
    if (isLoading.value) {
      return;
    }

    if (isEditMode.value) {
      await updateReceipt();
      return;
    }

    await saveReceipt();
  }

  Future<void> _closeAfterSave({
    required String title,
    required String message,
  }) async {
    if (isFromScanFlow.value) {
      Get.until((route) => route.settings.name == Routes.HOME_RECEIPT);

      if (Get.isRegistered<HomeReceiptController>()) {
        await Get.find<HomeReceiptController>()
            .loadReceipts(showLoading: false);
      }

      CustomToast.successToast(title, message);
      return;
    }

    Get.back(result: true);
    CustomToast.successToast(title, message);
  }

  Future<void> saveReceipt() async {
    if (isLoading.value) {
      return;
    }

    final isValidForm = formKey.currentState?.validate() ?? false;
    if (!isValidForm) {
      return;
    }

    final draftItemMessage = validateDraftItems();
    if (draftItemMessage != null) {
      CustomToast.errorToast(
        'Item belum lengkap',
        draftItemMessage,
      );
      return;
    }

    final receipt = draftReceipt;
    final validationMessage = ReceiptValidationHelper.validate(receipt);

    if (validationMessage != null) {
      CustomToast.errorToast(
        'Data belum lengkap',
        validationMessage,
      );
      return;
    }

    try {
      isLoading.value = true;

      final savedReceiptId = _receiptDaoService.insert(receipt);
      _saveDraftChildren(savedReceiptId);

      await _closeAfterSave(
        title: 'Struk berhasil disimpan',
        message: 'Struk manual sudah masuk ke galeri struk.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menyimpan',
        'Struk manual belum bisa disimpan.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReceipt() async {
    if (isLoading.value) {
      return;
    }

    final isValidForm = formKey.currentState?.validate() ?? false;
    if (!isValidForm) {
      return;
    }

    final id = receiptId.value;
    if (id == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk tidak ditemukan.',
      );
      return;
    }

    final draftItemMessage = validateDraftItems();
    if (draftItemMessage != null) {
      CustomToast.errorToast(
        'Item belum lengkap',
        draftItemMessage,
      );
      return;
    }

    final receipt = draftReceipt;
    final validationMessage = ReceiptValidationHelper.validate(receipt);

    if (validationMessage != null) {
      CustomToast.errorToast(
        'Data belum lengkap',
        validationMessage,
      );
      return;
    }

    try {
      isLoading.value = true;

      _receiptDaoService.update(
        receipt.copyWith(id: id),
      );
      _warrantyDaoService.deleteByReceiptId(id);
      _receiptItemDaoService.deleteByReceiptId(id);
      _saveDraftChildren(id);

      Get.back(result: true);
      CustomToast.successToast(
        'Perubahan disimpan',
        'Data struk berhasil diperbarui.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menyimpan perubahan',
        'Data struk belum bisa diperbarui.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _saveDraftChildren(int savedReceiptId) {
    for (final item in draftItems) {
      final itemId = _receiptItemDaoService.insert(
        ReceiptItem(
          receiptId: savedReceiptId,
          itemName: item.itemName,
          qty: item.qty,
          unitPrice: item.unitPrice,
          subtotal: item.subtotal,
          note: item.normalizedNote,
        ),
      );

      if (!item.hasWarranty) {
        continue;
      }

      _warrantyDaoService.insert(
        Warranty(
          receiptId: savedReceiptId,
          receiptItemId: itemId,
          productName: item.itemName,
          purchaseDate: purchaseDate,
          warrantyMonths: item.warrantyMonths,
          isReminderEnabled: false,
        ),
      );
    }
  }

  Future<void> deleteReceipt() async {
    if (isLoading.value) {
      return;
    }

    final id = receiptId.value;
    if (id == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk tidak ditemukan.',
      );
      return;
    }

    final isConfirmed = await DeleteConfirmHelper.show(
      title: 'Hapus Struk',
      message: 'Apakah Anda yakin ingin menghapus struk ini?',
      description: 'Data struk yang dihapus tidak bisa dikembalikan.',
    );

    if (!isConfirmed) {
      return;
    }

    try {
      isLoading.value = true;

      _receiptDaoService.delete(id);

      Get.back(result: true);
      CustomToast.successToast(
        'Struk dihapus',
        'Struk berhasil dihapus.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menghapus',
        'Struk belum bisa dihapus.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> archiveReceipt() async {
    if (isLoading.value) {
      return;
    }

    final id = receiptId.value;
    if (id == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk tidak ditemukan.',
      );
      return;
    }

    try {
      isLoading.value = true;

      _receiptDaoService.setArchived(
        id,
        isArchived: true,
      );

      loadedReceipt = loadedReceipt?.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );

      Get.back(result: true);
      CustomToast.successToast(
        'Struk diarsipkan',
        'Struk berhasil dipindahkan ke arsip.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal mengarsipkan',
        'Struk belum bisa dipindahkan ke arsip.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    loadedReceipt = null;
    receiptId.value = null;
    isEditMode.value = false;

    draftItems.clear();
    draftImagePath.value = null;
    draftImageSource.value = null;
    totalAmountC.clear();
    noteC.clear();
    storeNameC.clear();
    setPurchaseDate(DateTime.now());
    syncTotalAmountFromItems();
  }

  @override
  void onClose() {
    purchaseDateC.dispose();
    totalAmountC.dispose();
    noteC.dispose();
    storeNameC.dispose();
    super.onClose();
  }
}
