// lib/services/daos/app_setting_dao_service.dart
import 'package:receipt_keeper/services/db/app_db_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

class AppSettingDaoService {
  String getValue(
    String key, {
    String defaultValue = '',
  }) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT setting_value
      FROM app_setting
      WHERE setting_key = ?
      LIMIT 1
      ''',
      [key],
    );

    if (rows.isEmpty) {
      return defaultValue;
    }

    final value = rows.first['setting_value'];
    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  bool getBoolValue(
    String key, {
    bool defaultValue = false,
  }) {
    final value = getValue(
      key,
      defaultValue: defaultValue ? '1' : '0',
    ).toLowerCase();

    return value == '1' || value == 'true';
  }

  int getIntValue(
    String key, {
    int defaultValue = 0,
  }) {
    final value = getValue(
      key,
      defaultValue: defaultValue.toString(),
    );

    return int.tryParse(value) ?? defaultValue;
  }

  double getDoubleValue(
    String key, {
    double defaultValue = 0,
  }) {
    final value = getValue(
      key,
      defaultValue: defaultValue.toString(),
    );

    return double.tryParse(value) ?? defaultValue;
  }

  Map<String, String> getAll() {
    final rows = AppDbService.to.db.select(
      '''
      SELECT setting_key, setting_value
      FROM app_setting
      ORDER BY setting_key ASC
      ''',
    );

    final result = <String, String>{};

    for (final row in rows) {
      final key = row['setting_key']?.toString() ?? '';
      final value = row['setting_value']?.toString() ?? '';

      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }

  void setBoolValue(
    String key,
    bool value, {
    String? description,
  }) {
    setValue(
      key,
      value ? '1' : '0',
      description: description,
    );
  }

  void setValue(
    String key,
    String value, {
    String? description,
  }) {
    AppDbService.to.db.execute(
      '''
      INSERT INTO app_setting (
        setting_key,
        setting_value,
        description,
        updated_at
      )
      VALUES (?, ?, ?, ?)
      ON CONFLICT(setting_key) DO UPDATE SET
        setting_value = excluded.setting_value,
        description = COALESCE(excluded.description, app_setting.description),
        updated_at = excluded.updated_at
      ''',
      [
        key,
        value,
        description,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  bool containsKey(String key) {
    final rows = AppDbService.to.db.select(
      '''
      SELECT setting_key
      FROM app_setting
      WHERE setting_key = ?
      LIMIT 1
      ''',
      [key],
    );

    return rows.isNotEmpty;
  }

  void delete(String key) {
    AppDbService.to.db.execute(
      '''
      DELETE FROM app_setting
      WHERE setting_key = ?
      ''',
      [key],
    );
  }

  void ensureDefaultSettings() {
    _setDefaultIfMissing(
      AppSettingKeys.biometricOnAppOpen,
      '0',
      description: 'Biometrik saat buka aplikasi',
    );

    _setDefaultIfMissing(
      AppSettingKeys.defaultWarrantyMonths,
      '12',
      description: 'Default durasi garansi dalam bulan',
    );

    _setDefaultIfMissing(
      AppSettingKeys.notificationEnabled,
      '1',
      description: 'Notifikasi aplikasi aktif',
    );

    _setDefaultIfMissing(
      AppSettingKeys.warrantyReminderDays,
      '7',
      description: 'Pengingat garansi sebelum habis dalam hitungan hari',
    );

    _setDefaultIfMissing(
      AppSettingKeys.scanAutoProcessOcr,
      '1',
      description: 'OCR otomatis setelah gambar struk dipilih',
    );

    _setDefaultIfMissing(
      AppSettingKeys.scanPreferredSource,
      'camera',
      description: 'Sumber scan yang lebih sering dipakai pengguna',
    );

    _setDefaultIfMissing(
      AppSettingKeys.isPremium,
      '0',
      description: 'Status premium aktif',
    );

    _setDefaultIfMissing(
      AppSettingKeys.premiumProductId,
      '',
      description: 'Product id premium aktif',
    );

    _setDefaultIfMissing(
      AppSettingKeys.premiumPurchaseId,
      '',
      description: 'ID transaksi pembelian premium',
    );

    _setDefaultIfMissing(
      AppSettingKeys.premiumPurchasedAt,
      '',
      description: 'Waktu aktivasi premium',
    );

    _setDefaultIfMissing(
      AppSettingKeys.premiumLastRestoreAt,
      '',
      description: 'Waktu restore premium terakhir',
    );

    _setDefaultIfMissing(
      AppSettingKeys.backupLocalLastAt,
      '',
      description: 'Waktu backup lokal terakhir',
    );

    _setDefaultIfMissing(
      AppSettingKeys.backupLocalLastFileName,
      '',
      description: 'Nama file backup lokal terakhir',
    );

    _setDefaultIfMissing(
      AppSettingKeys.freeReceiptLimit,
      '20',
      description: 'Batas gratis jumlah struk',
    );

    _setDefaultIfMissing(
      AppSettingKeys.freeOcrLimit,
      '10',
      description: 'Batas gratis jumlah OCR per bulan',
    );

    _setDefaultIfMissing(
      AppSettingKeys.freeOcrUsedCount,
      '0',
      description: 'Jumlah OCR gratis yang sudah dipakai di bulan aktif',
    );

    _setDefaultIfMissing(
      AppSettingKeys.freeOcrUsedPeriod,
      '',
      description: 'Periode pemakaian OCR gratis',
    );
  }

  void _setDefaultIfMissing(
    String key,
    String value, {
    String? description,
  }) {
    if (containsKey(key)) {
      return;
    }

    setValue(
      key,
      value,
      description: description,
    );
  }
}
