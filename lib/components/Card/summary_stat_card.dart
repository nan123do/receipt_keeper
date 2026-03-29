import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/helpers/number_helper.dart';
import 'package:receipt_keeper/utils/theme.dart';

class SummaryStatCard extends StatelessWidget {
  final int value;
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  final bool isRupiah;

  const SummaryStatCard({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    required this.icon,
    this.gradientColors,
    this.isRupiah = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              [
                CareraTheme.bgMainColor,
                CareraTheme.mainColor,
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: CareraTheme.gray40,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40.r,
            width: 40.r,
            // padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              size: 14.r,
              color: CareraTheme.white,
            ),
          ),
          12.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isRupiah ? 'Rp ' : ''}${NumberHelper.toCurrencyString(value)}',
                  style: AxataTextStyle.text4xl.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.white,
                  ),
                ),
                2.gap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AxataTextStyle.textSm.copyWith(
                        color: CareraTheme.white,
                      ),
                    ),

                    // Subtitle di kanan, bisa 2 baris
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: AxataTextStyle.textSm.copyWith(
                            color: CareraTheme.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
