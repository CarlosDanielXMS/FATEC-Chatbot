import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}