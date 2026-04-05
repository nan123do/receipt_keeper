import 'package:receipt_keeper/controllers/page_index_controller.dart';
// lib/pages/settings/controllers/settings_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:receipt_keeper/components/Dialog/restore_confirm_dialog.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/components/selectlist.dart';
import 'package:receipt_keeper/helpers/feature_gate_helper.dart';
import 'package:receipt_keeper/helpers/premium_gate_prompt_helper.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/backup/local_backup_service.dart';
import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/services/daos/warranty_dao_service.dart';
import 'package:receipt_keeper/services/notification/notification_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';
import 'package:receipt_keeper/utils/global_data.dart';

class SettingsController extends GetxController {
  final AppSettingDaoService _appSettingDaoService = AppSettingDaoService();
  final WarrantyDaoService _warrantyDaoService = WarrantyDaoService();
  final FeatureGateHelper _featureGateHelper = FeatureGateHelper();
  final LocalBackupService _localBackupService = LocalBackupService();

  final RxBool isLoading = false.obs;
  final RxBool isBackupProcessing = false.obs;
  final RxBool isPremium = false.obs;

  final RxBool biometricOnAppOpen = false.obs;
  final RxInt defaultWarrantyMonths = 12.obs;
  final RxBool notificationEnabled = true.obs;
  final RxInt warrantyReminderDays = 7.obs;
  final RxBool scanAutoProcessOcr = true.obs;
  final RxString scanPreferredSource = 'camera'.obs;
  final RxString backupLocalLastAt = ''.obs;
  final RxString backupLocalLastFileName = ''.obs;

  static const String appVersion = '1.0.0+1';

  NotificationService? get _notificationService {
    if (!Get.isRegistered<NotificationService>()) {
      return null;
    }

    return NotificationService.to;
  }

  String get biometricLabel =>
      biometricOnAppOpen.value ? 'Aktif' : 'Belum aktif';

  String get defaultWarrantyLabel => '${defaultWarrantyMonths.value} bulan';

  String get notificationLabel {
    if (!notificationEnabled.value) {
      return 'Nonaktif';
    }

    return 'Aktif • H-${warrantyReminderDays.value}';
  }

  String get scanBehaviorLabel {
    final sourceLabel =
        scanPreferredSource.value == 'gallery' ? 'Galeri' : 'Kamera';

    final ocrLabel =
        scanAutoProcessOcr.value ? 'OCR otomatis' : 'Cek manual dulu';

    return '$sourceLabel • $ocrLabel';
  }

  bool get hasLocalBackup => backupLocalLastFileName.value.isNotEmpty;

  String get localBackupLastAtLabel {
    if (backupLocalLastAt.value.isEmpty) {
      return 'Belum ada';
    }

    final parsedDate = DateTime.tryParse(backupLocalLastAt.value);
    if (parsedDate == null) {
      return 'Belum ada';
    }

    return DateFormat('dd/MM/yyyy • HH:mm').format(parsedDate.toLocal());
  }

  String get localBackupLastFileNameLabel {
    if (backupLocalLastFileName.value.isEmpty) {
      return 'Belum ada';
    }

    return backupLocalLastFileName.value;
  }

