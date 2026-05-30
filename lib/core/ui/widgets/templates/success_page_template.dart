import 'package:chatbot/core/ui/widgets/feedback/app_feedback_state.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class SuccessPageTemplate extends StatelessWidget {
  const SuccessPageTemplate({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppFeedbackState.success(
        title: title,
        description: description,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      ),
    );
  }
}