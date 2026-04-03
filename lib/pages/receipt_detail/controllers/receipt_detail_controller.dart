// lib/pages/receipt_detail/controllers/receipt_detail_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/delete_confirm_helper.dart';
import 'package:receipt_keeper/helpers/report_export_helper.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_item_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';

class ReceiptDetailController extends GetxController {
  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final ReceiptItemDaoService _receiptItemDaoService = ReceiptItemDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  final RxBool isLoading = false.obs;
  final RxBool isItemActionLoading = false.obs;
  final RxBool isReceiptActionLoading = false.obs;
  final RxBool didChangeData = false.obs;

  final RxnInt receiptId = RxnInt();
  final Rxn<Receipt> receiptData = Rxn<Receipt>();
  final RxList<ReceiptItem> itemList = <ReceiptItem>[].obs;
  final RxList<Warranty> warrantyList = <Warranty>[].obs;

  Receipt? get receipt => receiptData.value;

  bool get hasReceipt => receipt != null;
  bool get hasItems => itemList.isNotEmpty;
  bool get hasWarranties => warrantyList.isNotEmpty;

  bool get isBusy =>
      isLoading.value ||
      isItemActionLoading.value ||
      isReceiptActionLoading.value;

  bool get canManageItems => hasReceipt && !isBusy;
  bool get canManageWarranties => hasReceipt && !isBusy;
  bool get canUseReceiptActions => hasReceipt && !isBusy;

  String get pageTitle {
    final storeName = normalizedStoreName;
    if (storeName != null) {
      return storeName;
    }

    return 'Detail Struk';
  }

