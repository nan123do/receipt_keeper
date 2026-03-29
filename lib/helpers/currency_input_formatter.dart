import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({
    this.symbol = '',
    String locale = 'en_US',
    this.allowDecimal = false,
    this.maxFractionDigits = 0,
    this.allowEmpty = false,
  })  : _intFormat = NumberFormat('#,##0', locale),
        _symbols = NumberFormat.decimalPattern(locale).symbols;

  /// Mis. '' | '$' | 'Rp ' | '€ '
  final String symbol;

  /// true => boleh desimal (.,)
  final bool allowDecimal;

  /// Maks digit desimal (kalau allowDecimal=true)
  final int maxFractionDigits;

  /// true => kalau kosong, biarkan '' (bukan jadi 0)
  final bool allowEmpty;

  final NumberFormat _intFormat;
  final NumberSymbols _symbols;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // text mentah tanpa symbol prefix (kalau ada)
    var input = newValue.text;
    if (symbol.isNotEmpty && input.startsWith(symbol)) {
      input = input.substring(symbol.length);
    }

    // Detect delete & apakah old value punya desimal (pakai DECIMAL_SEP locale)
    var oldInput = oldValue.text;
    if (symbol.isNotEmpty && oldInput.startsWith(symbol)) {
      oldInput = oldInput.substring(symbol.length);
    }
    final isDeleting = newValue.text.length < oldValue.text.length;
    final oldHadDecimal =
        allowDecimal && oldInput.contains(_symbols.DECIMAL_SEP);

    // ambil hanya digit + pemisah kandidat
    input = input.replaceAll(RegExp(r'[^0-9,\.]'), '');

    // kalau kosong
    if (input.isEmpty) {
      if (allowEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }
      final text = '${symbol}0';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    String intDigits;
    String fracDigits = '';
    bool hasTrailingDecimalSep = false;

    // FIX UTAMA:
    // kalau sedang delete dan sebelumnya TIDAK punya desimal,
    // jangan pernah interpret separator sebagai desimal.
    final forceIntegerMode = allowDecimal && isDeleting && !oldHadDecimal;

    if (allowDecimal && !forceIntegerMode) {
      final lastDot = input.lastIndexOf('.');
      final lastComma = input.lastIndexOf(',');

      // kalau ada dua-duanya, pakai yang paling kanan sebagai desimal
      if (lastDot >= 0 && lastComma >= 0) {
        final sepIndex = max(lastDot, lastComma);
        hasTrailingDecimalSep = sepIndex == input.length - 1;

        final left = input.substring(0, sepIndex);
        final right =
            sepIndex + 1 <= input.length ? input.substring(sepIndex + 1) : '';

        intDigits = left.replaceAll(RegExp(r'[^0-9]'), '');
        fracDigits = right.replaceAll(RegExp(r'[^0-9]'), '');

        if (maxFractionDigits > 0 && fracDigits.length > maxFractionDigits) {
          fracDigits = fracDigits.substring(0, maxFractionDigits);
        }
      } else {
        final sepIndex = max(lastDot, lastComma);

        if (sepIndex >= 0) {
          hasTrailingDecimalSep = sepIndex == input.length - 1;

          final sepChar = input[sepIndex];
          final left = input.substring(0, sepIndex);
          final right =
              sepIndex + 1 <= input.length ? input.substring(sepIndex + 1) : '';

          final rightDigits = right.replaceAll(RegExp(r'[^0-9]'), '');

          final isProbablyGrouping = sepChar == _symbols.GROUP_SEP &&
              !hasTrailingDecimalSep &&
              maxFractionDigits > 0 &&
              rightDigits.length > maxFractionDigits;

          if (isProbablyGrouping) {
            intDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
          } else {
            intDigits = left.replaceAll(RegExp(r'[^0-9]'), '');
            fracDigits = rightDigits;

            if (maxFractionDigits > 0 &&
                fracDigits.length > maxFractionDigits) {
              fracDigits = fracDigits.substring(0, maxFractionDigits);
            }
          }
        } else {
          intDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
        }
      }
    } else {
      // integer-only (allowDecimal=false atau forceIntegerMode)
      intDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    }

    // int part
    final intValue = intDigits.isEmpty ? 0 : int.parse(intDigits);
    final formattedInt = _intFormat.format(intValue);

    // susun output
    var out = '$symbol$formattedInt';

    // fractional part: tampilkan hanya jika user memang mengetik desimal
    if (!forceIntegerMode &&
        allowDecimal &&
        (hasTrailingDecimalSep || fracDigits.isNotEmpty)) {
      out += _symbols.DECIMAL_SEP;
      out += fracDigits;
    }

    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}
