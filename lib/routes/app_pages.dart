// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:receipt_keeper/pages/home/bindings/home_binding.dart';
import 'package:receipt_keeper/pages/home/views/home_view.dart';
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
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
