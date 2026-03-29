import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/utils/theme.dart';

class CustomToast {
  static errorToast(String? title, String? message) {
    Get.rawSnackbar(
      duration: const Duration(seconds: 2),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.infoCircle,
            color: CareraTheme.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    title ?? "error",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                Text(
                  message ?? "message_error".tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: CareraTheme.red,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 8,
      snackPosition: SnackPosition.TOP,
    );
  }

  static successToast(String? title, String? message) {
    Get.rawSnackbar(
      duration: const Duration(seconds: 1),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.checkCircle,
            color: CareraTheme.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    title ?? "success".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                Text(
                  message ?? "message_success".tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: CareraTheme.green,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 8,
      snackPosition: SnackPosition.TOP,
    );
  }

  static successToastWithDur(String? title, String? message, int duration) {
    Get.rawSnackbar(
      duration: Duration(seconds: duration),
      dismissDirection: DismissDirection.horizontal,
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.checkCircle,
            color: CareraTheme.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    title ?? "success".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                Text(
                  message ?? "message_success".tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: CareraTheme.green,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: 8,
      snackPosition: SnackPosition.TOP,
    );
  }
}
