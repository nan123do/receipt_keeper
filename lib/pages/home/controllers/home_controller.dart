import 'package:get/get.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    getInit();
  }

  getInit() {
    isLoading.value = false;
  }
}
