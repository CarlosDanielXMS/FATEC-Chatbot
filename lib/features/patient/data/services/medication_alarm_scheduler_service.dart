import 'package:chatbot/features/patient/data/models/alarm_model.dart';
import 'package:chatbot/features/patient/data/services/firestore_alarm_service.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';

class MedicationAlarmSchedulerService {
  MedicationAlarmSchedulerService({
    FirestoreAlarmService? alarmService,
  }) : _alarmService = alarmService ?? FirestoreAlarmService();

  static const _continuousTreatmentHorizonDays = 30;

  final FirestoreAlarmService _alarmService;

  Future<void> scheduleFutureAlarmsForMedication(Medication medication) async {
    final alarmMaps = _buildFutureAlarmMaps(medication);

    await _alarmService.createFutureAlarms(alarmMaps);
  }

  Future<void> rescheduleFutureAlarmsForMedication(Medication medication) async {
    await removeFutureAlarmsForMedication(medication);
    await scheduleFutureAlarmsForMedication(medication);
  }

  Future<void> removeFutureAlarmsForMedication(Medication medication) {
    return _alarmService.removeFutureAlarmsByMedication(
      patientId: medication.patientId,
      medicationId: medication.id,
    );
  }

  List<Map<String, dynamic>> _buildFutureAlarmMaps(Medication medication) {
    _validateMedicationForScheduling(medication);

    final initialTime = medication.initialTime!.trim();
    final recurrenceIntervalHours = medication.effectiveRecurrenceIntervalHours!;
    final treatmentStart = _resolveTreatmentStart(initialTime);
    final treatmentEnd = _resolveTreatmentEnd(
      medication: medication,
      treatmentStart: treatmentStart,
    );

    final now = DateTime.now();
    final alarmMaps = <Map<String, dynamic>>[];

    var scheduledAt = treatmentStart;

    while (scheduledAt.isBefore(treatmentEnd)) {
      if (scheduledAt.isAfter(now) || scheduledAt.isAtSameMomentAs(now)) {
        alarmMaps.add(
          AlarmModel.createMap(
            patientId: medication.patientId,
            medicationId: medication.id,
            medicationName: medication.name,
            scheduledAt: scheduledAt,
            time: _formatTime(scheduledAt),
          ),
        );
      }

      scheduledAt = scheduledAt.add(
        Duration(hours: recurrenceIntervalHours),
      );
    }

    return alarmMaps;
  }

  void _validateMedicationForScheduling(Medication medication) {
    if (medication.id.trim().isEmpty) {
      throw StateError('Medicamento sem identificador.');
    }

    if (medication.patientId.trim().isEmpty) {
      throw StateError('Medicamento sem paciente associado.');
    }

    if (medication.name.trim().isEmpty) {
      throw StateError('Medicamento sem nome.');
    }

    if (medication.initialTime?.trim().isNotEmpty != true) {
      throw StateError('Medicamento sem horário inicial.');
    }

    if (medication.effectiveRecurrenceIntervalHours == null ||
        medication.effectiveRecurrenceIntervalHours! <= 0) {
      throw StateError('Medicamento sem recorrência válida.');
    }

    if (medication.durationType == null) {
      throw StateError('Medicamento sem duração definida.');
    }

    if (medication.durationType == MedicationDurationType.fixedDays &&
        (medication.durationDays == null || medication.durationDays! <= 0)) {
      throw StateError('Medicamento sem quantidade de dias válida.');
    }
  }

  DateTime _resolveTreatmentStart(String initialTime) {
    final now = DateTime.now();
    final timeParts = initialTime.split(':');

    if (timeParts.length != 2) {
      throw StateError('Horário inicial inválido.');
    }

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (hour == null || minute == null) {
      throw StateError('Horário inicial inválido.');
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw StateError('Horário inicial inválido.');
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }

  DateTime _resolveTreatmentEnd({
    required Medication medication,
    required DateTime treatmentStart,
  }) {
    final startOfTreatmentDay = DateTime(
      treatmentStart.year,
      treatmentStart.month,
      treatmentStart.day,
    );

    if (medication.durationType == MedicationDurationType.fixedDays) {
      return startOfTreatmentDay.add(
        Duration(days: medication.durationDays!),
      );
    }

    return startOfTreatmentDay.add(
      const Duration(days: _continuousTreatmentHorizonDays),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}