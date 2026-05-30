import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Alarm', () {
    test('isFuture reflete scheduledAt em relação ao momento atual', () {
      final future = Alarm(
        id: 'alarm-1',
        patientId: 'patient-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        time: '08:00',
        enabled: true,
      );
      final past = Alarm(
        id: 'alarm-2',
        patientId: 'patient-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        time: '08:00',
        enabled: true,
      );

      expect(future.isFuture, isTrue);
      expect(past.isFuture, isFalse);
    });
  });

  group('AdherenceEvent', () {
    test('preserva dados do evento de adesão', () {
      final scheduledAt = DateTime(2026, 3, 7, 8);
      final actionAt = DateTime(2026, 3, 7, 8, 5);
      final event = AdherenceEvent(
        id: 'event-1',
        patientId: 'patient-1',
        alarmId: 'alarm-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: scheduledAt,
        action: AdherenceEventType.taken,
        actionAt: actionAt,
      );

      expect(event.id, 'event-1');
      expect(event.action.isTaken, isTrue);
      expect(event.scheduledAt, scheduledAt);
      expect(event.actionAt, actionAt);
    });
  });

  group('Medication', () {
    test('hasTreatment é false quando tratamento está incompleto', () {
      const medication = Medication(id: 'med-1', patientId: 'patient-1', name: 'Dipirona');

      expect(medication.hasTreatment, isFalse);
      expect(medication.dosageLabel, 'Dosagem não definida');
      expect(medication.recurrenceLabel, 'Recorrência não definida');
      expect(medication.durationLabel, 'Duração não definida');
    });

    test('hasTreatment é true quando todos os dados do tratamento existem', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: '08:00',
        recurrence: MedicationRecurrence.every8Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 7,
      );

      expect(medication.hasTreatment, isTrue);
    });

    test('hasTreatment é false quando initialTime está em branco', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: '   ',
        recurrence: MedicationRecurrence.every8Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 7,
      );

      expect(medication.hasTreatment, isFalse);
    });

    test('formata labels de dosagem, recorrência e duração', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        dosageAmount: 2.5,
        dosageUnit: MedicationDosageUnit.milliliter,
        recurrence: MedicationRecurrence.every12Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 10,
      );

      expect(medication.dosageLabel, '2,5 ml');
      expect(medication.recurrenceLabel, 'A cada 12 horas');
      expect(medication.durationLabel, '10 dias');
    });

    test('formata inteiro sem decimal e descreve uso contínuo', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        dosageAmount: 2,
        dosageUnit: MedicationDosageUnit.tablet,
        durationType: MedicationDurationType.continuous,
      );

      expect(medication.dosageLabel, '2 Comprimido');
      expect(medication.isContinuousUse, isTrue);
      expect(medication.durationLabel, 'Uso contínuo');
    });

    test('effectiveRecurrenceIntervalHours prioriza intervalo explícito', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        recurrence: MedicationRecurrence.every8Hours,
        recurrenceIntervalHours: 6,
      );

      expect(medication.effectiveRecurrenceIntervalHours, 6);
    });

    test('effectiveRecurrenceIntervalHours usa intervalo da recorrência', () {
      const medication = Medication(
        id: 'med-1',
        patientId: 'patient-1',
        name: 'Dipirona',
        recurrence: MedicationRecurrence.every12Hours,
      );

      expect(medication.effectiveRecurrenceIntervalHours, 12);
    });
  });
}
