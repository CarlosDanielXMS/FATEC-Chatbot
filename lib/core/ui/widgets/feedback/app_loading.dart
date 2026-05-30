import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
  });

  final String? message;

  bool get _hasMessage => message?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (_hasMessage) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              message!,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}