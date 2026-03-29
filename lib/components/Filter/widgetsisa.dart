import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class WidgetSisa extends StatelessWidget {
  const WidgetSisa({
    super.key,
    required this.sisa,
  });
  final int sisa;

  @override
  Widget build(BuildContext context) {
    return sisa > 0
        ? Container(
            margin: EdgeInsets.only(
              top: 24.h,
              bottom: 24.h,
              right: 24.w,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            child: Text(
              '+ $sisa Lagi',
              style: AxataTextStyle.textBase.copyWith(
                color: CareraTheme.mainColor,
              ),
            ),
          )
        : Container();
  }
}
