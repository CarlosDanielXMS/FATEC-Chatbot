import 'package:chatbot/core/ui/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppStepIndicator extends StatelessWidget {
  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Etapa $currentStep de $totalSteps',
      style: AppTypography.body,
    );
  }
}