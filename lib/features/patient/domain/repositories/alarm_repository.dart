import 'package:chatbot/features/patient/domain/entities/alarm.dart';

abstract class AlarmRepository {
  Stream<List<Alarm>> watchCurrentPatientAlarms();

  Future<List<Alarm>> getCurrentPatientAlarms();

  Future<void> setAlarmEnabled({
    required String alarmId,
    required bool enabled,
  });

  Future<void> setMedicationAlarmsEnabled({
    required String medicationId,
    required bool enabled,
  });

  Future<void> completeAlarm(String alarmId);
}