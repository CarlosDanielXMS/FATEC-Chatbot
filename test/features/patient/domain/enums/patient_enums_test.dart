import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedicationDosageUnit.fromValue', () {
    test('converte value, label e valores com espaços', () {
      expect(MedicationDosageUnit.fromValue('tablet'), MedicationDosageUnit.tablet);
      expect(MedicationDosageUnit.fromValue('Cápsula'), MedicationDosageUnit.capsule);
      expect(MedicationDosageUnit.fromValue(' mg '), MedicationDosageUnit.milligram);
    });

    test('retorna null para valor vazio, null ou desconhecido', () {
      expect(MedicationDosageUnit.fromValue(null), isNull);
      expect(MedicationDosageUnit.fromValue(''), isNull);
      expect(MedicationDosageUnit.fromValue('xarope'), isNull);
    });
  });

  group('MedicationDurationType.fromValue', () {
    test('converte value e label', () {
      expect(MedicationDurationType.fromValue('continuous'), MedicationDurationType.continuous);
      expect(MedicationDurationType.fromValue('Duração definida'), MedicationDurationType.fixedDays);
    });

    test('retorna null para valor inválido', () {
      expect(MedicationDurationType.fromValue(null), isNull);
      expect(MedicationDurationType.fromValue(''), isNull);
      expect(MedicationDurationType.fromValue('7 dias'), isNull);
    });
  });

  group('MedicationRecurrence', () {
    test('fromValue retorna recorrência por value e label', () {
      expect(MedicationRecurrence.fromValue('every8Hours'), MedicationRecurrence.every8Hours);
      expect(MedicationRecurrence.fromValue('A cada 12 horas'), MedicationRecurrence.every12Hours);
    });

    test('fromIntervalHours retorna recorrência pelo intervalo', () {
      expect(MedicationRecurrence.fromIntervalHours(3), MedicationRecurrence.every3Hours);
      expect(MedicationRecurrence.fromIntervalHours(6), MedicationRecurrence.every6Hours);
      expect(MedicationRecurrence.fromIntervalHours(24), MedicationRecurrence.onceDaily);
    });

    test('retorna null para valores inválidos', () {
      expect(MedicationRecurrence.fromValue(null), isNull);
      expect(MedicationRecurrence.fromValue(''), isNull);
      expect(MedicationRecurrence.fromValue('semanal'), isNull);
      expect(MedicationRecurrence.fromIntervalHours(null), isNull);
      expect(MedicationRecurrence.fromIntervalHours(5), isNull);
    });
  });

  group('AdherenceEventType', () {
    test('tryFromString converte valores conhecidos', () {
      expect(AdherenceEventType.tryFromString('taken'), AdherenceEventType.taken);
      expect(AdherenceEventType.tryFromString('postponed'), AdherenceEventType.postponed);
      expect(AdherenceEventType.tryFromString('missed'), AdherenceEventType.missed);
    });

    test('tryFromString retorna null para valor inválido', () {
      expect(AdherenceEventType.tryFromString(null), isNull);
      expect(AdherenceEventType.tryFromString('cancelled'), isNull);
    });

    test('getters identificam o tipo corretamente', () {
      expect(AdherenceEventType.taken.isTaken, isTrue);
      expect(AdherenceEventType.taken.isPostponed, isFalse);
      expect(AdherenceEventType.postponed.isPostponed, isTrue);
      expect(AdherenceEventType.missed.isMissed, isTrue);
    });
  });
}
