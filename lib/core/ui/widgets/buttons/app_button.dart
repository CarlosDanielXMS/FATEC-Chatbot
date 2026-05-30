import 'package:chatbot/core/ui/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum _AppButtonVariant {
  primary,
  secondary,
  text,
}

class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.label,
    required this.onPressed,
    required _AppButtonVariant variant,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  }) : _variant = variant;

  const AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isExpanded = true,
    Widget? icon,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: _AppButtonVariant.primary,
          isLoading: isLoading,
          isExpanded: isExpanded,
          icon: icon,
        );

  const AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isExpanded = true,
    Widget? icon,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: _AppButtonVariant.secondary,
          isLoading: isLoading,
          isExpanded: isExpanded,
          icon: icon,
        );

  const AppButton.text({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isExpanded = false,
    Widget? icon,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: _AppButtonVariant.text,
          isLoading: isLoading,
          isExpanded: isExpanded,
          icon: icon,
        );

  final String label;
  final VoidCallback? onPressed;
  final _AppButtonVariant _variant;
  final bool isLoading;
  final bool isExpanded;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final button = switch (_variant) {
      _AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _AppButtonContent(
            label: label,
            icon: icon,
            isLoading: isLoading,
            isExpanded: isExpanded,
          ),
        ),
      _AppButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _AppButtonContent(
            label: label,
            icon: icon,
            isLoading: isLoading,
            isExpanded: isExpanded,
          ),
        ),
      _AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _AppButtonContent(
            label: label,
            icon: icon,
            isLoading: isLoading,
            isExpanded: isExpanded,
          ),
        ),
    };

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.label,
    required this.isLoading,
    required this.isExpanded,
    this.icon,
  });

  final String label;
  final bool isLoading;
  final bool isExpanded;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(label),
      ],
    );
  }
}