// lib/components/TextField/labeledtextfield.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/helpers/currency_input_formatter.dart';
import 'package:receipt_keeper/utils/theme.dart';

class LabeledTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const LabeledTextField({
    super.key,
    this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.currencySymbol = '',
    this.onChanged,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isNumberField = keyboardType == TextInputType.number;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray80,
              fontWeight: FontWeight.w600,
            ),
          ),
          6.gap,
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
          inputFormatters: isNumberField
              ? [
                  CurrencyInputFormatter(
                    symbol: '', // penting: kosong
                    allowDecimal: true,
                    maxFractionDigits: 2, // 20,5 / 20,55
                    allowEmpty: true,
                  ),
                ]
              : [],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray50,
            ),
            labelText: null,
            contentPadding: EdgeInsets.all(10.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: CareraTheme.gray30),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
