import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppProgressDots extends StatelessWidget {
  const AppProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) {
          final isActive = index == currentIndex;

          return AnimatedContainer(
            duration: AppDurations.normal,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            width: isActive ? AppSpacing.s24 : AppSpacing.s8,
            height: AppSpacing.s8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          );
        },
      ),
    );
  }
}