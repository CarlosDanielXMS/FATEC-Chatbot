import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdherenceEventModel extends AdherenceEvent {
  const AdherenceEventModel({
    required super.id,
    required super.patientId,
    required super.alarmId,
    required super.medicationId,
    required super.medicationName,
    required super.scheduledAt,
    required super.action,
    required super.actionAt,
    super.createdAt,
  });

  factory AdherenceEventModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      throw StateError('Documento de evento de adesão sem dados.');
    }

    final action = AdherenceEventType.tryFromString(
      data[FirestoreFields.action] as String?,
    );

    if (action == null) {
      throw StateError('Evento de adesão com ação inválida.');
    }

    return AdherenceEventModel(
      id: snapshot.id,
      patientId: data[FirestoreFields.patientId] as String? ?? '',
      alarmId: data[FirestoreFields.alarmId] as String? ?? '',
      medicationId: data[FirestoreFields.medicationId] as String? ?? '',
      medicationName: data[FirestoreFields.medicationName] as String? ?? '',
      scheduledAt: _readRequiredDateTime(data[FirestoreFields.scheduledAt]),
      action: action,
      actionAt: _readRequiredDateTime(data[FirestoreFields.actionAt]),
      createdAt: _readDateTime(data[FirestoreFields.createdAt]),
    );
  }

  static Map<String, dynamic> createMap({
    required Alarm alarm,
    required AdherenceEventType action,
    required DateTime actionAt,
  }) {
    return {
      FirestoreFields.patientId: alarm.patientId,
      FirestoreFields.alarmId: alarm.id,
      FirestoreFields.medicationId: alarm.medicationId,
      FirestoreFields.medicationName: alarm.medicationName,
      FirestoreFields.scheduledAt: Timestamp.fromDate(alarm.scheduledAt),
      FirestoreFields.action: action.value,
      FirestoreFields.actionAt: Timestamp.fromDate(actionAt),
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  static DateTime _readRequiredDateTime(Object? value) {
    final dateTime = _readDateTime(value);

    if (dateTime == null) {
      throw StateError('Evento de adesão sem data obrigatória.');
    }

    return dateTime;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }
}