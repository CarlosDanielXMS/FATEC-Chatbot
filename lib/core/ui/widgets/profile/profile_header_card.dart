import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/cards/app_card.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.imageProvider,
    this.onEditPressed,
  });

  final String name;
  final String email;
  final ImageProvider? imageProvider;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: imageProvider,
            backgroundColor: AppColors.b02,
            child: imageProvider == null
                ? Image.asset(
                    'assets/icons/tabler-icon-user.png',
                    width: 32,
                    height: 32,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  email,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              onPressed: onEditPressed,
              icon: Image.asset(
                'assets/icons/tabler-icon-edit.png',
                width: 22,
                height: 22,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}