import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/models/adherence_event_model.dart';
import 'package:chatbot/features/patient/data/models/alarm_model.dart';
import 'package:chatbot/features/patient/data/models/medication_model.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MedicationModel', () {
    test('createMap cria payload de criação com campos normalizados de enum', () {
      final map = MedicationModel.createMap(
        patientId: 'patient-1',
        name: 'Dipirona',
        dosageAmount: 1.5,
        dosageUnit: MedicationDosageUnit.milliliter,
        initialTime: '08:00',
        recurrence: MedicationRecurrence.every8Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 7,
      );

      expect(map[FirestoreFields.patientId], 'patient-1');
      expect(map[FirestoreFields.name], 'Dipirona');
      expect(map[FirestoreFields.dosageAmount], 1.5);
      expect(map[FirestoreFields.dosageUnit], 'milliliter');
      expect(map[FirestoreFields.recurrence], 'every8Hours');
      expect(map[FirestoreFields.recurrenceIntervalHours], 8);
      expect(map[FirestoreFields.durationType], 'fixedDays');
      expect(map[FirestoreFields.durationDays], 7);
      expect(map[FirestoreFields.createdAt], isA<FieldValue>());
      expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
    });

    test('updateMap cria payload sem createdAt', () {
      final map = MedicationModel.updateMap(
        name: 'Paracetamol',
        dosageAmount: 2,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: '09:00',
        recurrence: MedicationRecurrence.onceDaily,
        durationType: MedicationDurationType.continuous,
        durationDays: null,
      );

      expect(map[FirestoreFields.name], 'Paracetamol');
      expect(map[FirestoreFields.dosageUnit], 'tablet');
      expect(map[FirestoreFields.recurrenceIntervalHours], 24);
      expect(map[FirestoreFields.durationDays], isNull);
      expect(map.containsKey(FirestoreFields.createdAt), isFalse);
      expect(map[FirestoreFields.updatedAt], isA<FieldValue>());
    });

    test('fromFirestore lê tipos numéricos, Timestamp e fallback de recorrência por intervalo', () async {
      final firestore = FakeFirebaseFirestore();
      final createdAt = DateTime(2026, 3, 7, 10);
      final ref = firestore.collection(FirestoreCollections.medications).doc('med-1');
      await ref.set({
        FirestoreFields.patientId: 'patient-1',
        FirestoreFields.name: 'Dipirona',
        FirestoreFields.dosageAmount: 2,
        FirestoreFields.dosageUnit: 'mg',
        FirestoreFields.initialTime: '08:00',
        FirestoreFields.recurrenceIntervalHours: 6,
        FirestoreFields.durationType: 'continuous',
        FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      });

      final model = MedicationModel.fromFirestore(await ref.get());

      expect(model.id, 'med-1');
      expect(model.patientId, 'patient-1');
      expect(model.dosageAmount, 2.0);
      expect(model.dosageUnit, MedicationDosageUnit.milligram);
      expect(model.recurrence, MedicationRecurrence.every6Hours);
      expect(model.durationType, MedicationDurationType.continuous);
      expect(model.createdAt, createdAt);
    });
  });

  group('AlarmModel', () {
    test('createMap e enabledUpdateMap criam payloads esperados', () {
      final scheduledAt = DateTime(2026, 3, 7, 8);
      final createMap = AlarmModel.createMap(
        patientId: 'patient-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: scheduledAt,
        time: '08:00',
        enabled: false,
      );
      final updateMap = AlarmModel.enabledUpdateMap(true);

      expect(createMap[FirestoreFields.patientId], 'patient-1');
      expect(createMap[FirestoreFields.medicationId], 'med-1');
      expect(createMap[FirestoreFields.medicationName], 'Dipirona');
      expect(createMap[FirestoreFields.scheduledAt], isA<Timestamp>());
      expect((createMap[FirestoreFields.scheduledAt] as Timestamp).toDate(), scheduledAt);
      expect(createMap[FirestoreFields.enabled], isFalse);
      expect(updateMap[FirestoreFields.enabled], isTrue);
      expect(updateMap[FirestoreFields.updatedAt], isA<FieldValue>());
    });

    test('fromFirestore lê documento com campos padrão', () async {
      final firestore = FakeFirebaseFirestore();
      final scheduledAt = DateTime(2026, 3, 7, 8);
      final ref = firestore.collection(FirestoreCollections.alarms).doc('alarm-1');
      await ref.set({
        FirestoreFields.patientId: 'patient-1',
        FirestoreFields.medicationId: 'med-1',
        FirestoreFields.medicationName: 'Dipirona',
        FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
        FirestoreFields.time: '08:00',
      });

      final model = AlarmModel.fromFirestore(await ref.get());

      expect(model.id, 'alarm-1');
      expect(model.patientId, 'patient-1');
      expect(model.medicationId, 'med-1');
      expect(model.medicationName, 'Dipirona');
      expect(model.scheduledAt, scheduledAt);
      expect(model.time, '08:00');
      expect(model.enabled, isTrue);
    });
  });

  group('AdherenceEventModel', () {
    test('createMap cria payload a partir de alarme', () {
      final scheduledAt = DateTime(2026, 3, 7, 8);
      final actionAt = DateTime(2026, 3, 7, 8, 5);
      final alarm = Alarm(
        id: 'alarm-1',
        patientId: 'patient-1',
        medicationId: 'med-1',
        medicationName: 'Dipirona',
        scheduledAt: scheduledAt,
        time: '08:00',
        enabled: true,
      );

      final map = AdherenceEventModel.createMap(
        alarm: alarm,
        action: AdherenceEventType.taken,
        actionAt: actionAt,
      );

      expect(map[FirestoreFields.patientId], 'patient-1');
      expect(map[FirestoreFields.alarmId], 'alarm-1');
      expect(map[FirestoreFields.medicationId], 'med-1');
      expect(map[FirestoreFields.action], 'taken');
      expect((map[FirestoreFields.scheduledAt] as Timestamp).toDate(), scheduledAt);
      expect((map[FirestoreFields.actionAt] as Timestamp).toDate(), actionAt);
      expect(map[FirestoreFields.createdAt], isA<FieldValue>());
    });

    test('fromFirestore lê evento válido e rejeita ação inválida', () async {
      final firestore = FakeFirebaseFirestore();
      final scheduledAt = DateTime(2026, 3, 7, 8);
      final actionAt = DateTime(2026, 3, 7, 8, 5);
      final ref = firestore.collection(FirestoreCollections.adherenceEvents).doc('event-1');
      await ref.set({
        FirestoreFields.patientId: 'patient-1',
        FirestoreFields.alarmId: 'alarm-1',
        FirestoreFields.medicationId: 'med-1',
        FirestoreFields.medicationName: 'Dipirona',
        FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
        FirestoreFields.action: 'postponed',
        FirestoreFields.actionAt: Timestamp.fromDate(actionAt),
      });

      final event = AdherenceEventModel.fromFirestore(await ref.get());

      expect(event.id, 'event-1');
      expect(event.action, AdherenceEventType.postponed);
      expect(event.scheduledAt, scheduledAt);
      expect(event.actionAt, actionAt);

      await ref.update({FirestoreFields.action: 'invalid'});
      await expectLater(
        Future<void>(() async {
          AdherenceEventModel.fromFirestore(await ref.get());
        }),
        throwsStateError,
      );
    });
  });
}
