import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppVerificationCodeField extends StatelessWidget {
  const AppVerificationCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      style: AppTypography.h2,
      onChanged: onChanged,
      decoration: InputDecoration(
        counterText: '',
        hintText: List.filled(length, '0').join(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
      ),
    );
  }
}