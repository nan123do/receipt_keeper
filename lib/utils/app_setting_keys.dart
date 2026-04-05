// lib/utils/app_setting_keys.dart
class AppSettingKeys {
  AppSettingKeys._();

  static const String biometricOnAppOpen = 'BIOMETRIC_ON_APP_OPEN';
  static const String defaultWarrantyMonths = 'DEFAULT_WARRANTY_MONTHS';
  static const String notificationEnabled = 'NOTIFICATION_ENABLED';
  static const String warrantyReminderDays = 'WARRANTY_REMINDER_DAYS';

  static const String scanAutoProcessOcr = 'SCAN_AUTO_PROCESS_OCR';
  static const String scanPreferredSource = 'SCAN_PREFERRED_SOURCE';

  static const String exampleDataSeeded = 'EXAMPLE_DATA_SEEDED';
  static const String exampleReceiptId = 'EXAMPLE_RECEIPT_ID';
  static const String exampleDataInfoDismissed = 'EXAMPLE_DATA_INFO_DISMISSED';

  static const String isPremium = 'IS_PREMIUM';
  static const String premiumProductId = 'PREMIUM_PRODUCT_ID';
  static const String premiumPurchaseId = 'PREMIUM_PURCHASE_ID';
  static const String premiumPurchasedAt = 'PREMIUM_PURCHASED_AT';
  static const String premiumLastRestoreAt = 'PREMIUM_LAST_RESTORE_AT';

  static const String backupLocalLastAt = 'BACKUP_LOCAL_LAST_AT';
  static const String backupLocalLastFileName = 'BACKUP_LOCAL_LAST_FILE_NAME';

  static const String freeReceiptLimit = 'FREE_RECEIPT_LIMIT';
  static const String freeOcrLimit = 'FREE_OCR_LIMIT';
  static const String freeOcrUsedCount = 'FREE_OCR_USED_COUNT';
  static const String freeOcrUsedPeriod = 'FREE_OCR_USED_PERIOD';
}
