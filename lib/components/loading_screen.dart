import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

class LoadingScreen {
  static void show() {
    if (Get.isDialogOpen ?? false) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen ?? false) return;

      Get.dialog(
        PopScope(
          canPop: true,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CareraTheme.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(strokeWidth: 3),
                    8.gap,
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: CareraTheme.mainColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black54,
        useSafeArea: true,
      );
    });
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
