import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/feedback/feedback.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/repositories/adherence_event_repository.dart';
import 'package:chatbot/features/patient/domain/repositories/alarm_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_empty_state.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_list.dart';
import 'package:flutter/material.dart';

class PatientAlarmsPage extends StatefulWidget {
  const PatientAlarmsPage({
    super.key,
    required this.alarmRepository,
    required this.adherenceEventRepository,
  });

  final AlarmRepository alarmRepository;
  final AdherenceEventRepository adherenceEventRepository;

  @override
  State<PatientAlarmsPage> createState() => _PatientAlarmsPageState();
}

class _PatientAlarmsPageState extends State<PatientAlarmsPage> {
  static const _horizontalInset = 15.0;
  static const _topInset = 12.0;
  static const _headerHeight = 24.0;
  static const _listTopSpacing = 24.0;

  final Set<String> _updatingMedicationIds = {};
  final Set<String> _takingAlarmIds = {};

  Future<void> _onAlarmEnabledChanged({
    required Alarm alarm,
    required bool enabled,
  }) async {
    if (_updatingMedicationIds.contains(alarm.medicationId)) return;

    setState(() {
      _updatingMedicationIds.add(alarm.medicationId);
    });

    try {
      await widget.alarmRepository.setMedicationAlarmsEnabled(
        medicationId: alarm.medicationId,
        enabled: enabled,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar o alarme.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingMedicationIds.remove(alarm.medicationId);
        });
      }
    }
  }

  Future<void> _onAlarmTaken(Alarm alarm) async {
    if (!alarm.enabled) return;
    if (_takingAlarmIds.contains(alarm.id)) return;

    setState(() {
      _takingAlarmIds.add(alarm.id);
    });

    try {
      await widget.adherenceEventRepository.createForAlarm(
        alarmId: alarm.id,
        action: AdherenceEventType.taken,
      );

      await widget.alarmRepository.completeAlarm(alarm.id);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível confirmar a tomada.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _takingAlarmIds.remove(alarm.id);
        });
      }
    }
  }

  List<Alarm> _selectCurrentAlarmByMedication(List<Alarm> alarms) {
    final sortedAlarms = List<Alarm>.of(alarms)
      ..sort((first, second) {
        return first.scheduledAt.compareTo(second.scheduledAt);
      });

    final selectedByMedication = <String, Alarm>{};

    for (final alarm in sortedAlarms) {
      selectedByMedication.putIfAbsent(alarm.medicationId, () => alarm);
    }

    return selectedByMedication.values.toList()
      ..sort((first, second) {
        return first.scheduledAt.compareTo(second.scheduledAt);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: StreamBuilder<List<Alarm>>(
        stream: widget.alarmRepository.watchCurrentPatientAlarms(),
        builder: (context, snapshot) {
          final alarms = _selectCurrentAlarmByMedication(
            snapshot.data ?? const <Alarm>[],
          );

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              _horizontalInset,
              _topInset,
              _horizontalInset,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AlarmsHeader(height: _headerHeight),
                const SizedBox(height: _listTopSpacing),
                Expanded(
                  child: _AlarmsBody(
                    alarms: alarms,
                    isLoading:
                        snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData,
                    hasError: snapshot.hasError,
                    updatingMedicationIds: _updatingMedicationIds,
                    takingAlarmIds: _takingAlarmIds,
                    onAlarmEnabledChanged: _onAlarmEnabledChanged,
                    onAlarmTaken: _onAlarmTaken,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlarmsHeader extends StatelessWidget {
  const _AlarmsHeader({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          'Alarmes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _AlarmsBody extends StatelessWidget {
  const _AlarmsBody({
    required this.alarms,
    required this.isLoading,
    required this.hasError,
    required this.updatingMedicationIds,
    required this.takingAlarmIds,
    required this.onAlarmEnabledChanged,
    required this.onAlarmTaken,
  });

  final List<Alarm> alarms;
  final bool isLoading;
  final bool hasError;
  final Set<String> updatingMedicationIds;
  final Set<String> takingAlarmIds;
  final Future<void> Function({
    required Alarm alarm,
    required bool enabled,
  }) onAlarmEnabledChanged;
  final ValueChanged<Alarm> onAlarmTaken;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const AppLoading();

    if (hasError) {
      return const AppFeedbackState.error(
        title: 'Não foi possível carregar',
        description: 'Tente abrir seus alarmes novamente em alguns instantes.',
      );
    }

    if (alarms.isEmpty) return const AlarmEmptyState();

    return AlarmList(
      alarms: alarms,
      updatingMedicationIds: updatingMedicationIds,
      takingAlarmIds: takingAlarmIds,
      onAlarmEnabledChanged: onAlarmEnabledChanged,
      onAlarmTaken: onAlarmTaken,
    );
  }
}