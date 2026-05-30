import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/core/validation/validators/positive_decimal_validator.dart';
import 'package:chatbot/core/validation/validators/required_text_validator.dart';
import 'package:chatbot/core/validation/validators/time_text_validator.dart';
import 'package:chatbot/features/patient/data/models/medication_model.dart';
import 'package:chatbot/features/patient/data/services/medication_alarm_scheduler_service.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreMedicationService {
  FirestoreMedicationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    MedicationAlarmSchedulerService? medicationAlarmSchedulerService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _medicationAlarmSchedulerService =
            medicationAlarmSchedulerService ?? MedicationAlarmSchedulerService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final MedicationAlarmSchedulerService _medicationAlarmSchedulerService;

  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection(FirestoreCollections.medications);
  }

  Stream<List<Medication>> watchCurrentPatientMedications() {
    final patientId = _currentPatientId();

    return _collection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final medications = snapshot.docs
          .map(MedicationModel.fromFirestore)
          .where((medication) => medication.patientId == patientId)
          .toList();

      _sortByCreatedAtDesc(medications);

      return medications;
    });
  }

  Future<List<Medication>> getCurrentPatientMedications() async {
    final patientId = _currentPatientId();

    final snapshot = await _collection
        .where(FirestoreFields.patientId, isEqualTo: patientId)
        .get();

    final medications = snapshot.docs
        .map(MedicationModel.fromFirestore)
        .where((medication) => medication.patientId == patientId)
        .toList();

    _sortByCreatedAtDesc(medications);

    return medications;
  }

  Future<Medication> getMedicationById(String medicationId) async {
    final normalizedMedicationId = _normalizeRequiredId(
      medicationId,
      fieldName: 'medicationId',
    );

    final snapshot = await _collection.doc(normalizedMedicationId).get();

    if (!snapshot.exists) {
      throw StateError('Medicamento não encontrado.');
    }

    final medication = MedicationModel.fromFirestore(snapshot);
    _ensureCurrentPatientOwnsMedication(medication);

    return medication;
  }

  Future<Medication> createMedication({
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) async {
    final patientId = _currentPatientId();

    _validateMedicationPayload(
      name: name,
      dosageAmount: dosageAmount,
      initialTime: initialTime,
      durationType: durationType,
      durationDays: durationDays,
    );

    final documentReference = await _collection.add(
      MedicationModel.createMap(
        patientId: patientId,
        name: _normalizeMedicationName(name),
        dosageAmount: dosageAmount,
        dosageUnit: dosageUnit,
        initialTime: initialTime.trim(),
        recurrence: recurrence,
        durationType: durationType,
        durationDays: _normalizedDurationDays(
          durationType: durationType,
          durationDays: durationDays,
        ),
      ),
    );

    final snapshot = await documentReference.get();

    if (!snapshot.exists) {
      throw StateError('Não foi possível criar o medicamento.');
    }

    final medication = MedicationModel.fromFirestore(snapshot);
    _ensureCurrentPatientOwnsMedication(medication);

    await _medicationAlarmSchedulerService.scheduleFutureAlarmsForMedication(
      medication,
    );

    return medication;
  }

  Future<void> updateMedication({
    required String medicationId,
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) async {
    final normalizedMedicationId = _normalizeRequiredId(
      medicationId,
      fieldName: 'medicationId',
    );

    _validateMedicationPayload(
      name: name,
      dosageAmount: dosageAmount,
      initialTime: initialTime,
      durationType: durationType,
      durationDays: durationDays,
    );

    final currentMedication = await getMedicationById(normalizedMedicationId);
    _ensureCurrentPatientOwnsMedication(currentMedication);

    await _collection.doc(normalizedMedicationId).update(
          MedicationModel.updateMap(
            name: _normalizeMedicationName(name),
            dosageAmount: dosageAmount,
            dosageUnit: dosageUnit,
            initialTime: initialTime.trim(),
            recurrence: recurrence,
            durationType: durationType,
            durationDays: _normalizedDurationDays(
              durationType: durationType,
              durationDays: durationDays,
            ),
          ),
        );

    final updatedMedication = await getMedicationById(normalizedMedicationId);

    await _medicationAlarmSchedulerService.rescheduleFutureAlarmsForMedication(
      updatedMedication,
    );
  }

  Future<void> deleteMedication(String medicationId) async {
    final normalizedMedicationId = _normalizeRequiredId(
      medicationId,
      fieldName: 'medicationId',
    );

    final medication = await getMedicationById(normalizedMedicationId);
    _ensureCurrentPatientOwnsMedication(medication);

    await _medicationAlarmSchedulerService.removeFutureAlarmsForMedication(
      medication,
    );

    await _collection.doc(normalizedMedicationId).delete();
  }

  String _currentPatientId() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    return user.uid;
  }

  String _normalizeRequiredId(
    String value, {
    required String fieldName,
  }) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError('$fieldName não informado.');
    }

    return normalized;
  }

  String _normalizeMedicationName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  int? _normalizedDurationDays({
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    if (durationType == MedicationDurationType.continuous) {
      return null;
    }

    return durationDays;
  }

  void _validateMedicationPayload({
    required String name,
    required double dosageAmount,
    required String initialTime,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    final nameValidation = RequiredTextValidator.validate(name);

    if (!nameValidation.isValid) {
      throw ArgumentError(nameValidation.errorMessage ?? 'Nome inválido.');
    }

    final initialTimeValidation = TimeTextValidator.validate(initialTime);

    if (!initialTimeValidation.isValid) {
      throw ArgumentError(
        initialTimeValidation.errorMessage ?? 'Horário inválido.',
      );
    }

    final dosageValidation = PositiveDecimalValidator.validate(
      dosageAmount.toString(),
    );

    if (!dosageValidation.isValid) {
      throw ArgumentError(
        dosageValidation.errorMessage ?? 'Dosagem inválida.',
      );
    }

    if (durationType == MedicationDurationType.fixedDays) {
      if (durationDays == null || durationDays <= 0) {
        throw ArgumentError('Informe a duração do tratamento.');
      }
    }
  }

  void _ensureCurrentPatientOwnsMedication(Medication medication) {
    final patientId = _currentPatientId();

    if (medication.patientId != patientId) {
      throw StateError('Medicamento não pertence ao paciente autenticado.');
    }
  }

  void _sortByCreatedAtDesc(List<Medication> medications) {
    medications.sort((firstMedication, secondMedication) {
      final firstCreatedAt = firstMedication.createdAt;
      final secondCreatedAt = secondMedication.createdAt;

      if (firstCreatedAt == null && secondCreatedAt == null) {
        return firstMedication.name.compareTo(secondMedication.name);
      }

      if (firstCreatedAt == null) return 1;
      if (secondCreatedAt == null) return -1;

      return secondCreatedAt.compareTo(firstCreatedAt);
    });
  }
}