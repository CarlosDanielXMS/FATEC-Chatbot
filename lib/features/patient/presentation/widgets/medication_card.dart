import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:flutter/material.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.medication,
    required this.index,
    required this.onTap,
  });

  final Medication medication;
  final int index;
  final VoidCallback onTap;

  static const _backgroundColors = [
    Color(0xFFE7EDF6),
    Color(0xFFFFEFE0),
    Color(0xFFDDF6DF),
    Color(0xFFFFFEC8),
  ];

  static const _foregroundColors = [
    AppColors.p05,
    Color(0xFFB3361D),
    Color(0xFF137A2D),
    Color(0xFFAD8500),
  ];

  @override
  Widget build(BuildContext context) {
    final colorIndex = index % _backgroundColors.length;
    final backgroundColor = _backgroundColors[colorIndex];
    final foregroundColor = _foregroundColors[colorIndex];

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 82,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s10,
                  AppSpacing.s8,
                  AppSpacing.s8,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/tabler-icon-pill.png',
                      color: foregroundColor,
                      height: 19,
                      width: 19,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        medication.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h3.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0x66000000),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s8,
                  AppSpacing.s12,
                  AppSpacing.s10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (!medication.hasTreatment) {
      return 'Tratamento ainda não configurado';
    }

    return '${medication.dosageLabel} • ${medication.initialTime} • ${medication.durationLabel}';
  }
}