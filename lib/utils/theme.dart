// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CareraTheme {
  //Screen Util Init
  static double screenHeight = 812;
  static double screenWidth = 375;
  static var currency = NumberFormat("#,##0", "en_US");

  // Color
  static Color bgScaffold = Color(0xffF5F5F5);
  static Color mainColor = turquoise100;
  static Color mainColorS = Color(0xff11c1fd);
  static Color bgMainColor = Color(0xff0b70a8);
  static Color white = Colors.white;
  static Color black = gray100;
  static Color grey = gray60;
  static Color greyLight = Color(0xffDBE3EB);
  static Color pink = Color(0xffFF5F5F);
  static Color yellow = Color(0xffFFE500);

  // Turquoise
  static const turquoise100 = Color(0xFF40D8D3);
  static const turquoise90 = Color(0xFF59DDD7);
  static const turquoise80 = Color(0xFF72E2DC);
  static const turquoise70 = Color(0xFF8BE7E0);
  static const turquoise60 = Color(0xFFA4ECE5);
  static const turquoise50 = Color(0xFFBDF1E9);
  static const turquoise40 = Color(0xFFD6F6EE);
  static const turquoise30 = Color(0xFFEBFBFA);
  static const turquoise20 = Color(0xFFF7FDF9);
  static const turquoise10 = Color(0xFFFBFEFC);

  // Gray
  static const gray100 = Color(0xFF111928);
  static const gray90 = Color(0xFF2B3240);
  static const gray80 = Color(0xFF454B58);
  static const gray70 = Color(0xFF5F6470);
  static const gray60 = Color(0xFF797D88);
  static const gray50 = Color(0xFF9396A0);
  static const gray40 = Color(0xFFADAFB8);
  static const gray30 = Color(0xFFC7C8D0);
  static const gray20 = Color(0xFFEEEEEE);
  static const gray10 = Color(0xFFE7E8E9);
  static const gray5 = Color(0xFFF3F3F4);

  // Aksen
  static const red = Color(0xFFDF667F);
  static const green = Color(0xFF30D158);
  static const blue = Color(0xFF0DB2FA);
  static const orange = Color(0xFFFF9500);
  static const orange100 = Color(0xFFFF9500);
  static const orange50 = Color(0xFFFFB07C);
  static const orange30 = Color(0xFFFFE0CC);
  static const orange20 = Color(0xFFFFF0D9);

  // Box Decoration
  static ShapeDecoration styleGradient = ShapeDecoration(
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF0276FF), Color(0xFF11A9FD), Color(0xFF11A9FD)],
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    shadows: const [
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 2,
        offset: Offset(0, 0),
        spreadRadius: 0,
      )
    ],
  );

  static BoxDecoration styleUnselectBoxFilter = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.all(
      Radius.circular(8.r),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x3F000000),
        blurRadius: 2,
        offset: Offset(0, 0),
        spreadRadius: 0,
      )
    ],
  );

  static BoxDecoration decBorderBlue = BoxDecoration(
    color: CareraTheme.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: mainColor,
    ),
  );

  static BoxDecoration decBorderBlueBold = decBorderBlue.copyWith(
    border: Border.all(
      color: mainColor,
      width: 4.r,
    ),
  );

  static BoxDecoration styleBoxFilter = BoxDecoration(
    color: mainColor.withValues(alpha: 0.1),
    border: Border.all(color: mainColor),
    borderRadius: BorderRadius.all(
      Radius.circular(8.r),
    ),
  );

  static EdgeInsets paddingScaffold = EdgeInsets.symmetric(
    vertical: 15.h,
    horizontal: 15.w,
  );
}

class AxataTextStyle {
  // ─── Text Sizes (responsive) ──────────────────────────────────
  static TextStyle textXs = TextStyle(fontSize: 10.sp);
  static TextStyle textSm = TextStyle(fontSize: 12.sp);
  static TextStyle textBase = TextStyle(fontSize: 14.sp);
  static TextStyle textLg = TextStyle(fontSize: 16.sp);
  static TextStyle textXl = TextStyle(fontSize: 18.sp);
  static TextStyle text2xl = TextStyle(fontSize: 20.sp);
  static TextStyle text3xl = TextStyle(fontSize: 24.sp);
  static TextStyle text4xl = TextStyle(fontSize: 30.sp);
  static TextStyle text5xl = TextStyle(fontSize: 36.sp);
  static TextStyle text6xl = TextStyle(fontSize: 48.sp);
  static TextStyle text7xl = TextStyle(fontSize: 60.sp);

  // ─── Bold Variants ────────────────────────────────────────────
  static TextStyle textXsBold =
      TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold);
  static TextStyle textSmBold =
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold);
  static TextStyle textBaseBold =
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold);
  static TextStyle textLgBold =
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold);
  static TextStyle textXlBold =
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold);
  static TextStyle text2xlBold =
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold);
  static TextStyle text3xlBold =
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold);
  static TextStyle text4xlBold =
      TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold);
  static TextStyle text5xlBold =
      TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold);
  static TextStyle text6xlBold =
      TextStyle(fontSize: 48.sp, fontWeight: FontWeight.bold);
  static TextStyle text7xlBold =
      TextStyle(fontSize: 60.sp, fontWeight: FontWeight.bold);
}
