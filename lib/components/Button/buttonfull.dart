import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ButtonFull extends StatelessWidget {
  const ButtonFull({
    super.key,
    this.title,
    this.middleText = 'Terapkan',
    this.readOnly = false,
    this.colorOpposite = false,
    this.ontap,
    this.icon,
    this.bgColor,
  });

  final String? title;
  final String middleText;
  final bool readOnly;
  final bool colorOpposite;
  final void Function()? ontap;
  final IconData? icon;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    buttonWidget() {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: ontap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: readOnly
                      ? CareraTheme.greyLight
                      : colorOpposite
                          ? Colors.white
                          : bgColor ?? CareraTheme.mainColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: colorOpposite
                      ? Border.all(color: CareraTheme.mainColor)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20.r,
                        color: readOnly
                            ? CareraTheme.black
                            : colorOpposite
                                ? bgColor ?? CareraTheme.mainColor
                                : Colors.white,
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Text(
                      middleText,
                      style: AxataTextStyle.textBase.copyWith(
                        color: readOnly
                            ? CareraTheme.black
                            : colorOpposite
                                ? bgColor ?? CareraTheme.mainColor
                                : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (title == null) {
      return buttonWidget();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: AxataTextStyle.textBase),
          buttonWidget(),
        ],
      );
    }
  }
}
