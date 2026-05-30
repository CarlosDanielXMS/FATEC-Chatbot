import 'package:chatbot/features/patient/data/services/firestore_medication_service.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:chatbot/features/patient/domain/repositories/medication_repository.dart';

class FirestoreMedicationRepositoryImpl implements MedicationRepository {
  FirestoreMedicationRepositoryImpl({
    FirestoreMedicationService? medicationService,
  }) : _medicationService = medicationService ?? FirestoreMedicationService();

  final FirestoreMedicationService _medicationService;

  @override
  Stream<List<Medication>> watchCurrentPatientMedications() {
    return _medicationService.watchCurrentPatientMedications();
  }

  @override
  Future<List<Medication>> getCurrentPatientMedications() {
    return _medicationService.getCurrentPatientMedications();
  }

  @override
  Future<Medication> getMedicationById(String medicationId) {
    return _medicationService.getMedicationById(medicationId);
  }

  @override
  Future<Medication> createMedication({
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    return _medicationService.createMedication(
      name: name,
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
      initialTime: initialTime,
      recurrence: recurrence,
      durationType: durationType,
      durationDays: durationDays,
    );
  }

  @override
  Future<void> updateMedication({
    required String medicationId,
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    return _medicationService.updateMedication(
      medicationId: medicationId,
      name: name,
      dosageAmount: dosageAmount,
      dosageUnit: dosageUnit,
      initialTime: initialTime,
      recurrence: recurrence,
      durationType: durationType,
      durationDays: durationDays,
    );
  }

  @override
  Future<void> deleteMedication(String medicationId) {
    return _medicationService.deleteMedication(medicationId);
  }
}