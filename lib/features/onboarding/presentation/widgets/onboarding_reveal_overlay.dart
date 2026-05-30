import 'dart:math' as math;
import 'dart:ui';

import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingRevealOverlay extends StatelessWidget {
  const OnboardingRevealOverlay({
    super.key,
    required this.progress,
    required this.origin,
  });

  final double progress;
  final Offset origin;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OnboardingRevealPainter(
          progress: progress.clamp(0.0, 1.0),
          origin: origin,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OnboardingRevealPainter extends CustomPainter {
  const _OnboardingRevealPainter({
    required this.progress,
    required this.origin,
  });

  final double progress;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final maxRadius = _maxDistanceToCorners(size, origin);

    const featherRadius = 56.0;

    final currentRadius = lerpDouble(
      0,
      maxRadius + featherRadius,
      progress,
    )!;

    final currentFeather = math.min(currentRadius, featherRadius);
    final solidRadius = math.max(0.0, currentRadius - currentFeather);

    final rect = Rect.fromCircle(
      center: origin,
      radius: currentRadius,
    );

    final solidStop = currentRadius == 0 ? 0.0 : solidRadius / currentRadius;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1,
        colors: const [
          AppColors.p05,
          AppColors.p05,
          Color(0xFA172B83),
          Color(0xE6172B83),
          Color(0xB3172B83),
          Color(0x40172B83),
          Color(0x00172B83),
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

    canvas.drawCircle(origin, currentRadius, paint);
  }

  double _maxDistanceToCorners(Size size, Offset origin) {
    final distances = <double>[
      (origin - const Offset(0, 0)).distance,
      (origin - Offset(size.width, 0)).distance,
      (origin - Offset(0, size.height)).distance,
      (origin - Offset(size.width, size.height)).distance,
    ];

    distances.sort();
    return distances.last;
  }

  @override
  bool shouldRepaint(covariant _OnboardingRevealPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}