import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PatientHomeSectionHeader extends StatelessWidget {
  const PatientHomeSectionHeader({
    super.key,
    required this.title,
    this.onActionPressed,
  });

  final String title;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.h2.copyWith(
                  color: AppColors.p05,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
            GestureDetector(
              onTap: onActionPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '›',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.p05,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}