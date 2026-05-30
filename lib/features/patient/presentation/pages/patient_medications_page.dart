import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/feedback/feedback.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/repositories/medication_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_empty_state.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_page_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientMedicationsPage extends StatefulWidget {
  const PatientMedicationsPage({
    super.key,
    required this.medicationRepository,
  });

  final MedicationRepository medicationRepository;

  @override
  State<PatientMedicationsPage> createState() => _PatientMedicationsPageState();
}

class _PatientMedicationsPageState extends State<PatientMedicationsPage> {
  void _goToAddMedication() {
    context.push(AppRoutes.patientMedicationAdd);
  }

  void _goToEditMedication(Medication medication) {
    context.push(AppRoutes.patientMedicationEdit(medication.id));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          const MedicationPageHeader(
            title: 'Medicamentos',
            showBackButton: false,
          ),
          Expanded(
            child: StreamBuilder<List<Medication>>(
              stream: widget.medicationRepository.watchCurrentPatientMedications(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppFeedbackState.error(
                    title: 'Não foi possível carregar',
                    description: 'Tente novamente em alguns instantes.',
                    actionLabel: 'Recarregar',
                    onActionPressed: () => setState(() {}),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoading();
                }

                final medications = snapshot.data ?? const [];

                if (medications.isEmpty) {
                  return const MedicationEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s8,
                    AppSpacing.s16,
                    AppSpacing.s16,
                  ),
                  itemCount: medications.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(height: AppSpacing.s16);
                  },
                  itemBuilder: (context, index) {
                    final medication = medications[index];

                    return MedicationCard(
                      medication: medication,
                      index: index,
                      onTap: () => _goToEditMedication(medication),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s8,
              AppSpacing.s16,
              AppSpacing.s10,
            ),
            child: AppButton.primary(
              label: 'Adicionar',
              icon: const Icon(Icons.add, size: 18),
              onPressed: _goToAddMedication,
            ),
          ),
        ],
      ),
    );
  }
}