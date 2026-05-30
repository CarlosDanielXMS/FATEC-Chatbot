import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.iconSize = 24,
  });

  final VoidCallback? onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: Image.asset(
        'assets/icons/tabler-icon-arrow-narrow-left.png',
        width: iconSize,
        height: iconSize,
        color: AppColors.textPrimary,
      ),
    );
  }
}