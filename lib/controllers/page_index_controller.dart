import 'package:get/get.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/helpers/feature_gate_helper.dart';
import 'package:receipt_keeper/helpers/premium_gate_prompt_helper.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';
import 'package:receipt_keeper/pages/warranty/controllers/warranty_controller.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/receipt_dao_service.dart';

class PageIndexController extends GetxController {
  final ReceiptDaoService _receiptDaoService = ReceiptDaoService();
  final FeatureGateHelper _featureGateHelper = FeatureGateHelper();

  final RxInt pageIndex = 0.obs;
  final RxInt pageIndexBefore = 0.obs;

  Future<void> changePage(int index) async {
    if (index == 2) {
      return;
    }

    final targetRoute = _routeForIndex(index);
    if (targetRoute == null) {
      return;
    }

    if (pageIndex.value != index) {
      pageIndex.value = index;
      pageIndexBefore.value = index;
    }

    if (Get.currentRoute == targetRoute) {
      return;
    }

    await Get.offNamed(
      targetRoute,
    );
  }

  void changeIndexPage(int index) {
    if (pageIndex.value == index) {
      return;
    }

    pageIndex.value = index;
    if (index != 2) {
      pageIndexBefore.value = index;
    }
  }

  Future<void> openScanReceipt({
    String initialSource = 'camera',
  }) async {
    final canCreate = await _ensureCanCreateReceipt();
    if (!canCreate) {
      return;
    }

    final result = await Get.toNamed(
      Routes.SCAN_RECEIPT,
      arguments: {
        'initialSource': initialSource,
      },
    );

    await _handleCreateReceiptResult(result);
  }

  Future<void> openManualReceipt() async {
    final canCreate = await _ensureCanCreateReceipt();
    if (!canCreate) {
      return;
    }

    final result = await Get.toNamed(Routes.MANUAL_RECEIPT);
    await _handleCreateReceiptResult(result);
  }

  String get baseRoute {
    return Routes.HOME_RECEIPT;
  }

  String? _routeForIndex(int index) {
    switch (index) {
      case 0:
        return Routes.HOME_RECEIPT;
      case 1:
        return Routes.WARRANTY;
      case 3:
        return Routes.PREMIUM;
      case 4:
        return Routes.SETTINGS;
      default:
        return null;
    }
  }

  Future<void> _handleCreateReceiptResult(dynamic result) async {
    if (result != true) {
      return;
    }

    if (Get.isRegistered<HomeReceiptController>()) {
      await Get.find<HomeReceiptController>().loadReceipts(showLoading: false);
    }

    if (Get.isRegistered<WarrantyController>()) {
      await Get.find<WarrantyController>().loadWarranties(showLoading: false);
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
}
