import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class RpPercentToggle extends StatefulWidget {
  /// dipanggil setiap kali user ganti pilihan
  final ValueChanged<String> onChanged;

  /// nilai awal, default "Rp"
  final String initialValue;

  const RpPercentToggle({
    super.key,
    required this.onChanged,
    this.initialValue = 'Rp',
  });

  @override
  // ignore: library_private_types_in_public_api
  _RpPercentToggleState createState() => _RpPercentToggleState();
}

class _RpPercentToggleState extends State<RpPercentToggle> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // helper builder untuk setiap opsi
    Widget buildOption(String label, bool isLeft) {
      final bool isSelected = label == selected;
      return GestureDetector(
        onTap: () {
          setState(() => selected = label);
          widget.onChanged(label);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 15.h,
          ),
          decoration: BoxDecoration(
            color: isSelected ? CareraTheme.mainColor : Colors.white,
            border: Border.all(color: CareraTheme.gray20),
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(10) : Radius.zero,
              right: isLeft ? Radius.zero : const Radius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: AxataTextStyle.textBase.copyWith(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildOption('Rp', true),
        buildOption('%', false),
      ],
    );
  }
}
