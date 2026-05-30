import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/services/firestore_adherence_event_service.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
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
}) {
  final scheduledAt = DateTime.now().add(const Duration(hours: 1));
  return firestore.collection(FirestoreCollections.alarms).doc(id).set({
    FirestoreFields.patientId: patientId,
    FirestoreFields.medicationId: 'med-1',
    FirestoreFields.medicationName: 'Dipirona',
    FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
    FirestoreFields.time: '08:00',
    FirestoreFields.enabled: true,
  });
}

Future<void> _seedEvent(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String patientId,
  required DateTime actionAt,
}) {
  return firestore.collection(FirestoreCollections.adherenceEvents).doc(id).set({
    FirestoreFields.patientId: patientId,
    FirestoreFields.alarmId: 'alarm-$id',
    FirestoreFields.medicationId: 'med-1',
    FirestoreFields.medicationName: 'Dipirona',
    FirestoreFields.scheduledAt: Timestamp.fromDate(actionAt.subtract(const Duration(minutes: 5))),
    FirestoreFields.action: AdherenceEventType.taken.value,
    FirestoreFields.actionAt: Timestamp.fromDate(actionAt),
  });
}

void main() {
  group('FirestoreAdherenceEventService', () {
    test('lança StateError quando não há usuário autenticado', () async {
      final service = FirestoreAdherenceEventService(
        auth: _auth(signedIn: false),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(service.getCurrentPatientAdherenceEvents(), throwsStateError);
    });

    test('getCurrentPatientAdherenceEvents filtra e ordena eventos por actionAt desc', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAdherenceEventService(auth: _auth(), firestore: firestore);
      final now = DateTime.now();
      await _seedEvent(firestore, id: 'old', patientId: 'patient-1', actionAt: now.subtract(const Duration(days: 1)));
      await _seedEvent(firestore, id: 'new', patientId: 'patient-1', actionAt: now);
      await _seedEvent(firestore, id: 'other', patientId: 'patient-2', actionAt: now.add(const Duration(days: 1)));

      final events = await service.getCurrentPatientAdherenceEvents();

      expect(events.map((event) => event.id), ['new', 'old']);
    });

    test('createForAlarm cria evento para alarme do paciente autenticado', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAdherenceEventService(auth: _auth(), firestore: firestore);
      await _seedAlarm(firestore, id: 'alarm-1', patientId: 'patient-1');

      final event = await service.createForAlarm(
        alarmId: ' alarm-1 ',
        action: AdherenceEventType.postponed,
      );

      expect(event.alarmId, 'alarm-1');
      expect(event.patientId, 'patient-1');
      expect(event.action, AdherenceEventType.postponed);

      final snapshot = await firestore.collection(FirestoreCollections.adherenceEvents).get();
      expect(snapshot.docs, hasLength(1));
    });

    test('createForAlarm rejeita alarmes ausentes, vazios ou de outro paciente', () async {
      final firestore = FakeFirebaseFirestore();
      final service = FirestoreAdherenceEventService(auth: _auth(), firestore: firestore);
      await _seedAlarm(firestore, id: 'other-alarm', patientId: 'patient-2');

      await expectLater(
        service.createForAlarm(alarmId: '   ', action: AdherenceEventType.taken),
        throwsArgumentError,
      );
      await expectLater(
        service.createForAlarm(alarmId: 'missing', action: AdherenceEventType.taken),
        throwsStateError,
      );
      await expectLater(
        service.createForAlarm(alarmId: 'other-alarm', action: AdherenceEventType.taken),
        throwsStateError,
      );
    });
  });
}
