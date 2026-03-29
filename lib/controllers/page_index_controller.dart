// lib/controllers/page_index_controller.dart
import 'package:get/get.dart';
import 'package:receipt_keeper/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxInt pageIndexBefore = 0.obs;

  void changePage(int index) {
    if (pageIndex.value == index) {
      return;
    }

    pageIndex.value = index;
    if (index != 2) {
      pageIndexBefore.value = index;
    }

    switch (index) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      default:
        Get.toNamed(Routes.HOME_RECEIPT);
        break;
    }
  }

  void changeIndexPage(int index) {
    pageIndex.value = index;
  }

  String get baseRoute {
    return Routes.HOME_RECEIPT;
  }
}
