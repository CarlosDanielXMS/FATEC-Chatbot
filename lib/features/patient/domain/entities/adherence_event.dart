import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';

class AdherenceEvent {
  const AdherenceEvent({
    required this.id,
    required this.patientId,
    required this.alarmId,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.action,
    required this.actionAt,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String alarmId;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledAt;
  final AdherenceEventType action;
  final DateTime actionAt;
  final DateTime? createdAt;
}