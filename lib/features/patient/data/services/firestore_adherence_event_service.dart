import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/data/models/adherence_event_model.dart';
import 'package:chatbot/features/patient/data/models/alarm_model.dart';
import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreAdherenceEventService {
  FirestoreAdherenceEventService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _adherenceEventsCollection {
    return _firestore.collection(FirestoreCollections.adherenceEvents);
  }

  CollectionReference<Map<String, dynamic>> get _alarmsCollection {
    return _firestore.collection(FirestoreCollections.alarms);
  }

  Stream<List<AdherenceEvent>> watchCurrentPatientAdherenceEvents() {
    final patientId = _currentPatientId();

    return _adherenceEventsCollection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .snapshots()
        .map(_mapAdherenceEvents);
  }

  Future<List<AdherenceEvent>> getCurrentPatientAdherenceEvents() async {
    final patientId = _currentPatientId();

    final snapshot = await _adherenceEventsCollection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .get();

    return _mapAdherenceEvents(snapshot);
  }

  Future<AdherenceEvent> createForAlarm({
    required String alarmId,
    required AdherenceEventType action,
  }) async {
    final normalizedAlarmId = _normalizeRequiredId(
      alarmId,
      fieldName: 'alarmId',
    );

    final alarmSnapshot = await _alarmsCollection.doc(normalizedAlarmId).get();

    if (!alarmSnapshot.exists) {
      throw StateError('Alarme não encontrado.');
    }

    final alarm = AlarmModel.fromFirestore(alarmSnapshot);
    _ensureCurrentPatientOwnsAlarm(alarm);

    final actionAt = DateTime.now();

    final eventReference = await _adherenceEventsCollection.add(
      AdherenceEventModel.createMap(
        alarm: alarm,
        action: action,
        actionAt: actionAt,
      ),
    );

    final eventSnapshot = await eventReference.get();

    return AdherenceEventModel.fromFirestore(eventSnapshot);
  }

  List<AdherenceEvent> _mapAdherenceEvents(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(AdherenceEventModel.fromFirestore).toList()
      ..sort((first, second) {
        return second.actionAt.compareTo(first.actionAt);
      });
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

  void _ensureCurrentPatientOwnsAlarm(AlarmModel alarm) {
    final patientId = _currentPatientId();

    if (alarm.patientId != patientId) {
      throw StateError('Alarme não pertence ao paciente autenticado.');
    }
  }
}