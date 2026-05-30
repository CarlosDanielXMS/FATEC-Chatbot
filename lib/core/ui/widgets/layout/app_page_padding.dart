import 'package:chatbot/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppPagePadding extends StatelessWidget {
  const AppPagePadding({
    super.key,
    required this.child,
    this.horizontal = AppSpacing.s16,
    this.vertical = AppSpacing.s24,
    this.padding,
  });

  final Widget child;
  final double horizontal;
  final double vertical;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical,
          ),
      child: child,
    );
  }
}