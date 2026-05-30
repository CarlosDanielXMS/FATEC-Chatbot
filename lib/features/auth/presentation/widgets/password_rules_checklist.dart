import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/validation/validation.dart';
import 'package:flutter/material.dart';

class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({
    super.key,
    this.password,
    this.validationResult,
    this.title = 'A senha deve ter:',
  }) : assert(
          password != null || validationResult != null,
          'Informe password ou validationResult.',
        );

  final String? password;
  final PasswordValidationResult? validationResult;
  final String title;

  PasswordValidationResult get _result {
    if (validationResult != null) {
      return validationResult!;
    }

    return PasswordValidator.validate(password ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        _PasswordRuleItem(
          label: 'Mínimo de 1 letra maiúscula',
          isValid: result.hasUppercase,
        ),
        _PasswordRuleItem(
          label: 'Mínimo de 1 letra minúscula',
          isValid: result.hasLowercase,
        ),
        _PasswordRuleItem(
          label: 'Mínimo de 1 caractere especial',
          isValid: result.hasSpecialChar,
        ),
        _PasswordRuleItem(
          label: 'Mínimo de 1 número',
          isValid: result.hasNumber,
        ),
        _PasswordRuleItem(
          label: 'Mínimo de 8 caracteres',
          isValid: result.hasMinLength,
        ),
      ],
    );
  }
}

class _PasswordRuleItem extends StatelessWidget {
  const _PasswordRuleItem({
    required this.label,
    required this.isValid,
  });

  final String label;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Image.asset(
            isValid
                ? 'assets/icons/tabler-icon-check.png'
                : 'assets/icons/tabler-icon-x.png',
            height: 18,
            width: 18,
            color: isValid ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}