import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
import 'package:chatbot/features/patient/data/services/medication_alarm_scheduler_service.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

String _nowHourMinute() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
}

MockFirebaseAuth _auth() {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: 'patient-1', email: 'patient@example.com'),
  );
}

Medication _validMedication({
  String id = 'med-1',
  String patientId = 'patient-1',
  String name = 'Dipirona',
  MedicationDurationType durationType = MedicationDurationType.fixedDays,
  int? durationDays = 2,
}) {
  return Medication(
    id: id,
    patientId: patientId,
    name: name,
    initialTime: _nowHourMinute(),
    recurrence: MedicationRecurrence.every12Hours,
    durationType: durationType,
    durationDays: durationDays,
  );
}

void main() {
  group('MedicationAlarmSchedulerService', () {
    test('scheduleFutureAlarmsForMedication cria alarmes futuros para medicamento válido', () async {
      final firestore = FakeFirebaseFirestore();
      final alarmService = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final scheduler = MedicationAlarmSchedulerService(alarmService: alarmService);

      await scheduler.scheduleFutureAlarmsForMedication(_validMedication());

      final snapshot = await firestore.collection(FirestoreCollections.alarms).get();
      expect(snapshot.docs, isNotEmpty);
      expect(snapshot.docs.every((doc) => doc.data()[FirestoreFields.patientId] == 'patient-1'), isTrue);
      expect(snapshot.docs.every((doc) => doc.data()[FirestoreFields.medicationId] == 'med-1'), isTrue);
    });

    test('removeFutureAlarmsForMedication remove alarmes futuros do medicamento', () async {
      final firestore = FakeFirebaseFirestore();
      final alarmService = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final scheduler = MedicationAlarmSchedulerService(alarmService: alarmService);
      final medication = _validMedication();

      await scheduler.scheduleFutureAlarmsForMedication(medication);
      expect((await firestore.collection(FirestoreCollections.alarms).get()).docs, isNotEmpty);

      await scheduler.removeFutureAlarmsForMedication(medication);

      final remaining = await firestore.collection(FirestoreCollections.alarms).get();
      expect(remaining.docs, isEmpty);
    });

    test('rescheduleFutureAlarmsForMedication recria alarmes futuros', () async {
      final firestore = FakeFirebaseFirestore();
      final alarmService = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final scheduler = MedicationAlarmSchedulerService(alarmService: alarmService);
      final medication = _validMedication();

      await scheduler.scheduleFutureAlarmsForMedication(medication);
      final before = await firestore.collection(FirestoreCollections.alarms).get();

      await scheduler.rescheduleFutureAlarmsForMedication(medication);
      final after = await firestore.collection(FirestoreCollections.alarms).get();

      expect(before.docs, isNotEmpty);
      expect(after.docs, isNotEmpty);
    });

    test('valida campos obrigatórios do medicamento antes de agendar', () async {
      final scheduler = MedicationAlarmSchedulerService(
        alarmService: FirestoreAlarmService(auth: _auth(), firestore: FakeFirebaseFirestore()),
      );

      await expectLater(scheduler.scheduleFutureAlarmsForMedication(_validMedication(id: '')), throwsStateError);
      await expectLater(scheduler.scheduleFutureAlarmsForMedication(_validMedication(patientId: '')), throwsStateError);
      await expectLater(scheduler.scheduleFutureAlarmsForMedication(_validMedication(name: '')), throwsStateError);
      await expectLater(
        scheduler.scheduleFutureAlarmsForMedication(
          _validMedication(durationType: MedicationDurationType.fixedDays, durationDays: 0),
        ),
        throwsStateError,
      );
    });
  });
}
