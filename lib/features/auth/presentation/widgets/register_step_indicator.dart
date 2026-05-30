import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class RegisterStepIndicator extends StatelessWidget {
  const RegisterStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Passo $currentStep de $totalSteps',
      style: AppTypography.label.copyWith(
        color: AppColors.p05,
      ),
      textAlign: TextAlign.center,
    );
  }
}