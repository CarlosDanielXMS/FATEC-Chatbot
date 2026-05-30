import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/repositories/alarm_repository.dart';

class FirestoreAlarmRepositoryImpl implements AlarmRepository {
  FirestoreAlarmRepositoryImpl({
    FirestoreAlarmService? alarmService,
  }) : _alarmService = alarmService ?? FirestoreAlarmService();

  final FirestoreAlarmService _alarmService;

  @override
  Stream<List<Alarm>> watchCurrentPatientAlarms() {
    return _alarmService.watchCurrentPatientAlarms();
  }

  @override
  Future<List<Alarm>> getCurrentPatientAlarms() {
    return _alarmService.getCurrentPatientAlarms();
  }

  @override
  Future<void> setAlarmEnabled({
    required String alarmId,
    required bool enabled,
  }) {
    return _alarmService.setAlarmEnabled(
      alarmId: alarmId,
      enabled: enabled,
    );
  }

  @override
  Future<void> setMedicationAlarmsEnabled({
    required String medicationId,
    required bool enabled,
  }) {
    return _alarmService.setMedicationAlarmsEnabled(
      medicationId: medicationId,
      enabled: enabled,
    );
  }

  @override
  Future<void> completeAlarm(String alarmId) {
    return _alarmService.completeAlarm(alarmId);
  }
}