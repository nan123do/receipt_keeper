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
    this.onTap,
    this.onQuickExport,
  });

  final Receipt receipt;
  final int itemCount;
  final int warrantyCount;
  final VoidCallback? onTap;
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
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CareraTheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CareraTheme.gray20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
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
                    Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AxataTextStyle.textBase.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CareraTheme.black,
                      ),
                    ),
                    6.gap,
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: CareraTheme.gray60,
                        ),
                        6.wGap,
                        Expanded(
                          child: Text(
                            AppFormatHelper.formatDateTime(
                              receipt.purchaseDate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AxataTextStyle.textSm.copyWith(
                              color: CareraTheme.gray60,
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.gap,
                    Text(
                      AppFormatHelper.formatRupiah(receipt.totalAmount),
                      style: AxataTextStyle.textLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CareraTheme.black,
                      ),
                    ),
                    10.gap,
                    Wrap(
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
                          backgroundColor: CareraTheme.turquoise30,
                          iconColor: CareraTheme.mainColor,
                          textColor: CareraTheme.gray90,
                        ),
                      ],
                    ),
                    if (onQuickExport != null) ...[
                      10.gap,
                      _buildQuickExportButton(),
                    ],
                  ],
                ),
              ),
              8.wGap,
              const Icon(
                Icons.chevron_right,
                color: CareraTheme.gray40,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final imagePath = receipt.imagePath?.trim();

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);

      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: CareraTheme.turquoise30,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        color: CareraTheme.mainColor,
        size: 28,
      ),
    );
  }

  Widget _buildQuickExportButton() {
    return InkWell(
      onTap: onQuickExport,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: CareraTheme.orange20,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ios_share_rounded,
              size: 15,
              color: CareraTheme.orange100,
            ),
            6.wGap,
            Text(
              'Export cepat',
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.orange100,
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
