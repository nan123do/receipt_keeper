// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:receipt_keeper/pages/home_receipt/bindings/home_receipt_binding.dart';
import 'package:receipt_keeper/pages/home_receipt/views/home_receipt_view.dart';
import 'package:receipt_keeper/pages/manual_receipt/bindings/manual_receipt_binding.dart';
import 'package:receipt_keeper/pages/manual_receipt/views/manual_receipt_view.dart';
import 'package:receipt_keeper/pages/scan_receipt/bindings/scan_receipt_binding.dart';
import 'package:receipt_keeper/pages/scan_receipt/views/scan_receipt_view.dart';
import 'package:receipt_keeper/pages/splash/bindings/splash_binding.dart';
import 'package:receipt_keeper/pages/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME_RECEIPT,
      page: () => HomeReceiptView(),
      binding: HomeReceiptBinding(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.MANUAL_RECEIPT,
      page: () => const ManualReceiptView(),
      binding: ManualReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SCAN_RECEIPT,
      page: () => const ScanReceiptView(),
      binding: ScanReceiptBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
