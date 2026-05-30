import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/models/alarm_model.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreAlarmService {
  FirestoreAlarmService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection(FirestoreCollections.alarms);
  }

  Stream<List<Alarm>> watchCurrentPatientAlarms() {
    final patientId = _currentPatientId();

    return _collection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final alarms = snapshot.docs
          .map(AlarmModel.fromFirestore)
          .where((alarm) => alarm.patientId == patientId)
          .toList();

      _sortByScheduledAtAsc(alarms);

      return alarms;
    });
  }

  Future<List<Alarm>> getCurrentPatientAlarms() async {
    final patientId = _currentPatientId();

    final snapshot = await _collection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .get();

    final alarms = snapshot.docs
        .map(AlarmModel.fromFirestore)
        .where((alarm) => alarm.patientId == patientId)
        .toList();

    _sortByScheduledAtAsc(alarms);

    return alarms;
  }

  Future<void> createFutureAlarms(List<Map<String, dynamic>> alarmMaps) async {
    if (alarmMaps.isEmpty) return;

    final batch = _firestore.batch();

    for (final alarmMap in alarmMaps) {
      final documentReference = _collection.doc();
      batch.set(documentReference, alarmMap);
    }

    await batch.commit();
  }

  Future<void> removeFutureAlarmsByMedication({
    required String patientId,
    required String medicationId,
  }) async {
    final normalizedPatientId = _normalizeRequiredId(
      patientId,
      fieldName: FirestoreFields.patientId,
    );

    final normalizedMedicationId = _normalizeRequiredId(
      medicationId,
      fieldName: FirestoreFields.medicationId,
    );

    final snapshot = await _collection
        .where(FirestoreFields.patientId, isEqualTo: normalizedPatientId)
        .where(FirestoreFields.medicationId, isEqualTo: normalizedMedicationId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final now = DateTime.now();
    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      final alarm = AlarmModel.fromFirestore(document);

      if (alarm.scheduledAt.isBefore(now)) continue;

      batch.delete(document.reference);
    }

    await batch.commit();
  }

  Future<void> setAlarmEnabled({
    required String alarmId,
    required bool enabled,
  }) async {
    final normalizedAlarmId = _normalizeRequiredId(
      alarmId,
      fieldName: FirestoreFields.alarmId,
    );

    final documentReference = _collection.doc(normalizedAlarmId);
    final snapshot = await documentReference.get();

    if (!snapshot.exists) {
      throw StateError('Alarme não encontrado.');
    }

    final alarm = AlarmModel.fromFirestore(snapshot);
    _ensureCurrentPatientOwnsAlarm(alarm);

    await documentReference.update(
      AlarmModel.enabledUpdateMap(enabled),
    );
  }

  Future<void> setMedicationAlarmsEnabled({
    required String medicationId,
    required bool enabled,
  }) async {
    final patientId = _currentPatientId();

    final normalizedMedicationId = _normalizeRequiredId(
      medicationId,
      fieldName: FirestoreFields.medicationId,
    );

    final snapshot = await _collection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .where(FirestoreFields.medicationId, isEqualTo: normalizedMedicationId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      final alarm = AlarmModel.fromFirestore(document);
      _ensureCurrentPatientOwnsAlarm(alarm);

      batch.update(
        document.reference,
        AlarmModel.enabledUpdateMap(enabled),
      );
    }

    await batch.commit();
  }

  Future<void> completeAlarm(String alarmId) async {
    final normalizedAlarmId = _normalizeRequiredId(
      alarmId,
      fieldName: FirestoreFields.alarmId,
    );

    final documentReference = _collection.doc(normalizedAlarmId);
    final snapshot = await documentReference.get();

    if (!snapshot.exists) {
      throw StateError('Alarme não encontrado.');
    }

    final alarm = AlarmModel.fromFirestore(snapshot);
    _ensureCurrentPatientOwnsAlarm(alarm);

    await documentReference.update(
      AlarmModel.enabledUpdateMap(false),
    );
  }

  String _currentPatientId() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    return user.uid;
  }

  String _normalizeRequiredId(
    String value, {
    required String fieldName,
  }) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError('$fieldName não informado.');
    }

    return normalized;
  }

  void _ensureCurrentPatientOwnsAlarm(Alarm alarm) {
    final patientId = _currentPatientId();

    if (alarm.patientId != patientId) {
      throw StateError('Alarme não pertence ao paciente autenticado.');
    }
  }

  void _sortByScheduledAtAsc(List<Alarm> alarms) {
    alarms.sort((firstAlarm, secondAlarm) {
      return firstAlarm.scheduledAt.compareTo(secondAlarm.scheduledAt);
    });
  }
}