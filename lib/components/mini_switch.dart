import 'package:flutter/material.dart';
import 'package:receipt_keeper/utils/theme.dart';

class MiniSwitch extends StatelessWidget {
  const MiniSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 42, // lebar visual (ganti suka-suka)
    this.height = 24, // tinggi visual
    this.scale = 0.8, // skala isi di dalam kotak
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Switch(
            activeThumbColor: CareraTheme.white,
            activeTrackColor: CareraTheme.mainColor,
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
