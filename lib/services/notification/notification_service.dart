// lib/services/notification/notification_service.dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/helpers/warranty_helper.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  final AppSettingDaoService _appSettingDaoService = AppSettingDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();

  static const String warrantyReminderChannelId = 'warranty_reminder_channel';
  static const String warrantyReminderChannelName = 'Pengingat Garansi';
  static const String warrantyReminderChannelDescription =
      'Notifikasi pengingat sebelum garansi habis';

  static const String _dailyWarrantyCheckKey =
      'WARRANTY_NOTIFICATION_LAST_CHECK_DATE';
  static const String _sentWarrantyReminderKeyPrefix =
      'WARRANTY_NOTIFICATION_SENT_';

  final RxBool isReady = false.obs;
  final RxBool hasPermission = false.obs;

  Future<NotificationService> init() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    await plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createDefaultChannels();
    await syncPermissionStatus();

    isReady.value = true;
    return this;
  }

  Future<void> _createDefaultChannels() async {
    final androidImplementation = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return;
    }

    const warrantyChannel = AndroidNotificationChannel(
      warrantyReminderChannelId,
      warrantyReminderChannelName,
      description: warrantyReminderChannelDescription,
      importance: Importance.max,
    );

    await androidImplementation.createNotificationChannel(
      warrantyChannel,
    );
  }

  Future<bool> syncPermissionStatus() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final enabled =
          await androidImplementation?.areNotificationsEnabled() ?? false;

      hasPermission.value = enabled;
      return enabled;
    }

    hasPermission.value = true;
    return true;
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted =
          await androidImplementation?.requestNotificationsPermission() ??
              false;

      hasPermission.value = granted;
      return granted;
    }

    if (Platform.isIOS) {
      final iosImplementation = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      hasPermission.value = granted;
      return granted;
    }

    if (Platform.isMacOS) {
      final macImplementation = plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

      final granted = await macImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      hasPermission.value = granted;
      return granted;
    }

    hasPermission.value = true;
    return true;
  }

  Future<void> showWarrantyReminder({
    required int notificationId,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isReady.value) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      warrantyReminderChannelId,
      warrantyReminderChannelName,
      channelDescription: warrantyReminderChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await plugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> runDailyWarrantyCheck({
    bool force = false,
  }) async {
    if (!isReady.value) {
      return;
    }

    final canProcess = await _canProcessWarrantyReminder();
    if (!canProcess) {
      return;
    }

    final todayKey = _formatDateKey(DateTime.now());

    if (!force) {
      final lastCheck = _appSettingDaoService.getValue(
        _dailyWarrantyCheckKey,
      );

      if (lastCheck == todayKey) {
        return;
      }
    }

    await _processEligibleWarranties();

    _appSettingDaoService.setValue(
      _dailyWarrantyCheckKey,
      todayKey,
      description: 'Tanggal cek harian pengingat garansi terakhir',
    );
  }

  Future<void> syncWarrantyReminderForWarranty(Warranty warranty) async {
    if (!isReady.value) {
      return;
    }

    if (!warranty.isReminderEnabled) {
      await cancelWarrantyNotifications(warranty);
      return;
    }

    final canProcess = await _canProcessWarrantyReminder();
    if (!canProcess) {
      return;
    }

    await _notifyWarrantyIfNeeded(warranty);
  }

  Future<void> resetWarrantyReminderForWarranty(Warranty warranty) async {
    await clearWarrantyReminderHistory(warranty);
    await cancelWarrantyNotifications(warranty);
    await syncWarrantyReminderForWarranty(warranty);
  }

  Future<void> removeWarrantyReminderState(Warranty warranty) async {
    await clearWarrantyReminderHistory(warranty);
    await cancelWarrantyNotifications(warranty);
  }

  Future<void> clearWarrantyReminderHistory(Warranty warranty) async {
    final warrantyId = warranty.id;
    if (warrantyId == null) {
      return;
    }

    _appSettingDaoService.delete(_buildReminderSentKey(warrantyId, 7));
    _appSettingDaoService.delete(_buildReminderSentKey(warrantyId, 3));
    _appSettingDaoService.delete(_buildReminderSentKey(warrantyId, 0));
  }

  Future<void> cancelWarrantyNotifications(Warranty warranty) async {
    final warrantyId = warranty.id;
    if (warrantyId == null) {
      return;
    }

    await cancel(_buildNotificationId(warrantyId, 7));
    await cancel(_buildNotificationId(warrantyId, 3));
    await cancel(_buildNotificationId(warrantyId, 0));
  }

  Future<bool> _canProcessWarrantyReminder() async {
    final isGlobalNotificationEnabled = _appSettingDaoService.getBoolValue(
      AppSettingKeys.notificationEnabled,
      defaultValue: true,
    );

    if (!isGlobalNotificationEnabled) {
      return false;
    }

    return syncPermissionStatus();
  }

  Future<void> _processEligibleWarranties() async {
    final warranties = _warrantyDaoService.getAll(
      isReminderEnabled: true,
    );

    for (final warranty in warranties) {
      await _notifyWarrantyIfNeeded(warranty);
    }
  }

  Future<void> _notifyWarrantyIfNeeded(Warranty warranty) async {
    final warrantyId = warranty.id;
    if (warrantyId == null) {
      return;
    }

    final reminderStage = _resolveReminderStage(warranty.daysLeft);
    if (reminderStage == null) {
      return;
    }

    if (_hasStageBeenSent(warrantyId, reminderStage)) {
      return;
    }

    await showWarrantyReminder(
      notificationId: _buildNotificationId(warrantyId, reminderStage),
      title: _buildReminderTitle(reminderStage),
      body: _buildReminderBody(
        warranty: warranty,
        reminderStage: reminderStage,
      ),
      payload:
          'warranty:$warrantyId:receipt:${warranty.receiptId}:stage:$reminderStage',
    );

    _appSettingDaoService.setValue(
      _buildReminderSentKey(warrantyId, reminderStage),
      DateTime.now().toIso8601String(),
      description:
          'Riwayat kirim pengingat garansi tahap $reminderStage hari untuk warranty $warrantyId',
    );
  }

  int? _resolveReminderStage(int daysLeft) {
    if (daysLeft <= 0) {
      return 0;
    }

    if (daysLeft <= 3) {
      return 3;
    }

    if (daysLeft <= 7) {
      return 7;
    }

    return null;
  }

  bool _hasStageBeenSent(int warrantyId, int reminderStage) {
    final value = _appSettingDaoService.getValue(
      _buildReminderSentKey(warrantyId, reminderStage),
    );

    return value.trim().isNotEmpty;
  }

  int _buildNotificationId(int warrantyId, int reminderStage) {
    return (warrantyId * 10) + reminderStage;
  }

  String _buildReminderSentKey(int warrantyId, int reminderStage) {
    return '$_sentWarrantyReminderKeyPrefix${warrantyId}_$reminderStage';
  }

  String _buildReminderTitle(int reminderStage) {
    switch (reminderStage) {
      case 7:
        return 'Garansi mendekati habis';
      case 3:
        return 'Garansi tinggal 3 hari';
      case 0:
        return 'Garansi perlu segera dicek';
      default:
        return 'Pengingat Garansi';
    }
  }

  String _buildReminderBody({
    required Warranty warranty,
    required int reminderStage,
  }) {
    final expiryDateLabel = AppFormatHelper.formatDate(
      warranty.expiryDate,
    );

    switch (reminderStage) {
      case 7:
        return '${warranty.productName} akan habis garansi pada $expiryDateLabel.';
      case 3:
        return '${warranty.productName} tinggal sedikit waktu sebelum garansi habis pada $expiryDateLabel.';
      case 0:
        if (warranty.daysLeft == 0) {
          return '${warranty.productName} habis garansi hari ini ($expiryDateLabel).';
        }

        return '${warranty.productName} sudah melewati masa garansi pada $expiryDateLabel.';
      default:
        return '${warranty.productName} mendekati masa akhir garansi.';
    }
  }

  String _formatDateKey(DateTime value) {
    final normalizedDate = WarrantyHelper.normalizeDate(value);

    final year = normalizedDate.year.toString().padLeft(4, '0');
    final month = normalizedDate.month.toString().padLeft(2, '0');
    final day = normalizedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> cancel(int notificationId) async {
    await plugin.cancel(notificationId);
  }

  Future<void> cancelAll() async {
    await plugin.cancelAll();
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Nanti dipakai saat kita buka detail garansi / detail receipt dari notif.
  }
}
