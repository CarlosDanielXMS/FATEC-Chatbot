import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PreferenceSwitchTile extends StatelessWidget {
  const PreferenceSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.iconAsset,
    this.subtitle,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? iconAsset;
  final String? subtitle;

  bool get _hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            Image.asset(
              iconAsset!,
              width: 22,
              height: 22,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_hasSubtitle) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}