import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class DataDisplay {
  static Widget dataDisplay<T>(
    List<T> data, {
    Function(int index)? onTap,
    required Widget Function(BuildContext context, T item) builder,
    Widget Function(T item)? action,
    EdgeInsetsGeometry? padding,
    Color? Function(T item)? backgroundColor,
    Color? borderColor,
    BoxBorder? border,
  }) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return SizedBox(height: 10.h);
      },
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        T item = data[index];
        return GestureDetector(
          onTap: onTap != null ? () => onTap(index) : null,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor != null
                  ? backgroundColor(item) ?? Colors.white
                  : Colors.white,
              border: border ??
                  Border.all(
                    color: borderColor ?? CareraTheme.gray30,
                    width: 0.8,
                  ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Widget custom isi utama (flexible)
                Expanded(
                  child: builder(context, item),
                ),
                if (action != null) ...[
                  action(item),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
