// lib/pages/premium/views/premium_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/pages/premium/controllers/premium_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';
import 'package:receipt_keeper/components/custom_navbar.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        extendBody: true,
        appBar: const CustomAppBar(
          title: 'Premium',
          theme: 'normal',
          showBackButton: false,
        ),
        bottomNavigationBar: const SafeArea(child: CustomBottomNavigationBar()),
        body: controller.isLoading.value
            ? const LoadingPage()
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  CareraTheme.paddingScaffold.left,
                  16,
                  CareraTheme.paddingScaffold.right,
                  24,
                ),
                children: [
                  _buildHeroCard(),
                  16.gap,
                  _buildBenefitCard(),
                  16.gap,
                  _buildProductSection(),
                  16.gap,
                  _buildPlanComparisonCard(),
                  if (controller.storeMessage.value.trim().isNotEmpty) ...[
                    16.gap,
                    _buildStoreMessageCard(),
                  ],
                  if (controller.notFoundProductIds.isNotEmpty) ...[
                    16.gap,
                    _buildNotFoundProductCard(),
                  ],
                  16.gap,
                  _buildRestoreInfoCard(),
                  20.gap,
                  ButtonFull(
                    middleText: controller.upgradeButtonText,
                    icon: Icons.workspace_premium_outlined,
                    readOnly: controller.isPremiumActive.value ||
                        controller.isPurchasing.value ||
                        !controller.isStoreAvailable.value ||
                        controller.isLoadingProducts.value ||
                        controller.selectedProduct == null,
                    ontap: controller.isPremiumActive.value ||
                            controller.isPurchasing.value ||
                            !controller.isStoreAvailable.value ||
                            controller.isLoadingProducts.value ||
                            controller.selectedProduct == null
                        ? null
                        : controller.purchaseSelectedProduct,
                  ),
                  10.gap,
                  ButtonFull(
                    middleText: controller.isRestoring.value
                        ? 'Memulihkan Pembelian...'
                        : 'Restore Pembelian',
                    icon: Icons.restore_outlined,
                    colorOpposite: true,
                    readOnly: controller.isRestoring.value ||
                        !controller.isStoreAvailable.value,
                    ontap: controller.isRestoring.value ||
                            !controller.isStoreAvailable.value
                        ? null
                        : controller.restorePremium,
                  ),
                  120.gap,
                ],
              ),
      );
    });
  }

  Widget _buildHeroCard() {
    final isPremium = controller.isPremiumActive.value;
    final selectedProduct = controller.selectedProduct;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? [
                  CareraTheme.turquoise20,
                  CareraTheme.white,
                ]
              : [
                  const Color(0xFFFFF6E8),
                  CareraTheme.white,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPremium ? CareraTheme.gray20 : CareraTheme.orange30,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isPremium
                  ? CareraTheme.mainColor.withValues(alpha: 0.12)
                  : CareraTheme.orange20,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              controller.statusTitle,
              style: AxataTextStyle.textSm.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    isPremium ? CareraTheme.mainColor : CareraTheme.orange100,
              ),
            ),
          ),
          14.gap,
          Text(
            isPremium
                ? 'Semua fitur premium sudah terbuka'
                : 'Buka batas gratis dan pakai fitur premium',
            style: AxataTextStyle.textXl.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
              height: 1.25,
            ),
          ),
          8.gap,
          Text(
            controller.statusDescription,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.45,
            ),
          ),
          if (!isPremium && selectedProduct != null) ...[
            14.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CareraTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CareraTheme.gray20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sell_outlined,
                    color: CareraTheme.mainColor,
                    size: 20,
                  ),
                  10.wGap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProduct.title,
                          style: AxataTextStyle.textSm.copyWith(
                            color: CareraTheme.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        4.gap,
                        Text(
                          selectedProduct.price,
                          style: AxataTextStyle.textBase.copyWith(
                            color: CareraTheme.mainColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPremium &&
              controller.activeProductId.value.trim().isNotEmpty) ...[
            14.gap,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CareraTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CareraTheme.gray20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: CareraTheme.green,
                    size: 20,
                  ),
                  10.wGap,
                  Expanded(
                    child: Text(
                      'Product aktif: ${controller.activeProductId.value}',
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefit premium',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          12.gap,
          _buildBenefitRow(
            icon: Icons.notifications_active_outlined,
            title: 'Pengingat garansi per produk',
            description:
                'Aktifkan notifikasi agar Anda tidak telat klaim saat garansi hampir habis.',
          ),
          12.gap,
          _buildBenefitRow(
            icon: Icons.document_scanner_outlined,
            title: 'OCR lebih leluasa',
            description:
                'Scan OCR otomatis lebih sering tanpa cepat kehabisan kuota bulanan.',
          ),
          12.gap,
          _buildBenefitRow(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Export PDF lebih nyaman',
            description:
                'Share PDF struk kapan saja dengan alur yang lebih praktis.',
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pilih paket premium',
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.refreshProducts,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: CareraTheme.turquoise20,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_outlined,
                        size: 16,
                        color: CareraTheme.mainColor,
                      ),
                      6.wGap,
                      Text(
                        'Muat ulang',
                        style: AxataTextStyle.textXs.copyWith(
                          color: CareraTheme.mainColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          14.gap,
          if (controller.isLoadingProducts.value)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CareraTheme.gray5,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CareraTheme.gray20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CareraTheme.mainColor,
                    ),
                  ),
                  12.wGap,
                  Expanded(
                    child: Text(
                      'Sedang memuat paket premium dari store...',
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.gray70,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (!controller.hasProducts)
            const EmptyState(
              useExpanded: false,
              icon: Icons.workspace_premium_outlined,
              title: 'Paket belum tampil',
              message:
                  'Paket premium belum tersedia. Cek product ID atau status produk di store.',
            )
          else
            Column(
              children: controller.availableProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildProductCard(product),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    final isSelected = controller.selectedProductId.value == product.id;

    return GestureDetector(
      onTap: () => controller.selectProduct(product.id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? CareraTheme.turquoise20 : CareraTheme.gray5,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? CareraTheme.mainColor : CareraTheme.gray20,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? CareraTheme.mainColor : CareraTheme.gray40,
                  width: 2,
                ),
                color: isSelected ? CareraTheme.mainColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            12.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AxataTextStyle.textSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CareraTheme.black,
                    ),
                  ),
                  6.gap,
                  Text(
                    product.description.trim().isEmpty
                        ? 'Paket premium Receipt Keeper'
                        : product.description,
                    style: AxataTextStyle.textSm.copyWith(
                      color: CareraTheme.gray70,
                      height: 1.4,
                    ),
                  ),
                  10.gap,
                  Text(
                    product.price,
                    style: AxataTextStyle.textBase.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CareraTheme.mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanComparisonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gratis vs Premium',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          14.gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPlanItem(
                  title: 'Gratis',
                  values: [
                    'Simpan hingga ${controller.freeReceiptLimit} struk',
                    'OCR otomatis hingga ${controller.freeOcrLimit} kali per bulan',
                    'Pengingat garansi belum tersedia',
                    'Export PDF tetap bisa digunakan',
                  ],
                  accentColor: CareraTheme.gray60,
                  backgroundColor: CareraTheme.gray5,
                ),
              ),
              10.wGap,
              Expanded(
                child: _buildPlanItem(
                  title: 'Premium',
                  values: [
                    'Simpan struk tanpa batas',
                    'OCR otomatis tanpa batas per bulan',
                    'Aktifkan pengingat garansi per produk',
                    'Export PDF langsung tanpa batas',
                  ],
                  accentColor: CareraTheme.mainColor,
                  backgroundColor: CareraTheme.turquoise20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreMessageCard() {
    final isError = controller.storeMessage.value
            .toLowerCase()
            .contains('gagal') ||
        controller.storeMessage.value.toLowerCase().contains('belum ditemukan');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF3F3) : CareraTheme.turquoise20,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError ? const Color(0xFFFFD9D9) : CareraTheme.gray20,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            size: 20,
            color: isError ? CareraTheme.red : CareraTheme.mainColor,
          ),
          10.wGap,
          Expanded(
            child: Text(
              controller.storeMessage.value,
              style: AxataTextStyle.textSm.copyWith(
                color: isError ? CareraTheme.red : CareraTheme.gray70,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundProductCard() {
    final joinedIds = controller.notFoundProductIds.join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: CareraTheme.orange100,
          ),
          10.wGap,
          Expanded(
            child: Text(
              'Produk ini belum ditemukan di store: $joinedIds',
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.orange100,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: CareraTheme.gray70,
          ),
          10.wGap,
          Expanded(
            child: Text(
              controller.restoreInfoText,
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray70,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: CareraTheme.turquoise20,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: CareraTheme.mainColor,
            size: 20,
          ),
        ),
        12.wGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AxataTextStyle.textSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.black,
                ),
              ),
              4.gap,
              Text(
                description,
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanItem({
    required String title,
    required List<String> values,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          12.gap,
          ...values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: accentColor,
                  ),
                  8.wGap,
                  Expanded(
                    child: Text(
                      item,
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.black,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
