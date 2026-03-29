import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class LabelValueRow extends StatelessWidget {
  const LabelValueRow(
    this.label,
    this.value, {
    super.key,
    this.style,
    this.leadingSpacing = 0.0, // new parameter
  });

  final String label;
  final Widget value; // ➜ bukan String lagi
  final TextStyle? style;
  final double leadingSpacing;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? AxataTextStyle.textBase;
    return Row(
      children: [
        SizedBox(width: leadingSpacing), // apply spacing before label
        Text(label, style: textStyle),
        const Spacer(),
        value, // bisa Text, Icon, Chip, dll.
      ],
    );
  }

  factory LabelValueRow.text(
    String label,
    String value, {
    TextStyle? style,
    double leadingSpacing = 0.0, // include in factory
  }) {
    return LabelValueRow(
      label,
      Text(value, style: style ?? AxataTextStyle.textBase),
      style: style,
      leadingSpacing: leadingSpacing,
    );
  }
}
