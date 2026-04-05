// lib/components/appbar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    required this.theme,
    this.widgetIcon,
    this.widgetTitle,
    this.onBack,
    this.actions,
    this.showBackButton = true,
  });

  final String title;
  final String theme;
  final Widget? widgetIcon;
  final Widget? widgetTitle;
  final Function()? onBack;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    AppBar widgetAppBar() {
      switch (theme) {
        case 'normal':
          return _baseAppBar(
            onBack: onBack,
            showBackButton: showBackButton,
          );

        case 'normalIcon':
          return _baseAppBar(
            onBack: onBack,
            showBackButton: showBackButton,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: widgetIcon ?? const SizedBox(),
              ),
            ],
          );

        case 'withsearch':
          return AppBar(
            backgroundColor: CareraTheme.white,
            automaticallyImplyLeading: false,
            title: widgetTitle,
            actions: [widgetIcon ?? const SizedBox()],
          );

        case 'primary':
          return AppBar(
            backgroundColor: CareraTheme.mainColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: showBackButton
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onBack ?? () => Get.back(),
                  )
                : null,
            titleSpacing: showBackButton ? 0 : 16,
            title: Text(
              title,
              style: AxataTextStyle.text2xl.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: actions,
          );

        default:
          return _baseAppBar(
            onBack: onBack,
            showBackButton: showBackButton,
            actions: actions,
          );
      }
    }

    return widgetAppBar();
  }

  AppBar _baseAppBar({
    Function()? onBack,
    List<Widget>? actions,
    required bool showBackButton,
  }) {
    return AppBar(
      backgroundColor: CareraTheme.white,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: CareraTheme.black,
                size: 20,
              ),
              onPressed: onBack ?? () => Get.back(),
            )
          : null,
      titleSpacing: showBackButton ? 0 : 16,
      title: Text(
        title,
        style: AxataTextStyle.text2xl.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: CareraTheme.mainColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
