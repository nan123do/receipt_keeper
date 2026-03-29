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
          // ───── Pill background bottom bar ─────
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
                      label: 'Dashboard',
                      isActive: currentIndex == 0,
                      onTap: () => controller.changePage(0),
                    ),
                    _NavIconButton(
                      icon: FontAwesomeIcons.thLarge,
                      label: 'Menu',
                      isActive: currentIndex == 1,
                      onTap: () => controller.changePage(1),
                    ),
                    const SizedBox(width: 60), // ruang FAB tengah
                    _NavIconButton(
                      icon: FontAwesomeIcons.fileAlt,
                      label: 'Laporan',
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

          // ───── FAB Penjualan (tengah) ─────
          Positioned(
            bottom: 22.5.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "addPenjualan",
                  onPressed: () => controller.changePage(2),
                  backgroundColor: CareraTheme.mainColor,
                  elevation: 4,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(-1.5, 0),
                      child: Icon(
                        FontAwesomeIcons.shoppingBasket,
                        size: 26.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                10.verticalSpace,
                Text(
                  'PENJUALAN',
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
          horizontal: isActive
              ? label == 'Menu'
                  ? 15.w
                  : 10.w
              : 6.w,
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
