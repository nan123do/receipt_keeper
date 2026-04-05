// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:receipt_keeper/controllers/page_index_controller.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/services/db/app_db_service.dart';
import 'package:receipt_keeper/services/notification/notification_service.dart';
import 'package:receipt_keeper/services/premium/premium_service.dart';
import 'package:receipt_keeper/services/seeds/demo_receipt_seed_service.dart';
import 'package:receipt_keeper/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await GetStorage.init();
  await Future.delayed(const Duration(seconds: 1));

  await Get.putAsync<AppDbService>(
    () => AppDbService().init(),
    permanent: true,
  );

  final appSettingDaoService = AppSettingDaoService();
  appSettingDaoService.ensureDefaultSettings();

  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
    permanent: true,
  );

  await Get.putAsync<PremiumService>(
    () => PremiumService().init(),
    permanent: true,
  );

  try {
    DemoReceiptSeedService().ensureSeeded();
  } catch (_) {}

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
        primarySwatch: Colors.teal,
        primaryColor: CareraTheme.mainColor,
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
