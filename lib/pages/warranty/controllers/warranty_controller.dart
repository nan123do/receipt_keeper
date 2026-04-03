// lib/pages/warranty/controllers/warranty_controller.dart
import 'package:get/get.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';

class WarrantyController extends GetxController {
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  final RxBool isLoading = false.obs;
  final RxList<Warranty> warrantyList = <Warranty>[].obs;
  final Rx<WarrantyFilterType> selectedFilter = WarrantyFilterType.all.obs;

  bool get hasData => warrantyList.isNotEmpty;
  bool get hasFilteredData => filteredWarrantyList.isNotEmpty;

  int get totalCount => warrantyList.length;

  int get activeCount => warrantyList.where((item) => item.isActive).length;

  int get expiringSoonCount =>
      warrantyList.where((item) => item.isExpiringSoon).length;

  int get expiredCount => warrantyList.where((item) => item.isExpired).length;

  List<WarrantyFilterType> get filterOptions => WarrantyFilterType.values;

  List<Warranty> get filteredWarrantyList {
    final filtered = _applyFilter(
      source: warrantyList,
      filter: selectedFilter.value,
    );

    return _sortWarranties(filtered);
  }

  List<WarrantySection> get groupedSections {
    if (filteredWarrantyList.isEmpty) {
      return [];
    }

    if (selectedFilter.value != WarrantyFilterType.all) {
      return [
        WarrantySection(
          title: getSectionTitle(selectedFilter.value),
          type: selectedFilter.value,
          items: filteredWarrantyList,
        ),
      ];
    }

    final expiringSoonItems = _sortWarranties(
      _applyFilter(
        source: warrantyList,
        filter: WarrantyFilterType.expiringSoon,
      ),
    );

    final activeItems = _sortWarranties(
      _applyFilter(
        source: warrantyList,
        filter: WarrantyFilterType.active,
      ),
    );

    final expiredItems = _sortWarranties(
      _applyFilter(
        source: warrantyList,
        filter: WarrantyFilterType.expired,
      ),
    );

    final result = <WarrantySection>[];

    if (expiringSoonItems.isNotEmpty) {
      result.add(
        WarrantySection(
          title: 'Habis dalam 7 hari',
          type: WarrantyFilterType.expiringSoon,
          items: expiringSoonItems,
        ),
      );
    }

    if (activeItems.isNotEmpty) {
      result.add(
        WarrantySection(
          title: 'Masih aktif',
          type: WarrantyFilterType.active,
          items: activeItems,
        ),
      );
    }

    if (expiredItems.isNotEmpty) {
      result.add(
        WarrantySection(
          title: 'Sudah habis',
          type: WarrantyFilterType.expired,
          items: expiredItems,
        ),
      );
    }

    return result;
  }

  String get currentFilterLabel {
    return getFilterLabel(selectedFilter.value);
  }

  String get resultLabel {
    final total = filteredWarrantyList.length;

    if (selectedFilter.value == WarrantyFilterType.all) {
      return '$total garansi tersimpan';
    }

    return '$total garansi ditemukan';
  }

  String get emptyTitle {
    switch (selectedFilter.value) {
      case WarrantyFilterType.all:
        return 'Belum ada garansi';
      case WarrantyFilterType.active:
        return 'Belum ada garansi aktif';
      case WarrantyFilterType.expiringSoon:
        return 'Belum ada garansi mendesak';
      case WarrantyFilterType.expired:
        return 'Belum ada garansi habis';
    }
  }

  String get emptyMessage {
    switch (selectedFilter.value) {
      case WarrantyFilterType.all:
        return 'Produk bergaransi akan tampil di halaman ini setelah Anda menambahkannya dari detail struk.';
      case WarrantyFilterType.active:
        return 'Garansi yang masih aktif akan tampil di filter ini.';
      case WarrantyFilterType.expiringSoon:
        return 'Garansi yang hampir habis akan tampil di filter ini.';
      case WarrantyFilterType.expired:
        return 'Garansi yang sudah habis akan tampil di filter ini.';
    }
  }

  @override
  void onInit() {
    super.onInit();
    getInit();
  }

  Future<void> getInit() async {
    await loadWarranties();
  }

  Future<void> loadWarranties({
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }

      final result = _warrantyDaoService.getAll();
      warrantyList.assignAll(result);
    } catch (e) {
      CustomToast.errorToast(
        'Gagal memuat garansi',
        'Daftar garansi belum bisa ditampilkan.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(WarrantyFilterType value) {
    if (selectedFilter.value == value) {
      return;
    }

    selectedFilter.value = value;
  }

  Future<void> openReceiptDetail(Warranty warranty) async {
    final result = await Get.toNamed(
      Routes.RECEIPT_DETAIL,
      arguments: {
        'receiptId': warranty.receiptId,
      },
    );

    if (result == true) {
      await loadWarranties(showLoading: false);
    }
  }

  String getStoreCaption(Warranty warranty) {
    return 'Struk #${warranty.receiptId}';
  }

  String getFilterLabel(WarrantyFilterType value) {
    switch (value) {
      case WarrantyFilterType.all:
        return 'Semua';
      case WarrantyFilterType.active:
        return 'Aktif';
      case WarrantyFilterType.expiringSoon:
        return 'Hampir habis';
      case WarrantyFilterType.expired:
        return 'Habis';
    }
  }

  String getSectionTitle(WarrantyFilterType value) {
    switch (value) {
      case WarrantyFilterType.all:
        return 'Semua garansi';
      case WarrantyFilterType.active:
        return 'Garansi aktif';
      case WarrantyFilterType.expiringSoon:
        return 'Garansi hampir habis';
      case WarrantyFilterType.expired:
        return 'Garansi sudah habis';
    }
  }

  List<Warranty> _applyFilter({
    required List<Warranty> source,
    required WarrantyFilterType filter,
  }) {
    switch (filter) {
      case WarrantyFilterType.all:
        return List<Warranty>.from(source);
      case WarrantyFilterType.active:
        return source.where((item) => item.isActive).toList();
      case WarrantyFilterType.expiringSoon:
        return source.where((item) => item.isExpiringSoon).toList();
      case WarrantyFilterType.expired:
        return source.where((item) => item.isExpired).toList();
    }
  }

  List<Warranty> _sortWarranties(List<Warranty> source) {
    final items = List<Warranty>.from(source);

    items.sort((a, b) {
      final priorityCompare = _statusPriority(a).compareTo(_statusPriority(b));
      if (priorityCompare != 0) {
        return priorityCompare;
      }

      if (a.isExpired && b.isExpired) {
        final expiredCompare = b.expiryDate.compareTo(a.expiryDate);
        if (expiredCompare != 0) {
          return expiredCompare;
        }
      } else {
        final activeCompare = a.expiryDate.compareTo(b.expiryDate);
        if (activeCompare != 0) {
          return activeCompare;
        }
      }

      final purchaseCompare = b.purchaseDate.compareTo(a.purchaseDate);
      if (purchaseCompare != 0) {
        return purchaseCompare;
      }

      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    return items;
  }

  int _statusPriority(Warranty warranty) {
    if (warranty.isExpiringSoon) {
      return 0;
    }

    if (warranty.isActive) {
      return 1;
    }

    return 2;
  }
}

enum WarrantyFilterType {
  all,
  active,
  expiringSoon,
  expired,
}

class WarrantySection {
  final String title;
  final WarrantyFilterType type;
  final List<Warranty> items;

  const WarrantySection({
    required this.title,
    required this.type,
    required this.items,
  });
}
