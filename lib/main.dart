import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:receipt_keeper/controllers/page_index_controller.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi GetStorage
  await GetStorage.init();
  await Future.delayed(const Duration(seconds: 1));

  Get.put(PageIndexController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(CareraTheme.screenWidth, CareraTheme.screenHeight),
      minTextAdapt: true,
    );

    return GetMaterialApp(
      title: "Receipt Keeper",
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      theme: ThemeData(
        // 1. Tentukan primarySwatch atau primaryColor
        primarySwatch: Colors.teal,
        primaryColor: CareraTheme.mainColor,

        // 2. Atur ColorScheme supaya seluruh widget M3/M2 pakai warna ini
        colorScheme: ColorScheme.light(
          primary: CareraTheme.mainColor,
          secondary: CareraTheme.mainColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CareraTheme.mainColor,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
    );
  }
}
