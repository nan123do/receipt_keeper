import 'package:flutter/material.dart';
import 'package:receipt_keeper/utils/theme.dart';

class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final double height;
  final Color color;

  const DashedDivider({
    super.key,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.thickness = 1,
    this.height = 16,
    this.color = CareraTheme.gray30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: thickness,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