  String? get normalizedStoreName {
    final value = receipt?.storeName?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  String get storeNameLabel {
    return normalizedStoreName ?? 'Tanpa nama toko';
  }

  String get purchaseDateLabel {
    return AppFormatHelper.formatDateTime(receipt?.purchaseDate);
  }

  String get totalAmountLabel {
    return AppFormatHelper.formatRupiah(receipt?.totalAmount ?? 0);
  }

  String get noteLabel {
    final value = receipt?.note?.trim();
    if (value == null || value.isEmpty) {
      return 'Tidak ada catatan';
    }

    return value;
  }

  String? get imagePath {
    final value = receipt?.imagePath?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  int get itemCount => itemList.length;

  int get warrantyCount => warrantyList.length;

  double get itemSubtotal {
    return itemList.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  String get itemSubtotalLabel {
    return AppFormatHelper.formatRupiah(itemSubtotal);
  }

  String get addItemButtonText {
    return isItemActionLoading.value ? 'Menyimpan...' : 'Tambah Item';
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    getInit();
  }

  Future<void> getInit() async {
    await loadDetail();
  }

  void _readArguments() {
    final args = Get.arguments;

    if (args is int) {
      receiptId.value = args;
      return;
    }

    if (args is String) {
      receiptId.value = int.tryParse(args);
      return;
    }

    if (args is Map<String, dynamic>) {
      final dynamic rawId = args['receiptId'] ?? args['id'];

      if (rawId is int) {
        receiptId.value = rawId;
        return;
      }

      if (rawId != null) {
        receiptId.value = int.tryParse(rawId.toString());
      }
    }
  }

  Future<void> loadDetail({
    bool showLoading = true,
  }) async {
    final id = receiptId.value;

    if (id == null || id <= 0) {
      CustomToast.errorToast(
        'Detail tidak valid',
        'ID struk tidak ditemukan.',
      );
      return;
    }

    try {
      if (showLoading) {
        isLoading.value = true;
      }

      final loadedReceipt = _receiptDaoService.getById(id);

      if (loadedReceipt == null) {
        receiptData.value = null;
        itemList.clear();
        warrantyList.clear();

        CustomToast.errorToast(
          'Data tidak ditemukan',
          'Struk yang dipilih sudah tidak tersedia.',
        );
        return;
      }

      final loadedItems = _receiptItemDaoService.getByReceiptId(id);
      final loadedWarranties = _warrantyDaoService.getByReceiptId(id);

      receiptData.value = loadedReceipt;
      itemList.assignAll(loadedItems);
      warrantyList.assignAll(loadedWarranties);
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memuat detail',
        'Detail struk belum bisa ditampilkan.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addManualItem({
    required String itemName,
    required double qty,
    required double unitPrice,
    String? note,
  }) async {
    final currentReceiptId = receiptId.value;
    if (currentReceiptId == null || currentReceiptId <= 0) {
      CustomToast.errorToast(
        'Data tidak valid',
        'ID struk tidak ditemukan.',
      );
      return;
    }

    try {
      isItemActionLoading.value = true;

      final newItem = ReceiptItem(
        receiptId: currentReceiptId,
        itemName: itemName.trim(),
        qty: qty,
        unitPrice: unitPrice,
        subtotal: qty * unitPrice,
        note: _normalizeNullable(note),
      );

      _receiptItemDaoService.insert(newItem);

      await _reloadChildrenOnly();
      await _syncReceiptTotalFromItems();

      didChangeData.value = true;

      CustomToast.successToast(
        'Item berhasil ditambahkan',
        'Item baru sudah masuk ke daftar struk.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menambahkan item',
        'Item baru belum bisa disimpan.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Future<void> updateManualItem({
    required ReceiptItem sourceItem,
    required String itemName,
    required double qty,
    required double unitPrice,
    String? note,
  }) async {
    if (sourceItem.id == null) {
      CustomToast.errorToast(
        'Data item tidak valid',
        'ID item tidak ditemukan.',
      );
      return;
    }

    try {
      isItemActionLoading.value = true;

      final updatedItem = sourceItem.copyWith(
        itemName: itemName.trim(),
        qty: qty,
        unitPrice: unitPrice,
        subtotal: qty * unitPrice,
        note: _normalizeNullable(note),
      );

      _receiptItemDaoService.update(updatedItem);
      await _syncLinkedWarrantyName(updatedItem);
      await _reloadChildrenOnly();
      await _syncReceiptTotalFromItems();

      didChangeData.value = true;

      CustomToast.successToast(
        'Item berhasil diperbarui',
        'Perubahan item sudah disimpan.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memperbarui item',
        'Perubahan item belum bisa disimpan.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Future<void> removeManualItem(ReceiptItem item) async {
    if (item.id == null) {
      CustomToast.errorToast(
        'Data item tidak valid',
        'ID item tidak ditemukan.',
      );
      return;
    }

    final linkedWarranties = warrantyList
        .where((warranty) => warranty.receiptItemId == item.id)
        .toList();

    final isConfirmed = await DeleteConfirmHelper.show(
      title: 'Hapus Item',
      message: 'Apakah Anda yakin ingin menghapus item ini?',
      description: linkedWarranties.isNotEmpty
          ? 'Garansi yang terhubung dengan item ini juga akan ikut dihapus.'
          : 'Item yang dihapus akan hilang dari struk ini.',
    );

    if (!isConfirmed) {
      return;
    }

    try {
      isItemActionLoading.value = true;

      for (final warranty in linkedWarranties) {
        if (warranty.id != null) {
          _warrantyDaoService.delete(warranty.id!);
        }
      }

      _receiptItemDaoService.delete(item.id!);

      await _reloadChildrenOnly();
      await _syncReceiptTotalFromItems();

      didChangeData.value = true;

      CustomToast.successToast(
        'Item berhasil dihapus',
        'Item sudah dihapus dari struk.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menghapus item',
        'Item belum bisa dihapus.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Warranty? findWarrantyByItemId(int? itemId) {
    if (itemId == null) {
      return null;
    }

    for (final warranty in warrantyList) {
      if (warranty.receiptItemId == itemId) {
        return warranty;
      }
    }

    return null;
  }

  ReceiptItem? findItemById(int? itemId) {
    if (itemId == null) {
      return null;
    }

    for (final item in itemList) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  ReceiptItem? getLinkedItem(Warranty warranty) {
    return findItemById(warranty.receiptItemId);
  }

  bool hasWarrantyForItem(ReceiptItem item) {
    return findWarrantyByItemId(item.id) != null;
  }

  String getWarrantyActionLabel(ReceiptItem item) {
    return hasWarrantyForItem(item) ? 'Edit Garansi' : 'Tambah Garansi';
  }

  Future<void> addWarrantyFromItem({
    required ReceiptItem sourceItem,
    required int warrantyMonths,
  }) async {
    final currentReceiptId = receiptId.value;
    final currentReceipt = receipt;

    if (currentReceiptId == null ||
        currentReceiptId <= 0 ||
        currentReceipt == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Struk belum ditemukan.',
      );
      return;
    }

    if (sourceItem.id == null) {
      CustomToast.errorToast(
        'Data item tidak valid',
        'Item belum bisa dipakai untuk garansi.',
      );
      return;
    }

    if (warrantyMonths <= 0) {
      CustomToast.errorToast(
        'Durasi tidak valid',
        'Durasi garansi harus lebih dari 0 bulan.',
      );
      return;
    }

    final existingWarranty = findWarrantyByItemId(sourceItem.id);
    if (existingWarranty != null) {
      CustomToast.errorToast(
        'Garansi sudah ada',
        'Item ini sudah punya data garansi. Silakan edit data yang ada.',
      );
      return;
    }

    try {
      isItemActionLoading.value = true;

      final newWarranty = Warranty(
        receiptId: currentReceiptId,
        receiptItemId: sourceItem.id,
        productName: sourceItem.itemName,
        purchaseDate: currentReceipt.purchaseDate,
        warrantyMonths: warrantyMonths,
      );

      _warrantyDaoService.insert(newWarranty);
      await _reloadChildrenOnly();

      didChangeData.value = true;

      CustomToast.successToast(
        'Garansi berhasil ditambahkan',
        'Data garansi sudah tersimpan pada struk ini.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menambahkan garansi',
        'Data garansi belum bisa disimpan.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Future<void> updateWarranty({
    required Warranty sourceWarranty,
    required int warrantyMonths,
  }) async {
    if (sourceWarranty.id == null) {
      CustomToast.errorToast(
        'Data garansi tidak valid',
        'ID garansi tidak ditemukan.',
      );
      return;
    }

    if (warrantyMonths <= 0) {
      CustomToast.errorToast(
        'Durasi tidak valid',
        'Durasi garansi harus lebih dari 0 bulan.',
      );
      return;
    }

    try {
      isItemActionLoading.value = true;

      final linkedItem = getLinkedItem(sourceWarranty);
      final updatedWarranty = sourceWarranty.copyWith(
        productName: linkedItem?.itemName ?? sourceWarranty.productName,
        purchaseDate: receipt?.purchaseDate ?? sourceWarranty.purchaseDate,
        warrantyMonths: warrantyMonths,
      );

      _warrantyDaoService.update(updatedWarranty);
      await _reloadChildrenOnly();

      didChangeData.value = true;

      CustomToast.successToast(
        'Garansi berhasil diperbarui',
        'Perubahan garansi sudah disimpan.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memperbarui garansi',
        'Perubahan garansi belum bisa disimpan.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Future<void> removeWarranty(Warranty warranty) async {
    if (warranty.id == null) {
      CustomToast.errorToast(
        'Data garansi tidak valid',
        'ID garansi tidak ditemukan.',
      );
      return;
    }

    final isConfirmed = await DeleteConfirmHelper.show(
      title: 'Hapus Garansi',
      message: 'Apakah Anda yakin ingin menghapus data garansi ini?',
      description:
          'Pengingat garansi untuk item ini akan ikut hilang dari struk.',
    );

    if (!isConfirmed) {
      return;
    }

    try {
      isItemActionLoading.value = true;

      _warrantyDaoService.delete(warranty.id!);
      await _reloadChildrenOnly();

      didChangeData.value = true;

      CustomToast.successToast(
        'Garansi berhasil dihapus',
        'Data garansi sudah dihapus dari struk.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menghapus garansi',
        'Data garansi belum bisa dihapus.',
      );
    } finally {
      isItemActionLoading.value = false;
    }
  }

  Future<void> openWarrantyPage() async {
    if (isBusy) {
      return;
    }

    final result = await Get.toNamed(Routes.WARRANTY);

    if (result == true) {
      didChangeData.value = true;
      await loadDetail(showLoading: false);
    }
  }

  Future<void> openEditReceipt() async {
    if (isBusy) {
      return;
    }

    final id = receiptId.value;
    if (id == null || id <= 0) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk tidak ditemukan.',
      );
      return;
    }

    try {
      isReceiptActionLoading.value = true;

      final result = await Get.toNamed(
        Routes.MANUAL_RECEIPT,
        arguments: {
          'isEditMode': true,
          'receiptId': id,
        },
      );

      if (result == true) {
        didChangeData.value = true;
        await _syncWarrantyPurchaseDateFromReceipt();
        await loadDetail(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Form edit struk belum bisa dibuka.',
      );
    } finally {
      isReceiptActionLoading.value = false;
    }
  }

  Future<void> exportReceipt() async {
    final currentReceipt = receipt;
    if (currentReceipt == null) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Struk belum bisa diexport.',
      );
      return;
    }

    try {
      isReceiptActionLoading.value = true;

      final storeName = normalizedStoreName ?? 'tanpa_toko';
      final subject =
          'Struk $storeName - ${AppFormatHelper.formatDate(currentReceipt.purchaseDate)}';

      final rawImagePath = currentReceipt.imagePath?.trim();
      if (rawImagePath != null && rawImagePath.isNotEmpty) {
        final imageFile = File(rawImagePath);

        if (imageFile.existsSync()) {
          await ReportExportHelper.shareFile(
            imageFile,
            subject: subject,
          );
          return;
        }
      }

      final tempDir = await getTemporaryDirectory();
      final safeStoreName = _sanitizeFileName(storeName);
      final exportFile = File(
        '${tempDir.path}/receipt_keeper_${safeStoreName}_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      await exportFile.writeAsString(_buildReceiptSummary(currentReceipt));

      await ReportExportHelper.shareFile(
        exportFile,
        subject: subject,
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal export',
        'Struk belum bisa dibagikan.',
      );
    } finally {
      isReceiptActionLoading.value = false;
    }
  }

  Future<void> deleteReceipt() async {
    if (isBusy) {
      return;
    }

    final id = receiptId.value;
    if (id == null || id <= 0) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Id struk tidak ditemukan.',
      );
      return;
    }

    final isConfirmed = await DeleteConfirmHelper.show(
      title: 'Hapus Struk',
      message: 'Apakah Anda yakin ingin menghapus struk ini?',
      description: 'Item dan garansi yang terhubung juga akan ikut dihapus.',
    );

    if (!isConfirmed) {
      return;
    }

    try {
      isReceiptActionLoading.value = true;

      _warrantyDaoService.deleteByReceiptId(id);
      _receiptItemDaoDeleteByReceiptId(id);
      _receiptDaoService.delete(id);

      didChangeData.value = true;

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
      isReceiptActionLoading.value = false;
    }
  }

  void backToPreviousPage() {
    Get.back(result: didChangeData.value);
  }

  Future<void> _reloadChildrenOnly() async {
    final id = receiptId.value;
    if (id == null || id <= 0) {
      return;
    }

    final loadedItems = _receiptItemDaoService.getByReceiptId(id);
    final loadedWarranties = _warrantyDaoService.getByReceiptId(id);

    itemList.assignAll(loadedItems);
    warrantyList.assignAll(loadedWarranties);
  }

  Future<void> _syncReceiptTotalFromItems() async {
    final currentReceipt = receipt;
    if (currentReceipt == null) {
      return;
    }

    final updatedReceipt = currentReceipt.copyWith(
      totalAmount: itemSubtotal,
      updatedAt: DateTime.now(),
    );

    _receiptDaoService.update(updatedReceipt);
    receiptData.value = updatedReceipt;
  }

  Future<void> _syncLinkedWarrantyName(ReceiptItem item) async {
    if (item.id == null) {
      return;
    }

    final currentPurchaseDate = receipt?.purchaseDate;
    final linkedWarranties = warrantyList
        .where((warranty) => warranty.receiptItemId == item.id)
        .toList();

    for (final warranty in linkedWarranties) {
      if (warranty.id == null) {
        continue;
      }

      _warrantyDaoService.update(
        warranty.copyWith(
          productName: item.itemName,
          purchaseDate: currentPurchaseDate ?? warranty.purchaseDate,
        ),
      );
    }
  }

  Future<void> _syncWarrantyPurchaseDateFromReceipt() async {
    final id = receiptId.value;
    if (id == null || id <= 0) {
      return;
    }

    final latestReceipt = _receiptDaoService.getById(id);
    if (latestReceipt == null) {
      return;
    }

    final currentWarranties = _warrantyDaoService.getByReceiptId(id);

    for (final warranty in currentWarranties) {
      if (warranty.id == null) {
        continue;
      }

      _warrantyDaoService.update(
        warranty.copyWith(
          purchaseDate: latestReceipt.purchaseDate,
        ),
      );
    }
  }

  // ignore: non_constant_identifier_names
  void _receiptItemDaoDeleteByReceiptId(int receiptId) {
    _receiptItemDaoService.deleteByReceiptId(receiptId);
  }

  String formatItemQty(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  String formatItemPrice(double value) {
    return AppFormatHelper.formatRupiah(
      value,
      maxFraction: value == value.truncateToDouble() ? 0 : 2,
    );
  }

  String _buildReceiptSummary(Receipt receipt) {
    final buffer = StringBuffer();

    buffer.writeln('RECEIPT KEEPER');
    buffer.writeln('Ringkasan Struk');
    buffer.writeln('');
    buffer.writeln('Toko: $storeNameLabel');
    buffer.writeln(
      'Tanggal: ${AppFormatHelper.formatDateTime(receipt.purchaseDate)}',
    );
    buffer.writeln(
      'Total: ${AppFormatHelper.formatRupiah(receipt.totalAmount)}',
    );
    buffer.writeln('Jumlah Item: $itemCount');
    buffer.writeln('Jumlah Garansi: $warrantyCount');

    final note = receipt.note?.trim();
    if (note != null && note.isNotEmpty) {
      buffer.writeln('Catatan: $note');
    }

    if (itemList.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Daftar Item:');

      for (final item in itemList) {
        buffer.writeln(
          '- ${item.itemName} | ${formatItemQty(item.qty)} x ${formatItemPrice(item.unitPrice)} = ${AppFormatHelper.formatRupiah(item.subtotal)}',
        );

        final itemNote = item.note?.trim();
        if (itemNote != null && itemNote.isNotEmpty) {
          buffer.writeln('  Catatan: $itemNote');
        }
      }
    }

    if (warrantyList.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Daftar Garansi:');

      for (final warranty in warrantyList) {
        buffer.writeln(
          '- ${warranty.productName} | ${warranty.warrantyMonths} bulan | Habis ${AppFormatHelper.formatDate(warranty.expiryDate)}',
        );
      }
    }

    return buffer.toString();
  }

  String _sanitizeFileName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String? _normalizeNullable(String? value) {
    final result = value?.trim();
    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }
}
