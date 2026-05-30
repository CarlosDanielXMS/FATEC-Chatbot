import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PatientHomeHeader extends StatelessWidget {
  const PatientHomeHeader({
    super.key,
    required this.now,
    required this.userName,
    this.onNotificationsPressed,
  });

  final DateTime now;
  final String userName;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final notificationIcon = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Image.asset(
        'assets/icons/tabler-icon-bell.png',
        width: 22,
        height: 22,
        color: AppColors.p05,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            '${_periodGreeting()}, $userName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        if (onNotificationsPressed == null)
          notificationIcon
        else
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              onTap: onNotificationsPressed,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: notificationIcon,
            ),
          ),
      ],
    );
  }

  String _periodGreeting() {
    if (now.hour < 12) return 'Bom dia';
    if (now.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}