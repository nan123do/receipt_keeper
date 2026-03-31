// lib/components/Card/receipt_card.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.receipt,
    this.itemCount = 0,
    this.warrantyCount = 0,
    this.isExample = false,
    this.onTap,
    this.onEdit,
    this.onQuickExport,
  });

  final Receipt receipt;
  final int itemCount;
  final int warrantyCount;
  final bool isExample;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onQuickExport;

  @override
  Widget build(BuildContext context) {
    final storeName = (receipt.storeName ?? '').trim().isEmpty
        ? 'Tanpa nama toko'
        : receipt.storeName!.trim();

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              12.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(storeName),
                    10.gap,
                    _buildTotalSection(),
                    10.gap,
                    _buildInfoBadges(),
                    if (onEdit != null || onQuickExport != null) ...[
                      12.gap,
                      const Divider(height: 1),
                      12.gap,
                      _buildActionSection(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String storeName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AxataTextStyle.textBase.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.black,
                  height: 1.3,
                ),
              ),
              4.gap,
              _buildDateRow(),
            ],
          ),
        ),
        if (onTap != null) ...[
          8.wGap,
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: CareraTheme.gray5,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: CareraTheme.gray60,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: CareraTheme.gray60,
        ),
        6.wGap,
        Expanded(
          child: Text(
            AppFormatHelper.formatDateTime(receipt.purchaseDate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Belanja',
            style: AxataTextStyle.textXs.copyWith(
              color: CareraTheme.gray70,
              fontWeight: FontWeight.w600,
            ),
          ),
          4.gap,
          Text(
            AppFormatHelper.formatRupiah(receipt.totalAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AxataTextStyle.textLg.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          icon: Icons.shopping_bag_outlined,
          text: '$itemCount item',
          backgroundColor: CareraTheme.gray5,
          iconColor: CareraTheme.gray70,
          textColor: CareraTheme.gray80,
        ),
        _buildBadge(
          icon: Icons.verified_outlined,
          text: '$warrantyCount garansi',
          backgroundColor:
              warrantyCount > 0 ? CareraTheme.turquoise30 : CareraTheme.gray5,
          iconColor:
              warrantyCount > 0 ? CareraTheme.mainColor : CareraTheme.gray70,
          textColor:
              warrantyCount > 0 ? CareraTheme.gray90 : CareraTheme.gray80,
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onEdit != null)
          _buildActionButton(
            onTap: onEdit,
            icon: Icons.edit_outlined,
            text: 'Edit',
            backgroundColor: CareraTheme.turquoise30,
            iconColor: CareraTheme.mainColor,
            textColor: CareraTheme.mainColor,
          ),
        if (onQuickExport != null)
          _buildActionButton(
            onTap: onQuickExport,
            icon: Icons.ios_share_rounded,
            text: 'Export PDF',
            backgroundColor: CareraTheme.orange20,
            iconColor: CareraTheme.orange100,
            textColor: CareraTheme.orange100,
          ),
      ],
    );
  }

  Widget _buildThumbnail() {
    final imagePath = receipt.imagePath?.trim();

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);

      if (file.existsSync()) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                width: 78,
                height: 78,
                fit: BoxFit.cover,
              ),
            ),
            if (isExample) _buildExampleBadge(),
          ],
        );
      }
    }

    return Stack(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: CareraTheme.turquoise30,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            color: CareraTheme.mainColor,
            size: 30,
          ),
        ),
        if (isExample) _buildExampleBadge(),
      ],
    );
  }

  Widget _buildExampleBadge() {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: CareraTheme.orange20,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CareraTheme.orange50),
        ),
        child: Text(
          'Contoh',
          style: AxataTextStyle.textXs.copyWith(
            color: CareraTheme.orange100,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            6.wGap,
            Text(
              text,
              style: AxataTextStyle.textSm.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          6.wGap,
          Text(
            text,
            style: AxataTextStyle.textSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
