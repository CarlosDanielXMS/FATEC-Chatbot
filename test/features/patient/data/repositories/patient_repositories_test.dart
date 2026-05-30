import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_adherence_event_repository_impl.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_alarm_repository_impl.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_medication_repository_impl.dart';
import 'package:chatbot/features/patient/data/services/firestore_adherence_event_service.dart';
import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
import 'package:chatbot/features/patient/data/services/firestore_medication_service.dart';
import 'package:chatbot/features/patient/data/services/medication_alarm_scheduler_service.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

MockFirebaseAuth _auth() {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: 'patient-1', email: 'patient@example.com'),
  );
}

String _nowHourMinute() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
}

void main() {
  group('Patient repositories', () {
    test('FirestoreMedicationRepositoryImpl delega operações ao service', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = _auth();
      final alarmService = FirestoreAlarmService(auth: auth, firestore: firestore);
      final medicationService = FirestoreMedicationService(
        auth: auth,
        firestore: firestore,
        medicationAlarmSchedulerService: MedicationAlarmSchedulerService(alarmService: alarmService),
      );
      final repository = FirestoreMedicationRepositoryImpl(medicationService: medicationService);
      final initialTime = _nowHourMinute();

      final medication = await repository.createMedication(
        name: 'Dipirona',
        dosageAmount: 1,
        dosageUnit: MedicationDosageUnit.tablet,
        initialTime: initialTime,
        recurrence: MedicationRecurrence.onceDaily,
        durationType: MedicationDurationType.fixedDays,
        durationDays: 2,
      );

      final medications = await repository.getCurrentPatientMedications();
      final found = await repository.getMedicationById(medication.id);

      expect(medications, hasLength(1));
      expect(found.name, 'Dipirona');
    });

    test('FirestoreAlarmRepositoryImpl delega atualização de alarme', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = _auth();
      final alarmService = FirestoreAlarmService(auth: auth, firestore: firestore);
      final repository = FirestoreAlarmRepositoryImpl(alarmService: alarmService);
      final scheduledAt = DateTime.now().add(const Duration(hours: 1));
      await firestore.collection(FirestoreCollections.alarms).doc('alarm-1').set({
        FirestoreFields.patientId: 'patient-1',
        FirestoreFields.medicationId: 'med-1',
        FirestoreFields.medicationName: 'Dipirona',
        FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
        FirestoreFields.time: '08:00',
        FirestoreFields.enabled: true,
      });

      await repository.setAlarmEnabled(alarmId: 'alarm-1', enabled: false);
      final alarms = await repository.getCurrentPatientAlarms();

      expect(alarms.single.enabled, isFalse);
    });

    test('FirestoreAdherenceEventRepositoryImpl delega criação de evento', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = _auth();
      final service = FirestoreAdherenceEventService(auth: auth, firestore: firestore);
      final repository = FirestoreAdherenceEventRepositoryImpl(adherenceEventService: service);
      final scheduledAt = DateTime.now().add(const Duration(hours: 1));
      await firestore.collection(FirestoreCollections.alarms).doc('alarm-1').set({
        FirestoreFields.patientId: 'patient-1',
        FirestoreFields.medicationId: 'med-1',
        FirestoreFields.medicationName: 'Dipirona',
        FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
        FirestoreFields.time: '08:00',
        FirestoreFields.enabled: true,
      });

      final event = await repository.createForAlarm(
        alarmId: 'alarm-1',
        action: AdherenceEventType.taken,
      );

      expect(event.action, AdherenceEventType.taken);
      expect(event.alarmId, 'alarm-1');
    });
  });
}
