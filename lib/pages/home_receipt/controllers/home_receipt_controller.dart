// lib/pages/home_receipt/controllers/home_receipt_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/delete_confirm_helper.dart';
import 'package:receipt_keeper/helpers/report_export_helper.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_item_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';

class HomeReceiptController extends GetxController {
  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final ReceiptItemDaoService _receiptItemDaoService = ReceiptItemDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  final TextEditingController searchC = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool latestFirst = true.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Receipt> receiptList = <Receipt>[].obs;
  final RxMap<int, int> itemCountMap = <int, int>{}.obs;
  final RxMap<int, int> warrantyCountMap = <int, int>{}.obs;

  Worker? _searchWorker;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  String get sortLabel => latestFirst.value ? 'Terbaru' : 'Terlama';

  int get totalReceiptCount => receiptList.length;

  int get totalWarrantyCount {
    var total = 0;

    for (final value in warrantyCountMap.values) {
      total += value;
    }

    return total;
  }

  List<HomeReceiptSection> get groupedReceiptSections {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final todayReceipts = <Receipt>[];
    final weekReceipts = <Receipt>[];
    final olderReceipts = <Receipt>[];

    for (final receipt in receiptList) {
      final purchaseDate = DateTime(
        receipt.purchaseDate.year,
        receipt.purchaseDate.month,
        receipt.purchaseDate.day,
      );

      if (_isSameDate(purchaseDate, today)) {
        todayReceipts.add(receipt);
        continue;
      }

      if (!purchaseDate.isBefore(startOfWeek)) {
        weekReceipts.add(receipt);
        continue;
      }

      olderReceipts.add(receipt);
    }

    final sections = <HomeReceiptSection>[];

    if (todayReceipts.isNotEmpty) {
      sections.add(
        HomeReceiptSection(
          title: 'Hari ini',
          items: todayReceipts,
        ),
      );
    }

    if (weekReceipts.isNotEmpty) {
      sections.add(
        HomeReceiptSection(
          title: 'Minggu ini',
          items: weekReceipts,
        ),
      );
    }

    if (olderReceipts.isNotEmpty) {
      sections.add(
        HomeReceiptSection(
          title: 'Lama',
          items: olderReceipts,
        ),
      );
    }

    return sections;
  }

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadReceipts(showLoading: false),
      time: const Duration(milliseconds: 350),
    );

    getInit();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchC.dispose();
    super.onClose();
  }

  Future<void> getInit() async {
    await loadReceipts();
  }

  Future<void> loadReceipts({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      final result = _receiptDaoService.getAll(
        search: searchQuery.value,
        isArchived: false,
        latestFirst: latestFirst.value,
      );

      receiptList.assignAll(result);
      _loadAdditionalCounts();
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memuat data',
        'Daftar struk belum bisa ditampilkan.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.trim();
  }

  Future<void> clearSearch() async {
    if (searchC.text.trim().isEmpty && searchQuery.value.isEmpty) {
      return;
    }

    searchC.clear();
    searchQuery.value = '';
    await loadReceipts(showLoading: false);
  }

  Future<void> changeSortOrder(bool value) async {
    if (latestFirst.value == value) {
      return;
    }

    latestFirst.value = value;
    await loadReceipts(showLoading: false);
  }

  Future<void> openReceiptDetail(Receipt receipt) async {
    final receiptId = receipt.id;
    if (receiptId == null) {
      CustomToast.errorToast(
        'Data belum lengkap',
        'Detail struk belum bisa dibuka.',
      );
      return;
    }

    try {
      final result = await Get.toNamed(
        Routes.RECEIPT_DETAIL,
        arguments: receiptId,
      );

      if (result == true) {
        await loadReceipts(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Detail struk akan aktif setelah modul detail dibuat.',
      );
    }
  }

  Future<void> openScanReceipt() async {
    try {
      final result = await Get.toNamed(Routes.SCAN_RECEIPT);

      if (result == true) {
        await loadReceipts(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Fitur scan struk akan aktif setelah modul scan dibuat.',
      );
    }
  }

  Future<void> archiveReceipt(Receipt receipt) async {
    final receiptId = receipt.id;
    if (receiptId == null) {
      return;
    }

    try {
      _receiptDaoService.setArchived(
        receiptId,
        isArchived: true,
      );

      await loadReceipts(showLoading: false);

      CustomToast.successToast(
        'Struk diarsipkan',
        'Struk berhasil dipindahkan ke arsip.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal mengarsipkan',
        'Struk belum bisa dipindahkan ke arsip.',
      );
    }
  }

  Future<void> deleteReceipt(Receipt receipt) async {
    final receiptId = receipt.id;
    if (receiptId == null) {
      return;
    }

    try {
      final isConfirmed = await DeleteConfirmHelper.show(
        title: 'Hapus Struk',
        message: 'Apakah Anda yakin ingin menghapus struk ini?',
        description: 'Data yang dihapus tidak bisa dikembalikan.',
      );

      if (!isConfirmed) {
        return;
      }

      _receiptDaoService.delete(receiptId);
      await loadReceipts(showLoading: false);

      CustomToast.successToast(
        'Struk dihapus',
        'Struk berhasil dihapus.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal menghapus',
        'Struk belum bisa dihapus.',
      );
    }
  }

  Future<void> quickExportReceipt(Receipt receipt) async {
    try {
      final storeName = _getStoreName(receipt);
      final subject =
          'Struk $storeName - ${AppFormatHelper.formatDate(receipt.purchaseDate)}';

      final imagePath = receipt.imagePath?.trim();
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);

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

      await exportFile.writeAsString(_buildReceiptSummary(receipt));

      await ReportExportHelper.shareFile(
        exportFile,
        subject: subject,
      );
    } catch (e) {
      CustomToast.errorToast(
        'Gagal export',
        'Struk belum bisa dibagikan.',
      );
    }
  }

  void _loadAdditionalCounts() {
    final itemCounts = <int, int>{};
    final warrantyCounts = <int, int>{};

    for (final receipt in receiptList) {
      final receiptId = receipt.id;
      if (receiptId == null) {
        continue;
      }

      itemCounts[receiptId] =
          _receiptItemDaoService.countByReceiptId(receiptId);
      warrantyCounts[receiptId] =
          _warrantyDaoService.countByReceiptId(receiptId);
    }

    itemCountMap.assignAll(itemCounts);
    warrantyCountMap.assignAll(warrantyCounts);
  }

  int getItemCount(int? receiptId) {
    if (receiptId == null) {
      return 0;
    }

    return itemCountMap[receiptId] ?? 0;
  }

  int getWarrantyCount(int? receiptId) {
    if (receiptId == null) {
      return 0;
    }

    return warrantyCountMap[receiptId] ?? 0;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _getStoreName(Receipt receipt) {
    final value = (receipt.storeName ?? '').trim();
    if (value.isEmpty) {
      return 'Tanpa Nama Toko';
    }

    return value;
  }

  String _sanitizeFileName(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  String _buildReceiptSummary(Receipt receipt) {
    final storeName = _getStoreName(receipt);
    final itemCount = getItemCount(receipt.id);
    final warrantyCount = getWarrantyCount(receipt.id);

    return '''
Receipt Keeper
====================

Toko        : $storeName
Tanggal     : ${AppFormatHelper.formatDateTime(receipt.purchaseDate)}
Total       : ${AppFormatHelper.formatRupiah(receipt.totalAmount)}
Jumlah Item : $itemCount
Garansi     : $warrantyCount
Catatan     : ${(receipt.note ?? '-').trim().isEmpty ? '-' : receipt.note!.trim()}

Dokumen ini dibagikan dari Receipt Keeper.
''';
  }
}

class HomeReceiptSection {
  final String title;
  final List<Receipt> items;

  const HomeReceiptSection({
    required this.title,
    required this.items,
  });
}
