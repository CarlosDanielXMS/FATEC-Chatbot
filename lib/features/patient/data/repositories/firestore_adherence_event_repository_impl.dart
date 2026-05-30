import 'package:chatbot/features/patient/domain/repositories/adherence_event_repository.dart';
import 'package:chatbot/features/patient/data/services/firestore_adherence_event_service.dart';
import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';

class FirestoreAdherenceEventRepositoryImpl
    implements AdherenceEventRepository {
  FirestoreAdherenceEventRepositoryImpl({
    FirestoreAdherenceEventService? adherenceEventService,
  }) : _adherenceEventService =
            adherenceEventService ?? FirestoreAdherenceEventService();

  final FirestoreAdherenceEventService _adherenceEventService;

  @override
  Stream<List<AdherenceEvent>> watchCurrentPatientAdherenceEvents() {
    return _adherenceEventService.watchCurrentPatientAdherenceEvents();
  }

  @override
  Future<List<AdherenceEvent>> getCurrentPatientAdherenceEvents() {
    return _adherenceEventService.getCurrentPatientAdherenceEvents();
  }

  @override
  Future<AdherenceEvent> createForAlarm({
    required String alarmId,
    required AdherenceEventType action,
  }) {
    return _adherenceEventService.createForAlarm(
      alarmId: alarmId,
      action: action,
    );
  }
}