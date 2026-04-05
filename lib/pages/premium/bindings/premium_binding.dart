import 'package:get/get.dart';
import 'package:receipt_keeper/pages/premium/controllers/premium_controller.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumController>(
      () => PremiumController(),
    );
  }
}
