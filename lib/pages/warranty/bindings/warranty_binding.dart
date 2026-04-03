import 'package:get/get.dart';
import 'package:receipt_keeper/pages/warranty/controllers/warranty_controller.dart';

class WarrantyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarrantyController>(
      () => WarrantyController(),
    );
  }
}
