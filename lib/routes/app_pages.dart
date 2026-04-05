// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:receipt_keeper/pages/home_receipt/bindings/home_receipt_binding.dart';
import 'package:receipt_keeper/pages/home_receipt/views/home_receipt_view.dart';
import 'package:receipt_keeper/pages/manual_receipt/bindings/manual_receipt_binding.dart';
import 'package:receipt_keeper/pages/manual_receipt/views/manual_receipt_view.dart';
import 'package:receipt_keeper/pages/premium/bindings/premium_binding.dart';
import 'package:receipt_keeper/pages/premium/views/premium_view.dart';
import 'package:receipt_keeper/pages/receipt_detail/bindings/receipt_detail_binding.dart';
import 'package:receipt_keeper/pages/receipt_detail/views/receipt_detail_view.dart';
import 'package:receipt_keeper/pages/scan_receipt/bindings/scan_receipt_binding.dart';
import 'package:receipt_keeper/pages/scan_receipt/views/scan_receipt_view.dart';
import 'package:receipt_keeper/pages/settings/bindings/settings_binding.dart';
import 'package:receipt_keeper/pages/settings/views/settings_view.dart';
import 'package:receipt_keeper/pages/splash/bindings/splash_binding.dart';
import 'package:receipt_keeper/pages/splash/views/splash_view.dart';
import 'package:receipt_keeper/pages/warranty/bindings/warranty_binding.dart';
import 'package:receipt_keeper/pages/warranty/views/warranty_view.dart';

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
    GetPage(
      name: _Paths.RECEIPT_DETAIL,
      page: () => const ReceiptDetailView(),
      binding: ReceiptDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.WARRANTY,
      page: () => const WarrantyView(),
      binding: WarrantyBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.PREMIUM,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
