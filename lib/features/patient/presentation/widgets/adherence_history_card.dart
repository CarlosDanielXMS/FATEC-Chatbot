import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:flutter/material.dart';

class AdherenceHistoryCard extends StatelessWidget {
  const AdherenceHistoryCard({
    super.key,
    required this.event,
  });

  final AdherenceEvent event;

  @override
  Widget build(BuildContext context) {
    final status = _AdherenceHistoryStatus.fromType(event.action);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusMarker(status: status),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  event.medicationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            status.label,
            style: AppTypography.label.copyWith(
              color: status.foregroundColor,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Programado para ${_formatDateTime(event.scheduledAt)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Respondido em ${_formatDateTime(event.actionAt)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final day = _twoDigits(value.day);
    final month = _twoDigits(value.month);
    final year = value.year;
    final hour = _twoDigits(value.hour);
    final minute = _twoDigits(value.minute);

    return '$day/$month/$year às $hour:$minute';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _StatusMarker extends StatelessWidget {
  const _StatusMarker({
    required this.status,
  });

  final _AdherenceHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.s12,
      height: AppSpacing.s12,
      decoration: BoxDecoration(
        color: status.foregroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

class _AdherenceHistoryStatus {
  const _AdherenceHistoryStatus({
    required this.label,
    required this.foregroundColor,
  });

  final String label;
  final Color foregroundColor;

  static _AdherenceHistoryStatus fromType(AdherenceEventType type) {
    return switch (type) {
      AdherenceEventType.taken => const _AdherenceHistoryStatus(
          label: 'Tomado',
          foregroundColor: AppColors.success,
        ),
      AdherenceEventType.postponed => const _AdherenceHistoryStatus(
          label: 'Vou tomar depois',
          foregroundColor: AppColors.warning,
        ),
      AdherenceEventType.missed => const _AdherenceHistoryStatus(
          label: 'Esquecido',
          foregroundColor: AppColors.error,
        ),
    };
  }
}