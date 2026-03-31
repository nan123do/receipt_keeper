import 'package:get/get.dart';
import 'package:receipt_keeper/pages/scan_receipt/controllers/scan_receipt_controller.dart';

class ScanReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanReceiptController>(
      () => ScanReceiptController(),
    );
  }
}
