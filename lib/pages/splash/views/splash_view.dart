// lib/pages/splash/views/splash_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/pages/splash/controllers/splash_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareraTheme.bgMainColor,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _AnimatedSplashBackdrop(),
          ),
          Center(
            child: Image.asset(
              'assets/logo/logo.png',
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSplashBackdrop extends StatefulWidget {
  const _AnimatedSplashBackdrop();

  @override
  State<_AnimatedSplashBackdrop> createState() =>
      _AnimatedSplashBackdropState();
}

class _AnimatedSplashBackdropState extends State<_AnimatedSplashBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat(); // loop terus
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashBackdropPainter(repaint: _c),
    );
  }
}

class _SplashBackdropPainter extends CustomPainter {
  final Animation<double> _t;

  _SplashBackdropPainter({required Animation<double> repaint})
      : _t = repaint,
        super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // Base background full
    final base = Paint()..color = CareraTheme.bgMainColor;
    canvas.drawRect(Offset.zero & size, base);

    // Ornamen hanya di bottom 30%
    final bottomH = size.height * 0.30;
    final top = size.height - bottomH;

    double dy(double p) => top + (bottomH * p);

    final main = CareraTheme.mainColor;
    final phase = _t.value * math.pi * 2;

    // helper gelombang
    double wobble({
      required double baseY,
      required double xFactor,
      required double amp,
      double speed = 1.0,
      double offset = 0.0,
    }) {
      return baseY + math.sin(phase * speed + offset + xFactor) * amp;
    }

    // amplitudo (relatif terhadap bottom area)
    final ampBig = bottomH * 0.12;
    final ampSmall = bottomH * 0.08;
    final ampChart = bottomH * 0.06;

    // Layer 1: gelombang besar (bottom)
    final paint1 = Paint()
      ..style = PaintingStyle.fill
      ..color = main.withValues(alpha: 0.18);

    final path1 = Path()
      ..moveTo(
          0, wobble(baseY: dy(0.62), xFactor: 0.0, amp: ampBig, speed: 1.0))
      ..quadraticBezierTo(
        size.width * 0.30,
        wobble(
            baseY: dy(0.40),
            xFactor: 1.2,
            amp: ampBig,
            speed: 1.0,
            offset: 0.6),
        size.width * 0.58,
        wobble(
            baseY: dy(0.65),
            xFactor: 2.2,
            amp: ampBig,
            speed: 1.0,
            offset: 0.2),
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        wobble(
            baseY: dy(0.88),
            xFactor: 3.2,
            amp: ampBig,
            speed: 1.0,
            offset: 0.9),
        size.width,
        wobble(
            baseY: dy(0.48),
            xFactor: 4.0,
            amp: ampBig,
            speed: 1.0,
            offset: 0.4),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);

    // Layer 2: gelombang kecil
    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = main.withValues(alpha: 0.12);

    final path2 = Path()
      ..moveTo(
          0, wobble(baseY: dy(0.30), xFactor: 0.3, amp: ampSmall, speed: 1.25))
      ..quadraticBezierTo(
        size.width * 0.26,
        wobble(
            baseY: dy(0.18),
            xFactor: 1.4,
            amp: ampSmall,
            speed: 1.25,
            offset: 0.7),
        size.width * 0.54,
        wobble(
            baseY: dy(0.34),
            xFactor: 2.6,
            amp: ampSmall,
            speed: 1.25,
            offset: 0.2),
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        wobble(
            baseY: dy(0.52),
            xFactor: 3.6,
            amp: ampSmall,
            speed: 1.25,
            offset: 0.9),
        size.width,
        wobble(
            baseY: dy(0.22),
            xFactor: 4.2,
            amp: ampSmall,
            speed: 1.25,
            offset: 0.4),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint2);

    // Layer 3: titik (ikut naik-turun dikit biar hidup)
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = main.withValues(alpha: 0.16);

    final r = size.shortestSide * 0.018;
    final offsets = <Offset>[
      Offset(size.width * 0.14,
          wobble(baseY: dy(0.12), xFactor: 0.6, amp: ampSmall, speed: 1.4)),
      Offset(
          size.width * 0.30,
          wobble(
              baseY: dy(0.20),
              xFactor: 1.3,
              amp: ampSmall,
              speed: 1.4,
              offset: 0.6)),
      Offset(
          size.width * 0.52,
          wobble(
              baseY: dy(0.10),
              xFactor: 2.2,
              amp: ampSmall,
              speed: 1.4,
              offset: 0.2)),
      Offset(
          size.width * 0.72,
          wobble(
              baseY: dy(0.22),
              xFactor: 3.1,
              amp: ampSmall,
              speed: 1.4,
              offset: 0.9)),
      Offset(
          size.width * 0.86,
          wobble(
              baseY: dy(0.14),
              xFactor: 3.8,
              amp: ampSmall,
              speed: 1.4,
              offset: 0.4)),
    ];
    for (final o in offsets) {
      canvas.drawCircle(o, r, dotPaint);
    }

    // Layer 4: garis halus (grid tipis) — geser dikit
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = main.withValues(alpha: 0.10);

    for (int i = 0; i < 3; i++) {
      final baseY = dy(0.08 + i * 0.18);
      final y = wobble(
          baseY: baseY,
          xFactor: i * 0.8,
          amp: bottomH * 0.015,
          speed: 1.1,
          offset: 0.3);
      final p = Path()
        ..moveTo(size.width * 0.06, y)
        ..quadraticBezierTo(size.width * 0.42, y - 8, size.width * 0.94, y - 2);
      canvas.drawPath(p, linePaint);
    }

    // Layer 5: grafik line chart — ikut “naik turun” halus
    final y1 = wobble(baseY: dy(0.46), xFactor: 0.8, amp: ampChart, speed: 1.0);
    final y2 = wobble(
        baseY: dy(0.30), xFactor: 1.6, amp: ampChart, speed: 1.0, offset: 0.6);
    final y3 = wobble(
        baseY: dy(0.62), xFactor: 2.4, amp: ampChart, speed: 1.0, offset: 0.2);
    final y4 = wobble(
        baseY: dy(0.40), xFactor: 3.0, amp: ampChart, speed: 1.0, offset: 0.9);
    final y5 = wobble(
        baseY: dy(0.22), xFactor: 3.6, amp: ampChart, speed: 1.0, offset: 0.4);
    final y6 = wobble(
        baseY: dy(0.56), xFactor: 4.2, amp: ampChart, speed: 1.0, offset: 0.7);
    final y7 = wobble(
        baseY: dy(0.28), xFactor: 4.8, amp: ampChart, speed: 1.0, offset: 0.1);

    final chartPath = Path()
      ..moveTo(size.width * 0.10, y1)
      ..cubicTo(
          size.width * 0.24, y2, size.width * 0.34, y3, size.width * 0.48, y4)
      ..cubicTo(
          size.width * 0.60, y5, size.width * 0.72, y6, size.width * 0.88, y7);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = main.withValues(alpha: 0.18)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(chartPath, glow);

    final chart = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = main.withValues(alpha: 0.95)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(chartPath, chart);

    final nodePaint = Paint()..color = main.withValues(alpha: 0.95);
    final nodes = <Offset>[
      Offset(size.width * 0.10, y1),
      Offset(size.width * 0.48, y4),
      Offset(size.width * 0.88, y7),
    ];
    for (final n in nodes) {
      canvas.drawCircle(n, 4, nodePaint);
      canvas.drawCircle(n, 8, Paint()..color = main.withValues(alpha: 0.10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
