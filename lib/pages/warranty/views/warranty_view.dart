// lib/pages/warranty/views/warranty_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Card/warranty_card.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/empty_state.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/pages/warranty/controllers/warranty_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class WarrantyView extends GetView<WarrantyController> {
  const WarrantyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Garansi',
          theme: 'normal',
        ),
        body: controller.isLoading.value
            ? const LoadingPage()
            : SafeArea(
                child: Padding(
                  padding: CareraTheme.paddingScaffold,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      16.gap,
                      _buildFilterCard(),
                      16.gap,
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.loadWarranties,
                          child: controller.hasFilteredData
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: controller.groupedSections
                                      .map(_buildSection)
                                      .toList(),
                                )
                              : ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 80),
                                    EmptyState(
                                      useExpanded: false,
                                      icon: Icons.verified_outlined,
                                      title: controller.emptyTitle,
                                      message: controller.emptyMessage,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CareraTheme.turquoise20,
            CareraTheme.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pantau garansi dengan lebih rapi',
            style: AxataTextStyle.textLg.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          6.gap,
          Text(
            'Garansi yang paling mendesak tampil lebih dulu supaya tidak terlewat.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.4,
            ),
          ),
          14.gap,
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Total',
                  value: '${controller.totalCount}',
                  icon: Icons.verified_outlined,
                  backgroundColor: CareraTheme.white,
                  iconColor: CareraTheme.mainColor,
                ),
              ),
              10.wGap,
              Expanded(
                child: _buildStatItem(
                  title: 'Mendesak',
                  value: '${controller.expiringSoonCount}',
                  icon: Icons.schedule_outlined,
                  backgroundColor: CareraTheme.orange20,
                  iconColor: CareraTheme.orange100,
                ),
              ),
              10.wGap,
              Expanded(
                child: _buildStatItem(
                  title: 'Habis',
                  value: '${controller.expiredCount}',
                  icon: Icons.error_outline,
                  backgroundColor: const Color(0xFFFFF1F4),
                  iconColor: CareraTheme.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          8.gap,
          Text(
            value,
            style: AxataTextStyle.textLg.copyWith(
              color: CareraTheme.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          2.gap,
          Text(
            title,
            style: AxataTextStyle.textXs.copyWith(
              color: CareraTheme.gray70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Garansi',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          4.gap,
          Text(
            controller.resultLabel,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
            ),
          ),
          12.gap,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.filterOptions.map((filter) {
              final isSelected = controller.selectedFilter.value == filter;

              return InkWell(
                onTap: () => controller.applyFilter(filter),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CareraTheme.turquoise30
                        : CareraTheme.gray5,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? CareraTheme.turquoise60
                          : CareraTheme.gray20,
                    ),
                  ),
                  child: Text(
                    controller.getFilterLabel(filter),
                    style: AxataTextStyle.textSm.copyWith(
                      color: isSelected
                          ? CareraTheme.mainColor
                          : CareraTheme.gray80,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(WarrantySection section) {
    final sectionStyle = _getSectionStyle(section.type);

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
                  color: sectionStyle.accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              10.wGap,
              Expanded(
                child: Text(
                  section.title,
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
                  color: sectionStyle.badgeBackgroundColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: sectionStyle.badgeBorderColor),
                ),
                child: Text(
                  '${section.items.length}',
                  style: AxataTextStyle.textSm.copyWith(
                    color: sectionStyle.badgeTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        12.gap,
        ...List.generate(section.items.length, (index) {
          final warranty = section.items[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == section.items.length - 1 ? 0 : 12,
            ),
            child: WarrantyCard(
              warranty: warranty,
              subtitle: controller.getStoreCaption(warranty),
              onTap: () => controller.openReceiptDetail(warranty),
            ),
          );
        }),
        18.gap,
      ],
    );
  }

  _WarrantySectionStyle _getSectionStyle(WarrantyFilterType type) {
    switch (type) {
      case WarrantyFilterType.all:
      case WarrantyFilterType.active:
        return _WarrantySectionStyle(
          accentColor: CareraTheme.turquoise100,
          badgeBackgroundColor: CareraTheme.turquoise20,
          badgeBorderColor: CareraTheme.turquoise60,
          badgeTextColor: CareraTheme.mainColor,
        );
      case WarrantyFilterType.expiringSoon:
        return const _WarrantySectionStyle(
          accentColor: CareraTheme.orange100,
          badgeBackgroundColor: CareraTheme.orange20,
          badgeBorderColor: CareraTheme.orange50,
          badgeTextColor: CareraTheme.orange100,
        );
      case WarrantyFilterType.expired:
        return _WarrantySectionStyle(
          accentColor: CareraTheme.red,
          badgeBackgroundColor: const Color(0xFFFFF1F4),
          badgeBorderColor: CareraTheme.red.withValues(alpha: 0.35),
          badgeTextColor: CareraTheme.red,
        );
    }
  }
}

class _WarrantySectionStyle {
  final Color accentColor;
  final Color badgeBackgroundColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;

  const _WarrantySectionStyle({
    required this.accentColor,
    required this.badgeBackgroundColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
  });
}
