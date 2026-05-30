import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
import 'package:chatbot/features/patient/data/services/firestore_medication_service.dart';
import 'package:chatbot/features/patient/data/services/medication_alarm_scheduler_service.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

MockFirebaseAuth _auth({String uid = 'patient-1', bool signedIn = true}) {
  return MockFirebaseAuth(
    signedIn: signedIn,
    mockUser: MockUser(uid: uid, email: '$uid@example.com'),
  );
}

String _nowHourMinute() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
}

FirestoreMedicationService _service({
  required FakeFirebaseFirestore firestore,
  MockFirebaseAuth? auth,
}) {
  final effectiveAuth = auth ?? _auth();
  final alarmService = FirestoreAlarmService(auth: effectiveAuth, firestore: firestore);
  final scheduler = MedicationAlarmSchedulerService(alarmService: alarmService);

  return FirestoreMedicationService(
    auth: effectiveAuth,
    firestore: firestore,
    medicationAlarmSchedulerService: scheduler,
  );
}

Future<void> _seedMedication(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String patientId,
  required DateTime createdAt,
  String name = 'Dipirona',
}) {
  return firestore.collection(FirestoreCollections.medications).doc(id).set({
    FirestoreFields.patientId: patientId,
    FirestoreFields.name: name,
    FirestoreFields.dosageAmount: 1,
    FirestoreFields.dosageUnit: MedicationDosageUnit.tablet.value,
    FirestoreFields.initialTime: '08:00',
    FirestoreFields.recurrence: MedicationRecurrence.every12Hours.value,
    FirestoreFields.recurrenceIntervalHours: 12,
    FirestoreFields.durationType: MedicationDurationType.fixedDays.value,
    FirestoreFields.durationDays: 2,
    FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
    FirestoreFields.updatedAt: Timestamp.fromDate(createdAt),
  });
}

