import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:chatbot/features/patient/presentation/widgets/adherence_history_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_empty_state.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_status_switch.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_taken_indicator.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_card.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_empty_state.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_selected_name_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_section_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_home_shortcut_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

Medication _medication({bool complete = true}) {
  return Medication(
    id: 'med-1',
    patientId: 'patient-1',
    name: 'Dipirona',
    dosageAmount: complete ? 1 : null,
    dosageUnit: complete ? MedicationDosageUnit.tablet : null,
    initialTime: complete ? '08:00' : null,
    recurrence: complete ? MedicationRecurrence.every8Hours : null,
    durationType: complete ? MedicationDurationType.fixedDays : null,
    durationDays: complete ? 7 : null,
  );
}

Alarm _alarm({bool enabled = true}) {
  return Alarm(
    id: 'alarm-1',
    patientId: 'patient-1',
    medicationId: 'med-1',
    medicationName: 'Dipirona',
    scheduledAt: DateTime(2026, 3, 7, 8),
    time: '08:00',
    enabled: enabled,
  );
}

void main() {
  group('Patient widgets', () {
    testWidgets('MedicationCard exibe dados do medicamento e executa onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          MedicationCard(
            medication: _medication(),
            index: 0,
            onTap: () => taps++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Dipirona'));
      await tester.pump();

      expect(find.text('Dipirona'), findsOneWidget);
      expect(find.textContaining('1 Comprimido'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('MedicationCard informa tratamento não configurado', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          MedicationCard(
            medication: _medication(complete: false),
            index: 0,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tratamento ainda não configurado'), findsOneWidget);
    });

    testWidgets('MedicationEmptyState exibe mensagem de lista vazia', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const MedicationEmptyState()));
      await tester.pump();

      expect(find.textContaining('Você não possui remédios cadastrados.'), findsOneWidget);
    });

    testWidgets('MedicationSelectedNameHeader exibe nome e permite limpar seleção', (tester) async {
      var cleared = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          MedicationSelectedNameHeader(
            name: 'Dipirona',
            onEditPressed: () => cleared++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.text('Dipirona'), findsOneWidget);
      expect(cleared, 1);
    });

    testWidgets('AlarmEmptyState exibe mensagem de lista vazia', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AlarmEmptyState()));

      expect(find.text('Você não possui alarmes definidos.'), findsOneWidget);
    });

    testWidgets('AlarmStatusSwitch chama onChanged com valor invertido', (tester) async {
      bool? nextValue;

      await tester.pumpWidget(
        wrapWithMaterial(
          AlarmStatusSwitch(
            value: false,
            enabled: true,
            onChanged: (value) => nextValue = value,
          ),
        ),
      );
      await tester.tap(find.byType(AlarmStatusSwitch));
      await tester.pump();

      expect(nextValue, isTrue);
    });

    testWidgets('AlarmTakenIndicator exibe label Tomei', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AlarmTakenIndicator(enabled: true)));

      expect(find.text('Tomei'), findsOneWidget);
    });

    testWidgets('AlarmCard exibe horário, medicamento e ações', (tester) async {
      bool? enabled;
      var taken = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          AlarmCard(
            alarm: _alarm(),
            isUpdating: false,
            isTaking: false,
            onEnabledChanged: (value) => enabled = value,
            onTakenPressed: () => taken++,
          ),
        ),
      );
      await tester.tap(find.text('Tomei'));
      await tester.pump();
      await tester.tap(find.byType(AlarmStatusSwitch));
      await tester.pump();

      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('Dipirona'), findsOneWidget);
      expect(taken, 1);
      expect(enabled, isFalse);
    });

    testWidgets('AdherenceHistoryCard formata status e datas', (tester) async {
      final event = AdherenceEvent(
        id: 'event-1',
        patientId: 'patient-1',
        alarmId: 'alarm-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: DateTime(2026, 3, 7, 8),
        action: AdherenceEventType.postponed,
        actionAt: DateTime(2026, 3, 7, 8, 5),
      );

      await tester.pumpWidget(wrapWithMaterial(AdherenceHistoryCard(event: event)));

      expect(find.text('Dipirona'), findsOneWidget);
      expect(find.text('Vou tomar depois'), findsOneWidget);
      expect(find.text('Programado para 07/03/2026 às 08:00'), findsOneWidget);
      expect(find.text('Respondido em 07/03/2026 às 08:05'), findsOneWidget);
    });

    testWidgets('PatientHomeSectionHeader executa ação', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          PatientHomeSectionHeader(
            title: 'Próximos alarmes',
            onActionPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('›'));
      await tester.pump();

      expect(find.text('Próximos alarmes'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('PatientHomeShortcutTile chama onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          PatientHomeShortcutTile.medications(onTap: () => taps++),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Medicamentos'));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
