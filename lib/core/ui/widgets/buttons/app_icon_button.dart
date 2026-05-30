import 'package:chatbot/core/ui/theme/app_radius.dart';
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  bool get _hasTooltip => tooltip?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: SizedBox.square(
          dimension: size,
          child: Center(child: icon),
        ),
      ),
    );

    if (!_hasTooltip) return button;

    return Tooltip(
      message: tooltip!,
      child: button,
    );
  }
}