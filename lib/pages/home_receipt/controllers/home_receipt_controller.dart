// lib/pages/home_receipt/controllers/home_receipt_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Filter/date_filter.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/delete_confirm_helper.dart';
import 'package:receipt_keeper/helpers/feature_gate_helper.dart';
import 'package:receipt_keeper/helpers/premium_gate_prompt_helper.dart';
import 'package:receipt_keeper/helpers/report_export_helper.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';
import 'package:receipt_keeper/services/daos/receipt_item_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/services/export/receipt_pdf_service.dart';
import 'package:receipt_keeper/services/notification/notification_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

class HomeReceiptController extends GetxController {
  final AppSettingDaoService _appSettingDaoService = AppSettingDaoService();
  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final ReceiptItemDaoService _receiptItemDaoService = ReceiptItemDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();
  final ReceiptPdfService _receiptPdfService = ReceiptPdfService();
  final FeatureGateHelper _featureGateHelper = FeatureGateHelper();

  final TextEditingController searchC = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool latestFirst = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<DateFilterValue> selectedDateFilter = DateFilterValue.all().obs;
  final RxList<Receipt> receiptList = <Receipt>[].obs;
  final RxMap<int, int> itemCountMap = <int, int>{}.obs;
  final RxMap<int, int> warrantyCountMap = <int, int>{}.obs;
  final RxnInt exampleReceiptId = RxnInt();
  final RxBool isExampleInfoDismissed = false.obs;

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

