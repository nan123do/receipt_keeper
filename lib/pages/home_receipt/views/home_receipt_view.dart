// lib/pages/home_receipt/views/home_receipt_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/Card/receipt_card.dart';
import 'package:receipt_keeper/components/TextField/labeledtextfield.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class HomeReceiptView extends GetView<HomeReceiptController> {
  const HomeReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareraTheme.bgScaffold,
      appBar: CustomAppBar(
        title: '',
        theme: 'withsearch',
        widgetTitle: Text(
          'Galeri Struk',
          style: AxataTextStyle.text2xl.copyWith(
            fontWeight: FontWeight.w600,
            color: CareraTheme.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingPage();
        }

        return RefreshIndicator(
          onRefresh: controller.loadReceipts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: CareraTheme.paddingScaffold,
            children: [
              _buildHeroSection(),
              16.gap,
              _buildSearchField(),
              12.gap,
              _buildToolbar(),
              16.gap,
              if (controller.receiptList.isEmpty) _buildEmptyState(),
              if (controller.receiptList.isNotEmpty)
                ...controller.groupedReceiptSections.map(
                  (section) => _buildSection(section.title, section.items),
                ),
              12.gap,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CareraTheme.bgMainColor,
            CareraTheme.turquoise100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simpan struk lebih rapi',
            style: AxataTextStyle.textXl.copyWith(
              color: CareraTheme.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          6.gap,
          Text(
            'Cari lebih cepat, cek garansi lebih mudah, dan export langsung dari satu tempat.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.white.withValues(alpha: 0.95),
            ),
          ),
          14.gap,
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  title: 'Struk',
                  value: '${controller.totalReceiptCount}',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              10.wGap,
              Expanded(
                child: _buildMiniStat(
                  title: 'Garansi',
                  value: '${controller.totalWarrantyCount}',
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          14.gap,
          ButtonFull(
            middleText: 'Scan Struk Baru',
            icon: Icons.document_scanner_outlined,
            bgColor: CareraTheme.white,
            ontap: controller.openScanReceipt,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CareraTheme.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CareraTheme.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: CareraTheme.white,
              size: 18,
            ),
          ),
          10.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AxataTextStyle.textLg.copyWith(
                    color: CareraTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return LabeledTextField(
      controller: controller.searchC,
      hintText: 'Cari nama toko atau catatan',
      prefixIcon: const Icon(
        Icons.search,
        color: CareraTheme.gray60,
      ),
      suffixIcon: Obx(() {
        final hasValue = controller.searchQuery.value.isNotEmpty;

        if (!hasValue) {
          return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: controller.clearSearch,
          icon: const Icon(
            Icons.close,
            color: CareraTheme.gray60,
          ),
        );
      }),
      onChanged: controller.onSearchChanged,
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final total = controller.receiptList.length;
            final text = controller.isSearching
                ? '$total hasil ditemukan'
                : '$total struk tersimpan';

            return Text(
              text,
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray70,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ),
        12.wGap,
        PopupMenuButton<bool>(
          initialValue: controller.latestFirst.value,
          color: CareraTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: controller.changeSortOrder,
          itemBuilder: (context) => const [
            PopupMenuItem<bool>(
              value: true,
              child: Text('Urutkan terbaru'),
            ),
            PopupMenuItem<bool>(
              value: false,
              child: Text('Urutkan terlama'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CareraTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CareraTheme.gray20),
            ),
            child: Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: CareraTheme.gray70,
                  ),
                  6.wGap,
                  Text(
                    controller.sortLabel,
                    style: AxataTextStyle.textSm.copyWith(
                      color: CareraTheme.gray80,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Receipt> receipts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: CareraTheme.turquoise30,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: AxataTextStyle.textBase.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.gray90,
                ),
              ),
              8.wGap,
              Text(
                '${receipts.length}',
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        12.gap,
        ...List.generate(receipts.length, (index) {
          final receipt = receipts[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == receipts.length - 1 ? 0 : 12,
            ),
            child: Dismissible(
              key: ValueKey(
                'receipt_${receipt.id}_${receipt.purchaseDate.toIso8601String()}',
              ),
              background: _buildArchiveSwipeBackground(),
              secondaryBackground: _buildDeleteSwipeBackground(),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await controller.archiveReceipt(receipt);
                  return false;
                }

                if (direction == DismissDirection.endToStart) {
                  await controller.deleteReceipt(receipt);
                  return false;
                }

                return false;
              },
              child: ReceiptCard(
                receipt: receipt,
                itemCount: controller.getItemCount(receipt.id),
                warrantyCount: controller.getWarrantyCount(receipt.id),
                onQuickExport: () => controller.quickExportReceipt(receipt),
                onTap: () => controller.openReceiptDetail(receipt),
              ),
            ),
          );
        }),
        16.gap,
      ],
    );
  }

  Widget _buildArchiveSwipeBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CareraTheme.turquoise100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            color: CareraTheme.white,
          ),
          8.wGap,
          Text(
            'Arsipkan',
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteSwipeBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CareraTheme.red,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Hapus',
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          8.wGap,
          Icon(
            Icons.delete_outline,
            color: CareraTheme.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Obx(() {
      final isSearching = controller.isSearching;

      return Padding(
        padding: const EdgeInsets.only(top: 96),
        child: EmptyState(
          useExpanded: false,
          icon: isSearching
              ? Icons.search_off_rounded
              : Icons.receipt_long_outlined,
          title: isSearching ? 'Struk tidak ditemukan' : 'Belum ada struk',
          message: isSearching
              ? 'Coba kata kunci lain untuk mencari struk Anda.'
              : 'Struk yang Anda simpan akan tampil di sini.',
        ),
      );
    });
  }
}
