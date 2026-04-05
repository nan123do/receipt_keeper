// lib/pages/settings/bindings/settings_binding.dart
import 'package:get/get.dart';
import 'package:receipt_keeper/pages/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}