  bool get showExampleInfoCard {
    if (isExampleInfoDismissed.value) {
      return false;
    }

    final exampleId = exampleReceiptId.value;
    if (exampleId == null) {
      return false;
    }

    return receiptList.any((e) => e.id == exampleId);
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
          title: 'Hari Ini',
          items: todayReceipts,
        ),
      );
    }

    if (weekReceipts.isNotEmpty) {
      sections.add(
        HomeReceiptSection(
          title: 'Minggu Ini',
          items: weekReceipts,
        ),
      );
    }

    if (olderReceipts.isNotEmpty) {
      sections.add(
        HomeReceiptSection(
          title: 'Lainnya',
          items: olderReceipts,
        ),
      );
    }

    return sections;
  }

  @override
  void onInit() {
    super.onInit();

    _loadExampleReceiptId();
    _loadExampleInfoState();

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
    await _runWarrantyReminderCheck();
    await loadReceipts();
  }

  Future<void> _runWarrantyReminderCheck() async {
    if (!Get.isRegistered<NotificationService>()) {
      return;
    }

    try {
      await NotificationService.to.runDailyWarrantyCheck();
    } catch (_) {}
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

      receiptList.assignAll(_filterReceiptsByDate(result));
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

  void _loadExampleReceiptId() {
    final rawId = _appSettingDaoService.getIntValue(
      AppSettingKeys.exampleReceiptId,
      defaultValue: 0,
    );

    exampleReceiptId.value = rawId > 0 ? rawId : null;
  }

  void _loadExampleInfoState() {
    isExampleInfoDismissed.value = _appSettingDaoService.getBoolValue(
      AppSettingKeys.exampleDataInfoDismissed,
      defaultValue: false,
    );
  }

  void dismissExampleInfoCard() {
    isExampleInfoDismissed.value = true;
    _appSettingDaoService.setValue(
      AppSettingKeys.exampleDataInfoDismissed,
      '1',
      description: 'Petunjuk data contoh di home sudah ditutup',
    );
  }

  bool isExampleReceipt(Receipt receipt) {
    final receiptId = receipt.id;
    if (receiptId == null) {
      return false;
    }

    return receiptId == exampleReceiptId.value;
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

  Future<void> applyDateFilter(DateFilterValue value) async {
    selectedDateFilter.value = value;
    await loadReceipts(showLoading: false);
  }

  Future<void> changeSortOrder(bool value) async {
    if (latestFirst.value == value) {
      return;
    }

    latestFirst.value = value;
    await loadReceipts(showLoading: false);
  }

  Future<void> openManualReceipt() async {
    final canCreate = await _ensureCanCreateReceipt();
    if (!canCreate) {
      return;
    }

    try {
      final result = await Get.toNamed(Routes.MANUAL_RECEIPT);

      if (result == true) {
        await loadReceipts(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Form struk manual belum bisa dibuka.',
      );
    }
  }

  Future<void> openEditReceipt(Receipt receipt) async {
    final receiptId = receipt.id;
    if (receiptId == null) {
      CustomToast.errorToast(
        'Data belum lengkap',
        'Struk belum bisa diedit.',
      );
      return;
    }

    try {
      final result = await Get.toNamed(
        Routes.MANUAL_RECEIPT,
        arguments: {
          'isEditMode': true,
          'receiptId': receiptId,
        },
      );

      if (result == true) {
        await loadReceipts(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Form edit struk belum bisa dibuka.',
      );
    }
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

    final result = await Get.toNamed(
      Routes.RECEIPT_DETAIL,
      arguments: receiptId,
    );

    if (result == true) {
      await loadReceipts(showLoading: false);
    }
  }

  Future<void> openScanReceipt() async {
    final canCreate = await _ensureCanCreateReceipt();
    if (!canCreate) {
      return;
    }

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

  Future<void> openWarrantyPage() async {
    try {
      final result = await Get.toNamed(Routes.WARRANTY);

      if (result == true) {
        await loadReceipts(showLoading: false);
      }
    } catch (e) {
      CustomToast.errorToast(
        'Halaman belum tersedia',
        'Daftar garansi belum bisa dibuka.',
      );
    }
  }

  Future<void> openPremiumPage() async {
    await Get.toNamed(Routes.PREMIUM);
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
    final receiptId = receipt.id;
    if (receiptId == null || receiptId <= 0) {
      CustomToast.errorToast(
        'Data tidak valid',
        'Struk belum bisa diexport.',
      );
      return;
    }

    if (!_featureGateHelper.canExportWithoutLimit()) {
      final shouldContinue =
          await PremiumGatePromptHelper.confirmFreeExportContinuation();

      if (!shouldContinue) {
        return;
      }
    }

    try {
      final items = _receiptItemDaoService.getByReceiptId(receiptId);
      final warranties = _warrantyDaoService.getByReceiptId(receiptId);
      final subject = ReportExportHelper.buildReceiptSubject(receipt);

      final pdfFile = await _receiptPdfService.generateReceiptPdfFile(
        receipt: receipt,
        items: items,
        warranties: warranties,
      );

      try {
        await ReportExportHelper.shareFile(
          pdfFile,
          subject: subject,
        );
      } catch (e) {
        CustomToast.errorToast(
          'Gagal membagikan PDF',
          'PDF struk sudah dibuat, tetapi belum bisa dibagikan.',
        );
      }
    } catch (e) {
      CustomToast.errorToast(
        'Gagal membuat PDF',
        'PDF struk belum bisa dibuat.',
      );
    }
  }

  Future<bool> _ensureCanCreateReceipt() async {
    final currentReceiptCount = _receiptDaoService.countAll();

    if (!_featureGateHelper.canAddReceipt(
      currentReceiptCount: currentReceiptCount,
    )) {
      await PremiumGatePromptHelper.showReceiptLimitReached(
        freeLimit: _featureGateHelper.freeReceiptLimit,
      );
      return false;
    }

    if (_featureGateHelper.shouldShowReceiptLimitWarning(
      currentReceiptCount: currentReceiptCount,
    )) {
      final remaining = _featureGateHelper.remainingFreeReceipt(
        currentReceiptCount: currentReceiptCount,
      );

      CustomToast.successToastWithDur(
        'Sisa slot struk gratis tinggal $remaining',
        'Paket gratis bisa menyimpan hingga ${_featureGateHelper.freeReceiptLimit} struk.',
        2,
      );
    }

    return true;
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

  List<Receipt> _filterReceiptsByDate(List<Receipt> source) {
    final filter = selectedDateFilter.value;

    if (filter.preset == DateFilterPreset.all) {
      return source;
    }

    return source.where((receipt) {
      final purchaseDate = receipt.purchaseDate;
      return !purchaseDate.isBefore(filter.start) &&
          !purchaseDate.isAfter(filter.end);
    }).toList();
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
}

class HomeReceiptSection {
  final String title;
  final List<Receipt> items;

  const HomeReceiptSection({
    required this.title,
    required this.items,
  });
}
