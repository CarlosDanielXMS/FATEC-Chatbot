import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.length,
    required this.currentIndex,
  });

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) {
          final isActive = index == currentIndex;

          return AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
            width: isActive ? 30 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? AppColors.s03 : AppColors.s01,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          );
        },
      ),
    );
  }
}