import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

// dulu:
// typedef OnSaveCallback = Future<void> Function();

// jadi:
typedef OnSaveCallback<T> = Future<T?> Function();

class CustomBottomSheet {
  static Future<T?> showDynamic<T>({
    required String title,
    required Widget body,
    required OnSaveCallback<T> onSave, // <T> di sini
    String primaryText = 'Simpan',
    bool isScrollControlled = true,
  }) {
    return Get.bottomSheet<T>(
      _BottomSheetContent<T>(
        title: title,
        body: body,
        onSave: onSave,
        primaryText: primaryText,
      ),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
  }
}

class _BottomSheetContent<T> extends StatelessWidget {
  final String title;
  final Widget body;
  final OnSaveCallback<T> onSave;
  final String primaryText;

  const _BottomSheetContent({
    required this.title,
    required this.body,
    required this.onSave,
    this.primaryText = 'Simpan',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        padding: CareraTheme.paddingScaffold,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag-handle
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 4.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: CareraTheme.gray20,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              20.h.gap,

              Text(
                title,
                style: AxataTextStyle.text2xl
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const Divider(color: CareraTheme.gray30),
              16.h.gap,

              body, // form kamu di sini

              20.h.gap,
              ButtonFull(
                middleText: primaryText,
                ontap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await Future.delayed(const Duration(milliseconds: 120));

                  final result = await onSave();

                  // guard: kadang widget sudah disposed saat transisi
                  if (!Get.context!.mounted) return;
                  if (result != null) {
                    Get.back(result: result);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
