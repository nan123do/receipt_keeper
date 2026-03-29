// lib/pages/home_receipt/bindings/home_receipt_binding.dart
import 'package:get/get.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';

class HomeReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeReceiptController>(
      () => HomeReceiptController(),
    );
  }
}
