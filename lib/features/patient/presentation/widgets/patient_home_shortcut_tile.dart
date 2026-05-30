import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class PatientHomeShortcutTile extends StatelessWidget {
  const PatientHomeShortcutTile._({
    super.key,
    required this.label,
    required this.onTap,
    this.iconAsset,
    this.customIcon,
  });

  const PatientHomeShortcutTile.medications({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          label: 'Medicamentos',
          iconAsset: 'assets/icons/tabler-icon-pill.png',
          onTap: onTap,
        );

  const PatientHomeShortcutTile.alarms({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          label: 'Alarmes',
          iconAsset: 'assets/icons/tabler-icon-alarm.png',
          onTap: onTap,
        );

  const PatientHomeShortcutTile.sideEffects({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          label: 'Efeitos\nadversos',
          customIcon: const _SideEffectsIcon(),
          onTap: onTap,
        );

  final String label;
  final String? iconAsset;
  final Widget? customIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 118,
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              customIcon ??
                  Image.asset(
                    iconAsset!,
                    width: 36,
                    height: 36,
                    color: AppColors.p05,
                  ),
              const Spacer(),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideEffectsIcon extends StatelessWidget {
  const _SideEffectsIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.s01,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '!',
        style: AppTypography.h3.copyWith(
          color: AppColors.s03,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}