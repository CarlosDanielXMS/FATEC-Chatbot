import 'dart:math' as math;
import 'dart:ui';

import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SplashGradientBackground extends StatelessWidget {
  const SplashGradientBackground({
    super.key,
    required this.revealProgress,
    required this.child,
  });

  final double revealProgress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashGradientBackgroundPainter(
        revealProgress: revealProgress.clamp(0.0, 1.0),
      ),
      child: child,
    );
  }
}

class _SplashGradientBackgroundPainter extends CustomPainter {
  const _SplashGradientBackgroundPainter({
    required this.revealProgress,
  });

  final double revealProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseGradient(canvas, size);

    if (revealProgress <= 0) return;

    _paintCircularReveal(canvas, size);
  }

  void _paintBaseGradient(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.s01,
        AppColors.background,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintCircularReveal(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final maxRadius = math.sqrt(
      math.pow(size.width / 2, 2) + math.pow(size.height / 2, 2),
    );

    const maxFeatherRadius = 72.0;

    final currentRadius = lerpDouble(
      0,
      maxRadius + maxFeatherRadius,
      revealProgress,
    )!;

    final currentFeather = math.min(currentRadius, maxFeatherRadius);

    final solidRadius = math.max(0.0, currentRadius - currentFeather);

    final rect = Rect.fromCircle(
      center: center,
      radius: currentRadius,
    );

    final solidStop = currentRadius == 0 ? 0.0 : solidRadius / currentRadius;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
          Color(0xFCFFFFFF),
          Color(0xEFFFFFFF),
          Color(0xB3FFFFFF),
          Color(0x33FFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: [
          0.0,
          solidStop,
          (solidStop + (1 - solidStop) * 0.30).clamp(0.0, 1.0),
          (solidStop + (1 - solidStop) * 0.55).clamp(0.0, 1.0),
          (solidStop + (1 - solidStop) * 0.78).clamp(0.0, 1.0),
          (solidStop + (1 - solidStop) * 0.92).clamp(0.0, 1.0),
          1.0,
        ],
      ).createShader(rect);

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(
    covariant _SplashGradientBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.revealProgress != revealProgress;
  }
}