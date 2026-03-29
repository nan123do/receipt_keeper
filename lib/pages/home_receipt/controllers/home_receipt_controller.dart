// lib/pages/home_receipt/controllers/home_receipt_controller.dart
import 'package:get/get.dart';

class HomeReceiptController extends GetxController {
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getInit();
  }

  Future<void> getInit() async {
    try {
      isLoading.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
