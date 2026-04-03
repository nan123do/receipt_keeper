// lib/components/Card/warranty_card.dart
import 'package:flutter/material.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class WarrantyCard extends StatelessWidget {
  const WarrantyCard({
    super.key,
    required this.warranty,
    required this.subtitle,
    this.onTap,
  });

  final Warranty warranty;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusType = AppFormatHelper.getWarrantyStatusType(warranty.daysLeft);
    final statusStyle = _getStatusStyle(statusType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CareraTheme.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CareraTheme.gray20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusStyle),
              12.gap,
              _buildInfoSection(),
              12.gap,
              _buildFooter(statusStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_WarrantyStatusStyle statusStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warranty.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AxataTextStyle.textBase.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.black,
                  height: 1.3,
                ),
              ),
              4.gap,
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        10.wGap,
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: statusStyle.backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: statusStyle.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusStyle.icon,
                size: 14,
                color: statusStyle.iconColor,
              ),
              6.wGap,
              Text(
                AppFormatHelper.formatWarrantyStatus(warranty.daysLeft),
                style: AxataTextStyle.textXs.copyWith(
                  color: statusStyle.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoColumn(
            label: 'Tanggal beli',
            value: AppFormatHelper.formatDate(warranty.purchaseDate),
          ),
        ),
        12.wGap,
        Expanded(
          child: _buildInfoColumn(
            label: 'Habis garansi',
            value: AppFormatHelper.formatDate(warranty.expiryDate),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(_WarrantyStatusStyle statusStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 16,
            color: statusStyle.iconColor,
          ),
          8.wGap,
          Expanded(
            child: Text(
              AppFormatHelper.formatWarrantyDaysLeft(warranty.daysLeft),
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray90,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: CareraTheme.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: CareraTheme.gray20),
            ),
            child: Text(
              '${warranty.warrantyMonths} bln',
              style: AxataTextStyle.textXs.copyWith(
                color: CareraTheme.gray70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onTap != null) ...[
            10.wGap,
            const Icon(
              Icons.chevron_right_rounded,
              color: CareraTheme.gray60,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AxataTextStyle.textXs.copyWith(
            color: CareraTheme.gray60,
            fontWeight: FontWeight.w600,
          ),
        ),
        6.gap,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AxataTextStyle.textSm.copyWith(
            color: CareraTheme.gray90,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  _WarrantyStatusStyle _getStatusStyle(WarrantyStatusType statusType) {
    switch (statusType) {
      case WarrantyStatusType.active:
        return const _WarrantyStatusStyle(
          backgroundColor: CareraTheme.turquoise30,
          borderColor: CareraTheme.turquoise50,
          iconColor: CareraTheme.turquoise100,
          textColor: CareraTheme.gray90,
          icon: Icons.verified_outlined,
        );
      case WarrantyStatusType.expiringSoon:
        return const _WarrantyStatusStyle(
          backgroundColor: CareraTheme.orange20,
          borderColor: CareraTheme.orange50,
          iconColor: CareraTheme.orange100,
          textColor: CareraTheme.gray90,
          icon: Icons.schedule_outlined,
        );
      case WarrantyStatusType.expired:
        return _WarrantyStatusStyle(
          backgroundColor: const Color(0xFFFFF1F4),
          borderColor: CareraTheme.red.withValues(alpha: 0.35),
          iconColor: CareraTheme.red,
          textColor: CareraTheme.gray90,
          icon: Icons.error_outline,
        );
    }
  }
}

class _WarrantyStatusStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  const _WarrantyStatusStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
