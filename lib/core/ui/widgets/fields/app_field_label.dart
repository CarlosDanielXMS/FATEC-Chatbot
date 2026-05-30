import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    super.key,
    required this.label,
    this.required = false,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTypography.label.copyWith(
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}