import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';

abstract class MedicationRepository {
  Stream<List<Medication>> watchCurrentPatientMedications();

  Future<List<Medication>> getCurrentPatientMedications();

  Future<Medication> getMedicationById(String medicationId);

  Future<Medication> createMedication({
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  });

  Future<void> updateMedication({
    required String medicationId,
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  });

  Future<void> deleteMedication(String medicationId);
}