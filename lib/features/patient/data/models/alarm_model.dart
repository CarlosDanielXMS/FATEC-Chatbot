import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.patientId,
    required super.medicationId,
    required super.medicationName,
    required super.scheduledAt,
    required super.time,
    required super.enabled,
    super.createdAt,
    super.updatedAt,
  });

  factory AlarmModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      throw StateError('Documento de alarme sem dados.');
    }

    return AlarmModel(
      id: snapshot.id,
      patientId: data[FirestoreFields.patientId] as String? ?? '',
      medicationId: data[FirestoreFields.medicationId] as String? ?? '',
      medicationName: data[FirestoreFields.medicationName] as String? ?? '',
      scheduledAt: _readRequiredDateTime(data[FirestoreFields.scheduledAt]),
      time: data[FirestoreFields.time] as String? ?? '',
      enabled: data[FirestoreFields.enabled] as bool? ?? true,
      createdAt: _readDateTime(data[FirestoreFields.createdAt]),
      updatedAt: _readDateTime(data[FirestoreFields.updatedAt]),
    );
  }

  static Map<String, dynamic> createMap({
    required String patientId,
    required String medicationId,
    required String medicationName,
    required DateTime scheduledAt,
    required String time,
    bool enabled = true,
  }) {
    final now = FieldValue.serverTimestamp();

    return {
      FirestoreFields.patientId: patientId,
      FirestoreFields.medicationId: medicationId,
      FirestoreFields.medicationName: medicationName,
      FirestoreFields.scheduledAt: Timestamp.fromDate(scheduledAt),
      FirestoreFields.time: time,
      FirestoreFields.enabled: enabled,
      FirestoreFields.createdAt: now,
      FirestoreFields.updatedAt: now,
    };
  }

  static Map<String, dynamic> enabledUpdateMap(bool enabled) {
    return {
      FirestoreFields.enabled: enabled,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  static DateTime _readRequiredDateTime(Object? value) {
    final dateTime = _readDateTime(value);

    if (dateTime == null) {
      throw StateError('Alarme sem horário agendado.');
    }

    return dateTime;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }
}