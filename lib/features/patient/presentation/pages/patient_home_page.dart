import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:chatbot/core/ui/widgets/feedback/feedback.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/repositories/alarm_repository.dart';
import 'package:chatbot/features/patient/domain/repositories/medication_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_education_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_next_alarm_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_section_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_week_calendar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({
    super.key,
    required this.authRepository,
    required this.alarmRepository,
    required this.medicationRepository,
  });

  final AuthRepository authRepository;
  final AlarmRepository alarmRepository;
  final MedicationRepository medicationRepository;

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  late final Future<String> _firstNameFuture = _loadFirstName();

  Future<String> _loadFirstName() async {
    final profile = await widget.authRepository.getCurrentUserProfile();

    return profile?.firstName ?? 'Usuário';
  }

  void _goToMedications() {
    context.go(AppRoutes.patientMedications);
  }

  void _goToAlarms() {
    context.go(AppRoutes.patientAlarms);
  }

  void _goToSideEffects() {
    context.push(AppRoutes.patientSideEffects);
  }

  void _goToChatBot() {
    context.push(AppRoutes.patientChatBot);
  }

  void _goToAdherenceHistory() {
    context.push(AppRoutes.patientAdherenceHistory);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: FutureBuilder<String>(
        future: _firstNameFuture,
        builder: (context, profileSnapshot) {
          final userName = profileSnapshot.data ?? 'Usuário';

          return StreamBuilder<List<Alarm>>(
            stream: widget.alarmRepository.watchCurrentPatientAlarms(),
            builder: (context, alarmSnapshot) {
              if (alarmSnapshot.hasError) {
                return const AppFeedbackState.error(
                  title: 'Não foi possível carregar',
                  description: 'Tente novamente em alguns instantes.',
                );
              }

              if (alarmSnapshot.connectionState == ConnectionState.waiting &&
                  !alarmSnapshot.hasData) {
                return const AppLoading();
              }

              final alarms = alarmSnapshot.data ?? const <Alarm>[];

              return StreamBuilder<List<Medication>>(
                stream:
                    widget.medicationRepository.watchCurrentPatientMedications(),
                builder: (context, medicationSnapshot) {
                  if (medicationSnapshot.hasError) {
                    return const AppFeedbackState.error(
                      title: 'Não foi possível carregar',
                      description: 'Tente novamente em alguns instantes.',
                    );
                  }

                  if (medicationSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !medicationSnapshot.hasData) {
                    return const AppLoading();
                  }

                  return _PatientHomeContent(
                    userName: userName,
                    alarms: alarms,
                    medications:
                        medicationSnapshot.data ?? const <Medication>[],
                    onMedicationsPressed: _goToMedications,
                    onAlarmsPressed: _goToAlarms,
                    onSideEffectsPressed: _goToSideEffects,
                    onKnowlegeBasePressed: _goToChatBot,
                    onAdherenceHistoryPressed: _goToAdherenceHistory,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PatientHomeContent extends StatelessWidget {
  const _PatientHomeContent({
    required this.userName,
    required this.alarms,
    required this.medications,
    required this.onMedicationsPressed,
    required this.onAlarmsPressed,
    required this.onSideEffectsPressed,
    required this.onKnowlegeBasePressed,
    required this.onAdherenceHistoryPressed,
  });

  final String userName;
  final List<Alarm> alarms;
  final List<Medication> medications;
  final VoidCallback onMedicationsPressed;
  final VoidCallback onAlarmsPressed;
  final VoidCallback onSideEffectsPressed;
  final VoidCallback onKnowlegeBasePressed;
  final VoidCallback onAdherenceHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 0, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PatientHomeHeader(
            now: now,
            userName: userName,
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PatientHomeWeekCalendar(
            selectedDate: now,
            alarms: alarms,
            medications: medications,
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PatientHomeNextAlarmCard(
            alarm: _selectNextAlarm(now),
            onSeeAlarmsPressed: onAlarmsPressed,
            onAddMedicationPressed: onMedicationsPressed,
          ),
        ),
        const SizedBox(height: 42),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PatientHomeSectionHeader(
            title: 'Orientações Educativas',
            onActionPressed: () {},
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 256,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            children: [
              PatientHomeEducationCard.sideEffectsShortcut(
                onTap: onSideEffectsPressed,
              ),
              const SizedBox(width: 12),
              PatientHomeEducationCard.knowledgeBase(
                onTap: onKnowlegeBasePressed,
              ),
              const SizedBox(width: 12),
              PatientHomeEducationCard.sideEffectsHistory(
                onTap: onAdherenceHistoryPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Alarm? _selectNextAlarm(DateTime now) {
    final futureAlarms = alarms
        .where((alarm) => alarm.enabled && !alarm.scheduledAt.isBefore(now))
        .toList()
      ..sort((first, second) {
        return first.scheduledAt.compareTo(second.scheduledAt);
      });

    if (futureAlarms.isEmpty) return null;

    return futureAlarms.first;
  }
}