import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreCollections', () {
    test('mantém nomes de collections usados pelo app', () {
      expect(FirestoreCollections.users, 'users');
      expect(FirestoreCollections.patients, 'patients');
      expect(FirestoreCollections.professionals, 'professionals');
      expect(FirestoreCollections.legalAcceptances, 'legalAcceptances');
      expect(FirestoreCollections.medications, 'medications');
      expect(FirestoreCollections.alarms, 'alarms');
      expect(FirestoreCollections.adherenceEvents, 'adherenceEvents');
    });
  });

  group('FirestoreFields', () {
    test('mantém campos essenciais de usuário e paciente', () {
      expect(FirestoreFields.uid, 'uid');
      expect(FirestoreFields.email, 'email');
      expect(FirestoreFields.role, 'role');
      expect(FirestoreFields.name, 'name');
      expect(FirestoreFields.cpf, 'cpf');
      expect(FirestoreFields.council, 'council');
    });

    test('mantém campos essenciais de tratamento e alarmes', () {
      expect(FirestoreFields.patientId, 'patientId');
      expect(FirestoreFields.medicationId, 'medicationId');
      expect(FirestoreFields.dosageAmount, 'dosageAmount');
      expect(FirestoreFields.initialTime, 'initialTime');
      expect(FirestoreFields.recurrenceIntervalHours, 'recurrenceIntervalHours');
      expect(FirestoreFields.scheduledAt, 'scheduledAt');
      expect(FirestoreFields.enabled, 'enabled');
      expect(FirestoreFields.actionAt, 'actionAt');
    });
  });
}
