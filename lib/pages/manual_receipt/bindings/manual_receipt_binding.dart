import 'package:get/get.dart';
import 'package:receipt_keeper/pages/manual_receipt/controllers/manual_receipt_controller.dart';

class ManualReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualReceiptController>(
      () => ManualReceiptController(),
    );
  }
}
