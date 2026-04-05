// lib/pages/home_receipt/views/home_receipt_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/Card/receipt_card.dart';
import 'package:receipt_keeper/components/Filter/date_filter_button.dart';
import 'package:receipt_keeper/components/TextField/labeledtextfield.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/pages/home_receipt/controllers/home_receipt_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class HomeReceiptView extends GetView<HomeReceiptController> {
  const HomeReceiptView({super.key});

  static const Color _pageBackground = Color(0xFFF5F7FB);
  static const Color _headerGradientStart = Color(0xFF1BC3D6);
  static const Color _headerGradientEnd = Color(0xFF0E79B2);
  static const Color _heroGradientStart = Color(0xFF25C7D8);
  static const Color _heroGradientEnd = Color(0xFF0F7EB3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: CareraTheme.paddingScaffold.left,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Galeri Struk',
              style: AxataTextStyle.text2xl.copyWith(
                color: CareraTheme.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Simpan struk dan cek garansi dengan mudah',
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: CareraTheme.paddingScaffold.right,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: controller.openPremiumPage,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  color: CareraTheme.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _headerGradientStart,
                _headerGradientEnd,
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: CareraTheme.white.withValues(alpha: 0.10),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
            padding: EdgeInsets.fromLTRB(
              CareraTheme.paddingScaffold.left,
              14,
              CareraTheme.paddingScaffold.right,
              24,
            ),
            children: [
              _buildHeroSection(),
              if (controller.showExampleInfoCard) ...[
                12.gap,
                _buildExampleInfoCard(),
              ],
              16.gap,
              _buildListHeader(),
              12.gap,
              _buildFilterSection(),
              16.gap,
              if (controller.receiptList.isEmpty) _buildEmptyState(),
              if (controller.receiptList.isNotEmpty)
                ...controller.groupedReceiptSections.map(
                  (section) => _buildSection(section.title, section.items),
                ),
              8.gap,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroSection() {
    final hasData = controller.receiptList.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _heroGradientStart,
            _heroGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F7EB3).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: CareraTheme.white.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: CareraTheme.white,
                ),
                6.wGap,
                Text(
                  hasData ? 'Semua struk Anda ada di sini' : 'Mulai dari sini',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          14.gap,
          Text(
            hasData
                ? 'Tambah struk baru\natau buka struk yang sudah tersimpan'
                : 'Mulai simpan struk pertama Anda',
            style: AxataTextStyle.text2xl.copyWith(
              color: CareraTheme.white,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          8.gap,
          Text(
            hasData
                ? 'Tap salah satu struk di bawah untuk lihat detail, edit, atau export.'
                : 'Scan struk belanja agar tersimpan rapi dan mudah dicari saat dibutuhkan.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.white.withValues(alpha: 0.94),
              height: 1.45,
            ),
          ),
          16.gap,
          ButtonFull(
            middleText: 'Scan Struk Baru',
            icon: Icons.document_scanner_outlined,
            ontap: controller.openScanReceipt,
          ),
          10.gap,
          ButtonFull(
            middleText: 'Input Manual',
            icon: Icons.edit_note_outlined,
            colorOpposite: true,
            ontap: controller.openManualReceipt,
          ),
          16.gap,
          Row(
            children: [
              Expanded(
                child: _buildHeroStatCard(
                  title: 'Total Struk',
                  value: '${controller.totalReceiptCount}',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              10.wGap,
              Expanded(
                child: _buildHeroStatCard(
                  title: 'Total Garansi',
                  value: '${controller.totalWarrantyCount}',
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
          12.gap,
          _buildWarrantyQuickAction(),
        ],
      ),
    );
  }

  Widget _buildHeroStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CareraTheme.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: CareraTheme.white,
              size: 20,
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
                    color: CareraTheme.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyQuickAction() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.openWarrantyPage,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: CareraTheme.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: CareraTheme.white.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CareraTheme.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  color: CareraTheme.white,
                  size: 20,
                ),
              ),
              12.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lihat Garansi',
                      style: AxataTextStyle.textBase.copyWith(
                        color: CareraTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    4.gap,
                    Text(
                      'Cek semua barang yang masih bergaransi',
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.white.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: CareraTheme.white.withValues(alpha: 0.92),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.orange20,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CareraTheme.orange50),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: CareraTheme.orange100,
              size: 18,
            ),
          ),
          10.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sudah ada data contoh',
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.orange100,
                  ),
                ),
                4.gap,
                Text(
                  'Buka data itu untuk melihat contoh struk, item, dan garansi. Anda bisa edit atau hapus kapan saja.',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray80,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          8.wGap,
          InkWell(
            onTap: controller.dismissExampleInfoCard,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: CareraTheme.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: CareraTheme.orange100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Struk Tersimpan',
            style: AxataTextStyle.textLg.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          4.gap,
          Text(
            controller.receiptList.isEmpty
                ? 'Struk yang Anda simpan akan tampil di sini.'
                : 'Tap kartu struk untuk melihat detail, edit, atau export.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cari & Urutkan',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          12.gap,
          _buildSearchField(),
          12.gap,
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DateFilterButton(
                    value: controller.selectedDateFilter.value,
                    onChanged: (value) => controller.applyDateFilter(value),
                  );
                }),
              ),
            ],
          ),
          12.gap,
          _buildToolbar(),
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
            borderRadius: BorderRadius.circular(14),
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
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
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
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: CareraTheme.mainColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              10.wGap,
              Expanded(
                child: Text(
                  title,
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.gray90,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CareraTheme.turquoise20,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: CareraTheme.turquoise60),
                ),
                child: Text(
                  '${receipts.length}',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.mainColor,
                    fontWeight: FontWeight.w700,
                  ),
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
                isExample: controller.isExampleReceipt(receipt),
                onEdit: () => controller.openEditReceipt(receipt),
                onQuickExport: () => controller.quickExportReceipt(receipt),
                onTap: () => controller.openReceiptDetail(receipt),
              ),
            ),
          );
        }),
        18.gap,
      ],
    );
  }

  Widget _buildArchiveSwipeBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CareraTheme.turquoise100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.archive_outlined,
              color: CareraTheme.white,
            ),
          ),
          10.wGap,
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
        borderRadius: BorderRadius.circular(18),
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
          10.wGap,
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CareraTheme.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline,
              color: CareraTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const EmptyState(
            useExpanded: false,
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada struk',
            message:
                'Mulai dengan scan struk baru atau tambahkan struk secara manual.',
          ),
          18.gap,
          ButtonFull(
            middleText: 'Scan Struk Baru',
            icon: Icons.document_scanner_outlined,
            ontap: controller.openScanReceipt,
          ),
          10.gap,
          ButtonFull(
            middleText: 'Input Manual',
            icon: Icons.edit_note_outlined,
            colorOpposite: true,
            ontap: controller.openManualReceipt,
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: CareraTheme.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: CareraTheme.gray20,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
