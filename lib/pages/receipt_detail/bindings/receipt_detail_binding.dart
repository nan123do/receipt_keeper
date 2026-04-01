import 'package:get/get.dart';
import 'package:receipt_keeper/pages/receipt_detail/controllers/receipt_detail_controller.dart';

class ReceiptDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiptDetailController>(
      () => ReceiptDetailController(),
    );
  }
}
