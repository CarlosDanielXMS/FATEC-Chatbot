import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

enum RegisterUserType {
  patient,
  professional,
}

class RegisterUserTypeSwitch extends StatelessWidget {
  const RegisterUserTypeSwitch({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final RegisterUserType selectedType;
  final ValueChanged<RegisterUserType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.p05,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchItem(
              label: 'Paciente',
              selected: selectedType == RegisterUserType.patient,
              onTap: () => onChanged(RegisterUserType.patient),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _SwitchItem(
              label: 'Profissional',
              selected: selectedType == RegisterUserType.professional,
              onTap: () => onChanged(RegisterUserType.professional),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.p05 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: selected ? AppColors.textInverse : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}