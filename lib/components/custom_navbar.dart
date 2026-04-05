import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/controllers/page_index_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class CustomBottomNavigationBar extends GetView<PageIndexController> {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomOffset = 10.h;
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: 110.h,
      width: size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: bottomOffset,
            child: Obx(() {
              final currentIndex = controller.pageIndex.value;

              return Container(
                height: 65.h,
                width: size.width - 20.w,
                decoration: BoxDecoration(
                  color: CareraTheme.white,
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: CareraTheme.mainColor,
                    width: 0.7,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CareraTheme.black.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _NavIconButton(
                      icon: FontAwesomeIcons.home,
                      label: 'Beranda',
                      isActive: currentIndex == 0,
                      onTap: () => controller.changePage(0),
                    ),
                    _NavIconButton(
                      icon: FontAwesomeIcons.shieldAlt,
                      label: 'Garansi',
                      isActive: currentIndex == 1,
                      onTap: () => controller.changePage(1),
                    ),
                    const SizedBox(width: 60),
                    _NavIconButton(
                      icon: FontAwesomeIcons.crown,
                      label: 'Premium',
                      isActive: currentIndex == 3,
                      onTap: () => controller.changePage(3),
                    ),
                    _NavIconButton(
                      icon: FontAwesomeIcons.cog,
                      label: 'Pengaturan',
                      isActive: currentIndex == 4,
                      onTap: () => controller.changePage(4),
                    ),
                  ],
                ),
              );
            }),
          ),
          Positioned(
            bottom: 22.5.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'receiptKeeperScanFab',
                  onPressed: _showCreateReceiptSheet,
                  backgroundColor: CareraTheme.mainColor,
                  elevation: 4,
                  child: Icon(
                    FontAwesomeIcons.camera,
                    size: 22.r,
                    color: Colors.white,
                  ),
                ),
                10.verticalSpace,
                Text(
                  'SCAN',
                  style: AxataTextStyle.textXlBold.copyWith(
                    color: CareraTheme.mainColor,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateReceiptSheet() {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: CareraTheme.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 90.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: CareraTheme.gray20,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              18.verticalSpace,
              Text(
                'Tambah Struk',
                style: AxataTextStyle.text2xl.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CareraTheme.black,
                ),
              ),
              6.verticalSpace,
              Text(
                'Pilih cara yang paling nyaman untuk menyimpan struk baru.',
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                  height: 1.4,
                ),
              ),
              16.verticalSpace,
              _CreateReceiptActionTile(
                title: 'Scan dari Kamera',
                description: 'Cocok jika struk masih ada di tangan Anda.',
                icon: Icons.camera_alt_outlined,
                iconBackground: CareraTheme.turquoise30,
                iconColor: CareraTheme.mainColor,
                onTap: () {
                  Get.back();
                  controller.openScanReceipt(initialSource: 'camera');
                },
              ),
              12.verticalSpace,
              _CreateReceiptActionTile(
                title: 'Pilih dari Galeri',
                description: 'Gunakan foto struk yang sudah tersimpan.',
                icon: Icons.photo_library_outlined,
                iconBackground: CareraTheme.orange20,
                iconColor: CareraTheme.orange100,
                onTap: () {
                  Get.back();
                  controller.openScanReceipt(initialSource: 'gallery');
                },
              ),
              12.verticalSpace,
              _CreateReceiptActionTile(
                title: 'Input Manual',
                description: 'Isi data struk sendiri tanpa foto terlebih dulu.',
                icon: Icons.edit_note_outlined,
                iconBackground: CareraTheme.gray5,
                iconColor: CareraTheme.gray80,
                onTap: () {
                  Get.back();
                  controller.openManualReceipt();
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = CareraTheme.mainColor;
    final Color inactiveColor = CareraTheme.mainColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 10.w : 6.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? CareraTheme.mainColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 20.r : 18.r,
              color: isActive ? activeColor : inactiveColor,
            ),
            4.h.verticalSpace,
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AxataTextStyle.textXs.copyWith(
                fontSize: 10.sp,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateReceiptActionTile extends StatelessWidget {
  const _CreateReceiptActionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: CareraTheme.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: CareraTheme.gray20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22.r,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AxataTextStyle.textBase.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CareraTheme.black,
                      ),
                    ),
                    4.verticalSpace,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: CareraTheme.gray60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
