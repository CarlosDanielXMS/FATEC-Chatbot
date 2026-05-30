import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class MedicationSelectedNameHeader extends StatelessWidget {
  const MedicationSelectedNameHeader({
    super.key,
    required this.name,
    required this.onEditPressed,
  });

  final String name;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onEditPressed,
          icon: const Icon(
            Icons.edit_outlined,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}