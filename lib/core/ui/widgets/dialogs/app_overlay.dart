import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppOverlay extends StatelessWidget {
  const AppOverlay({
    super.key,
    required this.child,
    this.color = AppColors.overlay,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(child: child),
    );
  }
}