import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';

abstract interface class AdherenceEventRepository {
  Stream<List<AdherenceEvent>> watchCurrentPatientAdherenceEvents();

  Future<List<AdherenceEvent>> getCurrentPatientAdherenceEvents();

  Future<AdherenceEvent> createForAlarm({
    required String alarmId,
    required AdherenceEventType action,
  });
}