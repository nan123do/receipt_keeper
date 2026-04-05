// lib/services/premium/premium_service.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:receipt_keeper/helpers/feature_gate_helper.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

class PremiumService extends GetxService {
  static PremiumService get to => Get.find<PremiumService>();

  static const String premiumMonthlyProductId =
      'receipt_keeper_premium_monthly';
  static const String premiumYearlyProductId = 'receipt_keeper_premium_yearly';

  static const Set<String> productIds = {
    premiumMonthlyProductId,
    premiumYearlyProductId,
  };

  final AppSettingDaoService _appSettingDaoService = AppSettingDaoService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FeatureGateHelper _featureGateHelper = FeatureGateHelper();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final RxBool isReady = false.obs;
  final RxBool isStoreAvailable = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasePending = false.obs;
  final RxBool isPremiumActive = false.obs;

  final RxString activeProductId = ''.obs;
  final RxString lastErrorMessage = ''.obs;
  final RxString lastStatusMessage = ''.obs;

  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxList<String> notFoundProductIds = <String>[].obs;

  Future<PremiumService> init() async {
    _syncStoredState();
    await _syncStoreAvailability();

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (_) {
        isPurchasePending.value = false;
        lastErrorMessage.value = 'Ada kendala saat menerima update pembelian.';
      },
    );

    ensureOcrUsagePeriod();

    isReady.value = true;
    return this;
  }

  bool get isPremium => isPremiumActive.value;

  String get premiumProductId => activeProductId.value;

  Future<void> _syncStoreAvailability() async {
    try {
      isStoreAvailable.value = await _inAppPurchase.isAvailable();
    } catch (_) {
      isStoreAvailable.value = false;
    }
  }

  Future<bool> refreshStoreAvailability() async {
    await _syncStoreAvailability();
    return isStoreAvailable.value;
  }

  void _syncStoredState() {
    isPremiumActive.value = _appSettingDaoService.getBoolValue(
      AppSettingKeys.isPremium,
      defaultValue: false,
    );

    activeProductId.value = _appSettingDaoService.getValue(
      AppSettingKeys.premiumProductId,
    );
  }

  void ensureOcrUsagePeriod({
    DateTime? now,
  }) {
    final currentPeriod = _featureGateHelper.buildOcrPeriod(now);
    final savedPeriod = _appSettingDaoService.getValue(
      AppSettingKeys.freeOcrUsedPeriod,
    );

    if (savedPeriod == currentPeriod) {
      return;
    }

    _appSettingDaoService.setValue(
      AppSettingKeys.freeOcrUsedPeriod,
      currentPeriod,
      description: 'Periode pemakaian OCR gratis',
    );

    _appSettingDaoService.setValue(
      AppSettingKeys.freeOcrUsedCount,
      '0',
      description: 'Jumlah OCR gratis yang sudah dipakai di periode aktif',
    );
  }

  void consumeOcrQuota({
    DateTime? now,
  }) {
    if (isPremium) {
      return;
    }

    ensureOcrUsagePeriod(now: now);

    final usedCount = _featureGateHelper.getOcrUsedCount(now: now);

    _appSettingDaoService.setValue(
      AppSettingKeys.freeOcrUsedCount,
      '${usedCount + 1}',
      description: 'Jumlah OCR gratis yang sudah dipakai di periode aktif',
    );
  }

  Future<void> loadProducts() async {
    await refreshStoreAvailability();

    if (!isStoreAvailable.value) {
      products.clear();
      notFoundProductIds.clear();
      return;
    }

    try {
      isLoadingProducts.value = true;
      lastErrorMessage.value = '';
      lastStatusMessage.value = '';

      final response = await _inAppPurchase.queryProductDetails(productIds);

      products.assignAll(response.productDetails);
      notFoundProductIds.assignAll(response.notFoundIDs);

      if (response.productDetails.isEmpty) {
        lastErrorMessage.value =
            'Paket premium belum ditemukan. Cek product ID di store.';
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        lastStatusMessage.value = 'Sebagian paket belum ditemukan di store.';
      }
    } catch (_) {
      products.clear();
      notFoundProductIds.clear();
      lastErrorMessage.value = 'Gagal memuat paket premium dari store.';
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> purchaseProduct(ProductDetails product) async {
    await refreshStoreAvailability();

    if (!isStoreAvailable.value) {
      throw Exception('Store pembelian belum tersedia di perangkat ini.');
    }

    try {
      isPurchasePending.value = true;
      lastErrorMessage.value = '';
      lastStatusMessage.value = 'Membuka halaman pembayaran...';

      final purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final isLaunched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!isLaunched) {
        isPurchasePending.value = false;
        throw Exception('Pembelian belum bisa dimulai. Silakan coba lagi.');
      }
    } catch (e) {
      isPurchasePending.value = false;
      rethrow;
    }
  }

  void activatePremium({
    required String productId,
    String? purchaseId,
    DateTime? purchasedAt,
    bool isRestore = false,
  }) {
    final purchasedAtValue = (purchasedAt ?? DateTime.now()).toIso8601String();

    _appSettingDaoService.setBoolValue(
      AppSettingKeys.isPremium,
      true,
      description: 'Status premium aktif',
    );

    _appSettingDaoService.setValue(
      AppSettingKeys.premiumProductId,
      productId,
      description: 'Product id premium aktif',
    );

    if (purchaseId != null && purchaseId.trim().isNotEmpty) {
      _appSettingDaoService.setValue(
        AppSettingKeys.premiumPurchaseId,
        purchaseId,
        description: 'ID transaksi pembelian premium',
      );
    }

    _appSettingDaoService.setValue(
      AppSettingKeys.premiumPurchasedAt,
      purchasedAtValue,
      description: 'Waktu aktivasi premium',
    );

    if (isRestore) {
      _appSettingDaoService.setValue(
        AppSettingKeys.premiumLastRestoreAt,
        DateTime.now().toIso8601String(),
        description: 'Waktu restore premium terakhir',
      );
    }

    _syncStoredState();
    isPurchasePending.value = false;
    lastErrorMessage.value = '';
    lastStatusMessage.value = isRestore
        ? 'Premium berhasil dipulihkan.'
        : 'Premium berhasil diaktifkan.';
  }

  Future<void> restorePurchases() async {
    await refreshStoreAvailability();

    if (!isStoreAvailable.value) {
      throw Exception('Store pembelian belum tersedia di perangkat ini.');
    }

    isPurchasePending.value = true;
    lastErrorMessage.value = '';
    lastStatusMessage.value = 'Restore pembelian sedang diproses...';

    await _inAppPurchase.restorePurchases();

    _appSettingDaoService.setValue(
      AppSettingKeys.premiumLastRestoreAt,
      DateTime.now().toIso8601String(),
      description: 'Waktu restore premium terakhir',
    );
  }

  DateTime? _parsePurchasedAt(PurchaseDetails purchase) {
    final rawValue = purchase.transactionDate?.trim();
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final milliseconds = int.tryParse(rawValue);
    if (milliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }

    return DateTime.tryParse(rawValue);
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        isPurchasePending.value = true;
        lastErrorMessage.value = '';
        lastStatusMessage.value = 'Menunggu konfirmasi pembayaran...';
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        isPurchasePending.value = false;
        lastStatusMessage.value = '';
        lastErrorMessage.value =
            purchase.error?.message ?? 'Pembelian gagal diproses.';
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        activatePremium(
          productId: purchase.productID,
          purchaseId: purchase.purchaseID,
          purchasedAt: _parsePurchasedAt(purchase),
          isRestore: purchase.status == PurchaseStatus.restored,
        );
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }
}
