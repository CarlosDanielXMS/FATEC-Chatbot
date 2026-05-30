import 'dart:async';

import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_card.dart';
import 'package:flutter/material.dart';

class AlarmList extends StatelessWidget {
  const AlarmList({
    super.key,
    required this.alarms,
    required this.updatingMedicationIds,
    required this.takingAlarmIds,
    required this.onAlarmEnabledChanged,
    required this.onAlarmTaken,
  });

  final List<Alarm> alarms;
  final Set<String> updatingMedicationIds;
  final Set<String> takingAlarmIds;
  final Future<void> Function({
    required Alarm alarm,
    required bool enabled,
  }) onAlarmEnabledChanged;
  final ValueChanged<Alarm> onAlarmTaken;

  static const _itemSpacing = AppSpacing.s16;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: alarms.length,
      separatorBuilder: (_, _) => const SizedBox(height: _itemSpacing),
      itemBuilder: (context, index) {
        final alarm = alarms[index];

        return AlarmCard(
          alarm: alarm,
          isUpdating: updatingMedicationIds.contains(alarm.medicationId),
          isTaking: takingAlarmIds.contains(alarm.id),
          onEnabledChanged: (enabled) {
            unawaited(
              onAlarmEnabledChanged(
                alarm: alarm,
                enabled: enabled,
              ),
            );
          },
          onTakenPressed: () => onAlarmTaken(alarm),
        );
      },
    );
  }
}