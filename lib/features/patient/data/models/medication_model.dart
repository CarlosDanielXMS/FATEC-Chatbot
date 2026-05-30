import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required super.id,
    required super.patientId,
    required super.name,
    super.dosageAmount,
    super.dosageUnit,
    super.initialTime,
    super.recurrence,
    super.recurrenceIntervalHours,
    super.durationType,
    super.durationDays,
    super.createdAt,
    super.updatedAt,
  });

  factory MedicationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      throw StateError('Documento de medicamento sem dados.');
    }

    final recurrenceIntervalHours = _readInt(
      data[FirestoreFields.recurrenceIntervalHours],
    );

    final recurrence = MedicationRecurrence.fromValue(
          data[FirestoreFields.recurrence] as String?,
        ) ??
        MedicationRecurrence.fromIntervalHours(recurrenceIntervalHours);

    return MedicationModel(
      id: snapshot.id,
      patientId: data[FirestoreFields.patientId] as String? ?? '',
      name: data[FirestoreFields.name] as String? ?? '',
      dosageAmount: _readDouble(data[FirestoreFields.dosageAmount]),
      dosageUnit: MedicationDosageUnit.fromValue(
        data[FirestoreFields.dosageUnit] as String?,
      ),
      initialTime: data[FirestoreFields.initialTime] as String?,
      recurrence: recurrence,
      recurrenceIntervalHours: recurrenceIntervalHours,
      durationType: MedicationDurationType.fromValue(
        data[FirestoreFields.durationType] as String?,
      ),
      durationDays: _readInt(data[FirestoreFields.durationDays]),
      createdAt: _readDateTime(data[FirestoreFields.createdAt]),
      updatedAt: _readDateTime(data[FirestoreFields.updatedAt]),
    );
  }

  static Map<String, dynamic> createMap({
    required String patientId,
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    final now = FieldValue.serverTimestamp();

    return {
      FirestoreFields.patientId: patientId,
      FirestoreFields.name: name,
      FirestoreFields.dosageAmount: dosageAmount,
      FirestoreFields.dosageUnit: dosageUnit.value,
      FirestoreFields.initialTime: initialTime,
      FirestoreFields.recurrence: recurrence.value,
      FirestoreFields.recurrenceIntervalHours: recurrence.intervalHours,
      FirestoreFields.durationType: durationType.value,
      FirestoreFields.durationDays: durationDays,
      FirestoreFields.createdAt: now,
      FirestoreFields.updatedAt: now,
    };
  }

  static Map<String, dynamic> updateMap({
    required String name,
    required double dosageAmount,
    required MedicationDosageUnit dosageUnit,
    required String initialTime,
    required MedicationRecurrence recurrence,
    required MedicationDurationType durationType,
    required int? durationDays,
  }) {
    return {
      FirestoreFields.name: name,
      FirestoreFields.dosageAmount: dosageAmount,
      FirestoreFields.dosageUnit: dosageUnit.value,
      FirestoreFields.initialTime: initialTime,
      FirestoreFields.recurrence: recurrence.value,
      FirestoreFields.recurrenceIntervalHours: recurrence.intervalHours,
      FirestoreFields.durationType: durationType.value,
      FirestoreFields.durationDays: durationDays,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }

  static double? _readDouble(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();

    return null;
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return null;
  }
}