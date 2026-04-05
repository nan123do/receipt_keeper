// lib/helpers/feature_gate_helper.dart
import 'dart:math' as math;

import 'package:receipt_keeper/services/daos/app_setting_dao_service.dart';
import 'package:receipt_keeper/utils/app_setting_keys.dart';

class FeatureGateHelper {
  FeatureGateHelper({
    AppSettingDaoService? appSettingDaoService,
  }) : _appSettingDaoService = appSettingDaoService ?? AppSettingDaoService();

  final AppSettingDaoService _appSettingDaoService;

  static const int defaultFreeReceiptLimit = 20;
  static const int defaultFreeOcrLimit = 10;
  static const int defaultWarningThreshold = 3;

  bool get isPremium {
    return _appSettingDaoService.getBoolValue(
      AppSettingKeys.isPremium,
      defaultValue: false,
    );
  }

  String get premiumProductId {
    return _appSettingDaoService.getValue(
      AppSettingKeys.premiumProductId,
    );
  }

  int get freeReceiptLimit {
    return _appSettingDaoService.getIntValue(
      AppSettingKeys.freeReceiptLimit,
      defaultValue: defaultFreeReceiptLimit,
    );
  }

  int get freeOcrLimit {
    return _appSettingDaoService.getIntValue(
      AppSettingKeys.freeOcrLimit,
      defaultValue: defaultFreeOcrLimit,
    );
  }

  String buildOcrPeriod([DateTime? date]) {
    final value = date ?? DateTime.now();
    final month = value.month.toString().padLeft(2, '0');
    return '${value.year}-$month';
  }

  int getOcrUsedCount({
    DateTime? now,
  }) {
    final currentPeriod = buildOcrPeriod(now);
    final savedPeriod = _appSettingDaoService.getValue(
      AppSettingKeys.freeOcrUsedPeriod,
    );

    if (savedPeriod != currentPeriod) {
      return 0;
    }

    return _appSettingDaoService.getIntValue(
      AppSettingKeys.freeOcrUsedCount,
      defaultValue: 0,
    );
  }

  int remainingFreeReceipt({
    required int currentReceiptCount,
  }) {
    if (isPremium) {
      return -1;
    }

    return math.max(0, freeReceiptLimit - currentReceiptCount);
  }

  bool canAddReceipt({
    required int currentReceiptCount,
  }) {
    if (isPremium) {
      return true;
    }

    return currentReceiptCount < freeReceiptLimit;
  }

  bool shouldShowReceiptLimitWarning({
    required int currentReceiptCount,
    int warningThreshold = defaultWarningThreshold,
  }) {
    if (isPremium) {
      return false;
    }

    final remaining = remainingFreeReceipt(
      currentReceiptCount: currentReceiptCount,
    );

    return remaining > 0 && remaining <= warningThreshold;
  }

  int remainingFreeOcr({
    DateTime? now,
  }) {
    if (isPremium) {
      return -1;
    }

    return math.max(
      0,
      freeOcrLimit - getOcrUsedCount(now: now),
    );
  }

  bool canUseOcr({
    DateTime? now,
  }) {
    if (isPremium) {
      return true;
    }

    return remainingFreeOcr(now: now) > 0;
  }

  bool shouldShowOcrLimitWarning({
    DateTime? now,
    int warningThreshold = defaultWarningThreshold,
  }) {
    if (isPremium) {
      return false;
    }

    final remaining = remainingFreeOcr(now: now);
    return remaining > 0 && remaining <= warningThreshold;
  }

  bool canUseWarrantyReminder() {
    return isPremium;
  }

  bool canExportWithoutLimit() {
    return isPremium;
  }
}
