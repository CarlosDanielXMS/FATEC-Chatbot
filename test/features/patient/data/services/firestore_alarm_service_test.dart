import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/models/alarm_model.dart';
import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
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

Future<void> _seedAlarm(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String patientId,
  required String medicationId,
  required DateTime scheduledAt,
  bool enabled = true,
}) {
  return firestore.collection(FirestoreCollections.alarms).doc(id).set({
    FirestoreFields.patientId: patientId,
    FirestoreFields.medicationId: medicationId,
    FirestoreFields.medicationName: 'Dipirona',
    FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
    FirestoreFields.time: '${scheduledAt.hour.toString().padLeft(2, '0')}:00',
    FirestoreFields.enabled: enabled,
    FirestoreFields.createdAt: Timestamp.fromDate(scheduledAt),
    FirestoreFields.updatedAt: Timestamp.fromDate(scheduledAt),
  });
}

void main() {
  group('FirestoreAlarmService', () {
    test('lança StateError quando não há usuário autenticado', () async {
      final service = FirestoreAlarmService(
        auth: _auth(signedIn: false),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(service.getCurrentPatientAlarms(), throwsStateError);
    });

    test('getCurrentPatientAlarms filtra usuário autenticado e ordena por horário', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final now = DateTime.now();
      await _seedAlarm(firestore, id: 'late', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.add(const Duration(hours: 3)));
      await _seedAlarm(firestore, id: 'early', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.add(const Duration(hours: 1)));
      await _seedAlarm(firestore, id: 'other', patientId: 'patient-2', medicationId: 'med-1', scheduledAt: now.add(const Duration(minutes: 30)));

      final alarms = await service.getCurrentPatientAlarms();

      expect(alarms.map((alarm) => alarm.id), ['early', 'late']);
    });

    test('watchCurrentPatientAlarms emite alarmes do usuário autenticado', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final stream = service.watchCurrentPatientAlarms();

      await _seedAlarm(
        firestore,
        id: 'alarm-1',
        patientId: 'patient-1',
        medicationId: 'med-1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((alarms) => alarms.any((alarm) => alarm.id == 'alarm-1'))),
      );
    });

    test('createFutureAlarms cria documentos e ignora lista vazia', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final scheduledAt = DateTime.now().add(const Duration(hours: 1));

      await service.createFutureAlarms([]);
      expect((await firestore.collection(FirestoreCollections.alarms).get()).docs, isEmpty);

      await service.createFutureAlarms([
        AlarmModel.createMap(
          patientId: 'patient-1',
          medicationId: 'med-1',
          medicationName: 'Dipirona',
          scheduledAt: scheduledAt,
          time: '08:00',
        ),
      ]);

      final snapshot = await firestore.collection(FirestoreCollections.alarms).get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.single.data()[FirestoreFields.patientId], 'patient-1');
    });

    test('setAlarmEnabled atualiza alarme do paciente autenticado', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      await _seedAlarm(
        firestore,
        id: 'alarm-1',
        patientId: 'patient-1',
        medicationId: 'med-1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await service.setAlarmEnabled(alarmId: ' alarm-1 ', enabled: false);

      final data = (await firestore.collection(FirestoreCollections.alarms).doc('alarm-1').get()).data()!;
      expect(data[FirestoreFields.enabled], isFalse);
    });

    test('setAlarmEnabled rejeita alarme de outro paciente ou inexistente', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      await _seedAlarm(
        firestore,
        id: 'other-alarm',
        patientId: 'patient-2',
        medicationId: 'med-1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await expectLater(service.setAlarmEnabled(alarmId: 'missing', enabled: true), throwsStateError);
      await expectLater(service.setAlarmEnabled(alarmId: 'other-alarm', enabled: true), throwsStateError);
      await expectLater(service.setAlarmEnabled(alarmId: '   ', enabled: true), throwsArgumentError);
    });

    test('setMedicationAlarmsEnabled atualiza todos os alarmes do medicamento', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final now = DateTime.now();
      await _seedAlarm(firestore, id: 'a1', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.add(const Duration(hours: 1)));
      await _seedAlarm(firestore, id: 'a2', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.add(const Duration(hours: 2)));
      await _seedAlarm(firestore, id: 'a3', patientId: 'patient-1', medicationId: 'med-2', scheduledAt: now.add(const Duration(hours: 3)));

      await service.setMedicationAlarmsEnabled(medicationId: 'med-1', enabled: false);

      final a1 = (await firestore.collection(FirestoreCollections.alarms).doc('a1').get()).data()!;
      final a2 = (await firestore.collection(FirestoreCollections.alarms).doc('a2').get()).data()!;
      final a3 = (await firestore.collection(FirestoreCollections.alarms).doc('a3').get()).data()!;
      expect(a1[FirestoreFields.enabled], isFalse);
      expect(a2[FirestoreFields.enabled], isFalse);
      expect(a3[FirestoreFields.enabled], isTrue);
    });

    test('completeAlarm desabilita alarme', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      await _seedAlarm(
        firestore,
        id: 'alarm-1',
        patientId: 'patient-1',
        medicationId: 'med-1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );

      await service.completeAlarm('alarm-1');

      final data = (await firestore.collection(FirestoreCollections.alarms).doc('alarm-1').get()).data()!;
      expect(data[FirestoreFields.enabled], isFalse);
    });

    test('removeFutureAlarmsByMedication remove apenas alarmes futuros do medicamento', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAlarmService(auth: _auth(), firestore: firestore);
      final now = DateTime.now();
      await _seedAlarm(firestore, id: 'past', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.subtract(const Duration(hours: 1)));
      await _seedAlarm(firestore, id: 'future', patientId: 'patient-1', medicationId: 'med-1', scheduledAt: now.add(const Duration(hours: 1)));
      await _seedAlarm(firestore, id: 'other-med', patientId: 'patient-1', medicationId: 'med-2', scheduledAt: now.add(const Duration(hours: 1)));

      await service.removeFutureAlarmsByMedication(patientId: 'patient-1', medicationId: 'med-1');

      expect((await firestore.collection(FirestoreCollections.alarms).doc('past').get()).exists, isTrue);
      expect((await firestore.collection(FirestoreCollections.alarms).doc('future').get()).exists, isFalse);
      expect((await firestore.collection(FirestoreCollections.alarms).doc('other-med').get()).exists, isTrue);
    });
  });
}
