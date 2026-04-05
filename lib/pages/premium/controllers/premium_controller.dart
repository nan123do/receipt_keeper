// lib/pages/premium/controllers/premium_controller.dart
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/feature_gate_helper.dart';
import 'package:receipt_keeper/services/premium/premium_service.dart';

class PremiumController extends GetxController {
  final PremiumService _premiumService = PremiumService.to;
  final FeatureGateHelper _featureGateHelper = FeatureGateHelper();

  final RxBool isLoading = false.obs;
  final RxBool isRestoring = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isPremiumActive = false.obs;
  final RxBool isStoreAvailable = false.obs;

  final RxString activeProductId = ''.obs;
  final RxString selectedProductId = ''.obs;
  final RxString storeMessage = ''.obs;

  final RxList<ProductDetails> availableProducts = <ProductDetails>[].obs;
  final RxList<String> notFoundProductIds = <String>[].obs;

  final List<Worker> _workers = [];

  int get freeReceiptLimit => _featureGateHelper.freeReceiptLimit;
  int get freeOcrLimit => _featureGateHelper.freeOcrLimit;

  bool get hasProducts => availableProducts.isNotEmpty;

  ProductDetails? get selectedProduct {
    final id = selectedProductId.value.trim();

    for (final product in availableProducts) {
      if (product.id == id) {
        return product;
      }
    }

    if (availableProducts.isEmpty) {
      return null;
    }

    return availableProducts.first;
  }

  String get statusTitle {
    if (isPremiumActive.value) {
      return 'Premium aktif';
    }

    return 'Masih di paket gratis';
  }

  String get statusDescription {
    if (isPremiumActive.value) {
      if (activeProductId.value.trim().isNotEmpty) {
        return 'Akun Anda sudah premium dengan produk ${activeProductId.value}.';
      }

      return 'Semua fitur premium sudah siap digunakan.';
    }

    if (!isStoreAvailable.value) {
      return 'Store pembelian belum tersedia di perangkat ini. Anda masih bisa memakai paket gratis.';
    }

    if (selectedProduct != null) {
      return 'Paket gratis bisa menyimpan hingga $freeReceiptLimit struk dan memakai OCR otomatis hingga $freeOcrLimit kali per bulan.';
    }

    return 'Paket gratis bisa menyimpan hingga $freeReceiptLimit struk dan memakai OCR otomatis hingga $freeOcrLimit kali per bulan.';
  }

  String get restoreInfoText {
    if (!isStoreAvailable.value) {
      return 'Restore belum bisa dijalankan karena store pembelian belum siap.';
    }

    return 'Jika Anda ganti HP atau install ulang aplikasi, masuk ke akun store yang sama lalu gunakan Restore Pembelian.';
  }

  String get emptyProductMessage {
    if (!isStoreAvailable.value) {
      return 'Store pembelian belum tersedia di perangkat ini.';
    }

    if (isLoadingProducts.value) {
      return 'Sedang memuat paket premium dari store...';
    }

    return 'Paket premium belum muncul. Cek product ID atau status produk di store.';
  }

  String get upgradeButtonText {
    if (isPremiumActive.value) {
      return 'Premium Sudah Aktif';
    }

    if (isPurchasing.value) {
      return 'Memproses Pembelian...';
    }

    if (!isStoreAvailable.value) {
      return 'Store Belum Tersedia';
    }

    if (isLoadingProducts.value) {
      return 'Memuat Paket...';
    }

    final product = selectedProduct;
    if (product == null) {
      return 'Paket Belum Siap';
    }

    return 'Beli ${product.price}';
  }

  @override
  void onInit() {
    super.onInit();
    _bindServiceState();
    getInit();
  }

  void _bindServiceState() {
    _workers.addAll([
      ever(_premiumService.isStoreAvailable, (_) => loadState()),
      ever(_premiumService.isLoadingProducts, (_) => loadState()),
      ever(_premiumService.isPurchasePending, (_) => loadState()),
      ever(_premiumService.isPremiumActive, (_) => loadState()),
      ever(_premiumService.activeProductId, (_) => loadState()),
      ever(_premiumService.products, (_) => loadState()),
      ever(_premiumService.notFoundProductIds, (_) => loadState()),
      ever(_premiumService.lastErrorMessage, (_) => loadState()),
      ever(_premiumService.lastStatusMessage, (_) => loadState()),
    ]);
  }

  Future<void> getInit() async {
    try {
      isLoading.value = true;
      await _premiumService.refreshStoreAvailability();
      await _premiumService.loadProducts();
      loadState();
    } catch (_) {
      loadState();
    } finally {
      isLoading.value = false;
    }
  }

  void _syncSelectedProduct() {
    if (availableProducts.isEmpty) {
      selectedProductId.value = '';
      return;
    }

    final currentSelectedId = selectedProductId.value.trim();
    final hasSelected = availableProducts.any(
      (product) => product.id == currentSelectedId,
    );

    if (hasSelected) {
      return;
    }

    final currentActiveId = activeProductId.value.trim();
    for (final product in availableProducts) {
      if (product.id == currentActiveId) {
        selectedProductId.value = product.id;
        return;
      }
    }

    selectedProductId.value = availableProducts.first.id;
  }

  void loadState() {
    isPremiumActive.value = _premiumService.isPremiumActive.value;
    isStoreAvailable.value = _premiumService.isStoreAvailable.value;
    isLoadingProducts.value = _premiumService.isLoadingProducts.value;
    isPurchasing.value = _premiumService.isPurchasePending.value;
    activeProductId.value = _premiumService.activeProductId.value;

    availableProducts.assignAll(_premiumService.products);
    notFoundProductIds.assignAll(_premiumService.notFoundProductIds);

    final errorText = _premiumService.lastErrorMessage.value.trim();
    final statusText = _premiumService.lastStatusMessage.value.trim();

    storeMessage.value = errorText.isNotEmpty ? errorText : statusText;

    _syncSelectedProduct();
  }

  void selectProduct(String productId) {
    selectedProductId.value = productId;
  }

  Future<void> refreshProducts() async {
    try {
      await _premiumService.loadProducts();
      loadState();
    } catch (_) {
      loadState();
    }
  }

  Future<void> purchaseSelectedProduct() async {
    final product = selectedProduct;
    if (product == null) {
      CustomToast.errorToast(
        'Paket belum siap',
        'Produk premium belum tersedia untuk dibeli.',
      );
      return;
    }

    if (isPurchasing.value) {
      return;
    }

    try {
      await _premiumService.purchaseProduct(product);

      CustomToast.successToast(
        'Pembelian dibuka',
        'Lanjutkan proses pembayaran di store untuk mengaktifkan premium.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Pembelian gagal',
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> restorePremium() async {
    if (isRestoring.value) {
      return;
    }

    try {
      isRestoring.value = true;
      await _premiumService.restorePurchases();
      loadState();

      CustomToast.successToast(
        'Restore diproses',
        'Tunggu sebentar sampai store mengirim ulang data pembelian.',
      );
    } catch (e) {
      CustomToast.errorToast(
        'Restore gagal',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isRestoring.value = false;
    }
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}
