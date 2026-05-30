import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

enum _AppFeedbackStateVariant {
  empty,
  error,
  success,
}

class AppFeedbackState extends StatelessWidget {
  const AppFeedbackState._({
    super.key,
    required this.title,
    required this.description,
    required _AppFeedbackStateVariant variant,
    this.actionLabel,
    this.onActionPressed,
    this.icon,
  }) : _variant = variant;

  const AppFeedbackState.empty({
    Key? key,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Widget? icon,
  }) : this._(
          key: key,
          title: title,
          description: description,
          variant: _AppFeedbackStateVariant.empty,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          icon: icon,
        );

  const AppFeedbackState.error({
    Key? key,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Widget? icon,
  }) : this._(
          key: key,
          title: title,
          description: description,
          variant: _AppFeedbackStateVariant.error,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          icon: icon,
        );

  const AppFeedbackState.success({
    Key? key,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Widget? icon,
  }) : this._(
          key: key,
          title: title,
          description: description,
          variant: _AppFeedbackStateVariant.success,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          icon: icon,
        );

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? icon;
  final _AppFeedbackStateVariant _variant;

  bool get _hasAction {
    return actionLabel?.trim().isNotEmpty == true && onActionPressed != null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? _buildDefaultIcon(),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              description,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (_hasAction) ...[
              const SizedBox(height: AppSpacing.s24),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return switch (_variant) {
      _AppFeedbackStateVariant.empty => const Icon(
          Icons.inbox_outlined,
          size: 64,
        ),
      _AppFeedbackStateVariant.error => const Icon(
          Icons.error_outline,
          size: 64,
        ),
      _AppFeedbackStateVariant.success => const Icon(
          Icons.check_circle_outline,
          size: 72,
        ),
    };
  }

  Widget _buildActionButton() {
    return switch (_variant) {
      _AppFeedbackStateVariant.empty ||
      _AppFeedbackStateVariant.success =>
        AppButton.primary(
          label: actionLabel!,
          onPressed: onActionPressed,
          isExpanded: false,
        ),
      _AppFeedbackStateVariant.error => AppButton.secondary(
          label: actionLabel!,
          onPressed: onActionPressed,
          isExpanded: false,
        ),
    };
  }
}