// lib/pages/splash/controllers/splash_controller.dart

import 'package:get/get.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/utils/global_data.dart';

class SplashController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    getInit();
  }

  Future<void> getInit() async {
    try {
      isLoading.value = true;

      // Biar splash tetap ada delay dikit (opsional)
      await Future.delayed(const Duration(seconds: 2));

      final useBio = GlobalData.BiometrikSaatBukaAplikasi;

      if (useBio) {
        // Get.offAllNamed(Routes.BIOMETRICGATE);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
      isLoading.value = false;
    } catch (e) {
      CustomToast.errorToast("Error", e.toString());
      isLoading.value = false;
    }
  }
}
