import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

class AppGoogleButton extends StatelessWidget {
  const AppGoogleButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue com o Google',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      label: isLoading ? 'Entrando...' : label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: isLoading
          ? null
          : Image.asset(
              'assets/icons/tabler-icon-google.png',
              width: 20,
              height: 20,
            ),
    );
  }
}