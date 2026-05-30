import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/buttons.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.length,
    required this.currentIndex,
    required this.onNextPressed,
    required this.onStartPressed,
    required this.onSkipPressed,
    required this.isLastPage,
    required this.startButtonKey,
  });

  final int length;
  final int currentIndex;
  final VoidCallback onNextPressed;
  final VoidCallback onStartPressed;
  final VoidCallback onSkipPressed;
  final bool isLastPage;
  final GlobalKey startButtonKey;

  static const _nextButtonSize = 56.0;
  static const _startButtonWidth = 210.0;
  static const _startButtonHeight = 51.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnboardingProgressIndicator(
          length: length,
          currentIndex: currentIndex,
        ),
        const SizedBox(height: AppSpacing.s24),
        Row(
          children: [
            TextButton(
              onPressed: isLastPage ? null : onSkipPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, _startButtonHeight),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Pular',
                style: AppTypography.label.copyWith(
                  color: isLastPage ? AppColors.b02 : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            if (isLastPage)
              KeyedSubtree(
                key: startButtonKey,
                child: SizedBox(
                  width: _startButtonWidth,
                  height: _startButtonHeight,
                  child: AppButton.primary(
                    label: 'Comece agora',
                    onPressed: onStartPressed,
                    isExpanded: false,
                  ),
                ),
              )
            else
              SizedBox.square(
                dimension: _nextButtonSize,
                child: ElevatedButton(
                  onPressed: onNextPressed,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.square(_nextButtonSize),
                  ),
                  child: Image.asset(
                    'assets/icons/tabler-icon-chevron-right.png',
                    width: 28,
                    height: 28,
                    color: AppColors.textInverse,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}