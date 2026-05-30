import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/layout/layout.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_progress_dots.dart';
import 'package:flutter/material.dart';

class OnboardingTemplate extends StatelessWidget {
  const OnboardingTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.currentIndex,
    required this.total,
    required this.illustration,
    required this.footer,
    this.onSkip,
  });

  final String title;
  final String description;
  final int currentIndex;
  final int total;
  final Widget illustration;
  final Widget footer;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppPagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: onSkip == null
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: onSkip,
                      child: const Text('Pular'),
                    ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  illustration,
                  const SizedBox(height: AppSpacing.s32),
                  Text(
                    title,
                    style: AppTypography.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    description,
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            AppProgressDots(
              total: total,
              currentIndex: currentIndex,
            ),
            const SizedBox(height: AppSpacing.s24),
            footer,
          ],
        ),
      ),
    );
  }
}