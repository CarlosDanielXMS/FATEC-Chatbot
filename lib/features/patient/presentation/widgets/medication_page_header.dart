import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MedicationPageHeader extends StatelessWidget {
  const MedicationPageHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showProgress = false,
    this.progressValue = 0.12,
    this.onBackPressed,
  });

  final String title;
  final bool showBackButton;
  final bool showProgress;
  final double progressValue;
  final VoidCallback? onBackPressed;

  static const _height = 48.0;
  static const _progressHeight = 2.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: showBackButton
              ? _MedicationChildHeader(
                  title: title,
                  onBackPressed: onBackPressed ?? context.pop,
                )
              : _MedicationRootHeader(title: title),
        ),
        if (showProgress)
          _MedicationProgressBar(
            value: progressValue,
            height: _progressHeight,
          ),
      ],
    );
  }
}

class _MedicationRootHeader extends StatelessWidget {
  const _MedicationRootHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MedicationChildHeader extends StatelessWidget {
  const _MedicationChildHeader({
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onBackPressed,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _MedicationProgressBar extends StatelessWidget {
  const _MedicationProgressBar({
    required this.value,
    required this.height,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: normalizedValue,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: height,
          child: const ColoredBox(
            color: AppColors.s03,
          ),
        ),
      ),
    );
  }
}