import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Ekstensi jarak cepat.
/// - 20.h.gap  ➜  SizedBox(height: 20.h)   (tetap ada)
/// - 20.w.wGap ➜  SizedBox(width : 20.w)
extension Gap on num {
  /// Jarak vertikal.
  SizedBox get gap => SizedBox(height: toDouble().h);

  /// Jarak horizontal.
  SizedBox get wGap => SizedBox(width: toDouble().w);
}
