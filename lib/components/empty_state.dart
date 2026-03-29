// lib/components/empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? circleColor;
  final Color? iconColor;

  /// default true supaya tidak merusak halaman-halaman yang sudah mengandalkan Expanded
  final bool useExpanded;

  const EmptyState({
    super.key,
    this.icon = Icons.inventory_2_outlined,
    this.title = 'Belum ada data',
    this.message = 'Belum ada data yang bisa ditampilkan.',
    this.circleColor,
    this.iconColor,
    this.useExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: circleColor ?? CareraTheme.gray60,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36.r,
              color: iconColor ?? CareraTheme.white,
            ),
          ),
          16.gap,
          Text(
            title,
            style: AxataTextStyle.textBaseBold,
            textAlign: TextAlign.center,
          ),
          6.gap,
          Text(
            message,
            textAlign: TextAlign.center,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray60,
            ),
          ),
        ],
      ),
    );

    if (!useExpanded) return child;
    return Expanded(child: child);
  }
}
