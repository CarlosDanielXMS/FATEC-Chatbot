import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppFieldErrorText extends StatelessWidget {
  const AppFieldErrorText(
    this.message, {
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        textAlign: TextAlign.start,
        style: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}