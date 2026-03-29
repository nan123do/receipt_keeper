import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class WidgetFilter extends StatelessWidget {
  const WidgetFilter({
    super.key,
    required this.namafilter,
    required this.selected,
  });
  final String namafilter;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.h,
        bottom: 8.h,
        right: 8.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 13.w,
        vertical: 8.h,
      ),
      decoration: selected == namafilter
          ? CareraTheme.styleBoxFilter
          : CareraTheme.styleUnselectBoxFilter,
      child: Text(
        namafilter,
        style: AxataTextStyle.textSm.copyWith(
          color: selected == namafilter
              ? CareraTheme.mainColor
              : CareraTheme.black,
        ),
      ),
    );
  }
}
