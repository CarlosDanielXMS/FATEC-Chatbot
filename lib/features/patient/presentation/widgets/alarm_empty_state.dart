import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AlarmEmptyState extends StatelessWidget {
  const AlarmEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Text(
          'Você não possui alarmes definidos.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}