void main() {
  group('FirestoreMedicationService', () {
    test('lança StateError quando não há usuário autenticado', () async {
      final service = _service(
        firestore: FakeFirebaseFirestore(),
        auth: _auth(signedIn: false),
      );

      await expectLater(service.getCurrentPatientMedications(), throwsStateError);
    });

    test('getCurrentPatientMedications filtra paciente e ordena por createdAt desc', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);
      await _seedMedication(firestore, id: 'old', patientId: 'patient-1', createdAt: DateTime(2026, 3, 1));
      await _seedMedication(firestore, id: 'new', patientId: 'patient-1', createdAt: DateTime(2026, 3, 2));
      await _seedMedication(firestore, id: 'other', patientId: 'patient-2', createdAt: DateTime(2026, 3, 3));

      final medications = await service.getCurrentPatientMedications();

      expect(medications.map((medication) => medication.id), ['new', 'old']);
    });

    test('getMedicationById retorna medicamento do paciente autenticado', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);
      await _seedMedication(firestore, id: 'med-1', patientId: 'patient-1', createdAt: DateTime(2026, 3, 1));

      final medication = await service.getMedicationById(' med-1 ');

      expect(medication.id, 'med-1');
      expect(medication.patientId, 'patient-1');
    });

    test('getMedicationById rejeita id vazio, inexistente ou de outro paciente', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);
      await _seedMedication(firestore, id: 'other-med', patientId: 'patient-2', createdAt: DateTime(2026, 3, 1));

      await expectLater(service.getMedicationById('   '), throwsArgumentError);
      await expectLater(service.getMedicationById('missing'), throwsStateError);
      await expectLater(service.getMedicationById('other-med'), throwsStateError);
    });

    test('createMedication normaliza dados, cria documento e agenda alarmes', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);

      final initialTime = _nowHourMinute();
      final medication = await service.createMedication(
        name: '  Dipirona   Sódica  ',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: initialTime,
        recurrence: MedicationRecurrence.every12Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 2,
      );

      expect(medication.patientId, 'patient-1');
      expect(medication.name, 'Dipirona Sódica');
      expect(medication.initialTime, initialTime);
      expect(medication.durationDays, 2);

      final alarms = await firestore.collection(FirestoreCollections.alarms).get();
      expect(alarms.docs, isNotEmpty);
      expect(alarms.docs.every((doc) => doc.data()[FirestoreFields.medicationId] == medication.id), isTrue);
    });

    test('createMedication zera durationDays para uso contínuo', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);

      final medication = await service.createMedication(
        name: 'Dipirona',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: _nowHourMinute(),
        recurrence: MedicationRecurrence.onceDaily,
        durationType: MedicationDurationType.continuous,
        durationDays: 10,
      );

      expect(medication.durationType, MedicationDurationType.continuous);
      expect(medication.durationDays, isNull);
    });

    test('createMedication valida payload obrigatório', () async {
      final service = _service(firestore: FakeFirebaseFirestore());

      await expectLater(
        service.createMedication(
          name: '   ',
          dosageAmount: 1,
          dosageUnit: MedicationDosageUnit.tablet,
          initialTime: '08:00',
          recurrence: MedicationRecurrence.onceDaily,
          durationType: MedicationDurationType.fixedDays,
          durationDays: 1,
        ),
        throwsArgumentError,
      );
      await expectLater(
        service.createMedication(
          name: 'Dipirona',
          dosageAmount: 0,
          dosageUnit: MedicationDosageUnit.tablet,
          initialTime: '08:00',
          recurrence: MedicationRecurrence.onceDaily,
          durationType: MedicationDurationType.fixedDays,
          durationDays: 1,
        ),
        throwsArgumentError,
      );
      await expectLater(
        service.createMedication(
          name: 'Dipirona',
          dosageAmount: 1,
          dosageUnit: MedicationDosageUnit.tablet,
          initialTime: '25:00',
          recurrence: MedicationRecurrence.onceDaily,
          durationType: MedicationDurationType.fixedDays,
          durationDays: 1,
        ),
        throwsArgumentError,
      );
      await expectLater(
        service.createMedication(
          name: 'Dipirona',
          dosageAmount: 1,
          dosageUnit: MedicationDosageUnit.tablet,
          initialTime: '08:00',
          recurrence: MedicationRecurrence.onceDaily,
          durationType: MedicationDurationType.fixedDays,
          durationDays: 0,
        ),
        throwsArgumentError,
      );
    });

    test('updateMedication atualiza documento e reagenda alarmes', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);
      await _seedMedication(firestore, id: 'med-1', patientId: 'patient-1', createdAt: DateTime(2026, 3, 1));

      await service.updateMedication(
        medicationId: 'med-1',
        name: '  Paracetamol  ',
        dosageAmount: 2,
        dosageUnit: MedicationDosageUnit.capsule,
        initialTime: _nowHourMinute(),
        recurrence: MedicationRecurrence.every12Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 2,
      );

      final updated = await service.getMedicationById('med-1');
      expect(updated.name, 'Paracetamol');
      expect(updated.dosageAmount, 2);
      expect(updated.dosageUnit, MedicationDosageUnit.capsule);

      final alarms = await firestore.collection(FirestoreCollections.alarms).get();
      expect(alarms.docs, isNotEmpty);
      expect(alarms.docs.every((doc) => doc.data()[FirestoreFields.medicationId] == 'med-1'), isTrue);
    });

    test('deleteMedication remove alarmes futuros e documento', () async {
      final firestore = FakeFirebaseFirestore();
      final service = _service(firestore: firestore);
      await _seedMedication(firestore, id: 'med-1', patientId: 'patient-1', createdAt: DateTime(2026, 3, 1));

      await service.updateMedication(
        medicationId: 'med-1',
        name: 'Dipirona',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: _nowHourMinute(),
        recurrence: MedicationRecurrence.every12Hours,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 2,
      );
      expect((await firestore.collection(FirestoreCollections.alarms).get()).docs, isNotEmpty);

      await service.deleteMedication('med-1');

      expect((await firestore.collection(FirestoreCollections.medications).doc('med-1').get()).exists, isFalse);
      expect((await firestore.collection(FirestoreCollections.alarms).get()).docs, isEmpty);
    });
  });
}
