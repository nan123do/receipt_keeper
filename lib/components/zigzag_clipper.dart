import 'package:flutter/material.dart';

class ZigZagClipper extends CustomClipper<Path> {
  final double zigzagSize;

  ZigZagClipper({this.zigzagSize = 10});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double z = zigzagSize;

    // --- TOP (zigzag) ---
    path.moveTo(0, 0);
    final int topCount = (size.width / z).floor();
    for (int i = 0; i < topCount; i++) {
      final double x = i * z;
      path.lineTo(x + z / 2, z); // turun
      path.lineTo(x + z, 0); // naik lagi ke garis atas
    }
    // kalau masih sisa lebar, tarik lurus
    path.lineTo(size.width, 0);

    // --- SIDE RIGHT ---
    path.lineTo(size.width, size.height);

    // --- BOTTOM (zigzag) ---
    final int bottomCount = (size.width / z).floor();
    for (int i = 0; i < bottomCount; i++) {
      final double x = size.width - i * z;
      path.lineTo(x - z / 2, size.height - z); // naik
      path.lineTo(x - z, size.height); // turun lagi ke bawah
    }
    path.lineTo(0, size.height);

    // --- SIDE LEFT ---
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ZigZagClipper oldClipper) =>
      oldClipper.zigzagSize != zigzagSize;
}
