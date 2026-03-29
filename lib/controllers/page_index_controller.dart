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
        Get.toNamed(Routes.HOME);
        break;
      case 1:
        Get.toNamed(Routes.HOME);
        break;
      case 2:
        // jangan stay di index 2 (biar bottom nav balik ke tab sebelumnya)
        pageIndex.value = pageIndexBefore.value;
        Get.toNamed(Routes.HOME);
        break;
      case 3:
        Get.toNamed(Routes.HOME);
        break;
      case 4:
        Get.toNamed(Routes.HOME);
        break;
      default:
        Get.toNamed(Routes.HOME);
        break;
    }
  }

  changeIndexPage(int index) {
    pageIndex.value = index;
  }

  /// Route dasar tempat kita "mendarat" kalau kembali dari flow penjualan
  /// berdasarkan tab terakhir (pageIndexBefore).
  String get baseRouteForPenjualanFlow {
    switch (pageIndexBefore.value) {
      case 0:
        return Routes.HOME;
      case 1:
        return Routes.HOME;
      case 3:
        return Routes.HOME;
      case 4:
        return Routes.HOME;
      default:
        // fallback kalau entah kenapa nilainya di luar range
        return Routes.HOME;
    }
  }
}
