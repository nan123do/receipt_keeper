// lib/components/receipt_preview_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class ReceiptPreviewBottomSheet extends StatelessWidget {
  const ReceiptPreviewBottomSheet({
    super.key,
    required this.receipt,
    required this.items,
    required this.warranties,
    this.isExample = false,
    this.onEdit,
    this.onQuickExport,
  });

  final Receipt receipt;
  final List<ReceiptItem> items;
  final List<Warranty> warranties;
  final bool isExample;
  final VoidCallback? onEdit;
  final VoidCallback? onQuickExport;

  @override
  Widget build(BuildContext context) {
    final storeName = (receipt.storeName ?? '').trim().isEmpty
        ? 'Tanpa nama toko'
        : receipt.storeName!.trim();

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: CareraTheme.paddingScaffold,
        decoration: BoxDecoration(
          color: CareraTheme.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 4,
              decoration: BoxDecoration(
                color: CareraTheme.gray20,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            18.gap,
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isExample) _buildExampleInfoCard(),
                    if (isExample) 14.gap,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            storeName,
                            style: AxataTextStyle.text2xl.copyWith(
                              fontWeight: FontWeight.w700,
                              color: CareraTheme.black,
                            ),
                          ),
                        ),
                        10.wGap,
                        InkWell(
                          onTap: Get.back,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CareraTheme.gray10,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: CareraTheme.gray70,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.gap,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          icon: Icons.shopping_bag_outlined,
                          text: '${items.length} item',
                          backgroundColor: CareraTheme.gray5,
                          iconColor: CareraTheme.gray70,
                          textColor: CareraTheme.gray80,
                        ),
                        _buildBadge(
                          icon: Icons.verified_outlined,
                          text: '${warranties.length} garansi',
                          backgroundColor: CareraTheme.turquoise30,
                          iconColor: CareraTheme.mainColor,
                          textColor: CareraTheme.gray90,
                        ),
                      ],
                    ),
                    16.gap,
                    _buildInfoCard(),
                    16.gap,
                    _buildSectionTitle('Daftar Item'),
                    10.gap,
                    if (items.isEmpty)
                      _buildEmptyText('Belum ada item pada struk ini.'),
                    if (items.isNotEmpty)
                      ...List.generate(items.length, (index) {
                        final item = items[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == items.length - 1 ? 0 : 10,
                          ),
                          child: _buildItemCard(item),
                        );
                      }),
                    16.gap,
                    _buildSectionTitle('Garansi'),
                    10.gap,
                    if (warranties.isEmpty)
                      _buildEmptyText(
                          'Belum ada produk bergaransi pada struk ini.'),
                    if (warranties.isNotEmpty)
                      ...List.generate(warranties.length, (index) {
                        final warranty = warranties[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == warranties.length - 1 ? 0 : 10,
                          ),
                          child: _buildWarrantyCard(warranty),
                        );
                      }),
                    if (onEdit != null || onQuickExport != null) ...[
                      20.gap,
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (onEdit != null)
                            _buildActionButton(
                              onTap: onEdit,
                              icon: Icons.edit_outlined,
                              text: 'Edit Struk',
                              backgroundColor: CareraTheme.turquoise30,
                              iconColor: CareraTheme.mainColor,
                              textColor: CareraTheme.mainColor,
                            ),
                          if (onQuickExport != null)
                            _buildActionButton(
                              onTap: onQuickExport,
                              icon: Icons.ios_share_rounded,
                              text: 'Export Cepat',
                              backgroundColor: CareraTheme.orange20,
                              iconColor: CareraTheme.orange100,
                              textColor: CareraTheme.orange100,
                            ),
                        ],
                      ),
                    ],
                    10.gap,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.orange20,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.orange50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: CareraTheme.orange100,
            size: 20,
          ),
          10.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ini data contoh bawaan aplikasi',
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.orange100,
                  ),
                ),
                4.gap,
                Text(
                  'Tujuannya agar pengguna baru bisa langsung melihat bentuk struk, item, dan garansi.',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray80,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Beli',
            value: AppFormatHelper.formatDateTime(receipt.purchaseDate),
          ),
          10.gap,
          _buildInfoRow(
            icon: Icons.payments_outlined,
            label: 'Total Belanja',
            value: AppFormatHelper.formatRupiah(receipt.totalAmount),
          ),
          10.gap,
          _buildInfoRow(
            icon: Icons.note_alt_outlined,
            label: 'Catatan',
            value: (receipt.note ?? '').trim().isEmpty
                ? '-'
                : receipt.note!.trim(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: CareraTheme.gray70,
        ),
        10.wGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray60,
                ),
              ),
              2.gap,
              Text(
                value,
                style: AxataTextStyle.textBase.copyWith(
                  color: CareraTheme.gray90,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AxataTextStyle.textBase.copyWith(
        fontWeight: FontWeight.w700,
        color: CareraTheme.black,
      ),
    );
  }

  Widget _buildEmptyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Text(
        text,
        style: AxataTextStyle.textSm.copyWith(
          color: CareraTheme.gray70,
        ),
      ),
    );
  }

  Widget _buildItemCard(ReceiptItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CareraTheme.turquoise30,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: CareraTheme.mainColor,
            ),
          ),
          10.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CareraTheme.black,
                  ),
                ),
                4.gap,
                Text(
                  '${_formatQty(item.qty)} x ${AppFormatHelper.formatRupiah(item.unitPrice)}',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                  ),
                ),
              ],
            ),
          ),
          10.wGap,
          Text(
            AppFormatHelper.formatRupiah(item.subtotal),
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyCard(Warranty warranty) {
    final statusText = AppFormatHelper.formatWarrantyStatus(warranty.daysLeft);
    final daysLeftText = AppFormatHelper.formatWarrantyDaysLeft(
      warranty.daysLeft,
    );

    final Color badgeBgColor;
    final Color badgeTextColor;

    if (warranty.isExpired) {
      badgeBgColor = CareraTheme.red.withValues(alpha: 0.12);
      badgeTextColor = CareraTheme.red;
    } else if (warranty.isExpiringSoon) {
      badgeBgColor = CareraTheme.orange20;
      badgeTextColor = CareraTheme.orange100;
    } else {
      badgeBgColor = CareraTheme.turquoise30;
      badgeTextColor = CareraTheme.mainColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  warranty.productName,
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CareraTheme.black,
                  ),
                ),
              ),
              10.wGap,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: AxataTextStyle.textSm.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          10.gap,
          _buildInfoRowSimple(
            label: 'Tanggal Beli',
            value: AppFormatHelper.formatDate(warranty.purchaseDate),
          ),
          6.gap,
          _buildInfoRowSimple(
            label: 'Masa Garansi',
            value: '${warranty.warrantyMonths} bulan',
          ),
          6.gap,
          _buildInfoRowSimple(
            label: 'Habis Pada',
            value: AppFormatHelper.formatDate(warranty.expiryDate),
          ),
          6.gap,
          _buildInfoRowSimple(
            label: 'Status',
            value: daysLeftText,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowSimple({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray60,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray90,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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

  String _formatQty(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