  String get cloudBackupLabel {
    if (isPremium.value) {
      return 'Segera hadir';
    }

    return 'Premium';
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<PageIndexController>()) {
      Get.find<PageIndexController>().changeIndexPage(4);
    }
    getInit();
  }

  Future<void> getInit() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;

      biometricOnAppOpen.value = _appSettingDaoService.getBoolValue(
        AppSettingKeys.biometricOnAppOpen,
        defaultValue: false,
      );

      defaultWarrantyMonths.value = _sanitizeWarrantyMonths(
        _appSettingDaoService.getIntValue(
          AppSettingKeys.defaultWarrantyMonths,
          defaultValue: 12,
        ),
      );

      notificationEnabled.value = _appSettingDaoService.getBoolValue(
        AppSettingKeys.notificationEnabled,
        defaultValue: true,
      );

      warrantyReminderDays.value = _sanitizeReminderDays(
        _appSettingDaoService.getIntValue(
          AppSettingKeys.warrantyReminderDays,
          defaultValue: 7,
        ),
      );

      scanAutoProcessOcr.value = _appSettingDaoService.getBoolValue(
        AppSettingKeys.scanAutoProcessOcr,
        defaultValue: true,
      );

      final source = _appSettingDaoService.getValue(
        AppSettingKeys.scanPreferredSource,
        defaultValue: 'camera',
      );

      scanPreferredSource.value = source == 'gallery' ? 'gallery' : 'camera';

      backupLocalLastAt.value = _appSettingDaoService.getValue(
        AppSettingKeys.backupLocalLastAt,
      );

      backupLocalLastFileName.value = _appSettingDaoService.getValue(
        AppSettingKeys.backupLocalLastFileName,
      );

      isPremium.value = _appSettingDaoService.getBoolValue(
        AppSettingKeys.isPremium,
        defaultValue: false,
      );

      GlobalData.BiometrikSaatBukaAplikasi = biometricOnAppOpen.value;
    } catch (_) {
      CustomToast.errorToast(
        'Gagal memuat pengaturan',
        'Data pengaturan belum bisa ditampilkan.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBiometric(bool value) async {
    final previousValue = biometricOnAppOpen.value;

    try {
      biometricOnAppOpen.value = value;

      _appSettingDaoService.setBoolValue(
        AppSettingKeys.biometricOnAppOpen,
        value,
        description: 'Biometrik saat buka aplikasi',
      );

      GlobalData.BiometrikSaatBukaAplikasi = value;

      CustomToast.successToast(
        value ? 'Biometrik diaktifkan' : 'Biometrik dimatikan',
        value
            ? 'Aplikasi akan memakai pengaturan biometrik saat dibuka.'
            : 'Aplikasi tidak lagi memakai pengaturan biometrik saat dibuka.',
      );
    } catch (_) {
      biometricOnAppOpen.value = previousValue;
      GlobalData.BiometrikSaatBukaAplikasi = previousValue;

      CustomToast.errorToast(
        'Gagal menyimpan pengaturan',
        'Pengaturan biometrik belum bisa diperbarui.',
      );
    }
  }

  Future<void> selectDefaultWarrantyMonths() async {
    final selectedValue = await Get.to<int>(
      () => SelectListView<int>(
        title: 'Durasi Garansi Default',
        items: const [1, 3, 6, 12, 24],
        labelBuilder: (item) => '$item bulan',
      ),
    );

    if (selectedValue == null || selectedValue == defaultWarrantyMonths.value) {
      return;
    }

    try {
      defaultWarrantyMonths.value = _sanitizeWarrantyMonths(selectedValue);

      _appSettingDaoService.setValue(
        AppSettingKeys.defaultWarrantyMonths,
        defaultWarrantyMonths.value.toString(),
        description: 'Default durasi garansi dalam bulan',
      );

      CustomToast.successToast(
        'Durasi default diperbarui',
        'Durasi garansi default sekarang ${defaultWarrantyMonths.value} bulan.',
      );
    } catch (_) {
      CustomToast.errorToast(
        'Gagal menyimpan pengaturan',
        'Durasi garansi default belum bisa diperbarui.',
      );
    }
  }

  Future<void> toggleNotificationEnabled(bool value) async {
    if (value && !_featureGateHelper.canUseWarrantyReminder()) {
      await PremiumGatePromptHelper.showNotificationPremiumOnly();
      return;
    }

    final previousValue = notificationEnabled.value;

    try {
      if (value) {
        final granted = await _ensureNotificationPermission();
        if (!granted) {
          return;
        }
      }

      notificationEnabled.value = value;

      _appSettingDaoService.setBoolValue(
        AppSettingKeys.notificationEnabled,
        value,
        description: 'Notifikasi aplikasi aktif',
      );

      if (value) {
        await _refreshWarrantyReminderState();
      } else {
        await _notificationService?.cancelAll();
      }

      CustomToast.successToast(
        value ? 'Notifikasi diaktifkan' : 'Notifikasi dimatikan',
        value
            ? 'Pengingat garansi global sudah aktif.'
            : 'Pengingat garansi global sementara dimatikan.',
      );
    } catch (_) {
      notificationEnabled.value = previousValue;

      CustomToast.errorToast(
        'Gagal mengubah notifikasi',
        'Pengaturan notifikasi belum bisa diperbarui.',
      );
    }
  }

  Future<void> selectWarrantyReminderDays() async {
    final selectedValue = await Get.to<int>(
      () => SelectListView<int>(
        title: 'Pengingat Garansi',
        items: const [5, 7, 14, 30],
        labelBuilder: (item) => 'H-$item sebelum habis',
      ),
    );

    if (selectedValue == null || selectedValue == warrantyReminderDays.value) {
      return;
    }

    try {
      warrantyReminderDays.value = _sanitizeReminderDays(selectedValue);

      _appSettingDaoService.setValue(
        AppSettingKeys.warrantyReminderDays,
        warrantyReminderDays.value.toString(),
        description: 'Pengingat garansi sebelum habis dalam hitungan hari',
      );

      if (notificationEnabled.value) {
        await _refreshWarrantyReminderState();
      }

      CustomToast.successToast(
        'Pengingat diperbarui',
        'Pengingat awal sekarang dikirim H-${warrantyReminderDays.value}.',
      );
    } catch (_) {
      CustomToast.errorToast(
        'Gagal menyimpan pengaturan',
        'Pengaturan pengingat belum bisa diperbarui.',
      );
    }
  }

  Future<void> toggleScanAutoProcessOcr(bool value) async {
    final previousValue = scanAutoProcessOcr.value;

    try {
      scanAutoProcessOcr.value = value;

      _appSettingDaoService.setBoolValue(
        AppSettingKeys.scanAutoProcessOcr,
        value,
        description: 'OCR otomatis setelah gambar struk dipilih',
      );

      CustomToast.successToast(
        value ? 'OCR otomatis diaktifkan' : 'OCR otomatis dimatikan',
        value
            ? 'Setelah pilih gambar, OCR akan langsung dijalankan.'
            : 'Setelah pilih gambar, Anda bisa cek dulu sebelum jalankan OCR.',
      );
    } catch (_) {
      scanAutoProcessOcr.value = previousValue;

      CustomToast.errorToast(
        'Gagal menyimpan pengaturan',
        'Perilaku scan belum bisa diperbarui.',
      );
    }
  }

  Future<void> selectPreferredSource() async {
    final selectedValue = await Get.to<String>(
      () => SelectListView<String>(
        title: 'Sumber Scan Utama',
        items: const ['camera', 'gallery'],
        labelBuilder: (item) => item == 'gallery' ? 'Galeri' : 'Kamera',
      ),
    );

    if (selectedValue == null || selectedValue == scanPreferredSource.value) {
      return;
    }

    try {
      scanPreferredSource.value = selectedValue;

      _appSettingDaoService.setValue(
        AppSettingKeys.scanPreferredSource,
        scanPreferredSource.value,
        description: 'Sumber scan yang lebih sering dipakai pengguna',
      );

      CustomToast.successToast(
        'Sumber scan diperbarui',
        scanPreferredSource.value == 'gallery'
            ? 'Galeri menjadi pilihan scan utama.'
            : 'Kamera menjadi pilihan scan utama.',
      );
    } catch (_) {
      CustomToast.errorToast(
        'Gagal menyimpan pengaturan',
        'Sumber scan utama belum bisa diperbarui.',
      );
    }
  }

  Future<void> createLocalBackup() async {
    if (isBackupProcessing.value) {
      return;
    }

    try {
      isBackupProcessing.value = true;

      final backupFile = await _localBackupService.createLocalBackup();
      await _saveBackupInfo(backupFile);
      await loadSettings();

      final fileName = backupFile.path.split(Platform.pathSeparator).last;

      CustomToast.successToast(
        'Backup lokal berhasil',
        'Salinan database berhasil dibuat ke $fileName.',
      );
    } catch (_) {
      CustomToast.errorToast(
        'Backup lokal gagal',
        'Database belum bisa disalin. Coba lagi sebentar lagi.',
      );
    } finally {
      isBackupProcessing.value = false;
    }
  }

  Future<void> restoreLatestLocalBackup() async {
    if (isBackupProcessing.value) {
      return;
    }

    final latestBackup = await _localBackupService.getLatestLocalBackup();
    if (latestBackup == null) {
      CustomToast.errorToast(
        'Backup belum tersedia',
        'Buat backup lokal dulu sebelum melakukan restore.',
      );
      return;
    }

    final fileName = latestBackup.path.split(Platform.pathSeparator).last;

    final confirmed = await Get.dialog<bool>(
          RestoreConfirmDialog(
            title: 'Restore Backup Lokal',
            message: 'Restore akan menimpa data saat ini. Lanjutkan?',
            description:
                'Backup terbaru yang dipakai: $fileName\nSebaiknya buat backup lokal baru dulu sebelum restore.',
            actionText: 'Restore',
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      isBackupProcessing.value = true;

      await _localBackupService.restoreFromBackup(latestBackup);
      await _saveBackupInfo(latestBackup);
      await loadSettings();

      CustomToast.successToast(
        'Restore berhasil',
        'Data berhasil dipulihkan dari backup lokal terbaru.',
      );
    } catch (_) {
      CustomToast.errorToast(
        'Restore gagal',
        'Backup lokal belum bisa dipulihkan.',
      );
    } finally {
      isBackupProcessing.value = false;
    }
  }

  void showCloudBackupPlaceholder() {
    CustomToast.errorToast(
      'Segera hadir',
      'Backup cloud premium belum tersedia pada versi ini.',
    );
  }

  Future<void> openPremiumPage() async {
    await Get.toNamed(Routes.PREMIUM);
  }

  Future<bool> _ensureNotificationPermission() async {
    final notificationService = _notificationService;
    if (notificationService == null) {
      return false;
    }

    final currentStatus = await notificationService.syncPermissionStatus();
    if (currentStatus) {
      return true;
    }

    final granted = await notificationService.requestNotificationPermission();
    if (!granted) {
      CustomToast.errorToast(
        'Izin notifikasi dibutuhkan',
        'Aktifkan izin notifikasi perangkat agar pengingat bisa dikirim.',
      );
    }

    return granted;
  }

  Future<void> _refreshWarrantyReminderState() async {
    final notificationService = _notificationService;
    if (notificationService == null) {
      return;
    }

    final warranties = _warrantyDaoService.getAll(
      isReminderEnabled: true,
    );

    for (final warranty in warranties) {
      await notificationService.resetWarrantyReminderForWarranty(warranty);
    }

    await notificationService.runDailyWarrantyCheck(force: true);
  }

  Future<void> _saveBackupInfo(File backupFile) async {
    final fileName = backupFile.path.split(Platform.pathSeparator).last;
    final modifiedAt = await backupFile.lastModified();

    _appSettingDaoService.setValue(
      AppSettingKeys.backupLocalLastAt,
      modifiedAt.toIso8601String(),
      description: 'Waktu backup lokal terakhir',
    );

    _appSettingDaoService.setValue(
      AppSettingKeys.backupLocalLastFileName,
      fileName,
      description: 'Nama file backup lokal terakhir',
    );
  }

  int _sanitizeWarrantyMonths(int value) {
    if (value <= 0) {
      return 12;
    }

    return value;
  }

  int _sanitizeReminderDays(int value) {
    if (value <= 0) {
      return 7;
    }

    return value;
  }
}
