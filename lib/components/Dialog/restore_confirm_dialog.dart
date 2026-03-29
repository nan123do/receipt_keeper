import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

class RestoreConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? description;

  /// Label tombol aksi (misal: "Restore", "Lanjut")
  final String actionText;

  /// Optional: ganti icon (default: restore)
  final IconData icon;

  const RestoreConfirmDialog({
    super.key,
    this.title = 'Restore Data',
    this.message = 'Restore akan menimpa data saat ini. Lanjutkan?',
    this.description,
    this.actionText = 'Restore',
    this.icon = Icons.restore_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 18.h,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header icon + title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: CareraTheme.mainColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: CareraTheme.mainColor,
                  size: 22.r,
                ),
              ),
              10.wGap,
              Expanded(
                child: Text(
                  title,
                  style: AxataTextStyle.textBaseBold,
                ),
              ),
            ],
          ),
          14.gap,

          Text(
            message,
            style: AxataTextStyle.textSm,
          ),

          if (description != null && description!.isNotEmpty) ...[
            6.gap,
            Text(
              description!,
              style: AxataTextStyle.textXs.copyWith(
                color: CareraTheme.gray60,
              ),
            ),
          ],

          12.gap,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Batal',
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                  ),
                ),
              ),
              8.wGap,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CareraTheme.mainColor,
                  foregroundColor: CareraTheme.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  actionText,
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
