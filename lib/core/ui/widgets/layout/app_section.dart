import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.spacing = AppSpacing.s16,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (title != null) {
      children.add(Text(title!, style: AppTypography.h3));
    }

    if (subtitle != null) {
      children.add(const SizedBox(height: AppSpacing.s8));
      children.add(Text(subtitle!, style: AppTypography.body));
    }

    if (children.isNotEmpty) {
      children.add(SizedBox(height: spacing));
    }

    children.add(child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}