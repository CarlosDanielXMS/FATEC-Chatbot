import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class MedicationEmptyState extends StatelessWidget {
  const MedicationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.s16),
          Image.asset(
            'assets/images/searching.png',
            height: 190,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Você não possui remédios cadastrados.\nAdicione para começar a acompanhar',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}