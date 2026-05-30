import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';

class Medication {
  const Medication({
    required this.id,
    required this.patientId,
    required this.name,
    this.dosageAmount,
    this.dosageUnit,
    this.initialTime,
    this.recurrence,
    this.recurrenceIntervalHours,
    this.durationType,
    this.durationDays,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String name;

  final double? dosageAmount;
  final MedicationDosageUnit? dosageUnit;
  final String? initialTime;
  final MedicationRecurrence? recurrence;
  final int? recurrenceIntervalHours;
  final MedicationDurationType? durationType;
  final int? durationDays;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasTreatment {
    return dosageAmount != null &&
        dosageUnit != null &&
        initialTime?.trim().isNotEmpty == true &&
        recurrence != null &&
        durationType != null;
  }

  bool get isContinuousUse {
    return durationType == MedicationDurationType.continuous;
  }

  int? get effectiveRecurrenceIntervalHours {
    return recurrenceIntervalHours ?? recurrence?.intervalHours;
  }

  String get dosageLabel {
    if (dosageAmount == null || dosageUnit == null) {
      return 'Dosagem não definida';
    }

    final amount = dosageAmount!;
    final formattedAmount = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toString().replaceAll('.', ',');

    return '$formattedAmount ${dosageUnit!.label}';
  }

  String get recurrenceLabel {
    return recurrence?.label ?? 'Recorrência não definida';
  }

  String get durationLabel {
    if (durationType == MedicationDurationType.continuous) {
      return 'Uso contínuo';
    }

    if (durationType == MedicationDurationType.fixedDays &&
        durationDays != null) {
      return '$durationDays dias';
    }

    return 'Duração não definida';
  }
}